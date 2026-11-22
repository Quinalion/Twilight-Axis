/mob/living/carbon/human
	var/au_bord_injected = FALSE

/obj/item/au_bord_injector
	name = "Injecteur \"Au Bord\""
	desc = "Одноразовый железный шприц с отаванским крестом, поверх которого \
		нарисован череп. Даже в таком виде от него исходит дурманящий аромат."
	icon = 'modular_twilight_axis/icons/roguetown/items/otavan_gadgets/misc.dmi'
	icon_state = "injector_ready"
	w_class = WEIGHT_CLASS_TINY
	grid_width = 32
	grid_height = 32
	var/spent = FALSE

/obj/item/au_bord_injector/examine(mob/user)
	. = ..()
	if(spent || !HAS_TRAIT(user, TRAIT_INQUISITION))
		return
	var/list/examination = .
	var/description_index = examination.Find(span_info(desc))
	if(description_index)
		examination[description_index] = span_info("Одноразовый железный шприц, \
			содержащий почти смертельную дозу стимулирующих препаратов. \
			Такие смеси используют баотанские культисты в своих ритуалах. \
			Теперь их достижения в правильных руках.")

/obj/item/au_bord_injector/attack_self(mob/user)
	if(ishuman(user))
		inject(user, user)

/obj/item/au_bord_injector/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return TRUE
	if(!ishuman(target))
		return FALSE
	inject(target, user)
	return TRUE

/obj/item/au_bord_injector/proc/inject(
	mob/living/carbon/human/recipient, mob/living/user,
)
	if(spent || recipient.stat == DEAD || !(src in user.held_items))
		return
	if(!recipient.can_inject(user, TRUE))
		return
	if(recipient != user && !do_after(user, 2 SECONDS, target = recipient))
		return
	if(QDELETED(src) || QDELETED(recipient) || spent || recipient.stat == DEAD)
		return
	if(!(src in user.held_items))
		return
	if(recipient != user && !user.Adjacent(recipient))
		return
	if(!recipient.can_inject(user, TRUE))
		return

	spent = TRUE
	icon_state = "injector_used"
	desc = "Одноразовый железный шприц с отаванским крестом. Он уже пуст."
	user.update_inv_hands()
	user.visible_message(span_warning("[user] injects [recipient] with [src]."))

	if(recipient.au_bord_injected)
		recipient.remove_status_effect(/datum/status_effect/buff/au_bord)
		if(recipient.can_heartattack())
			recipient.set_heartattack(TRUE)
			to_chat(recipient, span_userdanger("My heart stops!"))
		return

	recipient.au_bord_injected = TRUE
	recipient.apply_status_effect(/datum/status_effect/buff/au_bord)

/datum/status_effect/buff/au_bord
	id = "au_bord"
	duration = 110 SECONDS
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/au_bord
	effectedstats = list(
		STATKEY_STR = 2,
		STATKEY_PER = 2,
		STATKEY_INT = 2,
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_SPD = 2,
		STATKEY_LCK = 2,
	)

/datum/status_effect/buff/au_bord/on_apply()
	if(!..())
		return FALSE
	owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/druqks)
	return TRUE

/datum/status_effect/buff/au_bord/on_remove()
	owner.clear_fullscreen(id)
	return ..()

/datum/status_effect/buff/au_bord/tick()
	if(owner.stat == DEAD)
		return
	owner.stamina_add(-6)
	if(HAS_TRAIT(owner, TRAIT_NOHEAL) || HAS_TRAIT(owner, TRAIT_IRONMAN))
		return
	var/healing = HAS_TRAIT(owner, TRAIT_HALFHEAL) ? 1 : 2
	owner.adjustBruteLoss(-healing)
	owner.adjustFireLoss(-healing)

/atom/movable/screen/alert/status_effect/au_bord
	name = "Au Bord"
	desc = "My senses reel, but my strength has not yet left me."
	icon_state = "drunk"

/obj/item/lockpick/inquisitorial_vice
	name = "penitent's key"
	desc = "Набор отмычек из высококачественной стали, в Отаве известный \
		как «Clé du Pénitent». В комплекте идёт компактный паровой таран \
		для выбивания замков и засовов."
	icon = 'modular_twilight_axis/icons/roguetown/items/otavan_gadgets/misc.dmi'
	icon_state = "lockpick"
	max_integrity = 200
	obj_flags = CAN_BE_HIT
	picklvl = 2
	anvilrepair = /datum/skill/craft/blacksmithing
	always_destroy = FALSE
	var/ram_enabled = FALSE
	var/ram_busy = FALSE

/obj/item/lockpick/inquisitorial_vice/examine(mob/user)
	. = ..()
	if(!HAS_TRAIT(user, TRAIT_INQUISITION))
		return
	var/list/examination = .
	var/description_index = examination.Find(span_info(desc))
	if(description_index)
		examination[description_index] = span_info("«Clé du Pénitent», высококлассный \
			набор отмычек и обычный инструментарий ценных агентов Инквизиции. \
			Идущий в комплекте паровой таран не раз отрывал руки при неверном \
			использовании.")

/obj/item/lockpick/inquisitorial_vice/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click it in hand to switch between the pick and ram.")
	. += span_info("The ram breaks a door and costs 50 integrity per use.")

/obj/item/lockpick/inquisitorial_vice/rmb_self(mob/user, keybind = FALSE)
	if(ram_busy || !(src in user.held_items))
		return
	ram_enabled = !ram_enabled
	var/mode = ram_enabled ? "ram" : "lockpick"
	to_chat(user, span_notice("I ready the [mode]."))

/obj/item/lockpick/inquisitorial_vice/pre_attack(
	atom/target, mob/living/user, params,
)
	if(..())
		return TRUE
	if(!ram_enabled)
		return FALSE
	var/static/list/door_types = list(
		/obj/structure/mineral_door,
		/obj/structure/roguetent,
		/obj/structure/floordoor,
		/obj/structure/gate,
	)
	if(!is_type_in_list(target, door_types))
		return FALSE
	var/obj/structure/door = target
	if(ram_busy || !door.density || !user.Adjacent(door))
		return TRUE
	if(obj_integrity < 50 || obj_broken)
		to_chat(user, span_warning("The ram needs repairs."))
		return TRUE
	if(!door.max_integrity || (door.resistance_flags & INDESTRUCTIBLE))
		to_chat(user, span_warning("The ram cannot break this door."))
		return TRUE

	ram_busy = TRUE
	var/completed = do_after(user, 5, target = door)
	if(QDELETED(src))
		return TRUE
	ram_busy = FALSE
	if(!completed || QDELETED(door) || door.obj_destroyed || !door.density)
		return TRUE
	if(!(src in user.held_items) || !user.Adjacent(door) || obj_integrity < 50)
		return TRUE

	obj_integrity -= 50
	if(!obj_integrity)
		obj_break()
	user.visible_message(span_danger("[user] smashes [door] with [src]!"))
	playsound(door, 'sound/combat/hits/onwood/destroywalldoor.ogg', 100, TRUE)
	log_combat(user, door, "breached with", src)
	door.obj_destruction(BRUTE)
	return TRUE

/obj/item/explosive/impact/inquisitorial_burst
	name = "martyr's thorns"
	desc = "Истыканный шипами пороховой заряд. В Отаве его зовут «Hérisson». \
		Он выглядит так же страшно, как и действует."
	icon = 'modular_twilight_axis/icons/roguetown/items/otavan_gadgets/misc.dmi'
	icon_state = "grenade"

/obj/item/explosive/impact/inquisitorial_burst/blast(turf/center, forced)
	var/list/landing_tiles = list()
	for(var/turf/open/tile in view(3, center))
		if(get_dist(center, tile) < 2)
			continue
		if(istype(tile, /turf/open/transparent/openspace))
			continue
		if(tile.is_blocked_turf())
			continue
		landing_tiles += tile
	for(var/number in 1 to min(6, length(landing_tiles)))
		var/turf/tile = pick_n_take(landing_tiles)
		new /obj/item/inquisitorial_caltrop(tile)
	playsound(center, 'sound/misc/explode/incendiary (1).ogg', 100, TRUE)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(3, center)
	smoke.start()

/obj/item/inquisitorial_caltrop
	name = "caltrop"
	desc = "A small iron thorn that always lands with a point upwards."
	icon = 'modular_twilight_axis/icons/roguetown/items/otavan_gadgets/misc.dmi'
	icon_state = "caltrop"
	w_class = WEIGHT_CLASS_TINY
	grid_width = 32
	grid_height = 32

/obj/item/inquisitorial_caltrop/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/caltrop/inquisitorial)

/datum/component/caltrop/inquisitorial/Crossed(datum/source, atom/movable/crosser)
	if(!ishuman(crosser))
		return
	var/mob/living/carbon/human/victim = crosser
	if(victim.buckled || (victim.movement_type & FLYING) || victim.get_taur_tail())
		return
	if(HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		return
	var/zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/leg = victim.get_bodypart(zone)
	if(!leg || leg.status == BODYPART_ROBOTIC)
		return

	var/footwear = victim.shoes
	var/feet_covered = victim.wear_armor?.body_parts_covered & FEET
	feet_covered |= victim.wear_pants?.body_parts_covered & FEET
	var/barefoot = !footwear && !feet_covered
	if(barefoot && HAS_TRAIT(victim, TRAIT_HARDSOLE))
		return
	var/damage = 8
	var/plate_boots = istype(footwear, /obj/item/clothing/shoes/roguetown/boots/armor)
	if(footwear && !plate_boots)
		damage = 3
	victim.apply_damage(damage, BRUTE, zone)
	if(barefoot)
		victim.Knockdown(2 SECONDS)
	if(world.time >= cooldown)
		victim.visible_message(span_warning("[victim] steps on [parent]!"))
		cooldown = world.time + 1 SECONDS

/obj/item/paper/scroll/inquisitorial_oath
	name = "the confessor's covenant"
	desc = "Заверенная неизвестной вам печатью бумага с клятвой. Все буквы \
		выведены бурыми чернилами. В первой строке стоит «Oath du Gévaudan»."
	icon_state = "slip_sealed"
	info = "Oath du Gévaudan<br>I swear to take into my flesh what my sworn \
		enemies would deny me."
	var/reading = FALSE

/obj/item/paper/scroll/inquisitorial_oath/update_icon_state()
	icon_state = "slip_sealed"

/obj/item/paper/scroll/inquisitorial_oath/attack_self(mob/user)
	if(reading || !ishuman(user) || !(src in user.held_items))
		return
	if(!user.can_read(src))
		return
	if(HAS_TRAIT(user, TRAIT_ORGAN_EATER))
		to_chat(user, span_notice("I already carry the hunger this oath offers."))
		return
	reading = TRUE
	to_chat(user, span_notice("I begin to recite the oath."))
	for(var/verse in 1 to 3)
		if(!do_after(user, 3 SECONDS, target = user) || QDELETED(src))
			break
		if(!(src in user.held_items) || user.stat != CONSCIOUS)
			break
		if(verse < 3)
			to_chat(user, span_notice("I recite another verse. The seal grows hot."))
			continue
		ADD_TRAIT(user, TRAIT_ORGAN_EATER, type)
		user.visible_message(span_warning("[src] crumbles to ash in [user]'s hands."))
		new /obj/effect/temp_visual/small_smoke(get_turf(user))
		qdel(src)
		return
	if(!QDELETED(src))
		reading = FALSE

/datum/inqports/supplies/au_bord
	name = "Injecteur \"Au Bord\""
	item_type = /obj/item/au_bord_injector
	marquescost = 8

/datum/inqports/equipment/penitents_key
	name = "Penitent's Key"
	item_type = /obj/item/lockpick/inquisitorial_vice
	marquescost = 12
	maximum = 2

/datum/inqports/equipment/martyrs_thorns
	name = "Martyr's Thorns"
	item_type = /obj/item/explosive/impact/inquisitorial_burst
	marquescost = 6

/datum/inqports/reliquary/confessors_covenant
	name = "The Confessor's Covenant"
	item_type = /obj/item/paper/scroll/inquisitorial_oath
	marquescost = 20
	maximum = 1

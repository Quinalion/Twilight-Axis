/obj/effect/proc_holder/spell/self/direct_turrets
	name = "Direct Turrets"
	desc = "Target a specific person with your turrets!"
	recharge_time = 10 SECONDS
	chargedloop = null

/obj/effect/proc_holder/spell/self/direct_turrets/cast(list/targets, mob/living/user = usr)
	. = ..()
	var/obj/item/rogueweapon/mace/maul/toil/W = user.get_active_held_item()
	if(!istype(W))
		to_chat(user, span_warning("I must hold the Tool."))
		revert_cast()
		return FALSE
	var/list/possible = list()
	for(var/mob/living/carbon/human/H in oview(7, user))
		possible += H
	if(!length(possible))
		to_chat(user, span_warning("No one detected."))
		revert_cast()
		return FALSE
	var/mob/living/carbon/human/target = input(user, "TARGET", "ZIZO") as null|anything in possible
	if(!target)
		revert_cast()
		return FALSE
	for(var/obj/structure/toilturret/existing as anything in W.turrets.Copy())
		if(QDELETED(existing))
			W.turrets -= existing
			continue
		existing.forced_target = target
	to_chat(user, span_notice("TURRET LOCK: [target]."))
	return TRUE

/obj/effect/proc_holder/spell/self/scrap_turrets
	name = "Scrap Turrets"
	desc = "Disassemble all sentries."
	recharge_time = 5 SECONDS
	chargedloop = null

/obj/effect/proc_holder/spell/self/scrap_turrets/cast(list/targets, mob/living/user = usr)
	. = ..()
	var/obj/item/rogueweapon/mace/maul/toil/W = user.get_active_held_item()
	if(!istype(W))
		to_chat(user, span_warning("I must hold the Tool."))
		revert_cast()
		return FALSE
	for(var/obj/structure/toilturret/existing as anything in W.turrets.Copy())
		qdel(existing)
	W.turrets = list()
	to_chat(user, span_notice("My sentries have disassembled."))
	return TRUE

/datum/action/cooldown/spell/deploy_turret
	name = "Deploy Turret"
	desc = "Buildin' a Sentry."
	button_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	button_icon_state = "toil"
	click_to_activate = TRUE
	self_cast_possible = FALSE
	cast_range = 3
	charge_required = TRUE
	charge_time = 4 SECONDS
	charge_swingdelay_type = SWINGDELAY_CANCEL
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/deploy_turret/cast(atom/cast_on)
	. = ..()
	var/obj/item/rogueweapon/mace/maul/toil/W = owner.get_active_held_item()
	if(!istype(W))
		to_chat(owner, span_warning("I must hold the Tool."))
		return FALSE
	for(var/obj/structure/toilturret/existing as anything in W.turrets.Copy())
		if(QDELETED(existing))
			W.turrets -= existing
	if(length(W.turrets) >= W.max_turrets)
		to_chat(owner, span_warning("Too many sentries!"))
		return FALSE
	var/turf/T = get_turf(cast_on)
	if(!T || T.density || isopenspace(T))
		to_chat(owner, span_warning("No room!"))
		return FALSE
	W.turrets += new /obj/structure/toilturret(T, owner, W)
	to_chat(owner, span_notice("The turret whirs to life!"))
	return TRUE

/obj/structure/toilturret
	name = "cog turret"
	desc = "There's a horrible familiarity to its shape. You swore you haven't seen it before."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "ocular_warden"
	density = TRUE
	anchored = TRUE
	max_integrity = 150
	var/mob/living/carbon/human/owner
	var/obj/item/rogueweapon/mace/maul/toil/source_wrench
	var/range = 5
	var/cooldown = 0
	var/active = TRUE
	var/mob/living/carbon/human/forced_target

/obj/structure/toilturret/Initialize(mapload, mob/living/carbon/human/builder, obj/item/rogueweapon/mace/maul/toil/wrench)
	. = ..()
	owner = builder
	source_wrench = wrench
	START_PROCESSING(SSobj, src)

/obj/structure/toilturret/Destroy()
	STOP_PROCESSING(SSobj, src)
	source_wrench?.turrets -= src
	source_wrench = null
	owner = null
	forced_target = null
	return ..()

/obj/structure/toilturret/attack_right(mob/living/user, params)
	. = ..()
	if(!istype(user.get_active_held_item(), /obj/item/rogueweapon/mace/maul/toil))
		return
	active = !active
	if(active)
		icon_state = "ocular_warden"
	else
		icon_state = "ocular_warden_unwrenched"

/obj/structure/toilturret/process()
	if(!active)
		return
	if(world.time < cooldown)
		return
	if(!owner)
		qdel(src)
		return
	var/mob/living/carbon/human/target
	if(forced_target && !QDELETED(forced_target) && forced_target.stat < SOFT_CRIT && (forced_target in view(range, src)))
		target = forced_target
	else
		for(var/mob/living/carbon/human/H in view(range, src))
			if(H == owner || is_zizo(H) || H.stat >= SOFT_CRIT)
				continue
			target = H
			break
	if(!target)
		return
	cooldown = world.time + 20
	visible_message(span_danger("[src] takes aim at [target]!"))
	var/turf/startloc = get_turf(src)
	var/obj/projectile/P = new /obj/projectile/toilbolt(startloc)
	playsound(src, 'sound/combat/hits/onmetal/metalimpact (1).ogg', 60, TRUE)
	P.starting = startloc
	P.fired_from = src
	P.yo = target.y - startloc.y
	P.xo = target.x - startloc.x
	P.original = target
	P.preparePixelProjectile(target, src)
	P.fire()

/obj/projectile/toilbolt
	name = "bolt"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	damage = 15
	damage_type = BRUTE
	armor_penetration = 10
	range = 15
	hitsound = 'sound/combat/hits/hi_bolt (1).ogg'
	flag = "piercing"
	speed = 2


/obj/effect/proc_holder/spell/invoked/projectile/toil_mend
	name = "Mend"
	desc = "Shoot mending lightning that heals the target and fixes their equipment."
	clothes_req = FALSE
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "toil"
	sound = 'sound/magic/lightning.ogg'
	range = 7
	projectile_type = /obj/projectile/magic/mendbolt
	chargetime = 15
	recharge_time = 10 SECONDS
	chargedloop = null

/obj/projectile/magic/mendbolt
	name = "bolt of mending"
	tracer_type = /obj/effect/projectile/tracer/disabler
	color = "#ffb347"
	hitscan_light_color_override = "#ffb347"
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	light_color = "#ffb347"
	damage = 0
	nodamage = TRUE
	speed = 0.3
	flag = "magic"
	light_outer_range = 7

/obj/projectile/magic/mendbolt/on_hit(target)
	. = ..()
	if(ismob(target) && isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		L.apply_status_effect(/datum/status_effect/buff/healing, 10, TRUE)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			for(var/obj/item/I in H.get_equipped_items())
				I.obj_integrity = min(I.obj_integrity + (I.max_integrity * 0.2), I.max_integrity)
		to_chat(L, span_notice("I AM MENDED!"))
		ysis_effect(L, 4)
	qdel(src)

/datum/ritual/toil/progress
	name = "Mend"
	icon_type = /obj/effect/proc_holder/spell/invoked/projectile/toil_mend
	desc = "Learn a spell that heals others and repairs their equipment. Does not work on yourself."
	passive = TRUE
	research_cost = 3

/datum/ritual/toil/progress/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/toil_mend)
	return

/datum/ritual/toil/summonysis
	name = "Summon Ysis"
	icon_type = /obj/structure/ysis
	desc = "Summon a machine that heals and mends the equipment of anyone who activates it."
	center_requirement = /obj/item/bedsheet
	research_cost = 5

/datum/ritual/toil/summonysis/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/structure/ysis(center)
	to_chat(user, span_notice("Erectin' a Ysis."))

/proc/ysis_effect(atom/movable/target, healings)
	var/datum/effect_system/spark_spread/S = new(target)
	S.set_up(3, 1, target)
	S.start()
	for(var/i in 1 to healings)
		new /obj/effect/temp_visual/heal(get_turf(target), "#ffb347")
	target.add_filter("ysis_glow", 2, list(type = "outline", color = "#ffb347", size = 2))
	target.transition_filter("ysis_glow", list(size = 0), 2 SECONDS)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/datum, remove_filter), "ysis_glow"), 2 SECONDS)

/obj/structure/ysis
	name = "Ysis"
	desc = "It feels good to touch!"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "interdiction_lens"
	density = TRUE
	anchored = TRUE
	max_integrity = 200
	var/active = FALSE
	var/ready_time = 0
	var/cooldown_time = 45 SECONDS

/obj/structure/ysis/examine(mob/user)
	. = ..()
	if(world.time < ready_time)
		. += span_warning("WAIT [round((ready_time - world.time) / 10)] SECONDS.")

/obj/structure/ysis/update_icon()
	. = ..()
	if(active)
		icon_state = "interdiction_lens_active"
	else if(world.time < ready_time)
		icon_state = "interdiction_lens_unwrenched"
	else
		icon_state = "interdiction_lens"

/obj/structure/ysis/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user) || user.stat == DEAD)
		return
	if(active)
		to_chat(user, span_warning("[src] is already working on someone."))
		return
	if(world.time < ready_time)
		to_chat(user, span_warning("[src] is recovering!"))
		return
	var/mob/living/carbon/human/H = user
	to_chat(H, span_notice("THE YSIS WORKS UPON ME..."))
	active = TRUE
	update_icon()
	set_light(3, 1, 1.5, l_color = "#ffb347")
	ysis_effect(src, 0)
	playsound(src, 'sound/magic/charging.ogg', 60, TRUE)
	var/finished = do_after(H, 5 SECONDS, target = src)
	active = FALSE
	set_light(0)
	if(!finished)
		update_icon()
		return
	var/datum/status_effect/buff/healing/heal = H.apply_status_effect(/datum/status_effect/buff/healing, 10, TRUE)
	if(heal)
		heal.duration = world.time + 5 SECONDS
	for(var/obj/item/I in H.get_equipped_items())
		I.obj_integrity = min(I.obj_integrity + (I.max_integrity * 0.2), I.max_integrity)
	to_chat(H, span_notice("YSIS MENDS ME."))
	playsound(src, 'sound/magic/lightning.ogg', 60, TRUE)
	ysis_effect(H, 8)
	flick("interdiction_lens_discharged", src)
	ready_time = world.time + cooldown_time
	update_icon()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), cooldown_time)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(ysis_effect), src, 0), cooldown_time)

/datum/ritual/toil/fulmenor
	name = "Curse of Fulmenor"
	icon_type = /obj/item/natural/worms/leech
	desc = "Transform the target into a horrific, yet extremely strong and regenerative monster. It attacks people at random. Lasts one minute. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE
	research_cost = 5

/datum/ritual/toil/fulmenor/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	victim.apply_status_effect(/datum/status_effect/fulmenor)
	victim.emote("scream")
	to_chat(victim, span_userdanger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	to_chat(user, span_notice("THEY SHALL WRECK HAVOC."))

/datum/status_effect/fulmenor
	id = "fulmenor"
	duration = 1 MINUTES
	tick_interval = 5 SECONDS
	alert_type = null

/datum/status_effect/fulmenor/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.change_stat(STATKEY_STR, 6)
	H.change_stat(STATKEY_CON, 6)
	ADD_TRAIT(H, TRAIT_MONSTROUS, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_WEAK, "fulmenor")
	H.enter_frenzymod()
	to_chat(H, span_notice("I WANT TO HURT PEOPLE!"))
	return TRUE

/datum/status_effect/fulmenor/tick()
	var/mob/living/carbon/human/H = owner
	H.heal_overall_damage(10, 10)

/datum/status_effect/fulmenor/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.exit_frenzymod()
	H.change_stat(STATKEY_STR, -6)
	H.change_stat(STATKEY_CON, -6)
	REMOVE_TRAIT(H, TRAIT_MONSTROUS, TRAIT_GENERIC)
	REMOVE_TRAIT(H, TRAIT_SILVER_WEAK, "fulmenor")
	to_chat(H, span_notice("THE MONSTROUS HUNGER FADES FROM ME."))

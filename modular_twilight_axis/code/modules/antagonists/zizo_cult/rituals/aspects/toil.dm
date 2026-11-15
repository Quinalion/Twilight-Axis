/obj/effect/proc_holder/spell/invoked/projectile/toil_mend
	name = "Mending Bolt"
	desc = "Fire a bolt that heals another creature and repairs their worn equipment by twenty percent of its maximum integrity. Cannot target yourself."
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
	name = "Learn Mending"
	desk = "Learn Mending Bolt, which heals another creature and repairs their worn equipment by twenty percent of its maximum integrity. Cannot target yourself."
	passive = TRUE

/datum/ritual/toil/progress/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/toil_mend)
	return

/datum/ritual/toil/summonysis
	name = "Summon Healing Shrine"
	desk = "Transform a bedsheet into a healing shrine. A five-second interaction grants five seconds of healing and repairs worn equipment by twenty percent of its maximum integrity. The shrine has a forty-five-second cooldown."
	center_requirement = /obj/item/bedsheet

/datum/ritual/toil/summonysis/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/structure/ysis(center)
	to_chat(user, span_notice("You create a healing shrine."))

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
	name = "healing shrine"
	desc = "A shrine that heals its user and repairs worn equipment after a five-second interaction. Requires forty-five seconds to recharge."
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
	to_chat(H, span_notice("The shrine begins healing me."))
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
	to_chat(H, span_notice("The shrine heals me and repairs my equipment."))
	playsound(src, 'sound/magic/lightning.ogg', 60, TRUE)
	ysis_effect(H, 8)
	flick("interdiction_lens_discharged", src)
	ready_time = world.time + cooldown_time
	update_icon()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), cooldown_time)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(ysis_effect), src, 0), cooldown_time)

/datum/ritual/toil/fulmenor
	name = "Induce Frenzy"
	desk = "Curse the donor of a blood-fed leech for one minute. Force them into a frenzy, grant 6 Strength and Constitution, and heal brute and burn damage every five seconds. They become visibly monstrous and vulnerable to silver."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

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

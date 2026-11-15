/obj/effect/proc_holder/spell/self/rot_transfuse
	name = "Transfuse"
	desc = "Transfuse all reagents in your bloodstream to the target you're holding."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "transfuse"
	recharge_time = 5 SECONDS
	chargedloop = null

/obj/effect/proc_holder/spell/self/rot_transfuse/cast(list/targets, mob/user = usr)
	. = ..()
	var/obj/item/grabbing/G = user.get_active_held_item()
	if(!istype(G) || !isliving(G.grabbed))
		to_chat(user, span_warning("I need to be grabbing someone."))
		revert_cast()
		return FALSE
	var/mob/living/victim = G.grabbed
	if(user.reagents && victim.reagents && user.reagents.total_volume)
		user.reagents.trans_to(victim, user.reagents.total_volume, method = INJECT)
	to_chat(user, span_notice("I transfuse into [victim]."))
	return TRUE

/datum/ritual/rot/transfuse
	name = "Rot Initiate"
	icon_type = /obj/effect/proc_holder/spell/self/rot_transfuse
	desc = "Learn to transfuse reagents into whoever you grab. Learn lesser blight. Makes you immune to poison."
	passive = TRUE
	research_cost = 3

/datum/ritual/rot/transfuse/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/rot_transfuse)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/lesser_blight)
	ADD_TRAIT(H, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	return

/turf/open/floor/rogue/naturalstone/rot
	name = "nerve threads"
	desc = "A pulsing mass of flesh. It shivers and writhes at any touch."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/blightfloor.dmi'
	icon_state = "flesh_tile-0"
	transform = matrix(1, 0, -16, 0, 1, -16)
	layer = HIGH_TURF_LAYER
	color = "#bf5252"
	smooth = SMOOTH_FALSE

/turf/open/floor/rogue/naturalstone/rot/Initialize(mapload)
	. = ..()
	underlays += mutable_appearance('icons/turf/roguefloor.dmi', "digstone")
	update_flesh()
	for(var/d in GLOB.cardinals)
		var/turf/open/floor/rogue/naturalstone/rot/N = get_step(src, d)
		if(istype(N))
			N.update_flesh()

/turf/open/floor/rogue/naturalstone/rot/proc/update_flesh()
	var/mask = 0
	for(var/d in GLOB.cardinals)
		if(istype(get_step(src, d), /turf/open/floor/rogue/naturalstone/rot))
			mask |= d
	icon_state = "flesh_tile-[mask]"

/turf/closed/mineral/rogue/blight
	name = "flesh wall"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/blightwall.dmi'
	smooth_icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/blightwall.dmi'
	icon_state = "blightwall"
	color = "#bf5252"
	smooth = SMOOTH_FALSE

/turf/open/floor/rogue/naturalstone/rot/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/H = AM
	H.apply_status_effect(/datum/status_effect/debuff/rotground)
	var/obj/effect/temp_visual/small_smoke/puff = new(src)
	puff.color = "#7a2a2a"

/datum/status_effect/debuff/rotground
	id = "rotground"
	duration = -1
	tick_interval = 3 SECONDS
	alert_type = null
	var/elapsed = 0
	var/obj/effect/abstract/particle_holder/aura

/datum/status_effect/debuff/rotground/on_apply()
	. = ..()
	if(!is_zizo(owner))
		aura = new(owner, /particles/zizo_rot, PARTICLE_ATTACH_MOB)

/datum/status_effect/debuff/rotground/on_remove()
	. = ..()
	QDEL_NULL(aura)

/datum/status_effect/debuff/rotground/tick()
	var/mob/living/carbon/human/H = owner
	var/turf/T = get_turf(H)
	if(!ishuman(H) || !istype(T, /turf/open/floor/rogue/naturalstone/rot))
		qdel(src)
		return
	new /obj/effect/temp_visual/cult/turf/floor(T)
	if(is_zizo(H))
		H.heal_overall_damage(2, 2)
		H.heal_wounds(2)
		H.adjustStaminaLoss(-5)
		H.energy_add(20)
		new /obj/effect/temp_visual/heal(T, "#bf5252")
		if(prob(10))
			to_chat(H, span_notice("THE ROT'S AROMA REJUVENATES ME!"))
		return
	elapsed += 3
	H.adjustOxyLoss(3)
	H.adjustStaminaLoss(5)
	if(prob(10))
		to_chat(H, span_danger("IT SMELLS HORRIBLE! I CAN'T BREATHE!"))
	if(elapsed > 30 && prob(10))
		H.vomit(50)

/obj/structure/blight_pillar
	name = "rotting pillar"
	desc = "A pillar of fused bone and diseased flesh. Destroy it!"
	icon = 'icons/roguetown/maniac/creations.dmi'
	icon_state = "creation1"
	anchored = TRUE
	density = TRUE
	max_integrity = 300
	var/radius = 3
	var/list/turf_data = list()

/obj/structure/blight_pillar/Initialize(mapload)
	. = ..()
	new /obj/effect/abstract/particle_holder(src, /particles/zizo_rot)
	for(var/turf/T in range(radius, get_turf(src)))
		addtimer(CALLBACK(src, PROC_REF(blight_turf), T), get_dist(src, T) * 8)

/obj/structure/blight_pillar/proc/blight_turf(turf/T)
	if(QDELETED(src))
		return
	if(isclosedturf(T) && !istype(T, /turf/closed/indestructible))
		turf_data[T] = T.type
		T.ChangeTurf(/turf/closed/mineral/rogue/blight, flags = CHANGETURF_IGNORE_AIR)
	else if(isopenturf(T) && !istype(T, /turf/open/floor/rogue/naturalstone/rot))
		turf_data[T] = T.type
		T.ChangeTurf(/turf/open/floor/rogue/naturalstone/rot, flags = CHANGETURF_IGNORE_AIR)
	else
		return
	var/obj/effect/temp_visual/small_smoke/puff = new(T)
	puff.color = "#7a2a2a"

/obj/structure/blight_pillar/Destroy()
	for(var/turf/T in turf_data)
		T.ChangeTurf(turf_data[T], flags = CHANGETURF_IGNORE_AIR)
	turf_data.Cut()
	visible_message(span_danger("Lux fills the barren stone and returns lyfe to the land!"))
	playsound(src, 'sound/foley/breaksound.ogg', 50, TRUE)
	return ..()

/obj/structure/blight_pillar/lesser
	name = "lesser rotting pillar"
	icon_state = "creation3"
	max_integrity = 150
	radius = 1

/obj/effect/proc_holder/spell/self/lesser_blight
	name = "Lesser Blight"
	desc = "Raise a VILE totem before you to blight the land! The rotten flesh will harm any non-believers, yet strengthen fellow cultists."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "profane"
	recharge_time = 2 MINUTES
	chargedloop = null

/obj/effect/proc_holder/spell/self/lesser_blight/cast(list/targets, mob/user = usr)
	. = ..()
	var/turf/T = get_step(user, user.dir)
	if(!T || T.density)
		to_chat(user, span_warning("No space."))
		revert_cast()
		return FALSE
	new /obj/structure/blight_pillar/lesser(T)
	to_chat(user, span_notice("THE LAND ROTS."))
	return TRUE

/datum/ritual/rot/blight
	name = "Blight"
	icon_type = /obj/structure/blight_pillar
	desc = "Perform a rite that petrifies the area around you. Non-cultists will take damage when stepping upon the petrified land. It transforms walls into mineable rock."
	center_requirement = /mob/living/carbon/human

/datum/ritual/rot/blight/invoke(mob/living/user, turf/center)
	var/poo = new /obj/effect/temp_visual/opengate/fivesec(center)
	playsound(user, 'sound/villain/littlescary2.ogg', 60, TRUE)
	if(!do_after(user, 5 SECONDS))
		qdel(poo)
		return
	new /obj/structure/blight_pillar(center)
	to_chat(user, span_notice("THE LAND ROTS."))

/datum/ritual/rot/plague
	name = "Curse of Black Rot"
	icon_type = /obj/item/natural/worms/leech
	desc = "Curse your target with the black rot. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/rot/plague/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	if(!curse_target(remnant.fed_from))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	remnant.fed_from.apply_status_effect(/datum/status_effect/black_rot)
	to_chat(remnant.fed_from, span_danger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	remnant.fed_from.emote("scream")
	qdel(remnant)
	to_chat(user, span_notice("THEY HAVE THE ROT WITHIN THEM, NOW."))

/obj/effect/proc_holder/spell/invoked/dream_jaunt
	name = "Dream Jaunt"
	desc = "Bring yourself and whoever you hold into the dream."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "jaunt"
	range = 0
	movement_interrupt = FALSE
	chargedloop = null
	recharge_time = 60 SECONDS
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/dream_jaunt/cast(list/targets, mob/living/user)
	. = ..()
	if(!ishuman(user))
		return FALSE
	send_to_dream(user)
	if(ishuman(user.pulling))
		send_to_dream(user.pulling)
	return TRUE

/proc/send_to_dream(mob/living/carbon/human/target, status_type = /datum/status_effect/dream_teleport/strand)
	var/area/dream_area = GLOB.areas_by_type[/area/rogue/underworld/dream]
	var/turf/origin = get_turf(target)
	if(!dream_area || !origin)
		return
	var/list/safe_turfs = list()
	for(var/turf/T in get_area_turfs(dream_area))
		if(!T.density)
			safe_turfs += T
	if(!safe_turfs.len || !do_teleport(target, pick(safe_turfs)))
		return
	GLOB.players_in_dream |= target
	origin.visible_message(span_danger("[target] vanishes!"))
	playsound(origin, 'sound/misc/area.ogg')
	target.apply_status_effect(status_type, origin)

/datum/status_effect/dream_teleport/strand
	duration = 30 SECONDS

/datum/status_effect/dream_teleport/recall
	duration = 3 MINUTES

/mob/living/simple_animal/hostile/rogue/dreamfiend/nightmare
	faction = list("dream", "crabs", "zizo_cult")

/datum/status_effect/dream_teleport/strand/nightmare/on_creation(mob/living/new_owner, turf/origin)
	new_owner.SetSleeping(0)
	summon_dreamfiend(new_owner, null, /mob/living/simple_animal/hostile/rogue/dreamfiend/nightmare)
	return ..(new_owner, origin)

/datum/status_effect/dream_teleport/strand/nightmare/on_remove()
	. = ..()
	for(var/mob/living/simple_animal/hostile/rogue/dreamfiend/nightmare/F in world)
		if(F.ai_controller?.blackboard[BB_MAIN_TARGET] == owner)
			qdel(F)

/datum/ritual/strand/dream_jaunt
	name = "Dream Jaunt"
	desk = "Learn a spell to teleport yourself and whoever you're holding into a pocket dimension for 30 seconds."
	passive = TRUE

/datum/ritual/strand/dream_jaunt/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/dream_jaunt)
	return

/datum/ritual/strand/strandsend
	name = "Passage"
	desk = "Perform a rite to create a teleportation sigil. Activating it will teleport everything on the sigil to another teleportation sigil."
	center_requirement = /mob/living/carbon/human

/datum/ritual/strand/strandsend/invoke(mob/living/user, turf/center)
	var/obj/effect/decal/cleanable/sigil/S = locate() in center
	if(!S)
		return
	var/poo = new /obj/effect/temp_visual/cult/ritual_channel/fivesec(center)
	playsound(user, 'sound/villain/littlescary2.ogg', 60, TRUE)
	if(!do_after(user, 5 SECONDS))
		qdel(poo)
		return
	S.set_sigil_type("Portal")
	to_chat(user, span_notice("AN EYE IS A PASSAGE."))
	S.choose_link(user)

/datum/ritual/strand/strandrecall
	name = "Curse of Recall"
	desk = "Teleport yourself and your target into a pocket dimension for 3 minutes. Anyone you or your target grabs is brought with. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/strand/strandrecall/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	to_chat(user, span_notice("ALL MEN OBEY THE DREAMCALL. I HAVE 1 MINUTE TO PREPARE. ANYONE I AM GRABBING WILL BE BROUGHT WITH ME."))
	to_chat(victim, span_userdanger("I FEEL SOMETHING HORRIBLE COMING. I HAVE 1 MINUTE TO PREPARE. ANYONE I AM GRABBING WILL BE BROUGHT WITH ME."))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dreamcall), user, victim), 1 MINUTES)

/proc/dreamcall(mob/living/user, mob/living/victim)
	for(var/mob/living/M in list(user, victim))
		if(QDELETED(M) || !ishuman(M))
			continue
		send_to_dream(M, /datum/status_effect/dream_teleport/recall)
		if(ishuman(M.pulling))
			send_to_dream(M.pulling, /datum/status_effect/dream_teleport/recall)

/proc/is_zizocultist(datum/mind/M)
	return istype(M?.has_antag_datum(/datum/antagonist/zizocultist), /datum/antagonist/zizocultist/leader)

/proc/is_zizolackey(datum/mind/M)
	var/datum/antagonist/zizocultist/Z = M?.has_antag_datum(/datum/antagonist/zizocultist)
	return Z && !istype(Z, /datum/antagonist/zizocultist/leader)


/proc/is_zizo(mob/M)
	return M && (is_zizocultist(M.mind) || is_zizolackey(M.mind))

/proc/absorb_lux(mob/living/carbon/human/target, turf/T, give_crystal = TRUE)
	if(is_zizo(target))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/debuff/devitalised) || target.has_status_effect(/datum/status_effect/debuff/devitalised/lux_ripped))
		return FALSE
	target.apply_status_effect(/datum/status_effect/debuff/devitalised/lux_ripped)
	ADD_TRAIT(target, TRAIT_LUX_RIPPED, TRAIT_GENERIC)
	new /obj/effect/temp_visual/cult/sac(get_turf(target))
	new /obj/effect/temp_visual/cult/sparks(get_turf(target))
	target.Unconscious(4 MINUTES)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, apply_status_effect), /datum/status_effect/buff/healing, 70, TRUE), 4 MINUTES)
	target.Jitter(4)
	target.emote("scream")
	target.visible_message(span_danger("[target]'s memory is wiped clean! They will completely forget what happened and who did it to them. In 4 minutes, they shall wake."))
	var/obj/item/bodypart/chest/torso = target.get_bodypart(BODY_ZONE_CHEST)
	if(torso)
		torso.receive_damage(85)
		torso.add_wound(/datum/wound/fracture)
	playsound(target, 'sound/gore/flesh_eat_04.ogg', 60, TRUE)
	target.purity = FALSE
	to_chat(target, span_danger("THE LUX IS TORN FROM YOUR SOUL. YOUR MEMORY BECOMES A BLUR. YOU CAN'T REMEMBER WHO DID THIS TO YOU, OR ANY DETAILS ABOUT HOW IT HAPPENED."))
	if(give_crystal)
		new /obj/item/necro_relics/necro_crystal(T)
	return TRUE

/proc/psydont(mob/living/carbon/human/H)
	for(var/obj/item/clothing/neck/roguetown/psicross/silver/S in H.held_items + H.get_equipped_items(TRUE))
		return TRUE
	return FALSE

/proc/find_remnant(mob/user, turf/center)
	for(var/obj/item/natural/worms/leech/L in center)
		if(L.fed_from && !QDELETED(L.fed_from) && L.fed_from.stat != DEAD)
			if(psydont(L.fed_from))
				to_chat(user, span_danger("They are wearing silver, it resists the dark magick!"))
				return FALSE
			return L
	to_chat(user, span_warning("Empty."))

/proc/zizo_target_error(mob/living/user, mob/living/carbon/human/target, list/wanted)
	if(!target || target == user)
		to_chat(user, span_warning("PLACE A SACRIFICE ON THE CENTER."))
		return TRUE
	if(is_zizo(target))
		to_chat(user, span_warning("CAN'T SACRIFICE CULTIST."))
		return TRUE
	if(!target.mind?.key)
		to_chat(user, span_warning("THIS ONE HAS NO SOUL."))
		return TRUE
	if(!wanted && HAS_TRAIT(target, TRAIT_LUX_RIPPED))
		to_chat(user, span_warning("THEIR LUX IS ALREADY TORN AWAY."))
		return TRUE
	if(istype(target, /mob/living/carbon/human/species/skeleton) || is_species(target, /datum/species/gnoll))
		to_chat(user, span_warning("THIS RITUAL IS NOT FOR THEM."))
		return TRUE
	var/datum/job/J = SSjob.GetJob(target.mind?.assigned_role)
	if(!J || (J.type in list(/datum/job/roguetown/lord)) || J.type == /datum/job/roguetown/bandit || J.type == /datum/job/roguetown/wretch)
		to_chat(user, span_warning("THIS RITUAL IS NOT FOR THEM."))
		return TRUE
	if(!wanted && (target in GLOB.gate_targets))
		to_chat(user, span_warning("THIS RITUAL IS NOT FOR THEM."))
		return TRUE
	if(wanted && !(target in wanted))
		to_chat(user, span_warning("THIS RITUAL IS NOT FOR THEM."))
		return TRUE
	if(psydont(target))
		to_chat(user, span_warning("SILVER REPELS THE DARK MAGICK!"))
		return TRUE
	return FALSE

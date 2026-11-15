// TA EDIT - One shared cult aspect per round
GLOBAL_VAR(zizo_cult_aspect)

/datum/mind
	var/list/zizo_aspect_rites = list()

/proc/zizo_aspect_schools()
	return list(
		"BITE" = /datum/ritual/bite,
		"BLOOD" = /datum/ritual/blood,
		"NOISE" = /datum/ritual/noise,
		"PITCH" = /datum/ritual/pitch,
		"TOIL" = /datum/ritual/toil,
	)

/proc/zizo_ritual_available(mob/living/user, datum/ritual/ritual_type)
	if(!user?.mind || !ispath(ritual_type, /datum/ritual) || is_abstract(ritual_type))
		return FALSE
	if(initial(ritual_type.is_cultist_ritual) && !is_zizo(user))
		return FALSE
	if(initial(ritual_type.needs_aspect) && initial(ritual_type.needs_aspect) != GLOB.zizo_cult_aspect)
		return FALSE
	if(initial(ritual_type.passive) && (ritual_type in user.mind.zizo_aspect_rites))
		return FALSE
	return TRUE

/datum/ritual/servantry/aspect
	name = "Invoke Cult Aspect"
	desk = "Choose one aspect for the entire cult for this round. Unlock its ritual school and activate its world effect immediately. The choice cannot be changed. BITE brings snow, protects cultists from cold and enables corpses to rise in town. BLOOD turns water into blood and reduces blood recovery from drinking water for non-cultists. NOISE increases stress and causes breakdowns. PITCH causes twenty minutes of night and disables lights. TOIL collapses sections of town walls, doors and windows."
	is_cultist_ritual = TRUE

/datum/ritual/servantry/aspect/invoke(mob/living/user, turf/center)
	if(GLOB.zizo_cult_aspect)
		to_chat(user, span_warning("The cult has already invoked [GLOB.zizo_cult_aspect]."))
		return
	var/list/aspects = zizo_aspect_schools()
	var/choice = tgui_input_list(user, "Choose the cult's only aspect for this round. Its school and world effect will activate immediately.", "Cult Aspect", aspects)
	if(!choice || !(choice in aspects) || GLOB.zizo_cult_aspect || !is_zizo(user) || user.incapacitated() || !user.Adjacent(center))
		return
	GLOB.zizo_cult_aspect = choice
	activate_zizo_aspect(choice)
	for(var/datum/mind/M as anything in SSmapping.retainer.cultists)
		if(M.current)
			to_chat(M.current, span_boldnotice("The cult has invoked [choice]. Its ritual school is now available."))

/proc/apply_zizo_aspect_traits(mob/living/H)
	if(has_world_trait(/datum/world_trait/zizo_bite))
		ADD_TRAIT(H, TRAIT_RESISTCOLD, "zizo_aspect")

/datum/ritual/bite
	abstract_type = /datum/ritual/bite
	needs_aspect = "BITE"
	is_cultist_ritual = TRUE

/datum/ritual/blood
	abstract_type = /datum/ritual/blood
	needs_aspect = "BLOOD"
	is_cultist_ritual = TRUE

/datum/ritual/noise
	abstract_type = /datum/ritual/noise
	needs_aspect = "NOISE"
	is_cultist_ritual = TRUE

/datum/ritual/pitch
	abstract_type = /datum/ritual/pitch
	needs_aspect = "PITCH"
	is_cultist_ritual = TRUE

/datum/ritual/toil
	abstract_type = /datum/ritual/toil
	needs_aspect = "TOIL"
	is_cultist_ritual = TRUE

/datum/mind
	var/list/zizo_learned_rituals = list()
	var/datum/mind/zizo_master

/proc/zizo_world_aspects()
	return list("BITE", "BLOOD", "NOISE", "PITCH", "TOIL")

/proc/zizo_ritual_available(mob/living/user, datum/ritual/ritual_type)
	if(!user?.mind || !ispath(ritual_type, /datum/ritual) || is_abstract(ritual_type))
		return FALSE
	if(initial(ritual_type.is_cultist_ritual) && !is_zizo(user))
		return FALSE
	if(initial(ritual_type.passive) && (!ishuman(user) || (ritual_type in user.mind.zizo_learned_rituals)))
		return FALSE
	return TRUE

/datum/ritual/servantry/aspect
	name = "Invoke Cult Aspect"
	description = "Choose one aspect for the cult for this round. Its world effect activates immediately and cannot be changed. BITE brings snow, protects cultists from cold and raises corpses in town. BLOOD turns water into blood and reduces blood recovery from drinking water for non-cultists. NOISE increases stress and causes breakdowns. PITCH brings twenty minutes of night and disables lights. TOIL collapses sections of town walls, doors and windows."
	is_cultist_ritual = TRUE
	var/chosen_aspect

/datum/ritual/servantry/aspect/validate(mob/living/user, turf/center)
	return !GLOB.zizo_cult_aspect

/datum/ritual/servantry/aspect/prepare(mob/living/user, turf/center)
	chosen_aspect = tgui_input_list(user, "Choose the cult's only aspect for this round. The choice is final.", "Cult Aspect", zizo_world_aspects())
	return chosen_aspect in zizo_world_aspects()

/datum/ritual/servantry/aspect/invoke(mob/living/user, turf/center)
	if(GLOB.zizo_cult_aspect || !(chosen_aspect in zizo_world_aspects()))
		return FALSE
	GLOB.zizo_cult_aspect = chosen_aspect
	activate_zizo_aspect(chosen_aspect)
	for(var/datum/mind/cultist as anything in get_zizo_cult_minds())
		to_chat(cultist.current, span_boldnotice("[chosen_aspect] answers. The Dark Lady's work takes root."))
	return TRUE

/proc/apply_zizo_aspect_traits(mob/living/target)
	if(has_world_trait(/datum/world_trait/zizo_bite))
		ADD_TRAIT(target, TRAIT_RESISTCOLD, "zizo_aspect")

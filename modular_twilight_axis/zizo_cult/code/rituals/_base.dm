/datum/ritual
	abstract_type = /datum/ritual
	var/name = "Cult Ritual"
	var/book_category = "Rituals"
	var/keep_center = FALSE
	var/list/outputs = list()
	var/success_message
	var/crafting_effects = FALSE
	var/passive = FALSE
	var/list/spells = list()
	var/description = ""
	var/center_requirement

	var/n_req
	var/e_req
	var/s_req
	var/w_req

	var/north_book
	var/east_book
	var/south_book
	var/west_book
	var/center_book

	var/is_cultist_ritual = FALSE
	var/cultist_number = 0
	var/ritual_limit = 0
	var/number_cultist_for_add_limit = 0

/datum/ritual/proc/invoke(mob/living/user, turf/center)
	for(var/output in outputs)
		new output(center)
	if(crafting_effects)
		var/datum/effect_system/spark_spread/sparks = new(center)
		sparks.set_up(1, 1, center)
		sparks.start()
		playsound(center, pick('sound/items/bsmith1.ogg', 'sound/items/bsmith2.ogg', 'sound/items/bsmith3.ogg', 'sound/items/bsmith4.ogg'), 100, FALSE)
	if(success_message)
		to_chat(user, span_notice(success_message))
	if(!passive || !ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.mind || (type in H.mind.zizo_learned_rituals))
		return
	H.mind.zizo_learned_rituals |= type
	for(var/spell_type in spells)
		if(!H.mind.has_spell(spell_type))
			H.mind.AddSpell(new spell_type)
	apply_passive(H)

/datum/ritual/proc/apply_passive(mob/living/carbon/human/H)
	return

/datum/ritual/proc/ingredient_requirements()
	return list(
		"center" = center_requirement,
		"[NORTH]" = n_req,
		"[EAST]" = e_req,
		"[SOUTH]" = s_req,
		"[WEST]" = w_req,
	)

/datum/ritual/proc/required_cultists()
	return cultist_number

/datum/ritual/proc/validate(mob/living/user, turf/center)
	return TRUE

/datum/ritual/proc/prepare(mob/living/user, turf/center)
	return TRUE

/datum/ritual/proc/can_invoke(mob/living/user, turf/center)
	if(!user?.mind || user.incapacitated() || !user.Adjacent(center) || !istype(user.patron, /datum/patron/inhumen/zizo) || !zizo_ritual_available(user, type))
		return FALSE
	var/cultists = length(SSmapping.retainer.cultists)
	if(cultists < required_cultists())
		to_chat(user, span_warning("This ritual requires [required_cultists()] cultists."))
		return FALSE
	var/limit = get_dynamic_ritual_limit(src, cultists)
	if(limit > 0 && get_ritual_count(name) >= limit)
		to_chat(user, span_warning("This ritual has reached its limit for this round."))
		return FALSE
	return validate(user, center)

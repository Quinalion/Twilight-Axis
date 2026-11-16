/datum/ritual
	abstract_type = /datum/ritual
	var/name = "Cult Ritual"
	var/book_category = "Rituals"
	var/needs_aspect
	var/keep_center = FALSE
	var/passive = FALSE
	var/list/spells = list()
	var/desk = ""
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
	if(!passive || !ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.mind || (type in H.mind.zizo_aspect_rites))
		return
	H.mind.zizo_aspect_rites |= type
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

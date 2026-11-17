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
	var/list/ingredients = list()
	var/limit_reserved = FALSE
	var/mob/dead/volunteer
	var/mob/living/invoker
	var/client/spirit_client
	var/datum/mind/spirit_mind

/datum/ritual/Destroy()
	release_limit()
	ingredients = null
	volunteer = null
	invoker = null
	spirit_client = null
	spirit_mind = null
	return ..()

/datum/ritual/proc/ingredient_requirements()
	return list(
		"center" = center_requirement,
		"[NORTH]" = n_req,
		"[EAST]" = e_req,
		"[SOUTH]" = s_req,
		"[WEST]" = w_req,
	)

/datum/ritual/proc/find_ingredient(turf/place, required_type)
	return find_zizo_ritual_ingredient(place, required_type)

/datum/ritual/proc/bind_ingredients(turf/center)
	ingredients = list()
	var/list/used_ingredients = list()
	var/list/requirements = ingredient_requirements()
	for(var/position in requirements)
		var/required_type = requirements[position]
		if(!required_type)
			continue
		var/turf/place = position == "center" ? center : get_step(center, text2num(position))
		var/atom/movable/ingredient = find_ingredient(place, required_type)
		if(!ingredient || (ingredient in used_ingredients))
			return FALSE
		ingredients[position] = ingredient
		used_ingredients += ingredient
	return TRUE

/datum/ritual/proc/validate_ingredients(turf/center)
	var/list/requirements = ingredient_requirements()
	for(var/position in requirements)
		if(!requirements[position])
			continue
		var/atom/movable/ingredient = ingredients[position]
		var/turf/place = position == "center" ? center : get_step(center, text2num(position))
		if(QDELETED(ingredient) || ingredient.loc != place || !istype(ingredient, requirements[position]))
			return FALSE
	return TRUE

/datum/ritual/proc/get_target()
	RETURN_TYPE(/mob/living/carbon/human)
	return ingredients["center"]

/datum/ritual/proc/required_cultists()
	return cultist_number

/datum/ritual/proc/validate(mob/living/user, turf/center)
	return TRUE

/datum/ritual/proc/prepare(mob/living/user, turf/center)
	return TRUE

/datum/ritual/proc/can_invoke(mob/living/user, turf/center)
	if(QDELETED(user) || !user.mind || user.incapacitated() || !user.Adjacent(center) || !istype(user.patron, /datum/patron/inhumen/zizo) || !zizo_ritual_available(user, type))
		return FALSE
	if(user.mind.has_antag_datum(/datum/antagonist/skeleton))
		return FALSE
	var/cultists = length(SSmapping.retainer.cultists)
	if(cultists < required_cultists())
		to_chat(user, span_warning("The circle needs [required_cultists()] sworn cultists."))
		return FALSE
	var/limit = get_dynamic_ritual_limit(src, cultists)
	if(limit > 0 && get_ritual_count(type) + (GLOB.zizo_ritual_reservations[type] || 0) >= limit)
		to_chat(user, span_warning("This rite's allotted work is done for this round."))
		return FALSE
	return validate(user, center)

/datum/ritual/proc/reserve_limit()
	var/limit = get_dynamic_ritual_limit(src, length(SSmapping.retainer.cultists))
	if(limit <= 0)
		return TRUE
	if(get_ritual_count(type) + (GLOB.zizo_ritual_reservations[type] || 0) >= limit)
		return FALSE
	GLOB.zizo_ritual_reservations[type] = (GLOB.zizo_ritual_reservations[type] || 0) + 1
	limit_reserved = TRUE
	return TRUE

/datum/ritual/proc/release_limit()
	if(!limit_reserved)
		return
	GLOB.zizo_ritual_reservations[type] = max(0, GLOB.zizo_ritual_reservations[type] - 1)
	limit_reserved = FALSE

/datum/ritual/proc/execute(mob/living/user, turf/center, obj/effect/decal/cleanable/sigil/circle)
	invoker = user
	if(!bind_ingredients(center) || !can_invoke(user, center))
		to_chat(user, span_warning("The offerings do not answer this rite."))
		return FALSE
	if(!prepare(user, center))
		return FALSE
	if(QDELETED(circle) || !validate_ingredients(center) || !can_invoke(user, center) || !reserve_limit())
		to_chat(user, span_warning("The circle has been disturbed. The rite fails."))
		return FALSE
	if(!invoke(user, center))
		return FALSE
	for(var/position in ingredients)
		var/atom/movable/ingredient = ingredients[position]
		if(QDELETED(ingredient) || ismob(ingredient) || (position == "center" && keep_center))
			continue
		consume_zizo_ritual_ingredient(ingredient)
	increment_ritual_count(type)
	release_limit()
	if(!QDELETED(user))
		user.playsound_local(user, 'modular_twilight_axis/zizo_cult/sound/invocation.ogg', 25)
		user.whisper("O'vena tesa...")
		if(success_message)
			to_chat(user, span_notice(success_message))
	if(crafting_effects)
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(1, 1, center)
		sparks.start()
		playsound(center, pick('sound/items/bsmith1.ogg', 'sound/items/bsmith2.ogg', 'sound/items/bsmith3.ogg', 'sound/items/bsmith4.ogg'), 100, FALSE)
	return TRUE

/datum/ritual/proc/invoke(mob/living/user, turf/center)
	for(var/output in outputs)
		new output(center)
	if(passive)
		var/mob/living/carbon/human/target = user
		target.mind.zizo_learned_rituals |= type
		for(var/spell_type in spells)
			if(!target.mind.has_spell(spell_type))
				target.mind.AddSpell(new spell_type)
		apply_passive(target)
	return TRUE

/datum/ritual/proc/apply_passive(mob/living/carbon/human/target)
	return

/datum/ritual/proc/prepare_spirit(mob/living/user, prompt)
	var/mob/living/carbon/human/target = get_target()
	spirit_client = target.client
	spirit_mind = target.mind
	if(target.client)
		return TRUE
	var/list/candidates = pollGhostCandidates(prompt, ROLE_LICH_SKELETON, null, null, 10 SECONDS, POLL_IGNORE_LICH_SKELETON)
	if(!length(candidates))
		to_chat(user, span_warning("No soul answers the Dark Lady's call."))
		return FALSE
	volunteer = pick(candidates)
	return !QDELETED(volunteer) && !!volunteer.client

/datum/ritual/proc/claim_spirit()
	var/mob/living/carbon/human/target = get_target()
	if(QDELETED(target) || target.mind != spirit_mind)
		return FALSE
	if(target.client)
		return target.client == spirit_client
	if(QDELETED(volunteer) || !volunteer.client)
		return FALSE
	if(istype(volunteer, /mob/dead/new_player))
		var/mob/dead/new_player/player = volunteer
		player.close_spawn_windows()
	target.key = volunteer.key
	return !!target.mind

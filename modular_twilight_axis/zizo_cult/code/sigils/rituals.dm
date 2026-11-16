/obj/effect/decal/cleanable/sigil/proc/find_ritual_ingredient(turf/target_turf, required_type)
	if(!target_turf || !required_type)
		return null
	for(var/atom/movable/found_ingredient in target_turf)
		if(found_ingredient.type == required_type)
			return found_ingredient
	for(var/atom/movable/found_ingredient in target_turf)
		if(istype(found_ingredient, required_type))
			return found_ingredient
	return null

/obj/effect/decal/cleanable/sigil/proc/find_ritual_ingredients(datum/ritual/ritual)
	var/list/requirements = ritual.ingredient_requirements()
	var/list/ingredients = list()
	for(var/position in requirements)
		var/required_type = requirements[position]
		if(!required_type)
			continue
		var/turf/target_turf = position == "center" ? get_turf(src) : get_step(src, text2num(position))
		var/atom/movable/ingredient = find_ritual_ingredient(target_turf, required_type)
		if(!ingredient)
			return null
		if(position != "center" || !ritual.keep_center)
			ingredients += ingredient
	return ingredients

/obj/effect/decal/cleanable/sigil/proc/consume_ritual_ingredient(atom/movable/ingredient)
	if(!ingredient || QDELETED(ingredient) || ismob(ingredient))
		return
	qdel(ingredient)

/obj/effect/decal/cleanable/sigil/proc/show_ritual_tgui(mob/living/user)
	if(!user.client)
		return

	var/list/categories = list(
		"Servantry" = /datum/ritual/servantry,
		"Transmutation" = /datum/ritual/transmutation,
		"Fleshcrafting" = /datum/ritual/fleshcrafting,
		"Weaponry" = /datum/ritual/weaponary
	)

	if(GLOB.zizo_cult_aspect)
		var/list/aspect_schools = zizo_aspect_schools()
		categories[GLOB.zizo_cult_aspect] = aspect_schools[GLOB.zizo_cult_aspect]

	var/chosen_category = tgui_input_list(user, "Choose Ritual Category:", "Ritual Categories", categories)
	if(!chosen_category || !user.Adjacent(src))
		return

	var/category_type = categories[chosen_category]
	var/list/ritual_categories = subtypesof(category_type)
	var/list/available_rituals = list()

	for(var/datum/ritual/ritual_type as anything in ritual_categories)
		if(!zizo_ritual_available(user, ritual_type))
			continue

		var/ritual_name = initial(ritual_type.name)
		var/is_cultist_only = initial(ritual_type.is_cultist_ritual)

		if(is_cultist_only && !(is_zizocultist(user.mind) || is_zizolackey(user.mind)))
			continue

		available_rituals[ritual_name] = ritual_type

	if(!length(available_rituals))
		to_chat(user, span_warning("No available rituals in this category."))
		return

	var/chosen_ritual_name = tgui_input_list(user, "Choose Ritual:", "Rituals - [chosen_category]", available_rituals)
	if(!chosen_ritual_name || !user.Adjacent(src))
		return

	perform_ritual(user, available_rituals[chosen_ritual_name])

/obj/effect/decal/cleanable/sigil/proc/perform_ritual(mob/living/user, ritual_type)
	if(ritual_in_progress || !user.Adjacent(src) || user.incapacitated() || !istype(user.patron, /datum/patron/inhumen/zizo) || !zizo_ritual_available(user, ritual_type))
		return

	var/datum/ritual/ritual = new ritual_type()
	var/chosen_ritual_name = ritual.name
	var/current_cultists = length(SSmapping.retainer.cultists)

	var/required_cultists = ritual.cultist_number
	if(istype(ritual, /datum/ritual/fleshcrafting/ascend))
		required_cultists = SSmapping.retainer.get_cult_ascension_required_cultists()

		if(current_cultists < required_cultists)
			to_chat(user, span_danger("This ritual requires at least [required_cultists] cultists, but there are only [current_cultists]. You need [required_cultists - current_cultists] more cultists."))
			return

	else if(required_cultists > 0)
		if(current_cultists < required_cultists)
			to_chat(user, span_danger("This ritual requires at least [required_cultists] cultists, but there are only [current_cultists]. You need [required_cultists - current_cultists] more cultists."))
			return

	var/dynamic_limit = get_dynamic_ritual_limit(ritual, current_cultists)

	if(dynamic_limit > 0)
		var/current_count = get_ritual_count(chosen_ritual_name)
		if(current_count >= dynamic_limit)
			if(ritual.number_cultist_for_add_limit > 0)
				var/needed_cultists_for_more = ritual.number_cultist_for_add_limit
				var/current_extra_cultists = max(0, current_cultists - required_cultists)
				var/needed_for_next = needed_cultists_for_more - (current_extra_cultists % needed_cultists_for_more)

				to_chat(user, span_danger("This ritual can only be performed [dynamic_limit] times, and it has already been performed [current_count] times. You need [needed_for_next] more cultists to perform it again."))
			else
				to_chat(user, span_danger("This ritual can only be performed [dynamic_limit] times, and it has already been performed [current_count] times."))
			return

	var/list/ingredients_to_consume = find_ritual_ingredients(ritual)
	if(isnull(ingredients_to_consume))
		to_chat(user, span_danger("The ritual is missing a required offering."))
		user.electrocute_act(10, src)
		qdel(ritual)
		return

	var/turf/center = get_turf(src)
	ritual_in_progress = TRUE
	for(var/atom/movable/ingredient as anything in ingredients_to_consume)
		consume_ritual_ingredient(ingredient)

	user.playsound_local(user, 'modular_twilight_axis/zizo_cult/sound/invocation.ogg', 25)
	user.whisper("O'vena tesa...")

	increment_ritual_count(chosen_ritual_name)
	ritual.invoke(user, center)
	if(!QDELETED(src))
		ritual_in_progress = FALSE

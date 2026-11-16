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

	var/list/categories = list()
	for(var/ritual_name in GLOB.ritualslist)
		var/datum/ritual/ritual_type = GLOB.ritualslist[ritual_name]
		if(zizo_ritual_available(user, ritual_type))
			categories |= initial(ritual_type.book_category)

	var/chosen_category = tgui_input_list(user, "Choose Ritual Category:", "Ritual Categories", categories)
	if(!chosen_category || !user.Adjacent(src))
		return

	var/list/available_rituals = list()
	for(var/ritual_name in GLOB.ritualslist)
		var/datum/ritual/ritual_type = GLOB.ritualslist[ritual_name]
		if(initial(ritual_type.book_category) == chosen_category && zizo_ritual_available(user, ritual_type))
			available_rituals[ritual_name] = ritual_type

	if(!length(available_rituals))
		to_chat(user, span_warning("No available rituals in this category."))
		return

	var/chosen_ritual_name = tgui_input_list(user, "Choose Ritual:", "Rituals - [chosen_category]", available_rituals)
	if(!chosen_ritual_name || !user.Adjacent(src))
		return

	perform_ritual(user, available_rituals[chosen_ritual_name])

/obj/effect/decal/cleanable/sigil/proc/perform_ritual(mob/living/user, ritual_type)
	if(ritual_in_progress || !zizo_ritual_available(user, ritual_type))
		return
	var/datum/ritual/ritual = new ritual_type()
	var/turf/center = get_turf(src)
	if(!ritual.can_invoke(user, center) || isnull(find_ritual_ingredients(ritual)))
		to_chat(user, span_warning("The ritual requirements are not met."))
		qdel(ritual)
		return
	ritual_in_progress = TRUE
	if(!ritual.prepare(user, center))
		if(!QDELETED(src))
			ritual_in_progress = FALSE
		qdel(ritual)
		return
	if(QDELETED(src))
		qdel(ritual)
		return
	var/list/ingredients = find_ritual_ingredients(ritual)
	if(isnull(ingredients) || !ritual.can_invoke(user, center))
		ritual_in_progress = FALSE
		qdel(ritual)
		return
	for(var/atom/movable/ingredient as anything in ingredients)
		consume_ritual_ingredient(ingredient)
	user.playsound_local(user, 'modular_twilight_axis/zizo_cult/sound/invocation.ogg', 25)
	user.whisper("O'vena tesa...")
	increment_ritual_count(ritual.name)
	try
		ritual.invoke(user, center)
	catch(var/exception/error)
		if(!QDELETED(src))
			ritual_in_progress = FALSE
		throw error
	if(!QDELETED(src))
		ritual_in_progress = FALSE

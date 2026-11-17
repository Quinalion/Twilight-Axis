// TA EDIT START
/obj/effect/decal/cleanable/sigil/proc/find_ritual_ingredient(turf/place, required_type)
	return find_zizo_ritual_ingredient(place, required_type)

/obj/effect/decal/cleanable/sigil/proc/consume_ritual_ingredient(atom/movable/ingredient)
	consume_zizo_ritual_ingredient(ingredient)

/obj/effect/decal/cleanable/sigil/proc/show_ritual_tgui(mob/living/user)
	if(!user.client)
		return
	var/list/categories = list()
	for(var/ritual_name in GLOB.ritualslist)
		var/datum/ritual/ritual_type = GLOB.ritualslist[ritual_name]
		if(zizo_ritual_available(user, ritual_type))
			categories |= initial(ritual_type.book_category)
	var/chosen_category = tgui_input_list(user, "Choose a category.", "Cult Rituals", categories)
	if(!chosen_category || QDELETED(src) || !user.Adjacent(src))
		return
	var/list/available_rituals = list()
	for(var/ritual_name in GLOB.ritualslist)
		var/datum/ritual/ritual_type = GLOB.ritualslist[ritual_name]
		if(initial(ritual_type.book_category) == chosen_category && zizo_ritual_available(user, ritual_type))
			available_rituals[ritual_name] = ritual_type
	if(!length(available_rituals))
		return
	var/chosen_ritual = tgui_input_list(user, "Choose a rite.", chosen_category, available_rituals)
	if(!chosen_ritual || QDELETED(src) || !user.Adjacent(src))
		return
	perform_ritual(user, available_rituals[chosen_ritual])

/obj/effect/decal/cleanable/sigil/proc/perform_ritual(mob/living/user, ritual_type)
	if(ritual_in_progress || !zizo_ritual_available(user, ritual_type))
		return FALSE
	ritual_in_progress = TRUE
	var/datum/ritual/ritual = new ritual_type
	var/success = FALSE
	var/exception/ritual_error
	try
		success = ritual.execute(user, get_turf(src), src)
	catch(var/exception/error)
		ritual_error = error
	qdel(ritual)
	if(!QDELETED(src))
		ritual_in_progress = FALSE
	if(ritual_error)
		throw ritual_error
	return success
// TA EDIT END

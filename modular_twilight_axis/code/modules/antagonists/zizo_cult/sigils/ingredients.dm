// TA EDIT - Sigil ingredients
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

/obj/effect/decal/cleanable/sigil/proc/consume_ritual_ingredient(atom/movable/ingredient)
	if(!ingredient || QDELETED(ingredient) || ismob(ingredient))
		return
	qdel(ingredient)

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


/proc/is_zizo(mob/M)
	return !!M?.mind?.has_antag_datum(/datum/antagonist/zizocultist)

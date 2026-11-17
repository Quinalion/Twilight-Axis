/proc/build_zizo_rituals()
	. = list()
	for(var/datum/ritual/ritual as anything in subtypesof(/datum/ritual))
		if(!is_abstract(ritual))
			.[initial(ritual.name)] = ritual

/proc/get_ritual_count(ritual_type)
	return GLOB.ritual_counters[ritual_type] || 0

/proc/increment_ritual_count(ritual_type)
	GLOB.ritual_counters[ritual_type] = get_ritual_count(ritual_type) + 1

/proc/get_dynamic_ritual_limit(datum/ritual/ritual, current_cultists)
	if(ritual.number_cultist_for_add_limit <= 0)
		return ritual.ritual_limit
	var/extra_cultists = max(0, current_cultists - ritual.required_cultists())
	return ritual.ritual_limit + round(extra_cultists / ritual.number_cultist_for_add_limit)

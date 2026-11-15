/proc/build_zizo_rituals()
	. = list()
	for(var/datum/ritual/ritual as anything in subtypesof(/datum/ritual))
		if(is_abstract(ritual))
			continue
		.[initial(ritual.name)] = ritual

/proc/get_ritual_count(ritual_name)
	if(!GLOB.ritual_counters[ritual_name])
		GLOB.ritual_counters[ritual_name] = 0
	return GLOB.ritual_counters[ritual_name]

/proc/increment_ritual_count(ritual_name)
	if(!GLOB.ritual_counters[ritual_name])
		GLOB.ritual_counters[ritual_name] = 0
	GLOB.ritual_counters[ritual_name]++

/proc/get_dynamic_ritual_limit(datum/ritual/ritual, current_cultists)
	var/base_limit = ritual.ritual_limit
	var/cultists_per_additional_limit = ritual.number_cultist_for_add_limit

	if(cultists_per_additional_limit <= 0)
		return base_limit

	var/additional_limit = 0
	if(current_cultists > ritual.cultist_number)
		var/extra_cultists = current_cultists - ritual.cultist_number
		additional_limit = round(extra_cultists / cultists_per_additional_limit)

	return base_limit + additional_limit

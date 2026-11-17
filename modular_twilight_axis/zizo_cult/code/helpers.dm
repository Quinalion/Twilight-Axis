// TA EDIT START
/proc/find_zizo_ritual_ingredient(turf/place, required_type)
	for(var/atom/movable/ingredient in place)
		if(ingredient.type == required_type)
			return ingredient
	for(var/atom/movable/ingredient in place)
		if(istype(ingredient, required_type))
			return ingredient

/proc/consume_zizo_ritual_ingredient(atom/movable/ingredient)
	if(!QDELETED(ingredient) && !ismob(ingredient))
		qdel(ingredient)

/proc/psydont(mob/living/carbon/human/target)
	for(var/obj/item/clothing/neck/roguetown/psicross/silver/cross in target.held_items + target.get_equipped_items(TRUE))
		return TRUE
	return FALSE

/proc/is_zizo(mob/target)
	return !!target?.mind?.has_antag_datum(/datum/antagonist/zizocultist)

/proc/is_zizo_cult_member(mob/target)
	return is_zizo(target) || !!target?.mind?.zizo_master

/proc/get_zizo_role_title(mob/living/carbon/human/target)
	var/role = target.mind?.assigned_role
	if(istext(role))
		return role
	if(istype(role, /datum/job))
		var/datum/job/job = role
		return job.title
	return target.job

/proc/get_zizo_ascension_sacrifice()
	RETURN_TYPE(/mob/living/carbon/human)
	var/list/priority_roles = list("Bishop", "Ruler", "Hand", "Prince", "Marshal", "Court Magician", "Knight Captain", "Steward")
	for(var/role in priority_roles)
		if(role == "Ruler")
			var/mob/living/carbon/human/ruler = SSticker.rulermob
			if(istype(ruler) && !QDELETED(ruler) && ruler.stat != DEAD)
				return ruler
			continue
		for(var/mob/living/carbon/human/target in GLOB.human_list)
			var/title = get_zizo_role_title(target)
			if(target.stat != DEAD && (title == role || (role == "Prince" && title == "Princess")))
				return target

/proc/get_zizo_cult_minds()
	var/list/minds = SSmapping.retainer.cultists.Copy()
	for(var/datum/mind/mind as anything in get_minds())
		if(mind.zizo_master)
			minds |= mind
	return minds

/proc/drain_zizo_ritual_lux(mob/living/carbon/human/target, greater = FALSE)
	target.apply_status_effect(greater ? /datum/status_effect/debuff/devitalised/greater : /datum/status_effect/debuff/devitalised)
	target.Stun(3 SECONDS)
	target.Knockdown(3 SECONDS)
	target.Sleeping(6 SECONDS)
// TA EDIT END

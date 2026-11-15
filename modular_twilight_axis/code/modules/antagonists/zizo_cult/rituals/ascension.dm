/datum/ritual/fleshcrafting/ascend
	name = "!ВОЗВЫШЕНИЕ!"
	desk = "ЗАКОНЧИ ЭТО. ДАВАЙ!! РАДИ ЗИЗО!!!"
	center_requirement = /mob/living/carbon/human
	n_req = /mob/living/carbon/human
	center_book = "Лидер"
	north_book = "Цель возвышения"

	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/ascend/invoke(mob/living/user, turf/center)

	var/required_cultists = SSmapping.retainer.get_cult_ascension_required_cultists()

	var/current_cultists = length(SSmapping.retainer.cultists)

	if(current_cultists < required_cultists)
		to_chat(user, span_danger("This ritual requires at least [required_cultists] cultists, but there are only [current_cultists]. You need [required_cultists - current_cultists] more cultists."))
		return

	var/mob/living/carbon/human/cultist = locate() in center.contents
	if(!cultist || cultist != user)
		return
	if(!is_zizocultist(cultist.mind))
		return

	var/mob/living/carbon/human/sacrifice_target = null
	var/target_role = null
	var/obj/item/clothing/head/roguetown/crown/crown_target = null

	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.stat == DEAD)
			continue
		var/role_title
		if(H.mind && H.mind.assigned_role)
			if(istext(H.mind.assigned_role))
				role_title = H.mind.assigned_role
			else if(istype(H.mind.assigned_role))
				role_title = H.mind.assigned_role.title
			else
				role_title = null
		else
			role_title = null
		if(role_title == "Bishop")
			sacrifice_target = H
			target_role = "Bishop"
			break

	if(!sacrifice_target)
		if(SSticker.rulermob && istype(SSticker.rulermob, /mob/living/carbon/human))
			var/mob/living/carbon/human/ruler = SSticker.rulermob
			if(ruler.stat != DEAD)
				sacrifice_target = ruler
				target_role = "Ruler"

	if(!sacrifice_target)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.stat == DEAD)
				continue
			var/role_title
			if(H.mind && H.mind.assigned_role)
				if(istext(H.mind.assigned_role))
					role_title = H.mind.assigned_role
				else if(istype(H.mind.assigned_role))
					role_title = H.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Hand")
				sacrifice_target = H
				target_role = "Hand"
				break

	if(!sacrifice_target)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.stat == DEAD)
				continue
			var/role_title
			if(H.mind && H.mind.assigned_role)
				if(istext(H.mind.assigned_role))
					role_title = H.mind.assigned_role
				else if(istype(H.mind.assigned_role))
					role_title = H.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Prince" || role_title == "Princess")
				sacrifice_target = H
				target_role = role_title
				break

	if(!sacrifice_target)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.stat == DEAD)
				continue
			var/role_title
			if(H.mind && H.mind.assigned_role)
				if(istext(H.mind.assigned_role))
					role_title = H.mind.assigned_role
				else if(istype(H.mind.assigned_role))
					role_title = H.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Marshal")
				sacrifice_target = H
				target_role = "Marshal"
				break

	if(!sacrifice_target)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.stat == DEAD)
				continue
			var/role_title
			if(H.mind && H.mind.assigned_role)
				if(istext(H.mind.assigned_role))
					role_title = H.mind.assigned_role
				else if(istype(H.mind.assigned_role))
					role_title = H.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Court Magician")
				sacrifice_target = H
				target_role = "Court Magician"
				break

	if(!sacrifice_target)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.stat == DEAD)
				continue
			var/role_title
			if(H.mind && H.mind.assigned_role)
				if(istext(H.mind.assigned_role))
					role_title = H.mind.assigned_role
				else if(istype(H.mind.assigned_role))
					role_title = H.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Knight Captain")
				sacrifice_target = H
				target_role = "Knight Captain"
				break

	if(!sacrifice_target)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.stat == DEAD)
				continue
			var/role_title
			if(H.mind && H.mind.assigned_role)
				if(istext(H.mind.assigned_role))
					role_title = H.mind.assigned_role
				else if(istype(H.mind.assigned_role))
					role_title = H.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Steward")
				sacrifice_target = H
				target_role = "Steward"
				break

	if(!sacrifice_target)
		for(var/obj/item/clothing/head/roguetown/crown/C in get_step(center, NORTH))
			crown_target = C
			target_role = "Crown"
			break

	if(!sacrifice_target && !crown_target)
		to_chat(user, span_danger("No suitable sacrifice found. Check ascension requirements."))
		return

	if(sacrifice_target)
		var/mob/living/carbon/human/RULER = locate() in get_step(center, NORTH)
		if(RULER != sacrifice_target)
			to_chat(user, span_danger("[sacrifice_target.real_name] ([target_role]) must stand on the northern cell of the sigil."))
			return

		if(sacrifice_target.stat == DEAD)
			to_chat(user, span_danger("[sacrifice_target.real_name] ([target_role]) must be alive for this ritual."))
			return

		sacrifice_target.gib()
		to_chat(user, span_notice("You have sacrificed [sacrifice_target.real_name], the [target_role]!"))
	else if(crown_target)
		qdel(crown_target)
		to_chat(user, span_notice("You have sacrificed the Crown!"))

	SSmapping.retainer.cult_ascended = TRUE
	addomen(OMEN_ASCEND)
	to_chat(cultist, span_userdanger("I HAVE DONE IT! I HAVE REACHED A HIGHER FORM! ZIZO SMILES UPON ME WITH MALICE IN HER EYES TOWARD THE ONES WHO LACK KNOWLEDGE AND UNDERSTANDING!"))
	var/mob/living/trl = new /mob/living/simple_animal/hostile/retaliate/blood/ascended(center)
	cultist.mind?.transfer_to(trl)
	cultist.gib()
	priority_announce("The sky blackens, a dark day for Psydonia.", "Ascension", 'sound/misc/zizo.ogg')
	for(var/mob/living/carbon/human/V in GLOB.human_list)
		if(V.mind in SSmapping.retainer.cultists)
			V.add_stress(/datum/stressevent/lovezizo)
		else
			V.add_stress(/datum/stressevent/hatezizo)
	SSvote.started_time = world.time - CONFIG_GET(number/vote_delay) - 10
	SSvote.initiate_vote("endround", "AHAHAHAHAHAHAHAHAHHA")

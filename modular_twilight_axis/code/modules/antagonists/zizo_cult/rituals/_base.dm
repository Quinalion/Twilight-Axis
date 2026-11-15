/datum/ritual
	abstract_type = /datum/ritual
	var/name = "DVRK AND EVIL RITVAL"
	var/desc
	var/center_requirement
	var/n_req
	var/e_req
	var/s_req
	var/w_req
	var/is_cultist_ritual = FALSE
	var/research_cost = 5
	var/needs_aspect
	var/keep_center = FALSE
	var/center_desc
	var/n_desc
	var/e_desc
	var/s_desc
	var/w_desc
	var/passive = FALSE
	var/lesser = FALSE
	var/research_item
	var/icon_type
	var/node_state
	var/list/spells = list()

/datum/ritual/proc/invoke(mob/living/user, turf/center)
	return

/datum/ritual/proc/apply_passive(mob/living/carbon/human/H)
	return

/datum/ritual/proc/req_label(req, desc)
	if(desc)
		return desc
	if(req == /mob/living/carbon/human)
		return "a humanoid"
	var/atom/A = req
	return initial(A.name)

/datum/ritual/proc/hugbox()
	var/list/parts = list()
	if(center_requirement)
		parts += "Center - [req_label(center_requirement, center_desc)]"
	if(n_req)
		parts += "North - [req_label(n_req, n_desc)]"
	if(e_req)
		parts += "East - [req_label(e_req, e_desc)]"
	if(s_req)
		parts += "South - [req_label(s_req, s_desc)]"
	if(w_req)
		parts += "West - [req_label(w_req, w_desc)]"
	return jointext(parts, ", ")


/datum/ritual/strand
	abstract_type = /datum/ritual/strand
	needs_aspect = "STRAND"

/datum/ritual/pitch
	abstract_type = /datum/ritual/pitch
	needs_aspect = "PITCH"

/datum/ritual/toil
	abstract_type = /datum/ritual/toil
	needs_aspect = "TOIL"

/datum/ritual/bite
	abstract_type = /datum/ritual/bite
	needs_aspect = "BITE"

/datum/ritual/rot
	abstract_type = /datum/ritual/rot
	needs_aspect = "ROT"

/datum/ritual/noise
	abstract_type = /datum/ritual/noise
	needs_aspect = "NOISE"

/datum/ritual/blood
	abstract_type = /datum/ritual/blood
	needs_aspect = "BLOOD"

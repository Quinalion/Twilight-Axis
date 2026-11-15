/datum/objective/zizo
	name = "ASCEND"
	explanation_text = "Ensure that a member of the cult ASCENDS. You can look at your research menu to familiarize myself with your rituals."
	team_explanation_text = "Ensure that a member of the cult ASCENDS. You can look at your research menu to familiarize myself with your rituals."
	triumph_count = 5

/datum/objective/zizo/check_completion()
	if(SSmapping.retainer.cult_ascended)
		return TRUE

/datum/zizogoal
	var/name = "Goal"
	var/desc = "How to do it!"
	var/reward = 2
	var/weight = 10
	var/complete = FALSE

/datum/zizogoal/worshipzizo
	name = "Worship Zizo"
	desc = "Worship Zizo in with three non-cultists in sight."

/datum/zizogoal/worshipzizo_church
	name = "Worship Zizo at Church"
	desc = "Worship Zizo inside of the Church."

/datum/zizogoal/drinklux
	name = "Drink Lux"
	desc = "Consume a globule of lux."
	reward = 3

/datum/zizogoal/robgrave
	name = "Grave Robbery"
	desc = "Dig up a marked grave inside the graveyard."

/datum/zizogoal/worshipzizo_garrison
	name = "Worship Zizo at Garrison"
	desc = "Worship Zizo inside of the Garrison."

/datum/zizogoal/worshipzizo_warden
	name = "Worship Zizo at Warden Fort"
	desc = "Worship Zizo inside of the Warden Fort."

/datum/zizogoal/profaneshrine_church
	name = "Create Shrine in Church"
	desc = "Use the 'Raise Profane Shrine' rite inside of the church."

/datum/zizogoal/profaneshrine_tavern
	name = "Create Shrine in Tavern"
	desc = "Use the 'Raise Profane Shrine' rite inside of the tavern."

/datum/zizogoal/profaneshrine_bath
	name = "Create Shrine in Bathhouse"
	desc = "Use the 'Raise Profane Shrine' rite inside of the bathhouse."

/datum/zizogoal/profaneshrine_academy
	name = "Create Shrine in Academy"
	desc = "Use the 'Raise Profane Shrine' rite inside of the academy."

/datum/zizogoal/profaneshrine_graveyard
	name = "Create Shrine in Graveyard"
	desc = "Use the 'Raise Profane Shrine' rite inside of the church graveyard."

/proc/complete_zgoal(mob/living/carbon/human/user, goal_type)
	for(var/datum/zizogoal/gl in user.zizo_goals)
		if(gl.type != goal_type)
			continue
		if(gl.complete)
			continue
		gl.complete = TRUE
		user.zizo_goals_complete |= gl.type
		zizo_award(user, gl.reward)
		return TRUE

/proc/reroll_goals(mob/living/carbon/human/user)
	user.zizo_goals = list()
	var/list/weighted = list()
	for(var/item in GLOB.zizo_goals)
		if(item in user.zizo_goals_complete)
			continue
		weighted[item] = initial(item:weight)
	for(var/i in 1 to 3)
		if(!weighted.len)
			break
		var/chosen_type = pickweight(weighted)
		weighted -= chosen_type
		user.zizo_goals += new chosen_type()



/proc/is_zizo_graveyard(atom/location)
	var/area/rogue/A = get_area(location)
	if(!istype(A) || !A.town_area)
		return FALSE
	for(var/obj/structure/gravemarker/G in range(7, location))
		return TRUE
	return FALSE

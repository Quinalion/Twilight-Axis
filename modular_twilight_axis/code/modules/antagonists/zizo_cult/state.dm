// TA EDIT - Cult state
/datum/mind
	var/list/zizo_researched = list(
		/datum/ritual/servantry/convert, /datum/ritual/servantry/sacrifice,
		/datum/ritual/servantry/heartache, /datum/ritual/servantry/gutted,
		/datum/ritual/transmutation/cross, /datum/ritual/transmutation/criminalstool,
		/datum/ritual/transmutation/invademind, /datum/ritual/transmutation/summonoutfit,
		/datum/ritual/transmutation/raiseshrine, /datum/ritual/servantry/guidance,
		/datum/ritual/servantry/sleepcurse, /datum/ritual/transmutation/silencerleech,
		/datum/ritual/transmutation/propaganda, /datum/ritual/servantry/misfortune,
	)
	var/zizo_points = 0
	var/list/zizo_setup_stats
	var/zizo_setup_trait
/mob/living/carbon/human
	var/list/deadites_controlled
	var/purity = FALSE
	var/zizo_goals_cd = 0
	var/list/zizo_goals = list()
	var/list/zizo_goals_complete = list()
/mob/living
	var/aspect

/datum/antag_retainer
	var/list/cultists = list()
	var/cult_ascended = FALSE

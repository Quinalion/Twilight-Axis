GLOBAL_LIST_INIT(ritualslist, build_zizo_rituals())

/proc/build_zizo_rituals()
	. = list()
	for(var/datum/ritual/ritual as anything in subtypesof(/datum/ritual))
		if(initial(ritual.abstract_type) == ritual)
			continue
		.[ritual.name] = new ritual


GLOBAL_LIST_EMPTY(zizo_portals)
GLOBAL_VAR_INIT(zizo_portal_count, 0)
GLOBAL_LIST_EMPTY(gate_targets)
GLOBAL_LIST_EMPTY(cult_robes)
GLOBAL_LIST_EMPTY(zizo_reality_rends)
GLOBAL_LIST_EMPTY(zizo_fuges)
GLOBAL_LIST_EMPTY(zizo_summoned)
GLOBAL_LIST_EMPTY(zizo_marks)

GLOBAL_LIST_INIT(zizo_researchable, list(
	/datum/ritual/servantry/convert, /datum/ritual/servantry/sacrifice,
	/datum/ritual/servantry/heartache,
	/datum/ritual/servantry/gutted, /datum/ritual/transmutation/cross,
	/datum/ritual/transmutation/criminalstool, /datum/ritual/transmutation/invademind,
	/datum/ritual/transmutation/summonoutfit, /datum/ritual/servantry/aspect,
	/datum/ritual/transmutation/allseeingeye,
	/datum/ritual/fleshcrafting/bunnylegs, /datum/ritual/fleshcrafting/fleshmend,
	/datum/ritual/fleshcrafting/fleshmend/greater, /datum/ritual/fleshcrafting/darkeyes,
	/datum/ritual/fleshcrafting/nopain, /datum/ritual/fleshcrafting/immortality,
	/datum/ritual/transmutation/summonarmor, /datum/ritual/transmutation/summonweapon, /datum/ritual/transmutation/hiddenward, /datum/ritual/transmutation/lessernecromancy, /datum/ritual/fleshcrafting/lesserrituos,
	/datum/ritual/transmutation/summonpylon, /datum/ritual/transmutation/summonraver,
	/datum/ritual/transmutation/propaganda, /datum/ritual/servantry/sleepcurse, /datum/ritual/servantry/tongues, /datum/ritual/servantry/exhaustion, /datum/ritual/servantry/knock, /datum/ritual/servantry/misfortune,
	/datum/ritual/transmutation/silencerleech, /datum/ritual/servantry/darksunmark,
	/datum/ritual/strand/dream_jaunt, /datum/ritual/strand/strandsend,
	/datum/ritual/strand/strandrecall, /datum/ritual/toil/progress,
	/datum/ritual/toil/summonysis, /datum/ritual/toil/fulmenor,
	/datum/ritual/bite/necromancy, /datum/ritual/bite/resurrection,
	/datum/ritual/bite/thanatophobia,
	/datum/ritual/rot/transfuse, /datum/ritual/rot/blight,
	/datum/ritual/rot/plague, /datum/ritual/noise/thermalvis,
	/datum/ritual/noise/forgettongue, /datum/ritual/servantry/witchery,
	/datum/ritual/pitch/fireresist, /datum/ritual/pitch/shadowform,
	/datum/ritual/pitch/lightcurse, /datum/ritual/blood/transfuse,
	/datum/ritual/blood/bloodsnare, /datum/ritual/blood/bloodbond,
	/datum/ritual/transmutation/raiseshrine, /datum/ritual/servantry/guidance,
	))

GLOBAL_LIST_INIT(zizo_goals, list(
	/datum/zizogoal/worshipzizo, /datum/zizogoal/worshipzizo_church,
	/datum/zizogoal/worshipzizo_garrison, /datum/zizogoal/worshipzizo_warden, /datum/zizogoal/robgrave,
	/datum/zizogoal/drinklux,
	/datum/zizogoal/profaneshrine_church, /datum/zizogoal/profaneshrine_tavern,
	/datum/zizogoal/profaneshrine_bath, /datum/zizogoal/profaneshrine_academy,
	/datum/zizogoal/profaneshrine_graveyard,
	))

GLOBAL_LIST_EMPTY(zizo_bestowed)
GLOBAL_DATUM_INIT(zizo_research, /datum/zizo_research, new)

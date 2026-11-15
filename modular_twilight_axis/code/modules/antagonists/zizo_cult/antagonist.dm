/datum/antagonist/zizocultist
	name = "Zizoid Cultist"
	roundend_category = "Zizoid Cultists"
	antagpanel_category = "Zizoid Cult"
	rogue_enabled = TRUE
	storyteller_antag_flags = STORYTELLER_ANTAG_VILLAIN | STORYTELLER_ANTAG_ROUNDSTART
	storyteller_slot_default_cap = 5
	job_rank = ROLE_CULT
	antag_hud_type = ANTAG_HUD_ZIZOID
	antag_hud_name = "zizoid"
	confess_lines = list(
		"DEATH TO THE TEN!",
		"PRAISE ZIZO!",
		"I AM THE FUTURE!",
		"NO GODS! ONLY MASTERS!",
	)
	var/islesser = TRUE
	var/start_budget = 20
	var/start_points = 0
	innate_traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_CABAL,
		TRAIT_HERESIARCH,
	)

/datum/antagonist/zizocultist/roundstart
	start_budget = 26
	start_points = 5

/datum/antagonist/zizocultist/leader
	name = "Zizoid Cultist"
	islesser = FALSE
	innate_traits = list(
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_STEELHEARTED,
		TRAIT_NOMOOD,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_CABAL,
		TRAIT_HERESIARCH,
	)

/datum/antagonist/zizocultist/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	for(var/trait in innate_traits)
		ADD_TRAIT(M, trait, "zizocultist")
	if(has_world_trait(/datum/world_trait/zizo_bite))
		ADD_TRAIT(M, TRAIT_RESISTCOLD, "zizocultist")
	if(has_world_trait(/datum/world_trait/zizo_rot))
		ADD_TRAIT(M, TRAIT_NOHUNGER, "zizocultist")
	M.apply_status_effect(/datum/status_effect/buff/zizo_gate_sense)
	M.faction |= "zizo_cult"
	if(ishuman(M))
		add_verb(M, list(/mob/living/carbon/human/proc/communicate, /mob/living/carbon/human/proc/zizo_targets_list))

/datum/antagonist/zizocultist/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	for(var/trait in innate_traits)
		REMOVE_TRAIT(M, trait, "zizocultist")
	REMOVE_TRAIT(M, TRAIT_RESISTCOLD, "zizocultist")
	REMOVE_TRAIT(M, TRAIT_NOHUNGER, "zizocultist")
	M.remove_status_effect(/datum/status_effect/buff/zizo_gate_sense)
	M.remove_status_effect(/datum/status_effect/buff/zizo_gate_pull)
	M.faction -= "zizo_cult"
	remove_verb(M, list(/mob/living/carbon/human/proc/communicate, /mob/living/carbon/human/proc/zizo_targets_list))

/datum/antagonist/zizocultist/on_gain()
	. = ..()
	var/mob/living/carbon/human/H = owner.current
	SSmapping.retainer.cultists |= owner
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(refresh_zizo_marks)), 15 SECONDS, TIMER_UNIQUE | TIMER_LOOP)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(zizo_roll_start)), 1 MINUTES, TIMER_UNIQUE)
	H.set_patron(/datum/patron/inhumen/zizo)
	H.cmode_music = 'modular_twilight_axis/sound/zizo_cult/music/cmode/antag/combat_cult.ogg'
	H.playsound_local(get_turf(H), 'sound/music/maniac.ogg', 80, FALSE, pressure_affected = FALSE)
	H.purity = FALSE

	H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_JOURNEYMAN)

	owner.special_role = ROLE_ZIZOIDCULTIST
	add_objective(/datum/objective/zizo)
	H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT)
	H.grant_language(/datum/language/undead)
	owner.zizo_points += start_points
	if(ishuman(H))
		INVOKE_ASYNC(src, PROC_REF(open_setup), H)
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current)
	greet()

/datum/antagonist/zizocultist/on_removal()
	SSmapping.retainer.cultists -= owner
	remove_antag_hud(antag_hud_type, owner.current)
	var/mob/living/carbon/human/H = owner?.current
	if(istype(H))
		for(var/key in owner.zizo_setup_stats)
			H.change_stat(key, -owner.zizo_setup_stats[key])
		if(owner.zizo_setup_trait)
			REMOVE_TRAIT(H, owner.zizo_setup_trait, "zizo_setup")
		for(var/datum/zizo_setup/S in GLOB.zizo_setups)
			if(S.user == H)
				qdel(S)
	owner.special_role = null
	owner.zizo_setup_stats = null
	owner.zizo_setup_trait = null
	return ..()

/datum/antagonist/zizocultist/greet()
	to_chat(owner, span_danger("I'm a cultist to the ALMIGHTY. They call it the UNSPEAKABLE. A new future begins."))
	owner.announce_objectives()

/datum/antagonist/zizocultist/leader/greet()
	to_chat(owner, span_danger("I'm a cultist to the ALMIGHTY. They call it the UNSPEAKABLE. I require LACKEYS to make my RITUALS easier. I SHALL ASCEND."))
	owner.announce_objectives()

/datum/antagonist/zizocultist/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	if(istype(examined_datum, /datum/antagonist/zizocultist/leader))
		return span_boldnotice("OUR LEADER!")
	if(istype(examined_datum, /datum/antagonist/zizocultist))
		return span_boldnotice("A cultist of ZIZO.")
	if(istype(examined_datum, /datum/antagonist/assassin))
		return span_boldnotice("A GRAGGAROID! A CULTIST OF GRAGGAR!")

/datum/antagonist/zizocultist/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.current == SSticker.rulermob)
			return FALSE
		if(new_owner.unconvertable)
			return FALSE

/datum/antagonist/zizocultist/proc/add_cultist(datum/mind/cult_mind)
	cult_mind.add_antag_datum(/datum/antagonist/zizocultist)

/datum/antagonist/zizocultist/proc/add_objective(datum/objective/O)
	objectives += new O


/datum/antagonist/zizocultist/proc/open_setup(mob/living/carbon/human/H)
	new /datum/zizo_setup(H, start_budget)

/datum/antagonist/zizocultist
	name = "Zizoid Lackey"
	roundend_category = "Zizoid Cultists"
	antagpanel_category = "Zizoid Cult"
	storyteller_antag_flags = STORYTELLER_ANTAG_VILLAIN | STORYTELLER_ANTAG_ROUNDSTART
	storyteller_slot_default_cap = 5
	job_rank = ROLE_CULT
	antag_hud_type = ANTAG_HUD_ZIZOID
	rogue_enabled = TRUE
	antag_hud_name = "zizoid_lackey"
	confess_lines = list(
		"DEATH TO THE TEN!",
		"PRAISE ZIZO!",
		"I AM THE FUTURE!",
		"NO GODS! ONLY MASTERS!",
	)
	var/islesser = TRUE
	var/change_stats = TRUE

	var/traits_cult = list(
		TRAIT_STEELHEARTED,
		TRAIT_VILLAIN,
		TRAIT_NOMOOD,
		TRAIT_BLOOD_RESISTANCE
	)
	var/traits_cult_leader = list(
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_STEELHEARTED,
		TRAIT_NOMOOD,
		TRAIT_VILLAIN,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAIN,
	)

/datum/antagonist/zizocultist/zizo_knight
	change_stats = FALSE
	name = "Zizoid's knight"

/datum/antagonist/zizocultist/leader
	name = "Zizoid Cultist"
	antag_hud_type = ANTAG_HUD_ZIZOID
	antag_hud_name = "zizoid"
	islesser = FALSE

/datum/antagonist/zizocultist/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	if(istype(examined_datum, /datum/antagonist/zizocultist/leader))
		return span_boldnotice("OUR LEADER!")
	if(istype(examined_datum, /datum/antagonist/zizocultist))
		return span_boldnotice("A lackey for the future.")
	if(istype(examined_datum, /datum/antagonist/assassin))
		return span_boldnotice("A GRAGGAROID! A CULTIST OF GRAGGAR!")

/datum/antagonist/zizocultist/on_gain()
	. = ..()
	var/mob/living/carbon/human/H = owner.current
	SSmapping.retainer.cultists |= owner
	H.set_patron(/datum/patron/inhumen/zizo)
	apply_zizo_aspect_traits(H)
	SSmapping.retainer.cultist_number += 1
	to_chat(H, span_userdanger("I'm a member of Ascension cult of zizo."))
	owner.announce_objectives()
	owner.special_role = "Zizoid Lackey"
	H.cmode_music = sound("sound/music/combat_cult.ogg")
	H.playsound_local(get_turf(H), 'sound/music/maniac.ogg', 80, FALSE, pressure_affected = FALSE)
	add_verb(H, /mob/living/carbon/human/proc/communicate)
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current)

	if(change_stats)
		H.change_stat(STATKEY_STR, 2)
		H.adjust_skillrank(/datum/skill/misc/reading, 3, 3, TRUE)

	if(islesser)
		for (var/trait in traits_cult)
			ADD_TRAIT(H, trait, "[type]")
		add_objective(/datum/objective/zizoserve)
		if(!change_stats)
			return
		H.adjust_skillrank(/datum/skill/combat/knives, 1)
		H.adjust_skillrank(/datum/skill/combat/swords, 1)
		H.adjust_skillrank(/datum/skill/combat/polearms, 1)
		H.change_stat(STATKEY_INT, -2)
		H.grant_language(/datum/language/undead)
		return

	add_objective(/datum/objective/zizo)
	owner.special_role = ROLE_ZIZOIDCULTIST
	if(!change_stats)
		return
	H.adjust_skillrank(/datum/skill/combat/knives, 2)
	H.adjust_skillrank(/datum/skill/combat/swords, 2)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2)
	H.adjust_skillrank(/datum/skill/misc/athletics, 2)
	H.change_stat(STATKEY_STR, 2)
	H.change_stat(STATKEY_PER, 2)
	H.change_stat(STATKEY_WIL, 1)
	H.change_stat(STATKEY_CON, 2)
	H.change_stat(STATKEY_SPD, 1)
	H.change_stat(STATKEY_INT, 1)
	H.grant_language(/datum/language/undead)
	add_verb(H, /mob/living/carbon/human/proc/release_minion)
	add_verb(H,/mob/living/carbon/human/proc/cultist_number)
	add_verb(H,/mob/living/carbon/human/proc/ascension_check)
	for (var/trait in traits_cult_leader)
		ADD_TRAIT(H, trait, "[type]")

/datum/antagonist/zizocultist/greet()
	to_chat(owner.current, span_userdanger("I'm a lackey to the LEADER. A new future begins."))
	owner.announce_objectives()

/datum/antagonist/zizocultist/leader/greet()
	to_chat(owner.current, span_userdanger("I'm a cultist to the ALMIGHTY. They call it the UNSPEAKABLE. I require LACKEYS to make my RITUALS easier. I SHALL ASCEND."))
	owner.announce_objectives()

/datum/antagonist/zizocultist/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.current == SSticker.rulermob)
			return FALSE
		if(new_owner.current.job in GLOB.church_positions)
			return FALSE
		if(new_owner.current.job in GLOB.inquisition_positions)
			return FALSE
		if(new_owner.unconvertable)
			return FALSE
		if(new_owner.current && HAS_TRAIT(new_owner.current, TRAIT_MINDSHIELD))
			return FALSE

/datum/antagonist/zizocultist/proc/add_cultist(datum/mind/cult_mind)
	if(is_zizocultist(cult_mind) || is_zizolackey(cult_mind))
		return FALSE
	var/datum/antagonist/zizocultist/new_lackey = new /datum/antagonist/zizocultist(cult_mind)

	cult_mind.add_antag_datum(new_lackey)

	return TRUE

/datum/antagonist/zizocultist/proc/add_objective(datum/objective/O)
	var/datum/objective/V = new O
	objectives += V

/datum/antagonist/zizocultist/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/zizocultist/roundend_report()
	var/traitorwin = TRUE

	to_chat(world, printplayer(owner))

	var/count = 0
	if(islesser)
		if(objectives.len)
			for(var/datum/objective/objective in objectives)
				objective.update_explanation_text()
				if(objective.check_completion())
					to_chat(owner, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='greentext'>TRIUMPH!</span>")
				else
					to_chat(owner, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='redtext'>Failure.</span>")
					traitorwin = FALSE
				count += objective.triumph_count
	else
		if(objectives.len)
			for(var/datum/objective/objective in objectives)
				objective.update_explanation_text()
				if(objective.check_completion())
					to_chat(world, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='greentext'>TRIUMPH!</span>")
				else
					to_chat(world, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='redtext'>Failure.</span>")
					traitorwin = FALSE
				count += objective.triumph_count

	var/special_role_text = lowertext(name)
	if(traitorwin)
		if(count)
			if(owner)
				owner.adjust_triumphs(count)
		to_chat(world, span_greentext(">The [special_role_text] has TRIUMPHED!"))
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/triumph.ogg', 100, FALSE, pressure_affected = FALSE)
	else
		to_chat(world, span_redtext("The [special_role_text] has FAILED!"))
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/fail.ogg', 100, FALSE, pressure_affected = FALSE)

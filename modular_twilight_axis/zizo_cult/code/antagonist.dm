// TA EDIT START
/datum/antagonist/zizocultist
	name = "Zizoid Lackey"
	roundend_category = "Zizoid Cultists"
	antagpanel_category = "Zizoid Cult"
	storyteller_antag_flags = STORYTELLER_ANTAG_VILLAIN | STORYTELLER_ANTAG_ROUNDSTART
	storyteller_slot_default_cap = 5
	job_rank = ROLE_CULT
	antag_hud_type = ANTAG_HUD_ZIZOID
	antag_hud_name = "zizoid_lackey"
	rogue_enabled = TRUE
	confess_lines = list("DEATH TO THE TEN!", "PRAISE ZIZO!", "DEATH IS THE LAST ENEMY!", "HER WORK SHALL ENDURE!")
	var/islesser = TRUE
	var/change_stats = TRUE
	var/previous_special_role
	var/triumphs_awarded = FALSE
	var/list/cult_traits = list(TRAIT_CABAL, TRAIT_STEELHEARTED, TRAIT_VILLAIN, TRAIT_NOMOOD, TRAIT_BLOOD_RESISTANCE)

/datum/antagonist/zizocultist/zizo_knight
	name = "Zizoid Knight"
	change_stats = FALSE

/datum/antagonist/zizocultist/leader
	name = "Zizoid Cultist"
	antag_hud_name = "zizoid"
	islesser = FALSE
	cult_traits = list(TRAIT_CABAL, TRAIT_DECEIVING_MEEKNESS, TRAIT_STEELHEARTED, TRAIT_NOMOOD, TRAIT_VILLAIN, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAIN)

/datum/antagonist/zizocultist/can_be_owned(datum/mind/new_owner)
	if(!new_owner || !..() || !ishuman(new_owner.current) || new_owner.has_antag_datum(/datum/antagonist/zizocultist))
		return FALSE
	var/mob/living/carbon/human/target = new_owner.current
	var/role_title = get_zizo_role_title(target)
	return target != SSticker.rulermob && !(role_title in GLOB.church_positions) && !(role_title in GLOB.inquisition_positions) && !new_owner.unconvertable && !HAS_TRAIT(target, TRAIT_MINDSHIELD)

/datum/antagonist/zizocultist/on_gain()
	previous_special_role = owner.special_role
	owner.special_role = islesser ? "Zizoid Lackey" : ROLE_ZIZOIDCULTIST
	SSmapping.retainer.cultists |= owner
	SSmapping.retainer.cultist_number = length(SSmapping.retainer.cultists)
	forge_objectives()
	. = ..()
	if(change_stats && ishuman(owner.current))
		apply_training(owner.current)
	if(!silent)
		greet()

/datum/antagonist/zizocultist/on_removal()
	SSmapping.retainer.cultists -= owner
	SSmapping.retainer.cultist_number = length(SSmapping.retainer.cultists)
	owner.special_role = previous_special_role
	return ..()

/datum/antagonist/zizocultist/proc/cult_verbs()
	. = list(/mob/living/carbon/human/proc/communicate)
	if(!islesser)
		. += list(/mob/living/carbon/human/proc/release_minion, /mob/living/carbon/human/proc/cultist_number, /mob/living/carbon/human/proc/ascension_check)

/datum/antagonist/zizocultist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/target = mob_override || owner.current
	if(!istype(target))
		return
	target.set_patron(/datum/patron/inhumen/zizo)
	apply_zizo_aspect_traits(target)
	if(target.cmode && target.client)
		SSdroning.play_combat_music('sound/music/combat_cult.ogg', target.client)
	for(var/trait in cult_traits)
		ADD_TRAIT(target, trait, REF(src))
	add_antag_hud(antag_hud_type, antag_hud_name, target)
	if(ishuman(target))
		add_verb(target, cult_verbs())
		target.grant_language(/datum/language/undead)
		if(change_stats)
			target.apply_status_effect(islesser ? /datum/status_effect/cult_lackey : /datum/status_effect/cult_leader)

/datum/antagonist/zizocultist/remove_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	if(istype(target))
		for(var/trait in cult_traits)
			REMOVE_TRAIT(target, trait, REF(src))
		REMOVE_TRAIT(target, TRAIT_RESISTCOLD, "zizo_aspect")
		remove_verb(target, cult_verbs())
		if(change_stats)
			target.remove_status_effect(islesser ? /datum/status_effect/cult_lackey : /datum/status_effect/cult_leader)
		remove_antag_hud(antag_hud_type, target)
	return ..()

/datum/antagonist/zizocultist/proc/apply_training(mob/living/carbon/human/target)
	target.adjust_skillrank(/datum/skill/misc/reading, 3, 3, TRUE)
	target.adjust_skillrank(/datum/skill/combat/knives, islesser ? 1 : 2)
	target.adjust_skillrank(/datum/skill/combat/swords, islesser ? 1 : 2)
	if(islesser)
		target.adjust_skillrank(/datum/skill/combat/polearms, 1)
	else
		target.adjust_skillrank(/datum/skill/combat/wrestling, 2)
		target.adjust_skillrank(/datum/skill/misc/athletics, 2)

/datum/antagonist/zizocultist/proc/forge_objectives()
	var/objective_type = islesser ? /datum/objective/zizoserve : /datum/objective/zizo
	if(locate(objective_type) in objectives)
		return
	var/datum/objective/objective = new objective_type
	objective.owner = owner
	objectives += objective

/datum/antagonist/zizocultist/greet()
	to_chat(owner.current, span_userdanger("The Dark Lady has shown me a world beyond death. I serve Her cult and its ascension."))
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/maniac.ogg', 80, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/zizocultist/leader/greet()
	to_chat(owner.current, span_userdanger("Death is the last enemy. I shall gather the faithful, complete Her work and ascend."))
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/maniac.ogg', 80, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/zizocultist/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	if(istype(examined_datum, /datum/antagonist/zizocultist/leader))
		return span_boldnotice("The bearer of Her work.")
	if(istype(examined_datum, /datum/antagonist/zizocultist))
		return span_boldnotice("A fellow initiate of the Dark Lady.")
	if(istype(examined_datum, /datum/antagonist/assassin))
		return span_boldnotice("A servant of Graggar.")

/datum/antagonist/zizocultist/proc/add_cultist(datum/mind/cult_mind)
	return !!cult_mind?.add_antag_datum(/datum/antagonist/zizocultist)

/datum/antagonist/zizocultist/roundend_report()
	var/success = TRUE
	var/reward = 0
	for(var/datum/objective/objective as anything in objectives)
		if(!objective.check_completion())
			success = FALSE
		reward += objective.triumph_count
	if(success && !triumphs_awarded)
		owner.adjust_triumphs(reward)
		triumphs_awarded = TRUE
	return ..()
// TA EDIT END

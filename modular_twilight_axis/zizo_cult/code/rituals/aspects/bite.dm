/datum/ritual/bite/necromancy
	name = "Learn Necromancy"
	desk = "Learn Gravemark, Order Minions, Raise Undead Formation, Bone Chill and Bone Mend. Raise your Arcane skill to Expert and replace the weaker Raise Undead Formation spell if known."
	passive = TRUE
	spells = list(/datum/action/cooldown/spell/gravemark, /datum/action/cooldown/spell/minion_order, /datum/action/cooldown/spell/raise_undead_formation/zizo_cult, /datum/action/cooldown/spell/bonechill, /datum/action/cooldown/spell/bonemend)

/datum/ritual/bite/necromancy/apply_passive(mob/living/carbon/human/H)
	H.mind.current.faction |= "[H.name]_faction"
	H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_EXPERT)
	H.mind.RemoveSpell(/datum/action/cooldown/spell/raise_undead_formation/zizo_cult/lesser)

/datum/ritual/bite/resurrection
	north_book = "Optional Necromantic Crystal"
	center_book = "Corpse with a mind"
	name = "Raise Dead"
	desk = "Revive a corpse with a mind. Place a necromantic crystal on the northern sigil to consume it and revive the target as rotcured. Without a crystal, raise them as a Greater Deadite with the ability to use equipment. A Greater Deadite retains the weaknesses of a deadite and is not guaranteed to be loyal."
	center_requirement = /mob/living/carbon/human

/datum/ritual/bite/resurrection/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/corpse = locate() in center.contents
	if(!corpse || corpse.stat != DEAD || !corpse.mind)
		to_chat(user, span_warning("YOU NEED A CORPSE."))
		return
	playsound(get_turf(corpse), 'sound/magic/magnet.ogg', 80, TRUE)
	var/obj/item/necro_relics/necro_crystal/crystal = locate() in get_step(center, NORTH)
	if(crystal)
		qdel(crystal)
		corpse.revive(full_heal = TRUE, admin_revive = TRUE)
		ADD_TRAIT(corpse, TRAIT_ROTMAN, TRAIT_GENERIC)
		corpse.visible_message(span_notice("[corpse] is returned to lyfe!"))
		return
	corpse.blood_volume = BLOOD_VOLUME_NORMAL
	corpse.setOxyLoss(0, updating_health = FALSE)
	corpse.setToxLoss(0, updating_health = FALSE)
	corpse.adjustBruteLoss(-INFINITY, updating_health = FALSE)
	corpse.adjustFireLoss(-INFINITY, updating_health = FALSE)
	corpse.heal_wounds(INFINITY)
	corpse.zombie_check_can_convert()
	var/datum/antagonist/zombie/Z = corpse.mind.has_antag_datum(/datum/antagonist/zombie)
	if(Z)
		Z.wake_zombie(TRUE)
	REMOVE_TRAIT(corpse, TRAIT_CHUNKYFINGERS, "/datum/antagonist/zombie")
	REMOVE_TRAIT(corpse, TRAIT_ZOMBIE_SPEECH, "/datum/antagonist/zombie")
	corpse.emote("scream")
	to_chat(corpse, span_userdanger("I FEEL MORE COMPETENT THAN THE AVERAGE DEADITE."))

/datum/ritual/bite/thanatophobia
	name = "Inflict Fear of Death"
	desk = "Curse the donor of a blood-fed leech for ten minutes. Corpses and skeletons within five tiles frighten them, drain stamina and force them to move away."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/bite/thanatophobia/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	if(!curse_target(remnant.fed_from))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	remnant.fed_from.apply_status_effect(/datum/status_effect/debuff/thanatophobia)
	to_chat(remnant.fed_from, span_danger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	remnant.fed_from.emote("scream")
	qdel(remnant)
	to_chat(user, span_notice("THEY SHALL FEAR MY DOMAIN!"))

/datum/status_effect/debuff/thanatophobia
	id = "thanatophobia"
	duration = 10 MINUTES
	tick_interval = 10 SECONDS
	alert_type = null

/datum/status_effect/debuff/thanatophobia/tick()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H))
		return
	for(var/mob/living/L in view(5, H))
		if(L == H)
			continue
		if(L.stat == DEAD || L.mind?.has_antag_datum(/datum/antagonist/skeleton))
			to_chat(H, span_userdanger("I MUST NOT DIE! I CAN NOT BEAR TO SEE THE DEAD!"))
			H.emote("scream")
			H.adjustStaminaLoss(10)
			step_away(H, L, 10)
			break

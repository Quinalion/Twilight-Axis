/datum/ritual/dark_arts
	abstract_type = /datum/ritual/dark_arts
	book_category = "Dark Arts"
	is_cultist_ritual = TRUE

/datum/ritual/dark_arts/necromancy
	name = "Learn Necromancy"
	description = "Learn Gravemark, Order Minions, Raise Undead Formation, Bone Chill and Bone Mend. Raise Arcane to Expert and replace the lesser Raise Undead Formation spell."
	passive = TRUE
	spells = list(/datum/action/cooldown/spell/gravemark, /datum/action/cooldown/spell/minion_order, /datum/action/cooldown/spell/raise_undead_formation/zizo_cult, /datum/action/cooldown/spell/bonechill, /datum/action/cooldown/spell/bonemend)
	success_message = "The grave is a workshop. Its silence yields to understanding."

/datum/ritual/dark_arts/necromancy/apply_passive(mob/living/carbon/human/target)
	target.faction |= "[target.name]_faction"
	target.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_EXPERT)
	target.mind.RemoveSpell(/datum/action/cooldown/spell/raise_undead_formation/zizo_cult/lesser)

/datum/ritual/dark_arts/resurrection
	name = "Raise Dead"
	description = "Revive a corpse with a mind that has not refused revival. Consume an optional necromantic crystal on the northern sigil to restore them as rotcured. Without a crystal, raise a Greater Deadite able to use equipment. A Greater Deadite keeps the weaknesses of a deadite and is not bound to the cult."
	north_book = "Optional necromantic crystal"
	center_book = "Corpse with a mind"
	center_requirement = /mob/living/carbon/human
	var/obj/item/necro_relics/necro_crystal/crystal

/datum/ritual/dark_arts/resurrection/bind_ingredients(turf/center)
	if(!..())
		return FALSE
	crystal = locate() in get_step(center, NORTH)
	return TRUE

/datum/ritual/dark_arts/resurrection/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	if(!target?.mind || target.stat != DEAD || HAS_TRAIT(target, TRAIT_DNR))
		return FALSE
	if(crystal)
		return !QDELETED(crystal) && crystal.loc == get_step(center, NORTH)
	return target.get_bodypart(BODY_ZONE_HEAD) && !HAS_TRAIT(target, TRAIT_ZOMBIE_IMMUNE) && !target.mind.has_antag_datum(/datum/antagonist/vampire) && !target.mind.has_antag_datum(/datum/antagonist/werewolf) && !target.mind.has_antag_datum(/datum/antagonist/skeleton) && !target.mind.has_antag_datum(/datum/antagonist/gnoll)

/datum/ritual/dark_arts/resurrection/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/corpse = get_target()
	if(crystal)
		corpse.revive(full_heal = TRUE, admin_revive = TRUE)
		ADD_TRAIT(corpse, TRAIT_ROTMAN, TRAIT_GENERIC)
		qdel(crystal)
		corpse.visible_message(span_notice("[corpse] draws a ragged breath. The crystal's light fades."))
	else
		var/datum/antagonist/zombie/deadite = corpse.mind.has_antag_datum(/datum/antagonist/zombie)
		if(!deadite)
			deadite = corpse.zombie_check_can_convert()
		if(!deadite)
			return FALSE
		corpse.blood_volume = BLOOD_VOLUME_NORMAL
		corpse.setOxyLoss(0, updating_health = FALSE)
		corpse.setToxLoss(0, updating_health = FALSE)
		corpse.adjustBruteLoss(-INFINITY, updating_health = FALSE)
		corpse.adjustFireLoss(-INFINITY, updating_health = FALSE)
		corpse.heal_wounds(INFINITY)
		deadite.wake_zombie(TRUE)
		REMOVE_TRAIT(corpse, TRAIT_CHUNKYFINGERS, "/datum/antagonist/zombie")
		REMOVE_TRAIT(corpse, TRAIT_ZOMBIE_SPEECH, "/datum/antagonist/zombie")
		to_chat(corpse, span_userdanger("The grave releases me. My hands remember their craft; my hunger remains."))
	playsound(center, 'sound/magic/magnet.ogg', 80, TRUE)
	return TRUE

/datum/ritual/dark_arts/transfuse
	name = "Master Sigils"
	description = "Reduce sigil drawing from five seconds to one and remove the need for bloody hands. Bound hands and a missing active hand still prevent drawing."
	passive = TRUE
	success_message = "The signs are written in my blood. I no longer need to spill it."

/datum/ritual/dark_arts/transfuse/apply_passive(mob/living/carbon/human/target)
	ADD_TRAIT(target, TRAIT_BLOODBOUND, TRAIT_GENERIC)

/datum/ritual/dark_arts/bloodsnare
	name = "Create Blood Snare"
	description = "Consume an offering to create a three-charge trap that ignores cult members and servants. Organs create poison, weapons create a stunning trap, and other items create a blade trap."
	center_requirement = /obj/item

/datum/ritual/dark_arts/bloodsnare/validate(mob/living/user, turf/center)
	return !(locate(/obj/structure/rune_ward/zizo) in center)

/datum/ritual/dark_arts/bloodsnare/invoke(mob/living/user, turf/center)
	var/obj/item/offering = ingredients["center"]
	var/obj/structure/rune_ward/zizo/trap = new(center)
	if(istype(offering, /obj/item/organ))
		trap.effect = "poison"
	else if(istype(offering, /obj/item/rogueweapon))
		trap.effect = "stun"
	trap.owner_ref = WEAKREF(user)
	trap.owner_name = user.real_name
	trap.owner_ckey = user.ckey || "no ckey"
	for(var/obj/effect/decal/cleanable/sigil/circle in range(1, center))
		qdel(circle)
	new /obj/effect/temp_visual/cult/ritual_channel(center, 1.5 SECONDS)
	to_chat(user, span_notice("The blood lies still. It remembers whom to spare."))
	return TRUE

/datum/ritual/dark_arts/proc/can_curse_leech(obj/item/natural/worms/leech/leech)
	var/mob/living/carbon/human/donor = leech?.fed_from
	return !QDELETED(leech) && leech.blood_storage > 0 && !QDELETED(donor) && donor.stat != DEAD && !psydont(donor) && !donor.has_status_effect(/datum/status_effect/buff/curse_immunity)

/datum/ritual/dark_arts/bloodbond
	name = "Bind Blood"
	description = "Bind two living donors using a blood-fed leech from each. For ten minutes, each takes oxygen damage every five seconds while more than seven tiles from the other. Silver psycrosses and curse immunity protect the donors."
	center_book = "Two blood-fed leeches from different living donors"
	center_requirement = /obj/item/natural/worms/leech

/datum/ritual/dark_arts/bloodbond/bind_ingredients(turf/center)
	if(!..())
		return FALSE
	var/obj/item/natural/worms/leech/first
	for(var/obj/item/natural/worms/leech/leech in center)
		if(!can_curse_leech(leech))
			continue
		if(!first)
			first = leech
			continue
		if(leech.fed_from != first.fed_from)
			ingredients["center"] = first
			ingredients["partner"] = leech
			return TRUE
	return FALSE

/datum/ritual/dark_arts/bloodbond/validate(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/first = ingredients["center"]
	var/obj/item/natural/worms/leech/second = ingredients["partner"]
	return can_curse_leech(first) && can_curse_leech(second) && second.loc == center && first.fed_from != second.fed_from

/datum/ritual/dark_arts/bloodbond/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/first = ingredients["center"]
	var/obj/item/natural/worms/leech/second = ingredients["partner"]
	var/mob/living/carbon/human/first_donor = first.fed_from
	var/mob/living/carbon/human/second_donor = second.fed_from
	curse_target(first_donor)
	curse_target(second_donor)
	first_donor.apply_status_effect(/datum/status_effect/bloodlink, second_donor)
	second_donor.apply_status_effect(/datum/status_effect/bloodlink, first_donor)
	to_chat(user, span_notice("Two hearts are drawn onto a single thread."))
	return TRUE

/datum/ritual/dark_arts/shadowform
	name = "Assume Shadow Form"
	description = "Transform a living target into a monstrous shadow. Regenerate in darkness and burn in bright light. Grant night vision, immunity to blood loss and toxins, and remove the need to breathe, eat or sleep. Teach Shadow Jaunt and Extinguish. The target becomes vulnerable to silver."
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/clothing/cloak

/datum/ritual/dark_arts/shadowform/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target?.dna && target.mind && target.stat != DEAD && !target.has_status_effect(/datum/status_effect/shadowform)

/datum/ritual/dark_arts/shadowform/prepare(mob/living/user, turf/center)
	var/obj/effect/temp_visual/channel = new /obj/effect/temp_visual/cult/ritual_channel/fivesec(center)
	playsound(user, 'sound/villain/littlescary2.ogg', 60, TRUE)
	var/completed = do_after(user, 5 SECONDS, target = get_target())
	qdel(channel)
	return completed

/datum/ritual/dark_arts/shadowform/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	target.dna.species.species_traits |= MUTCOLORS
	target.dna.species.fixed_mut_color = "000000"
	target.dna.features["mcolor"] = "000000"
	target.update_body()
	target.update_hair()
	for(var/obj/item/bodypart/BP in target.bodyparts)
		for(var/datum/bodypart_feature/F in BP.bodypart_features)
			if(F.accessory_type)
				F.accessory_colors = recolor_accessory(F.accessory_type, "000000")
		BP.update_limb()
	for(var/obj/item/organ/O in target.internal_organs)
		if(O.accessory_type)
			O.accessory_colors = recolor_accessory(O.accessory_type, "000000")
	target.icon_render_key = null
	target.update_body_parts()
	target.apply_status_effect(/datum/status_effect/shadowform)
	target.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/shadow_snuff)
	target.mind?.AddSpell(new /obj/effect/proc_holder/spell/self/shadow_jaunt)
	target.AddComponent(/datum/component/light_vulnerability)
	var/obj/item/organ/eyes/eyes = target.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(target, TRUE)
		QDEL_NULL(eyes)
	eyes = new /obj/item/organ/eyes/night_vision
	eyes.Insert(target)
	ADD_TRAIT(target, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOSLEEP, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_BLOODLOSS_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOMETABOLISM, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_SILVER_WEAK, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_MONSTROUS, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOFIRE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_FIRE_RESIST, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_RESISTHEAT, TRAIT_GENERIC)
	target.dna.species.name = "???"
	target.emote("scream")
	target.Knockdown(5 SECONDS)
	to_chat(target, span_danger("The light forsakes my flesh. I belong to the dark between the stars."))
	return TRUE

/datum/ritual/dark_arts/leech_curse
	abstract_type = /datum/ritual/dark_arts/leech_curse
	center_requirement = /obj/item/natural/worms/leech

/datum/ritual/dark_arts/leech_curse/find_ingredient(turf/place, required_type)
	for(var/obj/item/natural/worms/leech/leech in place)
		if(can_curse_leech(leech))
			return leech

/datum/ritual/dark_arts/leech_curse/validate(mob/living/user, turf/center)
	return can_curse_leech(ingredients["center"])

/datum/ritual/dark_arts/leech_curse/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/leech = ingredients["center"]
	if(!curse_target(leech.fed_from))
		return FALSE
	apply_curse(leech.fed_from)
	return TRUE

/datum/ritual/dark_arts/leech_curse/proc/apply_curse(mob/living/carbon/human/target)
	return

/datum/ritual/dark_arts/lightcurse
	parent_type = /datum/ritual/dark_arts/leech_curse
	name = "Inflict Light Sensitivity"
	description = "Curse a blood-fed leech's living donor for ten minutes. Bright light repeatedly burns them. Silver psycrosses and curse immunity protect the donor."
	success_message = "Let the sun become a scourge upon their flesh."

/datum/ritual/dark_arts/lightcurse/apply_curse(mob/living/carbon/human/target)
	target.AddComponent(/datum/component/light_vulnerability, 10, 10 MINUTES)
	to_chat(target, span_danger("The daylight bites beneath my skin. Something has marked me."))
	target.emote("scream")

/datum/ritual/dark_arts/fulmenor
	parent_type = /datum/ritual/dark_arts/leech_curse
	name = "Induce Frenzy"
	description = "Curse a blood-fed leech's living donor for one minute. Force a frenzy, grant 6 Strength and Constitution, and heal brute and burn damage every five seconds. The donor becomes monstrous and vulnerable to silver. Silver psycrosses and curse immunity protect the donor."
	success_message = "The flesh obeys a hunger older than reason."

/datum/ritual/dark_arts/fulmenor/apply_curse(mob/living/carbon/human/target)
	target.apply_status_effect(/datum/status_effect/fulmenor)
	target.emote("scream")

/datum/ritual/dark_arts/progress
	name = "Learn Mending"
	description = "Learn Mending Bolt. Heal another creature and repair worn equipment by twenty percent of its maximum integrity. Cannot target yourself."
	passive = TRUE
	spells = list(/obj/effect/proc_holder/spell/invoked/projectile/toil_mend)
	success_message = "What is broken may yet be made whole."

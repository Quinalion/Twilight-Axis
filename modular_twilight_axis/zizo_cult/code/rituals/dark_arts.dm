/datum/ritual/dark_arts
	abstract_type = /datum/ritual/dark_arts
	book_category = "Dark Arts"
	is_cultist_ritual = TRUE

/datum/ritual/dark_arts/necromancy
	name = "Learn Necromancy"
	description = "Learn Gravemark, Order Minions, Raise Undead Formation, Bone Chill and Bone Mend. Raise your Arcane skill to Expert and replace the weaker Raise Undead Formation spell if known."
	passive = TRUE
	spells = list(/datum/action/cooldown/spell/gravemark, /datum/action/cooldown/spell/minion_order, /datum/action/cooldown/spell/raise_undead_formation/zizo_cult, /datum/action/cooldown/spell/bonechill, /datum/action/cooldown/spell/bonemend)

/datum/ritual/dark_arts/necromancy/apply_passive(mob/living/carbon/human/H)
	H.mind.current.faction |= "[H.name]_faction"
	H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_EXPERT)
	H.mind.RemoveSpell(/datum/action/cooldown/spell/raise_undead_formation/zizo_cult/lesser)

/datum/ritual/dark_arts/resurrection
	north_book = "Optional necromantic crystal"
	center_book = "Corpse with a mind"
	name = "Raise Dead"
	description = "Revive a corpse with a mind. Place a necromantic crystal on the northern sigil to consume it and revive the target as rotcured. Without a crystal, raise them as a Greater Deadite with the ability to use equipment. A Greater Deadite retains the weaknesses of a deadite and is not guaranteed to be loyal."
	center_requirement = /mob/living/carbon/human

/datum/ritual/dark_arts/resurrection/invoke(mob/living/user, turf/center)
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

/datum/ritual/dark_arts/transfuse
	name = "Master Sigils"
	description = "Reduce sigil drawing time from five seconds to one second and remove the requirement for bloody hands. Does not allow drawing with bound hands or a missing active hand."
	passive = TRUE

/datum/ritual/dark_arts/transfuse/apply_passive(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_BLOODBOUND, TRAIT_GENERIC)
	return

/datum/ritual/dark_arts/bloodsnare
	name = "Create Blood Snare"
	description = "Consume an offering to create a trap with three charges that ignores cultists. Organs create a poison trap, weapons create a stunning trap, and other items create a damaging blade trap."
	center_requirement = /obj/item
	keep_center = TRUE

/datum/ritual/dark_arts/bloodsnare/invoke(mob/living/user, turf/center)
	var/effect = "bleed"
	if(locate(/obj/structure/rune_ward/zizo) in center)
		return FALSE
	var/obj/item/offering = locate(/obj/item) in center
	if(!offering)
		return FALSE
	if(istype(offering, /obj/item/organ))
		effect = "poison"
	else if(istype(offering, /obj/item/rogueweapon))
		effect = "stun"
	qdel(offering)
	for(var/obj/effect/decal/cleanable/sigil/sig in range(1, center))
		qdel(sig)
	new /obj/effect/temp_visual/cult/ritual_channel(center, 1.5 SECONDS)
	var/obj/structure/rune_ward/zizo/T = new(center)
	T.effect = effect
	T.owner_ref = WEAKREF(user)
	T.owner_name = user.real_name
	T.owner_ckey = user.ckey || "no ckey"
	to_chat(user, span_notice("THE SIGIL FADES. IT IS READY."))

/datum/ritual/dark_arts/bloodbond
	center_book = "Two blood-fed leeches from different living donors"
	name = "Bind Blood"
	description = "Bind two living donors using a blood-fed leech from each. For ten minutes, each donor takes oxygen damage every five seconds while more than seven tiles from the other."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/dark_arts/bloodbond/invoke(mob/living/user, turf/center)
	var/list/found = list()
	for(var/obj/item/natural/worms/leech/L in center)
		if(L.fed_from && L.blood_storage > 0 && !QDELETED(L.fed_from) && L.fed_from.stat != DEAD)
			found += L
	if(found.len < 2)
		to_chat(user, span_warning("This rite needs two leeches."))
		return
	var/obj/item/natural/worms/leech/L1 = found[1]
	var/obj/item/natural/worms/leech/L2 = found[2]
	var/mob/living/carbon/human/A = L1.fed_from
	var/mob/living/carbon/human/B = L2.fed_from
	if(A == B)
		to_chat(user, span_warning("You can not bind someone to theirself. Fool!"))
		return
	if(A.has_status_effect(/datum/status_effect/buff/curse_immunity) || B.has_status_effect(/datum/status_effect/buff/curse_immunity))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	curse_target(A)
	curse_target(B)
	A.apply_status_effect(/datum/status_effect/bloodlink, B)
	B.apply_status_effect(/datum/status_effect/bloodlink, A)
	qdel(L1)
	qdel(L2)
	to_chat(user, span_notice("I BIND [A] AND [B], THEIR HEARTS BEAT AS ONE."))
/datum/ritual/dark_arts/shadowform
	name = "Assume Shadow Form"
	description = "Transform the target into a visibly monstrous shadow that regenerates in darkness but takes damage in bright light. Grant night vision, immunity to blood loss and toxins, and remove the need to breathe, eat or sleep. Grant Shadow Jaunt to move through walls in darkness and Extinguish to put out lights and fires. The target becomes vulnerable to silver."
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/clothing/cloak

/datum/ritual/dark_arts/shadowform/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		to_chat(user, span_warning("NOT FOR THEM."))
		return
	if(target.has_status_effect(/datum/status_effect/shadowform))
		return
	if(!target.dna)
		return
	var/poo = new /obj/effect/temp_visual/cult/ritual_channel/fivesec(center)
	playsound(user, 'sound/villain/littlescary2.ogg', 60, TRUE)
	if(!do_after(user, 5 SECONDS, target = target))
		qdel(poo)
		return
	if(QDELETED(target) || get_turf(target) != center || !target.dna || target.has_status_effect(/datum/status_effect/shadowform))
		return
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
	to_chat(target, span_danger("IT BURNS! IT BURNS! IT STICKS TO MY FLESH AND BURNS!"))

/datum/ritual/dark_arts/lightcurse
	name = "Inflict Light Sensitivity"
	description = "Curse the donor of a blood-fed leech for ten minutes. Bright light repeatedly burns them."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/dark_arts/lightcurse/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	if(!curse_target(remnant.fed_from))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	remnant.fed_from.AddComponent(/datum/component/light_vulnerability, 10, 10 MINUTES)
	to_chat(remnant.fed_from, span_danger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	remnant.fed_from.emote("scream")
	qdel(remnant)
	to_chat(user, span_notice("THEY SHALL KNOW MY HATRED OF HIS LIGHT."))

/datum/ritual/dark_arts/progress
	name = "Learn Mending"
	description = "Learn Mending Bolt, which heals another creature and repairs their worn equipment by twenty percent of its maximum integrity. Cannot target yourself."
	passive = TRUE

/datum/ritual/dark_arts/progress/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/toil_mend)
	return

/datum/ritual/dark_arts/fulmenor
	name = "Induce Frenzy"
	description = "Curse the donor of a blood-fed leech for one minute. Force them into a frenzy, grant 6 Strength and Constitution, and heal brute and burn damage every five seconds. They become visibly monstrous and vulnerable to silver."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/dark_arts/fulmenor/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	victim.apply_status_effect(/datum/status_effect/fulmenor)
	victim.emote("scream")
	to_chat(victim, span_userdanger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	to_chat(user, span_notice("THEY SHALL WRECK HAVOC."))


/datum/ritual/dark_arts/resurrection/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	return target?.mind && target.stat == DEAD

/datum/ritual/dark_arts/shadowform/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	return target?.dna && !target.has_status_effect(/datum/status_effect/shadowform)

/datum/ritual/dark_arts/bloodbond/validate(mob/living/user, turf/center)
	var/list/donors = list()
	for(var/obj/item/natural/worms/leech/leech in center)
		var/mob/living/carbon/human/donor = leech.fed_from
		if(!QDELETED(donor) && donor.stat != DEAD && leech.blood_storage > 0 && !donor.has_status_effect(/datum/status_effect/buff/curse_immunity))
			donors |= donor
	return length(donors) >= 2

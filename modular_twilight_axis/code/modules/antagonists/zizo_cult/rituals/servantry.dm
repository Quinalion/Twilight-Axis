/datum/ritual/servantry
	abstract_type = /datum/ritual/servantry

/datum/ritual/servantry/convert
	name = "Convert"
	icon_type = /obj/item/clothing/neck/roguetown/psicross/inhumen
	desc = "Place a sacrifice in the middle of the rune to convert them into a lackey. Grants SECRETS. Requires an assistant on the rune if there are more than 3 cultists."
	center_requirement = /mob/living/carbon/human
	center_desc = "a sacrifice"
	is_cultist_ritual = TRUE

/datum/ritual/servantry/convert/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(zizo_target_error(user, target))
		return
	if(target.has_status_effect(/datum/status_effect/debuff/devitalised/lux_ripped))
		to_chat(user, span_warning("THEIR LUX IS TOO WEAK."))
		return
	var/datum/antagonist/zizocultist/PR = user.mind.has_antag_datum(/datum/antagonist/zizocultist, TRUE)
	var/lackeys = 0
	for(var/datum/mind/M in SSmapping.retainer.cultists)
		if(!M.current || QDELETED(M.current) || M.current.stat == DEAD)
			continue
		if(is_zizolackey(M))
			lackeys++
	var/mob/living/carbon/human/assistant
	for(var/mob/living/carbon/human/H in range(1, center))
		if(H == user || H == target || !is_zizo(H))
			continue
		assistant = H
		break
	if(lackeys > 3 && !assistant)
		to_chat(user, span_warning("FOR THE CULT TO GROW LARGER, YOU MUST PERFORM THIS RITE WITH AN ASSISTANT CULTIST ON THE SIGIL."))
		return
	var/alert = tgui_alert(target, "YOU WILL BE SHOWN THE TRUTH. DO YOU RESIST?", "???", list("Yield", "Resist"))
	if(QDELETED(target) || get_turf(target) != center || !user.Adjacent(center) || user.incapacitated() || !is_zizo(user) || zizo_target_error(user, target))
		return
	var/was_pure = target.purity
	target.Immobilize(3 SECONDS)
	if(alert == "Yield")
		to_chat(target, span_notice("I see the truth now! It all makes so much sense! They aren't HERETICS! They want the BEST FOR US!"))
		PR.add_cultist(target.mind)
		if(!is_zizo(target))
			return
		target.praise()
		target.apply_status_effect(/datum/status_effect/buff/healing, 70, TRUE)
		if(was_pure)
			new /obj/item/necro_relics/necro_crystal(center)
			zizo_award(user, 3)
			zizo_award(target, 3)
		target.purity = FALSE
		for(var/datum/mind/M in SSmapping.retainer.cultists)
			if(M.current)
				zizo_award(M.current, 2)
		var/datum/job/J = SSjob.GetJob(target.mind?.assigned_role)
		if(J && (J.department_flag & (NOBLEMEN | CHURCHMEN | GARRISON | INQUISITION)))
			new /obj/item/necro_relics/necro_crystal(center)
			zizo_award(user, 3)
			zizo_award(target, 3)
		zizo_award(user, 3)
		zizo_award(target, 3)
	else
		target.visible_message(span_danger("[target] thrashes around, unyielding!"))
		if(tgui_alert(user, "THIS FOOL REFUSES CONVERSION!", "ZIZO", list("Sacrifice", "Spare")) == "Sacrifice" && (target in center.contents))
			var/datum/ritual/servantry/sacrifice/S = new
			S.invoke(user, center, TRUE)
			qdel(S)

/datum/ritual/servantry/sacrifice
	lesser = TRUE
	name = "Sacrifice"
	icon_type = /obj/item/rogueweapon/huntingknife/idagger
	desc = "Place a sacrifice in the middle of the rune to rip out their lux. Grants SECRETS and a dark crystal. Requires an assistant holding a knife to stand on the sigil for the rite to function."
	center_requirement = /mob/living/carbon/human
	center_desc = "a sacrifice"

/datum/ritual/servantry/sacrifice/invoke(mob/living/user, turf/center, solo)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(zizo_target_error(user, target))
		return
	var/mob/living/carbon/human/assistant
	for(var/mob/living/carbon/human/H in range(1, center))
		if(H == user || H == target || !is_zizo(H) || H.incapacitated())
			continue
		for(var/obj/item/I in H.held_items)
			if(istype(I, /obj/item/rogueweapon/huntingknife))
				assistant = H
				break
		if(assistant)
			break
	if(!assistant && !solo)
		to_chat(user, span_warning("I need another cultist on the rune with a knife in their hand."))
		return
	to_chat(user, span_notice("You begin the sacrifice..."))
	if(solo)
		target.Immobilize(10 SECONDS)
	assistant?.Immobilize(10 SECONDS)
	var/poo = new /obj/effect/temp_visual/opengate(center, 10 SECONDS)
	if(!do_after(user, 10 SECONDS, target = target))
		assistant?.SetImmobilized(0)
		qdel(poo)
		return
	if(QDELETED(target) || get_turf(target) != center || zizo_target_error(user, target) || (!solo && (QDELETED(assistant) || !assistant.Adjacent(center) || assistant.incapacitated() || !is_zizo(assistant))))
		return
	var/pure = target.purity
	if(!absorb_lux(target, center))
		to_chat(user, span_warning("[target] has no lux left to give."))
		return
	var/datum/job/J = SSjob.GetJob(target.mind?.assigned_role)
	if(J && (J.department_flag & (NOBLEMEN | CHURCHMEN | GARRISON | INQUISITION)))
		new /obj/item/necro_relics/necro_crystal(center)
		zizo_award(user, 3)
		zizo_award(assistant, 3)
	if(pure == TRUE)
		new /obj/item/necro_relics/necro_crystal(center)
		zizo_award(user, 3)
		zizo_award(assistant, 3)
	zizo_award(user, 5)
	zizo_award(assistant, 5)
	target.visible_message(span_danger("[assistant || user] tears open [target]'s chest and rips free their lux!"))
	to_chat(user, span_notice("The sacrifice is accepted!"))

/datum/ritual/servantry/heartache
	lesser = TRUE
	name = "Heartaches"
	icon_type = /obj/item/corruptedheart
	desc = "Create a heart to locate sacrifices."
	center_requirement = /obj/item/organ/heart

/datum/ritual/servantry/heartache/invoke(mob/user, turf/center)
	new /obj/item/corruptedheart(center)
	to_chat(user, span_notice("Use this item to seek your sacrifices."))

/datum/ritual/servantry/guidance
	lesser = TRUE
	name = "Divine Guidance"
	icon_type = /obj/item/organ/eyes
	desc = "Obtain guidance from ZIZO to receive SECRETS. Can use every 20 minutes."
	center_requirement = /obj/item/organ/eyes
	center_desc = "eyes"
	keep_center = TRUE

/datum/ritual/servantry/guidance/invoke(mob/living/user, turf/center)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/cultist = user
	if(world.time < cultist.zizo_goals_cd)
		to_chat(user, span_warning("It is too soon, you must wait."))
		return
	cultist.zizo_goals_cd = world.time + 20 MINUTES
	reroll_goals(cultist)
	for(var/datum/zizogoal/gl in cultist.zizo_goals)
		to_chat(cultist, span_notice("<B>[gl.name]:</B> [gl.desc]<BR><B>[gl.reward] SECRETS.</B>"))

/obj/item/corruptedheart
	name = "corrupted heart"
	desc = "It sparkles with forbidden magic energy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown
	var/tracked_name

/obj/item/corruptedheart/attack_right(mob/living/user)
	if(!istype(user.patron, /datum/patron/inhumen/zizo))
		to_chat(user, span_warning("The heart is silent."))
		return
	var/new_name = input(user, "WHOSE NAME DO YOU WHISPER TO THE HEART?", "ZIZO") as null|text
	if(!new_name)
		return
	var/known = user.mind?.do_i_know(name = new_name)
	for(var/mob/living/carbon/human/T in GLOB.gate_targets)
		if(T.real_name == new_name)
			known = TRUE
	if(!known)
		to_chat(user, span_warning("I don't know anyone by that name."))
		return
	tracked_name = new_name
	to_chat(user, span_notice("The heart beats in time with [tracked_name]'s own'."))

/obj/item/corruptedheart/attack_self(mob/living/user)
	if(world.time < cooldown)
		to_chat(user, span_warning("Too soon!"))
		return
	if(!istype(user.patron, /datum/patron/inhumen/zizo))
		to_chat(user, span_warning("The heart is silent."))
		return
	if(!tracked_name)
		to_chat(user, span_warning("Right-click the heart to set target."))
		return
	if(!do_after(user, 2 SECONDS, src))
		return
	var/mob/living/carbon/human/prey
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.real_name == tracked_name)
			prey = H
			break
	if(!prey || !prey.z)
		to_chat(user, span_warning("The heart finds nothing."))
		return
	if(psydont(prey))
		to_chat(user, span_danger("They are wearing silver, it resists the dark magick!"))
		return
	var/list/info = get_locator_info(user, prey)
	var/beat = 'sound/health/slowbeat.ogg'
	if(info["proximity"] == "very close")
		beat = 'sound/health/fastbeat.ogg'
	else if(info["proximity"] == "nearby")
		beat = 'sound/health/heartbeat.ogg'
	playsound(user, beat, 60, TRUE)
	to_chat(user, span_danger("The heart beats faster toward the [info["dir"]]. [prey.real_name] feels [info["proximity"]][info["z"]]."))
	cooldown = world.time + 10 SECONDS

/proc/get_locator_info(mob/user, atom/prey, detailed = TRUE)
	var/list/info = list()
	info["dir"] = dir2text(get_dir(user, prey))
	info["z"] = ""
	if(prey.z > user.z)
		info["z"] = ", somewhere above"
	else if(prey.z < user.z)
		info["z"] = ", somewhere below"
	info["proximity"] = ""
	if(detailed)
		var/dist = get_dist(user, prey)
		info["proximity"] = "far away"
		if(dist <= 5)
			info["proximity"] = "very close"
		else if(dist <= 15)
			info["proximity"] = "nearby"
	return info

/datum/ritual/servantry/gutted
	lesser = TRUE
	name = "Gutted Fish"
	icon_type = /obj/item/rogueweapon/huntingknife
	desc = "Place a dead and mindless humanoid in the center of the sigil to rip out its organs."
	center_requirement = /mob/living/carbon/human

/datum/ritual/servantry/gutted/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(target.stat != DEAD)
		return
	if(target.mind)
		to_chat(user, span_danger("The sacrifice must be mindless."))
		return
	center.visible_message(span_danger("[target] is lifted up into the air and multiple scratches, incisions and deep cuts start etching themselves into their skin as all of their internal organs spill on the floor below!"))
	var/atom/drop_location = target.drop_location()
	for(var/obj/item/organ/organ as anything in target.internal_organs)
		organ.Remove(target)
		organ.forceMove(drop_location)
	for(var/obj/item/bodypart/part as anything in target.bodyparts)
		part.drop_limb()

/datum/ritual/servantry/sleepcurse
	name = "Curse of Zizo"
	icon_type = /obj/item/natural/worms/leech
	desc = "Curse your target with a heart attack that renders them unconscious after fifteen seconds. Usually does not kill. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	research_cost = 3
	keep_center = TRUE

/datum/ritual/servantry/sleepcurse/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	to_chat(user, span_notice("THE METRONOME OF THEIR HEART SHALL CEASE!"))
	to_chat(victim, span_userdanger("A crushing pain burns in my chest!"))
	victim.emote("gasp")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sleepcurse), victim), 15 SECONDS)

/proc/sleepcurse(mob/living/carbon/human/victim)
	if(QDELETED(victim) || victim.stat == DEAD)
		return
	victim.heart_attack()

/datum/ritual/servantry/tongues
	lesser = TRUE
	name = "Curse of Tongues"
	icon_type = /obj/item/natural/worms/leech
	desc = "Curse your target with unintelligible speech. Lasts 5 minutes. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	research_cost = 3
	keep_center = TRUE

/datum/ritual/servantry/tongues/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	to_chat(user, span_notice("MAY THEIR TONGUE ROT AND BLEED AND BURST!"))
	to_chat(victim, span_userdanger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	victim.apply_status_effect(/datum/status_effect/debuff/zizo_tongues)

/datum/status_effect/debuff/zizo_tongues
	id = "zizo_tongues"
	duration = 5 MINUTES
	alert_type = null

/datum/status_effect/debuff/zizo_tongues/on_apply()
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, REF(src))
	return ..()

/datum/status_effect/debuff/zizo_tongues/on_remove()
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, REF(src))

/datum/ritual/servantry/exhaustion
	lesser = TRUE
	name = "Curse of Exhaustion"
	icon_type = /obj/item/natural/worms/leech
	desc = "Curse your target with immense exhaustion, encouraging them to find their bed and rest. The exhaustion lasts 5 minutes. Shows no effect to target. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	research_cost = 3
	keep_center = TRUE

/datum/ritual/servantry/exhaustion/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim, FALSE))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	to_chat(user, span_notice("MAY THEY KNOW SLUMBER UNTO DEATH!"))
	victim.apply_status_effect(/datum/status_effect/debuff/zizo_exhaustion)

/datum/status_effect/debuff/zizo_exhaustion
	id = "zizo_exhaustion"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/sleepytime

/datum/status_effect/debuff/zizo_exhaustion/on_apply()
	var/mob/living/carbon/human/H = owner
	H.remove_status_effect(/datum/status_effect/debuff/sleepytime)
	H.remove_stress(/datum/stressevent/sleepytime)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, remove_status_effect), type), 5 MINUTES)
	return ..()

/datum/status_effect/debuff/zizo_exhaustion/tick()
	var/datum/status_effect/incapacitating/sleeping/S = owner.IsSleeping()
	if(!S)
		return
	S.duration += 1 MINUTES
	owner.remove_status_effect(type)

/datum/ritual/servantry/knock
	lesser = TRUE
	name = "Curse of Knock"
	icon_type = /obj/item/storage/keyring
	node_state = "keyring3"
	desc = "Keys no longer work for your target! Lasts 10 minutes. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	research_cost = 3
	keep_center = TRUE

/datum/ritual/servantry/knock/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	to_chat(user, span_notice("THEY SHALL HAVE FINGERS OF BUTTER!"))
	to_chat(victim, span_userdanger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	victim.apply_status_effect(/datum/status_effect/debuff/zizo_knock)

/datum/status_effect/debuff/zizo_knock
	id = "zizo_knock"
	duration = 10 MINUTES
	alert_type = null

/datum/ritual/servantry/misfortune
	lesser = TRUE
	name = "Curse of Misfortune"
	icon_type = /obj/item/dice/d6
	desc = "Curse your target with misfortune. Lasts 10 minutes. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	research_cost = 3
	keep_center = TRUE

/datum/ritual/servantry/misfortune/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	to_chat(user, span_notice("MAY THEY TRIP AND FALL AND DIE!"))
	to_chat(victim, span_userdanger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	victim.apply_status_effect(/datum/status_effect/debuff/zizo_misfortune)

/datum/status_effect/debuff/zizo_misfortune
	id = "zizo_misfortune"
	duration = 10 MINUTES
	alert_type = null

GLOBAL_LIST_EMPTY(zizo_proxy)

/datum/ritual/servantry/darksunmark
	lesser = TRUE
	name = "Dark Sun's Mark"
	icon_type = /obj/item/candle/yellow
	desc = "Mark someone for death by Graggar Assassins."
	center_requirement = /obj/item/rogueweapon/huntingknife/idagger
	research_cost = 2

/datum/ritual/servantry/darksunmark/invoke(mob/living/user, turf/center)
	var/target_name = input(user, "Who do you wish to die?", "GRAGGAR")
	if(!user.mind || !user.mind.do_i_know(name = target_name))
		to_chat(user, span_warning("I don't know anyone by that name."))
		return
	var/mob/living/carbon/human/target
	var/assassin_found = FALSE
	for(var/mob/living/carbon/human/HL as anything in GLOB.human_list)
		if(HL.stat == DEAD)
			continue
		if(HL.real_name == target_name)
			target = HL
			continue
		if(HAS_TRAIT(HL, TRAIT_ASSASSIN))
			assassin_found = TRUE
			var/obj/item/rogueweapon/huntingknife/idagger/steel/profane/dagger = locate() in HL.get_all_gear()
			if(dagger)
				to_chat(HL, "profane dagger whispers, <span class='danger'>\"The terrible Zizo has called for our aid. Hunt and strike down our common foe, [target_name]!\"</span>")
	if(!target || !assassin_found)
		to_chat(user, span_warning("There has been no answer to your call to the Dark Sun. It seems his servants are far from here..."))
		return
	to_chat(user, span_warning("Your target has been marked, your profane call answered by the Dark Sun. [target.real_name] will surely perish!"))
	to_chat(target, span_warningbig("My hair stands on end. Has someone just said my name? I should watch my back."))
	target.playsound_local(target, 'sound/magic/marked.ogg', 100)

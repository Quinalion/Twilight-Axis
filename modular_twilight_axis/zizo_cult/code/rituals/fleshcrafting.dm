/datum/ritual/fleshcrafting
	abstract_type = /datum/ritual/fleshcrafting
	book_category = "Fleshcrafting"

/datum/ritual/fleshcrafting/bunnylegs
	name = "Strengthen Legs"
	description = "Grant the target enhanced jumping ability."
	cultist_number = 6

	center_book = "Human target"
	center_requirement = /mob/living/carbon/human

	w_req = /obj/item/bodypart/l_leg
	e_req = /obj/item/bodypart/r_leg
	n_req = /obj/item/alch/airdust

	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/bunnylegs/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	ADD_TRAIT(target, TRAIT_ZJUMP, TRAIT_GENERIC)
	to_chat(target, span_notice("I feel like my legs have become stronger."))

/datum/ritual/fleshcrafting/fleshmend
	name = "Restore Flesh"
	description = "Fully heal a consenting target, regenerate missing limbs and heal wounds. Can revive a dead target who has not refused revival or taken the vow of Necra. Reduces Strength, Speed and Constitution by 2 for fifteen minutes."
	center_book = "Consenting target"
	center_requirement = /mob/living/carbon/human
	n_req =  /obj/item/alch/viscera
	s_req = /obj/item/alch/calendula

/datum/ritual/fleshcrafting/fleshmend/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(!target.mind)
		to_chat(user, span_warning("They are not worth saving."))
		return
	if(!target.mind.active)
		to_chat(user, span_warning("They are unresponsive to my attempts. For now."))
		return
	target.playsound_local(target, 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
	if((!HAS_TRAIT(target, TRAIT_DNR) && !HAS_TRAIT(target, TRAIT_NECRAS_VOW)) || target.stat != DEAD)
		target.fully_heal()
		target.regenerate_limbs()
		target.heal_wounds(500)
		if(target.stat == DEAD)
			target.revive()
		target.apply_status_effect(/datum/status_effect/debuff/fleshmend_exhaustion)
		to_chat(target, span_notice("ZIZO EMPOWERS ME!"))

/datum/ritual/fleshcrafting/darkeyes
	name = "Grant Night Vision"
	description = "Grant the target night vision. Their eyes glow visibly."
	center_requirement = /mob/living/carbon/human

	w_req = /obj/item/alch/viscera
	e_req = /obj/item/natural/bundle/bone
	n_req = /obj/item/organ/eyes

/datum/ritual/fleshcrafting/darkeyes/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	ADD_TRAIT(target, TRAIT_ZIZOEYES, TRAIT_GENERIC)
	to_chat(target, span_notice("Я больше не боюсь темноты. Но теперь мне стоит скрывать мои глаза.."))

/datum/ritual/fleshcrafting/undead
	name = "Create Necromantic Crystal"
	description = "Create a necromantic crystal that summons skeletons controlled by volunteer spirits. Recharge it with lux."
	ritual_limit = 2
	number_cultist_for_add_limit = 2
	center_requirement = /obj/item/natural/glass_shard

	w_req = /obj/item/organ/brain
	e_req = /obj/item/organ/brain
	n_req = /obj/item/alch/bone
	s_req = /obj/item/natural/bundle/bone

	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/undead/invoke(mob/living/user, turf/center)

	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/item/necro_relics/necro_crystal(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/fleshcrafting/nopain
	name = "Suppress Pain"
	description = "Grant the target pain immunity and 1 Willpower. Drain lux from a Psydon worshipper on the northern sigil, leaving them devitalised and briefly incapacitated."
	center_requirement = /mob/living/carbon/human
	center_book = "Human beneficiary"
	north_book = "Psydon worshipper with undrained lux"

	n_req = /mob/living/carbon/human

/datum/ritual/fleshcrafting/nopain/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	var/mob/living/carbon/human/victim = locate() in get_step(center, NORTH)

	if(victim.has_status_effect(/datum/status_effect/debuff/devitalised))
		to_chat(target, span_danger("Его душа уже осквернена..."))
		return
	if(victim.patron.type != /datum/patron/old_god)
		to_chat(target, span_danger("Нужен тот, кто верует в Псайдона..."))
		return
	if(victim.patron.type == /datum/patron/old_god)
		target.apply_status_effect(/datum/status_effect/cult_painless)
		to_chat(target, span_notice("За счет его силы люкса, я теперь не чувствую боли!"))
		to_chat(victim, span_danger("О нет.. За счет силы моей веры они стали сильнее.. Что же мне делать дальше.."))
		victim.apply_status_effect(/datum/status_effect/debuff/devitalised)
		victim.Stun(30)
		victim.Knockdown(30)
		victim.Sleeping(60)

/datum/ritual/fleshcrafting/immortality
	name = "Grant Flawed Immortality"
	description = "Drain an aasimar on the northern sigil, leaving them devitalised and stunned. Grant the target death immunity, pain immunity, resistance to limb damage, wound regeneration and immunity to blood loss, toxins and zombie infection. Remove the target's need to breathe, eat or sleep, but block normal spellcasting. The target learns Regenerate and loses 3 Strength, Speed and Willpower."
	center_book = "Human beneficiary"
	north_book = "Aasimar with undrained lux"
	center_requirement = /mob/living/carbon/human

	n_req = /mob/living/carbon/human

/datum/ritual/fleshcrafting/immortality/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	var/mob/living/carbon/human/victim = locate() in get_step(center, NORTH)
	if(!(is_species(victim, /datum/species/aasimar)))
		return
	if(victim.has_status_effect(/datum/status_effect/debuff/devitalised))
		to_chat(target, span_notice("This aasimar is already used in ritual..."))
		return
	victim.apply_status_effect(/datum/status_effect/debuff/devitalised)
	victim.Stun(30)
	victim.Knockdown(30)
	target.apply_status_effect(/datum/status_effect/cult_immortality)
	target.Knockdown(5 SECONDS)
	target.emote("agony", forced = TRUE)
	if(!target.mind.has_spell(/obj/effect/proc_holder/spell/self/zizo_regenerate))
		target.mind.AddSpell(new /obj/effect/proc_holder/spell/self/zizo_regenerate)

/datum/ritual/fleshcrafting/fleshform
	name = "Create Flesh Homunculus"
	description = "Transform the target into a flesh homunculus, destroying their original body. If the body has no player, recruit a volunteer spirit to control it. Cannot target the cult leader."
	cultist_number = 2
	center_requirement = /mob/living/carbon/human
	center_book = "Target to transform"

	n_req = /obj/item/organ/heart
	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/fleshform/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(is_zizocultist(target.mind))
		to_chat(target, span_danger("I'm not letting my strongest follower become a mindless brute."))
		return

	if(!target.ckey || !target.mind)
		var/list/candidates = pollGhostCandidates("Do you want to play as cultistic flesh?", null, null, null, 10 SECONDS, POLL_IGNORE_LICH_SKELETON)
		if(!LAZYLEN(candidates))
			to_chat(user, span_warning("The depths are hollow."))
			return

		var/mob/dead/mob = pick(candidates)
		if(!istype(mob))
			return

		if(istype(mob, /mob/dead/new_player))
			var/mob/dead/new_player/new_player = mob
			new_player.close_spawn_windows()

		target.key = mob.key

	to_chat(target, span_warning("SOON I WILL BECOME A HIGHER FORM!"))
	addtimer(CALLBACK(src, PROC_REF(flesh_convert), target, center), 5 SECONDS)

/datum/ritual/fleshcrafting/fleshform/proc/flesh_convert(mob/living/victim, turf/place)
	if(QDELETED(victim))
		return
	if(place != get_turf(victim))
		return
	if(!victim.mind)
		return
	var/mob/living/trl = new /mob/living/simple_animal/hostile/retaliate/blood(place)
	victim.mind.transfer_to(trl)
	victim.gib()

/datum/ritual/fleshcrafting/gutted
	name = "Dissect Corpse"
	description = "Remove all organs and limbs from a corpse. Produce two bundles of bones if the corpse has not already been devitalised."
	center_requirement = /mob/living/carbon/human
	center_book = "Corpse"

/datum/ritual/fleshcrafting/gutted/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(target.stat != DEAD)
		return
	target.take_overall_damage(500)
	center.visible_message(span_danger("[target] is lifted up into the air and multiple scratches, incisions and deep cuts start etching themselves into their skin as all of their internal organs spill on the floor below!"))
	var/atom/drop_location = target.drop_location()
	for(var/obj/item/organ/organ as anything in target.internal_organs)
		organ.Remove(target)
		organ.forceMove(drop_location)
	var/obj/item/bodypart/chest/cavity = target.get_bodypart(BODY_ZONE_CHEST)
	if(cavity.cavity_item)
		cavity.cavity_item.forceMove(drop_location)
		cavity.cavity_item = null
	for(var/obj/item/bodypart/part as anything in target.bodyparts)
		part.drop_limb()
	if(target.has_status_effect(/datum/status_effect/debuff/devitalised))
		to_chat(user, span_danger("Он уже выпотрошен"))
		return
	new /obj/item/natural/bundle/bone(center)
	new /obj/item/natural/bundle/bone(center)
	target.apply_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/fleshcrafting/nopain/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	var/mob/living/carbon/human/victim = locate() in get_step(center, NORTH)
	return target && victim && !target.has_status_effect(/datum/status_effect/cult_painless) && istype(victim.patron, /datum/patron/old_god) && !victim.has_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/fleshcrafting/immortality/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	var/mob/living/carbon/human/victim = locate() in get_step(center, NORTH)
	return target?.mind && victim && !target.has_status_effect(/datum/status_effect/cult_immortality) && is_species(victim, /datum/species/aasimar) && !victim.has_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/fleshcrafting/gutted/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	return target && target.stat == DEAD && !target.has_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/fleshcrafting/fleshmend
	var/mob/living/carbon/human/consenting_target

/datum/ritual/fleshcrafting/fleshmend/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	return target?.mind?.active && (!consenting_target || consenting_target == target) && (target.stat != DEAD || (!HAS_TRAIT(target, TRAIT_DNR) && !HAS_TRAIT(target, TRAIT_NECRAS_VOW)))

/datum/ritual/fleshcrafting/fleshmend/prepare(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	consenting_target = target
	return alert(target, "Accept healing from Zizo?", "Restore Flesh", "Accept", "Refuse") == "Accept"

/datum/ritual/fleshcrafting/fleshform/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center
	return target && !is_zizocultist(target.mind)

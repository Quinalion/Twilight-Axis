/datum/ritual/fleshcrafting
	abstract_type = /datum/ritual/fleshcrafting
	book_category = "Fleshcrafting"

/datum/ritual/fleshcrafting/bunnylegs
	name = "Strengthen Legs"
	description = "Grant a living target enhanced jumping ability."
	cultist_number = 6
	center_book = "Living human target"
	center_requirement = /mob/living/carbon/human
	w_req = /obj/item/bodypart/l_leg
	e_req = /obj/item/bodypart/r_leg
	n_req = /obj/item/alch/airdust
	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/bunnylegs/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target && target.stat != DEAD && !HAS_TRAIT(target, TRAIT_ZJUMP)

/datum/ritual/fleshcrafting/bunnylegs/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	ADD_TRAIT(target, TRAIT_ZJUMP, TRAIT_GENERIC)
	to_chat(target, span_notice("Bone and sinew remember a stronger shape."))
	return TRUE

/datum/ritual/fleshcrafting/fleshmend
	name = "Restore Flesh"
	description = "Fully heal a consenting target, regenerate missing limbs and heal wounds. Revive the dead unless they have refused revival or taken Necra's vow. Reduce Strength, Speed and Constitution by 2 for fifteen minutes."
	center_book = "Consenting target"
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/alch/viscera
	s_req = /obj/item/alch/calendula

/datum/ritual/fleshcrafting/fleshmend/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target?.mind && (target.client || target.get_ghost(TRUE, TRUE)) && (target.stat != DEAD || (!HAS_TRAIT(target, TRAIT_DNR) && !HAS_TRAIT(target, TRAIT_NECRAS_VOW)))

/datum/ritual/fleshcrafting/fleshmend/prepare(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	var/mob/recipient = target.client ? target : target.get_ghost(TRUE, TRUE)
	return alert(recipient, "Accept the Dark Lady's healing? Your body will be weakened for fifteen minutes.", "Restore Flesh", "Accept", "Refuse") == "Accept"

/datum/ritual/fleshcrafting/fleshmend/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	target.playsound_local(target, 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
	target.fully_heal()
	target.regenerate_limbs()
	target.heal_wounds(500)
	if(target.stat == DEAD)
		target.revive()
	target.apply_status_effect(/datum/status_effect/debuff/fleshmend_exhaustion)
	to_chat(target, span_notice("Torn flesh knits anew. Death must wait."))
	return TRUE

/datum/ritual/fleshcrafting/darkeyes
	name = "Grant Night Vision"
	description = "Grant a living target night vision. Their eyes glow visibly."
	center_requirement = /mob/living/carbon/human
	w_req = /obj/item/alch/viscera
	e_req = /obj/item/natural/bundle/bone
	n_req = /obj/item/organ/eyes

/datum/ritual/fleshcrafting/darkeyes/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target && target.stat != DEAD && !HAS_TRAIT(target, TRAIT_ZIZOEYES)

/datum/ritual/fleshcrafting/darkeyes/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	ADD_TRAIT(target, TRAIT_ZIZOEYES, TRAIT_GENERIC)
	to_chat(target, span_notice("The night opens to my gaze. Her mark shines in my eyes."))
	return TRUE

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
	outputs = list(/obj/item/necro_relics/necro_crystal)
	crafting_effects = TRUE
	success_message = "A hollow vessel waits for the spark of unlyfe."

/datum/ritual/fleshcrafting/nopain
	name = "Suppress Pain"
	description = "Grant the living target pain immunity and 1 Willpower. Drain lux from a living Psydon worshipper on the northern sigil, leaving them devitalised and briefly incapacitated."
	center_requirement = /mob/living/carbon/human
	center_book = "Living human beneficiary"
	north_book = "Living Psydon worshipper with undrained lux"
	n_req = /mob/living/carbon/human

/datum/ritual/fleshcrafting/nopain/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	var/mob/living/carbon/human/donor = ingredients["[NORTH]"]
	return target && target.stat != DEAD && donor && donor.stat != DEAD && !target.has_status_effect(/datum/status_effect/cult_painless) && istype(donor.patron, /datum/patron/old_god) && donor.has_extractable_lux() && !donor.has_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/fleshcrafting/nopain/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	var/mob/living/carbon/human/donor = ingredients["[NORTH]"]
	drain_zizo_ritual_lux(donor)
	target.apply_status_effect(/datum/status_effect/cult_painless)
	to_chat(target, span_notice("Pain falls silent. A stolen prayer sustains me."))
	to_chat(donor, span_danger("My prayer is torn from me and woven into another's flesh."))
	return TRUE

/datum/ritual/fleshcrafting/immortality
	name = "Grant Flawed Immortality"
	description = "Drain a living aasimar on the northern sigil, leaving them devitalised and incapacitated. Grant the living target death immunity, pain immunity, resistance to limb damage, wound regeneration and immunity to blood loss, toxins and zombie infection. Remove the need to breathe, eat or sleep, but block normal spellcasting. Teach Regenerate and reduce Strength, Speed and Willpower by 3."
	center_book = "Living human beneficiary"
	north_book = "Living aasimar with undrained lux"
	center_requirement = /mob/living/carbon/human
	n_req = /mob/living/carbon/human

/datum/ritual/fleshcrafting/immortality/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	var/mob/living/carbon/human/donor = ingredients["[NORTH]"]
	return target?.mind && target.stat != DEAD && donor && donor.stat != DEAD && !target.has_status_effect(/datum/status_effect/cult_immortality) && is_species(donor, /datum/species/aasimar) && donor.has_extractable_lux() && !donor.has_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/fleshcrafting/immortality/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	var/mob/living/carbon/human/donor = ingredients["[NORTH]"]
	drain_zizo_ritual_lux(donor)
	target.apply_status_effect(/datum/status_effect/cult_immortality)
	target.Knockdown(5 SECONDS)
	target.emote("agony", forced = TRUE)
	if(!target.mind.has_spell(/obj/effect/proc_holder/spell/self/zizo_regenerate))
		target.mind.AddSpell(new /obj/effect/proc_holder/spell/self/zizo_regenerate)
	to_chat(target, span_danger("Death loosens its hold. The price is written into my flesh."))
	return TRUE

/datum/ritual/fleshcrafting/fleshform
	name = "Create Flesh Homunculus"
	description = "Transform the target into a flesh homunculus bound to the cult. Destroy their original body. An unoccupied body requires a volunteer spirit. Cannot target yourself or the cult leader."
	cultist_number = 2
	center_requirement = /mob/living/carbon/human
	center_book = "Target to transform"
	n_req = /obj/item/organ/heart
	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/fleshform/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target && target != user && !target.mind?.has_antag_datum(/datum/antagonist/zizocultist/leader)

/datum/ritual/fleshcrafting/fleshform/prepare(mob/living/user, turf/center)
	if(!prepare_spirit(user, "Serve Zizo's cult as a flesh homunculus?"))
		return FALSE
	var/mob/living/carbon/human/target = get_target()
	var/obj/effect/temp_visual/channel = new /obj/effect/temp_visual/cult/ritual_channel/fivesec(center)
	var/completed = do_after(user, 5 SECONDS, target = target)
	qdel(channel)
	return completed

/datum/ritual/fleshcrafting/fleshform/invoke(mob/living/user, turf/center)
	if(!claim_spirit())
		return FALSE
	var/mob/living/carbon/human/target = get_target()
	var/mob/living/creature = new /mob/living/simple_animal/hostile/retaliate/blood(center)
	target.mind.zizo_master = user.mind
	target.mind.transfer_to(creature)
	target.gib()
	to_chat(creature, span_userdanger("Flesh has no final shape. I rise to serve Her work."))
	return TRUE

/datum/ritual/fleshcrafting/gutted
	name = "Dissect Corpse"
	description = "Remove all organs and limbs from a corpse. Produce two bundles of bones. Cannot reuse a devitalised corpse."
	center_requirement = /mob/living/carbon/human
	center_book = "Corpse"

/datum/ritual/fleshcrafting/gutted/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target && target.stat == DEAD && !target.has_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/fleshcrafting/gutted/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	target.take_overall_damage(500)
	center.visible_message(span_danger("[target] rises from the stone. Unseen hands part flesh from bone."))
	var/atom/drop_location = target.drop_location()
	for(var/obj/item/organ/organ as anything in target.internal_organs.Copy())
		organ.Remove(target)
		organ.forceMove(drop_location)
	var/obj/item/bodypart/chest/chest = target.get_bodypart(BODY_ZONE_CHEST)
	if(chest?.cavity_item)
		chest.cavity_item.forceMove(drop_location)
		chest.cavity_item = null
	for(var/obj/item/bodypart/part as anything in target.bodyparts.Copy())
		part.drop_limb()
	new /obj/item/natural/bundle/bone(center)
	new /obj/item/natural/bundle/bone(center)
	target.apply_status_effect(/datum/status_effect/debuff/devitalised)
	return TRUE

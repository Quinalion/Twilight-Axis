/datum/ritual/fleshcrafting
	abstract_type = /datum/ritual/fleshcrafting

/datum/ritual/fleshcrafting/bunnylegs
	name = "Saliendo Pedes"
	icon_type = /obj/item/bodypart/l_leg
	desc = "Use a pair of legs to permanently increase your jump height."
	center_requirement = /mob/living/carbon/human
	w_req = /obj/item/bodypart/l_leg
	e_req = /obj/item/bodypart/r_leg

/datum/ritual/fleshcrafting/bunnylegs/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	ADD_TRAIT(target, TRAIT_ZJUMP, TRAIT_GENERIC)
	to_chat(target, span_notice("I feel like my legs have become stronger."))

/datum/ritual/fleshcrafting/fleshmend
	lesser = TRUE
	name = "Fleshmend"
	icon_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak
	desc = "Use a piece of raw meat to heal yourself."
	n_req = /obj/item/reagent_containers/food/snacks/rogue/meat/steak
	center_requirement = /mob/living/carbon/human
	var/heal_tick = 30
	research_cost = 2

/datum/ritual/fleshcrafting/fleshmend/greater
	lesser = FALSE
	name = "Greater Fleshmend"
	icon_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak
	desc = "Use a piece of raw meat to heal yourself, but better."
	is_cultist_ritual = TRUE
	heal_tick = 70
	research_cost = 5

/datum/ritual/fleshcrafting/fleshmend/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	target.playsound_local(target, 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
	target.apply_status_effect(/datum/status_effect/buff/healing, heal_tick, TRUE)
	to_chat(target, span_notice("Zizo empowers me."))

/datum/ritual/fleshcrafting/darkeyes
	lesser = TRUE
	name = "Darkened Eyes"
	icon_type = /obj/item/organ/eyes
	desc = "Use a pair of eyes to permanently see in the dark."
	center_requirement = /mob/living/carbon/human
	w_req = /obj/item/organ/eyes
	e_req = /obj/item/organ/eyes
	research_cost = 3

/datum/ritual/fleshcrafting/darkeyes/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	var/obj/item/organ/eyes/old_eyes = target.getorganslot(ORGAN_SLOT_EYES)
	if(old_eyes)
		old_eyes.Remove(target, 1)
		QDEL_NULL(old_eyes)
	var/obj/item/organ/eyes/night_vision/new_eyes = new
	new_eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	new_eyes.Insert(target)
	to_chat(target, span_notice("I no longer fear the dark."))

/datum/ritual/fleshcrafting/nopain
	name = "Painless Battle"
	icon_type = /obj/item/organ/brain
	desc = "Use a heart and a brain to become immune to pain. Requires a dark crystal."
	research_cost = 3
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/necro_relics/necro_crystal
	w_req = /obj/item/organ/heart
	e_req = /obj/item/organ/brain

/datum/ritual/fleshcrafting/nopain/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	ADD_TRAIT(target, TRAIT_NOPAIN, TRAIT_GENERIC)
	to_chat(target, span_notice("I no longer feel pain."))

/datum/ritual/fleshcrafting/lesserrituos
	lesser = TRUE
	name = "Lesser Rituos"
	icon_type = /obj/item/necro_relics/necro_crystal
	desc = "The dark lady's lessser work. When I cast this ritual upon myself, I gain strength from undeath. Can be stacked 3 times. Requires a dark crystal."
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/necro_relics/necro_crystal
	research_cost = 10

/datum/ritual/fleshcrafting/lesserrituos/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = user
	var/obj/item/bodypart/head = target.get_bodypart(BODY_ZONE_HEAD)
	if(get_turf(user) != center || !target.mind || head?.skeletonized || HAS_TRAIT_FROM(target, TRAIT_MONSTROUS, "lesser_rituos"))
		to_chat(user, span_warning("THE RITE DOES NOTHING."))
		new /obj/item/necro_relics/necro_crystal(center)
		return
	to_chat(user, span_notice("The rite begins. Remain still."))
	var/poo = new /obj/effect/temp_visual/opengate(center, 10 SECONDS)
	playsound(user, 'sound/villain/littlescary.ogg', 100, TRUE)
	if(!do_after(user, 10 SECONDS) || QDELETED(target) || !(target in center.contents))
		qdel(poo)
		new /obj/item/necro_relics/necro_crystal(center)
		return
	var/limbs = 0
	for(var/obj/item/bodypart/part in target.bodyparts)
		if(part.skeletonized && part != head && !istype(part, /obj/item/bodypart/chest))
			limbs++
	var/stage = 1
	if(HAS_TRAIT(target, TRAIT_WARLOCK) || limbs >= 4)
		stage = 3
	else if(limbs)
		stage = 2
	target.mob_biotypes |= MOB_UNDEAD
	var/list/parts = list()
	for(var/obj/item/bodypart/part in target.bodyparts)
		if(part.skeletonized || (stage < 3 && (part == head || istype(part, /obj/item/bodypart/chest))))
			continue
		parts += part
	if(stage == 1 && length(parts))
		parts = list(pick(parts))
	for(var/obj/item/bodypart/part in parts)
		part.skeletonize(FALSE)
	target.update_body_parts()
	var/list/traits = list(TRAIT_ARCYNE)
	if(stage != 2)
		traits += list(TRAIT_NOMOOD, TRAIT_SILVER_WEAK)
	if(stage > 1)
		traits += list(TRAIT_TOXIMMUNE, TRAIT_NOHUNGER, TRAIT_NOBREATH, TRAIT_UNLYCKERABLE, TRAIT_LIMBATTACHMENT)
	if(stage == 3)
		traits += list(TRAIT_NOPAIN, TRAIT_BLOODLOSS_IMMUNE)
		ADD_TRAIT(target, TRAIT_MONSTROUS, "lesser_rituos")
	for(var/trait in traits)
		if(!HAS_TRAIT(target, trait))
			ADD_TRAIT(target, trait, "lesser_rituos")
	var/list/config = list("mastery" = FALSE, "major" = 0, "minor" = 0, "utilities" = 0)

	if(LAZYLEN(target.mind.mage_aspect_config))
		config = target.mind.mage_aspect_config.Copy()
	if(stage < 3)
		config["minor"] += 1
		config["utilities"] += 3
	target.mind.setup_mage_aspects(config)
	playsound(center, 'sound/misc/lava_death.ogg', 100, FALSE)
	to_chat(target, span_notice("Death is not an end. My soul is Hers."))
	new /obj/effect/temp_visual/zizo_ring(center)
	var/obj/effect/abstract/particle_holder/burst = new(center, /particles/zizo_burst)
	QDEL_IN(burst, 1.4 SECONDS)
	target.Knockdown(5 SECONDS)
	target.emote("agony")
	for(var/atom/A in range(7, center))
		if(A.light_on && A.light_outer_range)
			zizo_flicker(A)
	if(stage == 3)
		if(HAS_TRAIT(target, TRAIT_WARLOCK))
			grant_poke_spell_zizo_warlock(target)
		else
			grant_poke_spell_zizo(target)

/datum/ritual/fleshcrafting/immortality
	lesser = TRUE
	name = "Flawed Immortality"
	icon_type = /obj/item/organ/heart
	desc = "Sacrifice an Aasimar to obtain a flawed version of immortality. Not as useful as you might expect."
	center_requirement = /mob/living/carbon/human
	n_req = /mob/living/carbon/human
	research_cost = 10

/datum/ritual/fleshcrafting/immortality/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	var/mob/living/carbon/human/victim = locate() in get_step(center, NORTH)
	if(!(is_species(victim, /datum/species/aasimar)))
		to_chat(user, span_danger("The sacrifice must be an Aasimar."))
		return
	victim.set_species(/datum/species/human/northern)
	ADD_TRAIT(target, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NODEATH, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOLIMBDISABLE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NODISMEMBER, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_BLOODLOSS_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOHARDCRIT, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_ZOMBIE_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_RESISTCOLD, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_RESISTHEAT, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_PACIFISM, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_NOSOFTCRIT, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_SPELLCOCKBLOCK, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_MONSTROUS, TRAIT_GENERIC)
	ADD_TRAIT(target, TRAIT_SILVER_WEAK, TRAIT_GENERIC)
	to_chat(target, span_notice("ZIZO EMPOWERS ME!! SOMETHING HAS GONE WRONG, THE RITUAL FAILED BUT WHAT IT LEFT ME WITH IS STILL POWER!!"))
	target.mind.AddSpell(new /obj/effect/proc_holder/spell/self/regenerate)
	target.change_stat(STATKEY_STR, -3)
	target.change_stat(STATKEY_SPD, -4)
	target.Knockdown(5 SECONDS)
	target.emote("agony")

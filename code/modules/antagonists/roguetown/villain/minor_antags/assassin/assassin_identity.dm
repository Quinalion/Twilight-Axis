/datum/assassin_identity
	var/datum/dna/identity_dna
	var/list/appearance = list()
	var/list/body_features = list()
	var/list/organ_appearance = list()
	var/datum/voicepack/male_voice
	var/datum/voicepack/female_voice
	var/static/list/appearance_fields = list(
		"icon", "real_name", "nickname", "job", "advjob", "gender",
		"pronouns", "age", "pose_text",
		"hair_color", "hairstyle", "facial_hair_color", "facial_hairstyle",
		"skin_tone", "detail_color", "eye_color", "lip_style", "lip_color",
		"shavelevel", "has_stubble", "voice_type", "voice_pitch", "voice_color",
		"vocal_bark", "vocal_bark_id", "vocal_current_bark", "vocal_pitch",
		"vocal_pitch_range", "vocal_speed", "vocal_volume", "deathsound",
		"flavortext", "flavortext_cached", "nsfwflavortext",
		"nsfwflavortext_cached", "rumour", "rumour_cached", "noble_gossip",
		"noble_gossip_cached", "headshot_link", "headshot_artist_credit",
		"headshot_artist_link", "img_gallery", "nsfw_img_gallery",
		"mob_descriptors", "custom_descriptors",
	)

/datum/assassin_identity/New(mob/living/carbon/human/source)
	identity_dna = new
	source.dna.copy_dna(identity_dna)
	identity_dna.features = deepCopyList(source.dna.features)
	male_voice = source.dna.species.soundpack_m
	female_voice = source.dna.species.soundpack_f
	for(var/field in appearance_fields)
		appearance[field] = copyAppearanceValue(source.vars[field])
	for(var/obj/item/bodypart/part as anything in source.bodyparts)
		var/list/features = list()
		for(var/datum/bodypart_feature/feature as anything \
			in part.bodypart_features)
			features += feature.copy_feature()
		body_features[part.body_zone] = features
	for(var/slot in getAssassinAppearanceSlots(source))
		var/obj/item/organ/organ = source.getorganslot(slot)
		if(!organ)
			organ_appearance[slot] = null
			continue
		organ_appearance[slot] = organ.create_organ_dna()
	return ..()

/datum/assassin_identity/Destroy()
	QDEL_NULL(identity_dna)
	for(var/zone in body_features)
		var/list/features = body_features[zone]
		QDEL_LIST(features)
	for(var/slot in organ_appearance)
		qdel(organ_appearance[slot])
	return ..()

/proc/getAssassinAppearanceSlots(
	mob/living/carbon/human/source)
	var/list/slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_TESTICLES,
		ORGAN_SLOT_BREASTS, ORGAN_SLOT_VAGINA, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS)
	for(var/obj/item/organ/organ as anything in source.internal_organs)
		if(organ.visible_organ)
			slots |= organ.slot
	return slots

/datum/assassin_identity/proc/copyAppearanceValue(value)
	if(islist(value))
		return deepCopyList(value)
	if(istype(value, /sound))
		return sound(value)
	return value

/datum/assassin_identity/proc/applyTo(mob/living/carbon/human/recipient)
	var/datum/assassin_body_state/health = new(recipient,
		recipient.dna.species.type != identity_dna.species.type)
	var/obj/item/undies/underwear = recipient.underwear
	recipient.underwear = null
	recipient.dna.features = deepCopyList(identity_dna.features)
	recipient.set_species(identity_dna.species.type, icon_update = FALSE)
	recipient.underwear = underwear
	recipient.dna.unique_enzymes = identity_dna.unique_enzymes
	recipient.dna.uni_identity = identity_dna.uni_identity
	recipient.dna.blood_type = identity_dna.blood_type
	recipient.dna.real_name = identity_dna.real_name
	recipient.dna.features = deepCopyList(identity_dna.features)
	recipient.dna.body_markings = deepCopyList(identity_dna.body_markings)
	recipient.dna.species.soundpack_m = male_voice
	recipient.dna.species.soundpack_f = female_voice
	for(var/field in appearance)
		recipient.vars[field] = copyAppearanceValue(appearance[field])
	recipient.name = recipient.real_name
	for(var/slot in (getAssassinAppearanceSlots(recipient) | organ_appearance))
		var/obj/item/organ/old_organ = recipient.getorganslot(slot)
		var/datum/organ_dna/organ_dna = organ_appearance[slot]
		if(old_organ && (!organ_dna || old_organ.type != organ_dna.organ_type))
			old_organ.Remove(recipient, TRUE)
			QDEL_NULL(old_organ)
		var/obj/item/organ/organ = old_organ
		if(organ_dna)
			if(!organ)
				organ = organ_dna.create_organ()
				organ.Insert(recipient, TRUE, FALSE)
			else
				organ_dna.imprint_organ(organ)
			organ.update_accessory_colors()
			recipient.dna.organ_dna[slot] = organ.create_organ_dna()
		else
			var/datum/organ_dna/absent = new
			absent.disabled = TRUE
			recipient.dna.organ_dna[slot] = absent
	recipient.remove_all_bodypart_features()
	for(var/zone in body_features)
		var/obj/item/bodypart/part = recipient.get_bodypart(zone)
		if(!part)
			continue
		for(var/datum/bodypart_feature/feature as anything \
			in body_features[zone])
			part.clone_bodypart_feature(feature)
	apply_markings_to_body_parts(recipient.dna.body_markings, recipient)
	recipient.dna.update_body_size()
	health.restoreTo(recipient)
	qdel(health)
	recipient.regenerate_icons()

/datum/assassin_body_state
	var/list/limbs = list()
	var/list/wounds = list()
	var/list/bandages = list()
	var/list/embedded = list()
	var/list/organs = list()
	var/list/preserved_organs = list()
	var/toxin_damage
	var/eye_blindness
	var/eye_blurriness
	var/blind_from_damage
	var/nearsighted_from_damage
	var/list/equipment = list()
	var/list/held_items
	var/static/list/equipment_slots = list(
		SLOT_HEAD, SLOT_WEAR_MASK, SLOT_GLASSES, SLOT_MOUTH, SLOT_NECK,
		SLOT_GLOVES, SLOT_SHOES,
	)
	var/static/list/limb_fields = list(
		"brute_dam", "burn_dam", "stamina_dam", "rotted", "skeletonized",
		"grievously_wounded", "bandage_health",
	)
	var/static/list/organ_fields = list(
		"damage", "prev_damage", "organ_flags", "deaf", "damaged",
	)

/datum/assassin_body_state/New(mob/living/carbon/human/source, changing_species)
	toxin_damage = source.toxloss
	eye_blindness = source.eye_blind
	eye_blurriness = source.eye_blurry
	blind_from_damage = HAS_TRAIT_FROM(source, TRAIT_BLIND, EYE_DAMAGE)
	nearsighted_from_damage = HAS_TRAIT_FROM(source,
		TRAIT_NEARSIGHT, EYE_DAMAGE)
	held_items = source.held_items.Copy()
	for(var/slot in equipment_slots)
		equipment["[slot]"] = source.get_item_by_slot(slot)
	// Keep injuries out of the species change's limb and organ cleanup.
	for(var/obj/item/bodypart/part as anything in source.bodyparts)
		var/list/state = list()
		for(var/field in limb_fields)
			state[field] = part.vars[field]
		limbs[part.body_zone] = state
		var/list/part_wounds = list()
		for(var/datum/wound/wound as anything in part.wounds?.Copy())
			part_wounds[wound] = wound.bleed_rate
			wound.remove_from_bodypart()
		wounds[part.body_zone] = part_wounds
		bandages[part.body_zone] = part.bandage
		part.bandage = null
		embedded[part.body_zone] = part.embedded_objects
		part.embedded_objects = list()
	var/list/appearance_slots = getAssassinAppearanceSlots(source)
	if(changing_species)
		for(var/slot in source.dna.species.organs)
			if(!(slot in appearance_slots))
				preserved_organs[slot] = source.getorganslot(slot)
	for(var/obj/item/organ/organ as anything in source.internal_organs.Copy())
		var/list/state = list()
		for(var/field in organ_fields)
			if(field in organ.vars)
				state[field] = organ.vars[field]
		organs[organ.slot] = state
		if(changing_species && !(organ.slot in appearance_slots))
			preserved_organs[organ.slot] = organ
			removeOrgan(organ, source)
	return ..()

/datum/assassin_body_state/proc/removeOrgan(
	obj/item/organ/organ, mob/living/carbon/human/owner)
	if(istype(organ, /obj/item/organ/brain))
		var/obj/item/organ/brain/brain = organ
		brain.Remove(owner, TRUE, TRUE)
	else
		organ.Remove(owner, TRUE)

/datum/assassin_body_state/proc/restoreTo(mob/living/carbon/human/recipient)
	recipient.toxloss = toxin_damage
	// Keep the actual brain and its traumas rather than a regenerated copy.
	for(var/slot in preserved_organs)
		var/obj/item/organ/replacement = recipient.getorganslot(slot)
		if(replacement)
			removeOrgan(replacement, recipient)
			qdel(replacement)
		var/obj/item/organ/original = preserved_organs[slot]
		original?.Insert(recipient, TRUE, FALSE)
	for(var/zone in limbs)
		var/obj/item/bodypart/part = recipient.get_bodypart(zone)
		if(!part)
			continue
		var/list/state = limbs[zone]
		for(var/field in state)
			part.vars[field] = state[field]
		var/list/part_wounds = wounds[zone]
		for(var/datum/wound/wound as anything in part_wounds)
			wound.apply_to_bodypart(part, silent = TRUE)
			wound.set_bleed_rate(part_wounds[wound])
		part.bandage = bandages[zone]
		part.embedded_objects = embedded[zone]
		for(var/obj/item/item as anything in part.embedded_objects)
			item.embedded_host = recipient
		part.update_bodypart_damage_state()
		part.update_disabled()
	for(var/slot in organs)
		var/obj/item/organ/organ = recipient.getorganslot(slot)
		if(!organ)
			continue
		var/list/state = organs[slot]
		for(var/field in state)
			if(field in organ.vars)
				organ.vars[field] = state[field]
	recipient.set_blindness(eye_blindness)
	recipient.set_blurriness(eye_blurriness)
	if(blind_from_damage)
		recipient.become_blind(EYE_DAMAGE)
	if(nearsighted_from_damage)
		recipient.become_nearsighted(EYE_DAMAGE)
	for(var/slot in equipment)
		var/obj/item/item = equipment[slot]
		if(item && item.loc == get_turf(recipient))
			recipient.equip_to_slot_if_possible(item, text2num(slot),
				disable_warning = TRUE)
	for(var/hand in 1 to length(held_items))
		var/obj/item/item = held_items[hand]
		if(item && item.loc == get_turf(recipient))
			recipient.put_in_hand(item, hand)
	recipient.updatehealth()

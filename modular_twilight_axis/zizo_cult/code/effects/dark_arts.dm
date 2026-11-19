/datum/status_effect/bloodlink
	id = "bloodlink"
	duration = 10 MINUTES
	tick_interval = 5 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bloodlink
	var/mob/living/carbon/human/partner

/datum/status_effect/bloodlink/on_creation(mob/living/new_owner, mob/living/carbon/human/linked)
	partner = linked
	. = ..()

/datum/status_effect/bloodlink/on_apply()
	. = ..()
	to_chat(owner, span_danger("A foreign heartbeat coils around my own."))
	owner.emote("scream")

/datum/status_effect/bloodlink/tick()
	if(QDELETED(partner) || partner.stat == DEAD)
		qdel(src)
		return
	var/turf/owner_turf = get_turf(owner)
	var/turf/partner_turf = get_turf(partner)
	if(!owner_turf || !partner_turf)
		return
	if(owner_turf.z != partner_turf.z || get_dist(owner, partner) > 7)
		owner.adjustOxyLoss(4)
		owner.Jitter(4)
		if(prob(30))
			to_chat(owner, span_danger("The thread draws taut. I must find [partner.real_name]."))

/atom/movable/screen/alert/status_effect/bloodlink
	name = "Blood Bond"
	desc = "For ten minutes, being more than seven tiles from your partner causes oxygen damage every five seconds. The bond ends if your partner dies."
	icon_state = "debuff"

/datum/component/light_vulnerability
	var/burn_damage = 5

/datum/component/light_vulnerability/Initialize(damage = 5, duration = 0)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	burn_damage = damage
	if(duration)
		QDEL_IN(src, duration)
	RegisterSignal(parent, COMSIG_HUMAN_LIFE, PROC_REF(check_light))

/datum/component/light_vulnerability/proc/check_light(mob/living/carbon/human/H)
	if(!ishuman(H) || H.stat == DEAD)
		return
	var/turf/T = get_turf(H)
	if(T && T.get_lumcount() >= 0.75)
		H.adjustFireLoss(burn_damage)
		if(prob(30))
			to_chat(H, span_danger("The light scours the Dark Lady's mark from my flesh."))

/datum/status_effect/shadowform
	id = "shadowform"
	duration = -1
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/shadowform
	var/obj/effect/abstract/particle_holder/shadow_particles
	var/list/granted_spells = list()
	var/datum/mind/spell_mind
	var/datum/weakref/changed_species
	var/original_species_name
	var/list/granted_traits = list(
		TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_NOBREATH, TRAIT_NOSLEEP,
		TRAIT_BLOODLOSS_IMMUNE, TRAIT_NOMETABOLISM, TRAIT_TOXIMMUNE,
		TRAIT_SILVER_WEAK, TRAIT_MONSTROUS, TRAIT_NOFIRE,
		TRAIT_FIRE_RESIST, TRAIT_RESISTHEAT, TRAIT_NITEVISION,
	)

/datum/status_effect/shadowform/on_apply()
	var/mob/living/carbon/human/target = owner
	if(!istype(target) || !target.dna || !target.mind)
		return FALSE
	. = ..()
	for(var/trait in granted_traits)
		ADD_TRAIT(target, trait, id)
	target.update_sight()
	changed_species = WEAKREF(target.dna.species)
	original_species_name = target.dna.species.name
	target.dna.species.name = "???"
	target.add_filter("shadowform_tint", 1,
		list("type" = "color", "color" = "#000000"))
	target.add_filter("shadowform", 2,
		list("type" = "outline", "color" = "#2b0a3d", "size" = 1))
	shadow_particles = new(target, /particles/zizo_shadow, PARTICLE_ATTACH_MOB)
	spell_mind = target.mind
	var/list/spell_types = list(
		/obj/effect/proc_holder/spell/invoked/shadow_snuff,
		/obj/effect/proc_holder/spell/self/shadow_jaunt,
	)
	for(var/spell_type in spell_types)
		if(spell_mind.has_spell(spell_type))
			continue
		var/datum/spell = new spell_type
		spell_mind.AddSpell(spell)
		granted_spells += spell

/datum/status_effect/shadowform/proc/clearShadowForm()
	for(var/trait in granted_traits)
		REMOVE_TRAIT(owner, trait, id)
	for(var/datum/spell as anything in granted_spells)
		if(!QDELETED(spell) && (spell in spell_mind?.spell_list))
			spell_mind.RemoveSpell(spell)
	granted_spells.Cut()
	spell_mind = null
	var/datum/species/species = changed_species?.resolve()
	if(species && species.name == "???")
		species.name = original_species_name
	changed_species = null
	QDEL_NULL(shadow_particles)
	if(!QDELETED(owner))
		owner.remove_filter(list("shadowform", "shadowform_tint"))
		owner.update_sight()

/datum/status_effect/shadowform/on_remove()
	clearShadowForm()
	return ..()

/datum/status_effect/shadowform/be_replaced()
	clearShadowForm()
	return ..()

/datum/status_effect/shadowform/tick()
	var/turf/place = get_turf(owner)
	if(!place)
		return
	if(place.get_lumcount() >= 0.75)
		owner.adjustFireLoss(5)
	else
		owner.adjustBruteLoss(-5)
		owner.adjustFireLoss(-5)
		owner.heal_wounds(5)

/atom/movable/screen/alert/status_effect/shadowform
	var/obj/effect/abstract/particle_holder/shadow_particles

/datum/status_effect/shadowform/on_apply()
	. = ..()
	owner.add_filter("shadowform", 2, list(type = "outline", color = "#2b0a3d", size = 1))
	shadow_particles = new(owner, /particles/zizo_shadow, PARTICLE_ATTACH_MOB)

/datum/status_effect/shadowform/on_remove()
	. = ..()
	owner.remove_filter("shadowform")
	QDEL_NULL(shadow_particles)

/datum/status_effect/shadowform/tick()
	var/turf/T = get_turf(owner)
	if(T && T.get_lumcount() < 0.75)
		owner.adjustBruteLoss(-5)
		owner.adjustFireLoss(-5)
		owner.heal_wounds(5)

/atom/movable/screen/alert/status_effect/shadowform
	name = "Shadow Form"
	desc = "Regenerate in darkness. Bright light causes burns. Your transformed body is vulnerable to silver."
	icon_state = "buff"

/obj/structure/rune_ward/zizo
	name = "bloody sigil"
	desc = "Strange runics smeared in blood."
	icon = 'modular_twilight_axis/zizo_cult/icons/effects/effects.dmi'
	icon_state = "blood_snare"
	alpha = 45
	max_integrity = 500
	checks_antimagic = FALSE
	var/charges = 3
	var/effect = "bleed"
	var/snare_damage = 120

/obj/structure/rune_ward/zizo/Crossed(atom/movable/AM)
	if(!isliving(AM) || AM.throwing || is_zizo_cult_member(AM))
		return
	var/mob/living/L = AM
	if((L.movement_type & (FLYING|FLOATING)) || L.is_jumping || L.pulledby)
		return
	if(L.mob_timers["rune_ward_immunity"] > world.time)
		return
	L.mob_timers["rune_ward_immunity"] = world.time + 3 SECONDS
	log_combat(L, src, "triggered [name] placed by [owner_name] ([owner_ckey]) at [AREACOORD(src)]")
	rune_effect(L)
	trigger_visual()
	consume()

/obj/structure/rune_ward/zizo/proc/consume()
	charges--
	if(charges <= 0)
		qdel(src)

/obj/structure/rune_ward/zizo/trigger_visual()
	new /obj/effect/temp_visual/cult/sparks(get_turf(src))

/obj/structure/rune_ward/zizo/rune_effect(mob/living/L)
	playsound(src, 'sound/magic/blade_burst.ogg', 80, TRUE)
	L.Slowdown(6)
	L.emote("scream")
	switch(effect)
		if("poison")
			L.reagents?.add_reagent(/datum/reagent/berrypoison, 25)
			L.Jitter(4)
			to_chat(L, span_danger("<B>Tainted blood erupts from the sigil!</B>"))
		if("stun")
			to_chat(L, span_danger("<B>The blood-written ward locks my limbs!</B>"))
			L.electrocute_act(20, src)
			L.Paralyze(60)
		else
			to_chat(L, span_danger("<B>Blades of blood tear upward through my flesh!</B>"))
			new /obj/effect/temp_visual/blade_burst(get_turf(src))
			applyBladeDamage(L)

/obj/structure/rune_ward/zizo/proc/applyBladeDamage(mob/living/target)
	var/blocked = target.run_armor_check(BODY_ZONE_CHEST, "stab",
		armor_penetration = PEN_HEAVY, damage = snare_damage,
		blade_dulling = BCLASS_STAB, intdamfactor = 1,
		pen_info = 1, no_debuff = TRUE)
	if(!target.apply_damage(snare_damage, BRUTE, BODY_ZONE_CHEST, blocked))
		return
	var/wound_damage = max(0, snare_damage - blocked)
	if(!wound_damage || !iscarbon(target))
		return
	var/mob/living/carbon/victim = target
	var/obj/item/bodypart/chest = victim.get_bodypart(BODY_ZONE_CHEST)
	var/mob/living/attacker = owner_ref?.resolve()
	chest?.bodypart_attacked_by(BCLASS_STAB, wound_damage, attacker,
		BODY_ZONE_CHEST, crit_message = TRUE, pen_info = 1, no_debuff = TRUE)

/datum/status_effect/fulmenor
	id = "fulmenor"
	effectedstats = list(STATKEY_STR = 6, STATKEY_CON = 6)
	duration = 1 MINUTES
	tick_interval = 5 SECONDS
	alert_type = null

/datum/status_effect/fulmenor/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_MONSTROUS, id)
	ADD_TRAIT(H, TRAIT_SILVER_WEAK, "fulmenor")
	H.enter_frenzymod()
	to_chat(H, span_notice("Something ravenous stirs beneath my skin."))
	return TRUE

/datum/status_effect/fulmenor/tick()
	var/mob/living/carbon/human/H = owner
	H.heal_overall_damage(10, 10)

/datum/status_effect/fulmenor/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.exit_frenzymod()
	REMOVE_TRAIT(H, TRAIT_MONSTROUS, id)
	REMOVE_TRAIT(H, TRAIT_SILVER_WEAK, "fulmenor")
	to_chat(H, span_notice("The borrowed hunger loosens its hold."))

/datum/status_effect/fulmenor/be_replaced()
	var/mob/living/carbon/human/H = owner
	H.exit_frenzymod()
	REMOVE_TRAIT(H, TRAIT_MONSTROUS, id)
	REMOVE_TRAIT(H, TRAIT_SILVER_WEAK, "fulmenor")
	return ..()

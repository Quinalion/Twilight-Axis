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
	to_chat(owner, span_danger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	owner.emote("scream")

/datum/status_effect/bloodlink/tick()
	if(QDELETED(partner) || partner.stat == DEAD)
		qdel(src)
		return
	if(get_dist(owner, partner) > 7)
		owner.adjustOxyLoss(4)
		owner.Jitter(4)
		if(prob(30))
			to_chat(owner, span_danger("My chest aches! Where is [partner.real_name]?!"))

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
			to_chat(H, span_danger("THE LIGHT BURNS!"))

/datum/status_effect/shadowform
	id = "shadowform"
	duration = -1
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/shadowform
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
	if(!isliving(AM) || AM.throwing || is_zizo(AM))
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
			to_chat(L, span_danger("<B>THE SIGIL SPRAYS FOUL BLOOD OVER ME!</B>"))
		if("stun")
			to_chat(L, span_danger("<B>THE SIGIL CRACKLES AND SEIZES MY LIMBS!</B>"))
			L.electrocute_act(20, src)
			L.Paralyze(60)
		else
			to_chat(L, span_danger("<B>BLOODY BLADES RISE FROM THE GROUND AND REND ME!</B>"))
			new /obj/effect/temp_visual/blade_burst(get_turf(src))
			var/mob/living/carbon/human/owner = owner_ref?.resolve()
			if(ishuman(owner) && ishuman(L))
				arcyne_strike(owner, L, null, snare_damage, BODY_ZONE_CHEST, 					BCLASS_STAB, armor_penetration = PEN_HEAVY, spell_name = "Blood Snare", 					damage_type = BRUTE, skip_animation = TRUE)
			else
				L.adjustBruteLoss(snare_damage)
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
	to_chat(H, span_notice("I WANT TO HURT PEOPLE!"))
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
	to_chat(H, span_notice("THE MONSTROUS HUNGER FADES FROM ME."))

/datum/status_effect/fulmenor/be_replaced()
	var/mob/living/carbon/human/H = owner
	H.exit_frenzymod()
	REMOVE_TRAIT(H, TRAIT_MONSTROUS, id)
	REMOVE_TRAIT(H, TRAIT_SILVER_WEAK, "fulmenor")
	return ..()

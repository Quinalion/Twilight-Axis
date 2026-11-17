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

/obj/effect/proc_holder/spell/invoked/shadow_snuff
	name = "Extinguish"
	desc = "Extinguish the targeted fire or light and any burning objects it contains."
	range = 7
	overlay_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	action_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	overlay_state = "zizocandle"
	recharge_time = 2 SECONDS
	chargedloop = null

/obj/effect/proc_holder/spell/invoked/shadow_snuff/cast(list/targets, mob/living/user)
	. = ..()
	var/atom/target = targets[1]
	if(!target)
		return FALSE
	if(isobj(target))
		var/obj/O = target
		O.extinguish()
	for(var/obj/O in target.contents)
		O.extinguish()
	return TRUE

/obj/effect/dummy/phased_mob/slaughter/shadow/relaymove(mob/user, direction)
	var/turf/dest = get_step(src, direction)
	if(!dest || dest.get_lumcount() >= 0.75)
		to_chat(user, span_warning("THERE IS LIGHT THERE."))
		return
	forceMove(dest)

/obj/effect/proc_holder/spell/self/shadow_jaunt
	name = "Shadow Jaunt"
	desc = "Become invisible and move through walls for five seconds. Requires darkness and cannot enter brightly lit tiles."
	overlay_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	action_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	overlay_state = "zizocloud"
	recharge_time = 1 MINUTES
	chargedloop = null

/obj/effect/proc_holder/spell/self/shadow_jaunt/cast(list/targets, mob/user = usr)
	. = ..()
	if(!ishuman(user))
		revert_cast()
		return FALSE
	var/turf/T = get_turf(user)
	if(T.get_lumcount() >= 0.75)
		to_chat(user, span_warning("IT'S TOO BRIGHT!"))
		revert_cast()
		return FALSE
	var/obj/effect/dummy/phased_mob/slaughter/shadow/holder = new(T)
	var/obj/effect/temp_visual/dir_setting/cult/phase/out/P = new(T, user.dir)
	P.color = "#2b0a3d"
	new /obj/effect/temp_visual/decoy/fading/halfsecond(T, user)
	user.visible_message(span_warning("[user] melts into the shadows."))
	user.forceMove(holder)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, end_jaunt), holder), 5 SECONDS)
	return TRUE

/datum/ritual/pitch/shadowform
	name = "Assume Shadow Form"
	desk = "Transform the target into a visibly monstrous shadow that regenerates in darkness but takes damage in bright light. Grant night vision, immunity to blood loss and toxins, and remove the need to breathe, eat or sleep. Grant Shadow Jaunt to move through walls in darkness and Extinguish to put out lights and fires. The target becomes vulnerable to silver."
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/clothing/cloak

/datum/ritual/pitch/shadowform/invoke(mob/living/user, turf/center)
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
	if(!do_after(user, 5 SECONDS))
		qdel(poo)
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

/datum/ritual/pitch/lightcurse
	name = "Inflict Light Sensitivity"
	desk = "Curse the donor of a blood-fed leech for ten minutes. Bright light repeatedly burns them."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/pitch/lightcurse/invoke(mob/living/user, turf/center)
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
				arcyne_strike(owner, L, null, snare_damage, BODY_ZONE_CHEST, BCLASS_STAB, armor_penetration = PEN_HEAVY, spell_name = "Blood Snare", damage_type = BRUTE, skip_animation = TRUE)
			else
				L.adjustBruteLoss(snare_damage)

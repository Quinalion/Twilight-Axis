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
	for(var/obj/item/I in owner.get_equipped_items() + owner.held_items)
		I.fire_act()
	for(var/obj/item/grabbing/G in owner.held_items)
		if(isliving(G.grabbed))
			var/mob/living/victim = G.grabbed
			victim.adjust_fire_stacks(3, /datum/status_effect/fire_handler/fire_stacks/dark)
			victim.ignite_mob()
			victim.adjustFireLoss(10)

/atom/movable/screen/alert/status_effect/shadowform
	name = "SCADUFORM"
	desc = ""
	icon_state = "buff"

/obj/effect/proc_holder/spell/invoked/shadow_snuff
	name = "Snuff"
	desc = "Snuff out a fire or light."
	range = 7
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
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
	name = "Scadu Jaunt"
	desc = "Turn invisible and move through walls. Only functions in darkness."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
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

/obj/effect/proc_holder/spell/invoked/dark_grip
	name = "Scadu Grip"
	desc = "Requires an aggressive grab. Engulf your target in dark flame!"
	recharge_time = 60 SECONDS
	invocation_type = "emote"
	overlay_icon = 'icons/mob/actions/vampspells.dmi'
	action_icon = 'icons/mob/actions/vampspells.dmi'
	overlay_state = "potence"
	action_icon_state = "potence"

/obj/effect/proc_holder/spell/invoked/dark_grip/cast(list/targets, mob/living/user,)
	var/mob/living/target = targets[1]
	if(!target || target == user)
		to_chat(user, span_warning("You need a valid target to begin the wrestling!"))
		revert_cast()
		return FALSE

	if(user.pulling != target || user.grab_state < GRAB_AGGRESSIVE)
		to_chat(user, span_warning("You must have an aggressive grab on [target] to begin the wrestling!"))
		revert_cast()
		return FALSE

	var/datum/component/wrestle_combat_tracker/tracker = user.GetComponent(/datum/component/wrestle_combat_tracker)
	if(!tracker)
		tracker = user.AddComponent(/datum/component/wrestle_combat_tracker)

	to_chat(user, span_notice("Dark flame gathers in my palms!"))
	to_chat(target, span_userdanger("[user]'s palms burn with dark flame!"))
	tracker.channeling_throw = TRUE
	user.emote("attack")
	if(!do_after(user, 1 SECONDS, target = target))
		tracker.channeling_throw = FALSE
		revert_cast()
		return FALSE

	if(target.has_status_effect(/datum/status_effect/buff/clash))
		target.remove_status_effect(/datum/status_effect/buff/clash)
		user.stop_pulling(TRUE)
		user.Knockdown(2 SECONDS)
		to_chat(user, span_notice("A reversal!"))
		playsound(user, 'modular_twilight_axis/sound/zizo_cult/combat/crowdcheer.ogg', 100, TRUE)
	else
		target.adjust_fire_stacks(8, /datum/status_effect/fire_handler/fire_stacks/dark)
		target.ignite_mob()
		target.apply_damage(40, BURN, user.zone_selected || BODY_ZONE_CHEST)
		playsound(user, 'sound/combat/tf2crit.ogg', 100, TRUE)
	tracker.channeling_throw = FALSE
	return TRUE

/datum/ritual/pitch/fireresist
	name = "Fire Monk"
	icon_type = /obj/effect/proc_holder/spell/invoked/dark_grip
	desc = "Reach your physical capacity in martial arts. All grapple checks are maximized, and you learn master wrestling. Learn a move to engulf your grapple target in dark flame."
	passive = TRUE
	research_cost = 3

/datum/ritual/pitch/fireresist/apply_passive(mob/living/carbon/human/H)
	H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_MASTER)
	ADD_TRAIT(H, TRAIT_PEAK_GRAPPLER, TRAIT_GENERIC)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/dark_grip)
	return

/datum/ritual/pitch/shadowform
	name = "Scaduform"
	icon_type = /obj/effect/proc_holder/spell/invoked/shadow_snuff
	desc = "Transform into a dark shadow that takes damage in the light. You can jaunt through darkness and remotely snuff lights. Your body becomes inhumen, recognizably monstrous, but non-living and immune to bloodloss. Anything you touch is lit aflame, including equipment on the body. And people you grab."
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
	var/poo = new /obj/effect/temp_visual/opengate/fivesec(center)
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
	for(var/obj/item/I in target.get_equipped_items() + target.held_items)
		I.fire_act()
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
	name = "Curse of Radiance"
	icon_type = /obj/item/natural/worms/leech
	desc = "Curse a target to burn in the light. Requires a leech that fed from your target."
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
	icon = 'modular_twilight_axis/icons/zizo_cult/obj/sigils.dmi'
	icon_state = "lesser"
	alpha = 45
	max_integrity = 500
	checks_antimagic = FALSE
	var/charges = 3
	var/effect = "bleed"
	var/snare_damage = 120

/obj/structure/rune_ward/zizo/is_ally(mob/M)
	return is_zizo(M)

/obj/structure/rune_ward/zizo/consume()
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

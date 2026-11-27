/obj/item/rogueweapon/zizo/neant
	name = "corrupted avantyne scythe"
	desc = "A scythe of corrupted avantyne, fitted with a long chain. Its purple blade can extract lux and fire profane projectiles."
	icon_state = "neant"
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon64.dmi'
	drop_sound = 'modular_twilight_axis/zizo_cult/sound/blade_drop.ogg'
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = FIRE_PROOF
	dropshrink = 0.75
	max_blade_int = 200
	max_integrity = 400
	possible_item_intents = list(/datum/intent/spear/cut/oneh)
	gripped_intents = list(/datum/intent/spear/cut/bardiche/cult, /datum/intent/spear/cut/bardiche/cleave, /datum/intent/spear/bash, /datum/intent/shoot/neant)
	thrown_bclass = BCLASS_CUT
	blade_dulling = DULLING_BASHCHOP
	wdefense = 8
	force = 28
	force_wielded = 38
	throwforce = 25
	minstr = 13
	sellprice = 0
	wbalance = WBALANCE_HEAVY
	associated_skill = /datum/skill/combat/polearms
	wlength = WLENGTH_GREAT

	COOLDOWN_DECLARE(fire_projectile)

/datum/intent/spear/cut/bardiche/cult
	penfactor = PEN_MEDIUM

/datum/intent/spear/cut/bardiche/cleave/cult
	penfactor = PEN_MEDIUM

/obj/item/rogueweapon/zizo/neant/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -7,"sy" = 2,"nx" = 7,"ny" = 3,"wx" = -2,"wy" = 1,"ex" = 1,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 30,"eturn" = -30,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 5,"sy" = -3,"nx" = -5,"ny" = -2,"wx" = -5,"wy" = -1,"ex" = 3,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 7,"sturn" = -7,"wturn" = 16,"eturn" = -22,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogueweapon/zizo/neant/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "NEANT")

/obj/item/rogueweapon/zizo/neant/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/zizo/neant/attack(mob/living/M, mob/living/user)
	if(user.used_intent.tranged)
		return
	return ..()

/obj/item/rogueweapon/zizo/neant/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!HAS_TRAIT(user, TRAIT_CABAL) || !istype(user.patron, /datum/patron/inhumen/zizo))
		return
	if(user.used_intent?.tranged)
		handle_magick(user, target)
		return
	if(!ishuman(target))
		return
	if(check_zone(user.zone_selected) != BODY_ZONE_CHEST)
		return
	var/mob/living/carbon/human/H = target
	if(!H.has_status_effect(/datum/status_effect/debuff/devitalised))
		return
	var/dead = H.stat == DEAD
	if((H.health < H.crit_threshold) || dead)
		var/speed = dead ? 3 SECONDS : 7 SECONDS
		visible_message(user, span_notice("[src] lights up and begins to tear at [target]..."))
		if(!do_after(user, speed, H))
			return
		var/obj/item/bodypart/chest/C = H.get_bodypart(BODY_ZONE_CHEST)
		if(!C)
			return
		playsound(get_turf(user), 'sound/surgery/scalpel2.ogg', 70)
		if(do_after(user, 0.5 SECONDS, target))
			C.add_wound(/datum/wound/slash/incision)

		playsound(get_turf(user), 'sound/surgery/organ2.ogg', 70)
		if(do_after(user, 0.5 SECONDS, target))
			C.add_wound(/datum/wound/fracture/chest)

		new /obj/item/reagent_containers/lux(get_turf(target))

		H.apply_status_effect(/datum/status_effect/debuff/devitalised)
		SEND_SIGNAL(user, COMSIG_LUX_EXTRACTED, target)
		record_featured_stat(FEATURED_STATS_CRIMINALS, user)
		record_round_statistic(STATS_LUX_HARVESTED)

		H.add_splatter_floor()
		H.adjustBruteLoss(20)
		visible_message(user, span_notice("The blade of [src] draws the lux from [target]!"))

/obj/item/rogueweapon/zizo/neant/proc/handle_magick(mob/living/user, atom/target)
	if(!COOLDOWN_FINISHED(src, fire_projectile))
		return
	var/client/client = user.client
	if(!client?.chargedprog)
		return

	var/startloc = get_turf(src)
	var/obj/projectile/bullet/neant/PJ = new(startloc)
	PJ.aim_peak = 80
	PJ.starting = startloc
	PJ.firer = user
	PJ.fired_from = src
	PJ.original = target
	playsound(get_turf(user),'modular_twilight_axis/zizo_cult/sound/scythe_fire.ogg', 70)

	if(user.STAPER > 8)
		PJ.aim_peak += (user.STAPER - 8) * 3

	if(user.STAINT > 10)
		PJ.damage = PJ.damage * (user.STAINT / 10)
		PJ.aim_peak += (user.STAINT - 10) * 3

	new /obj/effect/temp_visual/dir_setting/firing_effect/neant(get_step(user, user.dir), user.dir)
	PJ.preparePixelProjectile(target, user)
	PJ.fire()
	user.changeNext_move(CLICK_CD_RANGE)
	COOLDOWN_START(src, fire_projectile, 4 SECONDS)

/obj/projectile/bullet/neant
	name = "Profane Evisceration"
	icon = 'modular_twilight_axis/zizo_cult/icons/effects/effects.dmi'
	icon_state = "scythe_projectile"
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	range = 8
	damage = 25
	armor_penetration = 30
	damage_type = BRUTE
	woundclass = BCLASS_CUT
	flag =  "piercing"
	speed = 1

/obj/effect/temp_visual/dir_setting/firing_effect/neant
	icon = 'modular_twilight_axis/zizo_cult/icons/effects/effects.dmi'
	icon_state = "scythe_firing"
	duration = 4

/datum/intent/shoot/neant
	name = "shoot"
	icon_state = "inshoot"
	warnie = "aimwarn"
	tranged = TRUE
	chargetime = 2 SECONDS
	no_early_release = TRUE
	noaa = TRUE
	charging_slowdown = 2

/datum/intent/shoot/neant/prewarning()
	if(mastermob)
		mastermob.visible_message(span_warning("[mastermob] draws [masteritem]!"))

/obj/item/rogueweapon/sword/long/zizo/cult
	name = "corrupted avantyne longsword"
	desc = "A longsword of corrupted avantyne, shaped through the rituals of Zizo."

/obj/item/rogueweapon/sword/sabre/zizo
	name = "corrupted avantyne sabre"
	desc = "A sabre of corrupted avantyne that drains life from its victims."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon32.dmi'
	icon_state = "sabre"
	max_blade_int = 300
	max_integrity = 300
	force = 26
	smeltresult = /obj/item/ingot/steel/zizo

/obj/item/rogueweapon/sword/sabre/zizo/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "SWORD")
	AddComponent(/datum/component/lifesteal, 15)

/obj/item/rogueweapon/sword/sabre/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/huntingknife/idagger/steel/cursed
	name = "corrupted avantyne dagger"
	desc = "A dagger of corrupted avantyne. Its blade can be coated with poison."
	force = 23
	max_blade_int = 250
	max_integrity = 200
	wdefense = 6
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon32.dmi'
	icon_state = "dagger"
	smeltresult = /obj/item/ingot/steel/zizo

/obj/item/rogueweapon/huntingknife/idagger/steel/cursed/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "DAGGER")

/obj/item/rogueweapon/huntingknife/idagger/steel/cursed/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/stoneaxe/battle/zizo
	name = "corrupted avantyne battle axe"
	desc = "A battle axe with a broad head of corrupted avantyne."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon32.dmi'
	icon_state = "battle_axe"
	wdefense = 5
	max_blade_int = 350
	max_integrity = 300
	possible_item_intents = list(/datum/intent/axe/cut, /datum/intent/axe/chop)
	gripped_intents = list(/datum/intent/axe/cut/cult, /datum/intent/axe/chop/cult, /datum/intent/axe/chop/heavy, /datum/intent/axe/bash/battle)
	smeltresult = /obj/item/ingot/steel/zizo

/datum/intent/axe/chop/cult
	intent_intdamage_factor = 1.3
	demolition_mod = 6
	swingdelay = 5
	damfactor = 1.6

/datum/intent/axe/cut/cult
	demolition_mod = 3
	damfactor = 1.4

/obj/item/rogueweapon/stoneaxe/battle/zizo/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "AXE")

/obj/item/rogueweapon/stoneaxe/battle/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/mace/steel/zizo
	name = "corrupted avantyne mace"
	desc = "A heavy mace of corrupted avantyne."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon32.dmi'
	icon_state = "mace"
	force = 30
	force_wielded = 38
	wdefense = 5
	max_integrity = 320
	special = /datum/special_intent/ground_smash/cult

/datum/special_intent/ground_smash/cult
	cooldown = 60 SECONDS
	tile_coordinates = list(list(0,0), list(0,1, 0.1 SECONDS), list(0,2, 0.2 SECONDS), list(1,0), list(1,1, 0.1 SECONDS), list(1,2, 0.1 SECONDS), list(-1,0), list(-1,1, 0.1 SECONDS), list(-1,2, 0.1 SECONDS))

/obj/item/rogueweapon/mace/steel/zizo/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "MACE")

/obj/item/rogueweapon/mace/steel/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/shield/tower/zizo
	name = "corrupted avantyne tower shield"
	desc = "A large tower shield reinforced with corrupted avantyne."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon32.dmi'
	icon_state = "tower_shield"
	force = 10
	throwforce = 10
	wdefense = 12
	coverage = 85
	max_integrity = 350
	smeltresult = /obj/item/ingot/steel/zizo

/obj/item/rogueweapon/shield/tower/zizo/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "SHIELD")

/obj/item/rogueweapon/shield/tower/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/rogueweapon/spear/zizo
	name = "corrupted avantyne spear"
	desc = "A spear tipped with corrupted avantyne."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon64.dmi'
	icon_state = "spear"

/obj/item/rogueweapon/spear/zizo/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "SPEAR")

/obj/item/rogueweapon/spear/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/greataxe/steel/doublehead/zizo
	name = "corrupted avantyne double-headed greataxe"
	desc = "A two-handed axe with a double head of corrupted avantyne."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon64.dmi'
	icon_state = "greataxe"
	special = /datum/special_intent/wave_swing/vicious
	max_blade_int = 400
	max_integrity = 380
	wdefense = 9
	minstr = 11
	force = 20
	force_wielded = 35

/obj/item/rogueweapon/greataxe/steel/doublehead/zizo/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "AXE")

/obj/item/rogueweapon/greataxe/steel/doublehead/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/obj/item/rogueweapon/halberd/glaive/zizo
	name = "corrupted avantyne glaive"
	desc = "A curved blade of corrupted avantyne mounted on a long pole."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/weapon64.dmi'
	icon_state = "glaive"

/obj/item/rogueweapon/halberd/glaive/zizo/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "GLAIVE")

/obj/item/rogueweapon/halberd/glaive/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_WEAPON)

/proc/reroll_gate_targets(gate_count)
	if(gate_count <= 0)
		return
	var/list/weighted = list()
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(!H.mind || H.stat == DEAD || is_zizo(H))
			continue
		var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
		if(!J || (J.type in list(/datum/job/roguetown/lord)) || J.type == /datum/job/roguetown/bandit || J.type == /datum/job/roguetown/wretch)
			continue
		if(gate_count == 1 && !(J.type in (list(ZIZO_CULT_TIER_TWO_ROLES))))
			continue
		if(gate_count > 1 && !(J.type in (list(ZIZO_CULT_TIER_THREE_ROLES))))
			continue
		weighted[H] = 1
		if(H.purity == TRUE)
			weighted[H] = 5

	GLOB.gate_targets = list()
	for(var/i in 1 to 5)
		if(!weighted.len)
			break
		var/mob/living/carbon/human/chosen = pickweight(weighted)
		GLOB.gate_targets += chosen
		weighted -= chosen


/proc/refresh_zizo_marks()
	for(var/image/old in GLOB.zizo_marks)
		for(var/client/C in GLOB.clients)
			C.images -= old
	GLOB.zizo_marks.Cut()
	for(var/mob/living/carbon/human/T in GLOB.gate_targets)
		if(QDELETED(T) || T.stat == DEAD)
			continue
		var/image/mark = image('modular_twilight_axis/icons/zizo_cult/effects/eldritch.dmi', T, "eye_pulse", ABOVE_ALL_MOB_LAYER)
		mark.pixel_y = 30
		GLOB.zizo_marks += mark
		for(var/datum/mind/M in SSmapping.retainer.cultists)
			var/client/C = M.current?.client
			if(C)
				C.images += mark

/proc/zizo_dist(atom/A, atom/B)
	return max(abs(A.x - B.x), abs(A.y - B.y)) + abs(A.z - B.z)

/proc/zizo_roll_start()
	refill_bestow_areas()


GLOBAL_LIST_EMPTY(zizo_bestow_areas)

/proc/refill_bestow_areas()
	if(!GLOB.zizo_bestow_areas)
		GLOB.zizo_bestow_areas = list()
	var/list/pool = list(
		/area/rogue/indoors/town/shop,
		/area/rogue/indoors/town/tavern,
		/area/rogue/indoors/town/church,
		/area/rogue/indoors/town/bath,
		/area/rogue/indoors/town/physician,
		/area/rogue/indoors/town/magician,
		/area/rogue/indoors/town/garrison,
		/area/rogue/indoors/town/warden,
		/area/rogue/outdoors/town,
	) - GLOB.zizo_bestow_areas
	while(GLOB.zizo_bestow_areas.len < 3 && pool.len)
		var/chosen = pick(pool)
		GLOB.zizo_bestow_areas += chosen
		pool -= chosen

/proc/zizo_bestow_alert(area/where, final)
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.mind && H.get_skill_level(/datum/skill/magic/arcane) > 0)
			to_chat(H, span_userdanger("Vile magick ripples out from [where.name]! Something evil has happened!"))
			if(!is_zizo(H))
				zizo_wonder(H, FALSE)
	for(var/obj/item/inqhound/hound in world)
		hound.say("REALMATIC DESTABILIZATION DETECTED AT [uppertext(where.name)]. HERETICAL ACTIVITY: LIKELY.")
	if(!final)
		return
	priority_announce("THE GODS WEEP. ASCENSION IS NIGH.", title = "Omen", sound = 'sound/villain/dreamer_warning.ogg')
	var/datum/particle_weather/gentle = new /datum/particle_weather/blood_rain_gentle
	SSParticleWeather.runningWeather = gentle
	gentle.start()


/datum/ritual/servantry/aspect
	name = "Open Gate"
	icon_type = /obj/item/necro_relics/necro_crystal
	desc = "REQUIRED TO UNLOCK ASCENSION. Activate the ritual to learn the locations it must be performed. It unlocks an Aspect that grants new research for the cult. MUST BE PERFORMED 3 TIMES TO UNLOCK ASCENSION."
	is_cultist_ritual = TRUE
	var/gate_count = 0
	var/in_progress = FALSE

/obj/effect/temp_visual/opengate
	icon = 'icons/effects/clan.dmi'
	icon_state = "summoning"
	dir = SOUTH
	randomdir = FALSE
	duration = 15 SECONDS
	layer = MASSIVE_OBJ_LAYER
	var/list/runes = list()

/obj/effect/temp_visual/opengate/Initialize(mapload, set_duration)
	if(set_duration)
		duration = set_duration
	. = ..()
	runes += new /obj/effect/temp_visual/cult/rune_spawn/rune7/wide(loc, duration, "#cc1010")

/obj/effect/temp_visual/opengate/Destroy()
	QDEL_LIST(runes)
	return ..()

/obj/effect/temp_visual/opengate/fivesec
	duration = 5 SECONDS

/proc/print_gate_sacrifice_info(mob/user)
	refill_bestow_areas()
	to_chat(user, span_warning("PERFORM THE RITE AT:"))
	for(var/atype in GLOB.zizo_bestow_areas)
		var/area/A = atype
		to_chat(user, span_notice("- [initial(A.name)]"))
	if(GLOB.gate_targets.len)
		to_chat(user, span_warning("SHE HUNGERS FOR:"))
		for(var/mob/living/carbon/human/H in GLOB.gate_targets)
			to_chat(user, span_notice("- [H.real_name]"))
	else
		to_chat(user, span_warning("NO SUITABLE SACRIFICE CAN BE FOUND YET."))

/turf/closed/wall/proc/zizo_collapse()
	var/datum/effect_system/smoke_spread/dust = new
	dust.set_up(0, src)
	dust.start()
	playsound(src, 'sound/misc/meteorimpact.ogg', 50, TRUE)
	dismantle_wall(1)

/proc/zizo_calamity(choice)
	if(choice == "BITE")
		SSmapping.add_world_trait(/datum/world_trait/zizo_bite, 0)
		GLOB.forecast = PARTICLEWEATHER_SNOW
		SSParticleWeather.run_weather(pick(/datum/particle_weather/snow_gentle, /datum/particle_weather/snow_storm))
		for(var/datum/mind/M in SSmapping.retainer.cultists)
			if(M.current)
				ADD_TRAIT(M.current, TRAIT_RESISTCOLD, "zizocultist")
		priority_announce("Inhumen cultists afflict Twilight Axis with Curse of Murk!", title = "Calamity", sound = 'sound/villain/dreamer_warning.ogg')
	if(choice == "STRAND")
		SSmapping.add_world_trait(/datum/world_trait/zizo_strand, 0)
		priority_announce("Inhumen cultists afflict Twilight Axis with Curse of Nightmares!", title = "Calamity", sound = 'sound/villain/dreamer_warning.ogg')
	if(choice == "TOIL")
		SSmapping.add_world_trait(/datum/world_trait/zizo_toil, 0)
		priority_announce("Inhumen cultists afflict Twilight Axis with Curse of Decay!", title = "Calamity", sound = 'sound/villain/dreamer_warning.ogg')
		var/list/town_walls = list()
		for(var/turf/closed/wall/W in world)
			if(istype(get_area(W), /area/rogue/indoors/town) || istype(get_area(W), /area/rogue/outdoors/town))
				town_walls += W
			CHECK_TICK
		var/list/collapsing = list()
		var/list/breaking = list()
		for(var/i in 1 to 5)
			if(!length(town_walls))
				break
			var/turf/closed/wall/epicenter = pick_n_take(town_walls)
			playsound(epicenter, 'modular_twilight_axis/sound/zizo_cult/misc/cavein.ogg', 200, TRUE)
			for(var/turf/closed/wall/W in range(3, epicenter))
				collapsing |= W
			for(var/obj/structure/O in range(3, epicenter))
				if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/structure/roguewindow))
					breaking |= O
		for(var/turf/closed/wall/W as anything in collapsing)
			new /obj/effect/temp_visual/cult/sparks(W)
			addtimer(CALLBACK(W, TYPE_PROC_REF(/turf/closed/wall, zizo_collapse)), 4 SECONDS)
		for(var/obj/structure/O as anything in breaking)
			addtimer(CALLBACK(O, TYPE_PROC_REF(/obj, take_damage), O.max_integrity, BRUTE, "", FALSE), 4 SECONDS)
	if(choice == "ROT")
		SSmapping.add_world_trait(/datum/world_trait/zizo_rot, 0)
		for(var/datum/mind/M in SSmapping.retainer.cultists)
			if(M.current)
				ADD_TRAIT(M.current, TRAIT_NOHUNGER, "zizocultist")
		priority_announce("Inhumen cultists afflict Twilight Axis with Curse of Rot!", title = "Calamity", sound = 'sound/villain/dreamer_warning.ogg')
		var/list/food = list()
		for(var/obj/item/reagent_containers/food/snacks/F in world)
			if(F.eat_effect != /datum/status_effect/debuff/rotfood && !prob(40))
				food += F
		for(var/obj/item/reagent_containers/food/snacks/F as anything in food)
			if(F.become_rotten())
				STOP_PROCESSING(SSobj, F)
			CHECK_TICK
	if(choice == "NOISE")
		SSmapping.add_world_trait(/datum/world_trait/zizo_noise, 0)
		priority_announce("Inhumen cultists afflict Twilight Axis with Curse of Madness!", title = "Calamity", sound = 'sound/villain/dreamer_warning.ogg')
	if(choice == "BLOOD")
		SSmapping.add_world_trait(/datum/world_trait/zizo_blood, 0)
		priority_announce("Inhumen cultists afflict Twilight Axis with Curse of Blood!", title = "Calamity", sound = 'sound/villain/dreamer_warning.ogg')
		for(var/turf/open/water/W in world)
			W.water_reagent = /datum/reagent/blood
			W.water_color = "#C80000"
			W.mapped = FALSE
			W.update_icon()
			CHECK_TICK
	if(choice == "PITCH")
		GLOB.todoverride = "night"
		settod()
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reset_tod_override)), 20 MINUTES)
		priority_announce("Inhumen cultists afflict Twilight Axis with Curse of Darkness!", title = "Calamity", sound = 'sound/villain/dreamer_warning.ogg')
		for(var/obj/machinery/light/roguestreet/L in GLOB.streetlamp_list)
			L.break_light_tube()
			L.burn_out()
			addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, fix)), 20 MINUTES)
		var/datum/round_event_control/lightsout/blackout = new
		SSgamemode.TriggerEvent(blackout, TRUE)

/datum/ritual/servantry/aspect/invoke(mob/living/user, turf/center)
	if(in_progress || gate_count >= 3 || !is_zizo(user))
		return
	var/mob/living/carbon/human/target = locate() in center.contents
	if(gate_count > 0)
		if(zizo_target_error(user, target, GLOB.gate_targets))
			print_gate_sacrifice_info(user)
			return
	refill_bestow_areas()
	var/area/here = get_area(center)
	var/valid_area
	for(var/atype in GLOB.zizo_bestow_areas)
		if(istype(here, atype))
			valid_area = atype
			break

	if(!valid_area)
		to_chat(user, span_warning("THIS PLACE IS NOT RIGHT. SEEK:"))
		for(var/atype in GLOB.zizo_bestow_areas)
			var/area/A = atype
			to_chat(user, span_notice("- [initial(A.name)]"))
		if(gate_count > 0 && tgui_alert(user, "REROLL GATE TARGETS?", "ZIZO", list("Reroll", "Cancel")) == "Reroll")
			reroll_gate_targets(gate_count)
			print_gate_sacrifice_info(user)
			return
		return
	var/list/choices = list("PITCH", "TOIL", "STRAND", "ROT", "BLOOD", "NOISE", "BITE") - GLOB.zizo_bestowed
	var/choice = tgui_input_list(user, "CHOOSE AN ASPECT TO BRING FORTH.","ZIZO", choices)
	if(!choice || in_progress || gate_count >= 3 || !user.Adjacent(center) || !is_zizo(user))
		return
	in_progress = TRUE
	to_chat(user, span_notice("The rite begins. Remain still.<BR>Some may be alerted to your location after it is complete."))
	var/poo = new /obj/effect/temp_visual/opengate(center, 25 SECONDS)
	playsound(user, 'sound/villain/littlescary.ogg', 100, TRUE)
	var/completed = do_after(user, 25 SECONDS, target = center)
	in_progress = FALSE
	if(!completed || !is_zizo(user) || (gate_count > 0 && (QDELETED(target) || get_turf(target) != center || zizo_target_error(user, target, GLOB.gate_targets))))
		qdel(poo)
		return
	if(choice in GLOB.zizo_bestowed)
		return
	GLOB.zizo_bestowed += choice
	zizo_calamity(choice)
	to_chat(user, span_boldnotice("The [choice] aspect has been unleashed upon Twilight Axis! Its rites may now be researched."))
	user.Jitter(4)
	gate_count++

	if(gate_count > 0)
		center_requirement = /mob/living/carbon/human

	if(gate_count < 3)
		to_chat(user, span_boldnotice("Gate opened! [3 - gate_count] more to unlock Ascension!"))
	if(gate_count == 3)
		GLOB.zizo_researchable |= /datum/ritual/fleshcrafting/ascend
		for(var/obj/item/clothing/cloak/cultrobe/robe as anything in GLOB.cult_robes)
			robe.empower()

	if(gate_count > 0)
		reroll_gate_targets(gate_count)

	if(gate_count == 1)
		to_chat(user, span_userdanger("SHE DEMANDS A SACRIFICE FOR THE NEXT GATE."))
		print_gate_sacrifice_info(user)
		GLOB.zizo_researchable |= /datum/ritual/transmutation/summonfuge
		if(user.mind)
			user.mind.zizo_researched |= /datum/ritual/transmutation/summonfuge
			to_chat(user, span_boldnotice("I CAN NOW TRANSMUTE A FUGE."))

	if(target && !is_zizo(target))
		absorb_lux(target, get_turf(target), FALSE)

	for(var/datum/mind/M in SSmapping.retainer.cultists)
		if(M.current)
			zizo_award(M.current, 5)
	zizo_award(user, 5)
	playsound(user, 'sound/villain/hall_attack4.ogg', 100, TRUE)
	new /obj/structure/reality_rend(center)
	GLOB.zizo_bestow_areas -= valid_area
	refill_bestow_areas()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(zizo_bestow_alert), here, gate_count >= 3), 30 SECONDS)

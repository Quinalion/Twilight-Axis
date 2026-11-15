// TA EDIT - Cult world aspects
/datum/world_trait/zizo_blood
	name = "Zizo's Blood"

/datum/world_trait/zizo_noise
	name = "Zizo's Noise"

/datum/world_trait/zizo_rot
	name = "Zizo's Rot"
	processes = TRUE
	var/list/spots = list()
	var/next_spawn = 0

/datum/world_trait/zizo_rot/New()
	. = ..()
	for(var/area/rogue/outdoors/town/A in world)
		if(istype(A, /area/rogue/outdoors/town/roofs))
			continue
		for(var/turf/open/floor/T in A)
			spots += T

/datum/world_trait/zizo_rot/process()
	if(world.time < next_spawn || !length(spots))
		return
	for(var/obj/structure/blight_pillar/P as anything in tracked_items.Copy())
		if(QDELETED(P))
			tracked_items -= P
	if(length(tracked_items) >= 6)
		return
	next_spawn = world.time + 5 MINUTES
	var/turf/T = pick(spots)
	if(T.density || (locate(/obj/structure) in T) || (locate(/mob/living) in T))
		return
	tracked_items += new /obj/structure/blight_pillar(T)

/datum/world_trait/zizo_toil
	name = "Zizo's Toil"

/datum/world_trait/zizo_strand
	name = "Zizo's Strand"

/datum/world_trait/zizo_bite
	name = "Zizo's Bite"

/proc/activate_zizo_aspect(choice)
	if(choice == "BITE")
		SSmapping.add_world_trait(/datum/world_trait/zizo_bite, 0)
		GLOB.forecast = PARTICLEWEATHER_SNOW
		SSParticleWeather.run_weather(pick(/datum/particle_weather/snow_gentle, /datum/particle_weather/snow_storm))
		for(var/datum/mind/M in SSmapping.retainer.cultists)
			if(M.current)
				ADD_TRAIT(M.current, TRAIT_RESISTCOLD, "zizo_aspect")
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
				ADD_TRAIT(M.current, TRAIT_NOHUNGER, "zizo_aspect")
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


/turf/closed/wall/proc/zizo_collapse()
	var/datum/effect_system/smoke_spread/dust = new
	dust.set_up(0, src)
	dust.start()
	playsound(src, 'sound/misc/meteorimpact.ogg', 50, TRUE)
	dismantle_wall(1)

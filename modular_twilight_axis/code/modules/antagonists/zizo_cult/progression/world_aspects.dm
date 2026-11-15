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

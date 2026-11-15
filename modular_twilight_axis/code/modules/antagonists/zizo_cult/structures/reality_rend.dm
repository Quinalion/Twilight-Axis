/obj/structure/reality_rend
	name = "reality rend"
	desc = "A wound in the world."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	color = "#000000"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/radius = 2
	var/list/turf_data = list()

/datum/stressevent/saw_wonder/cult
	timer = 1 MINUTES

/obj/structure/reality_rend/examine(mob/user)
	if(!ishuman(user))
		return
	zizo_wonder(user)

/proc/zizo_wonder(mob/living/carbon/human/H, knockdown = TRUE)
	H.overlay_fullscreen("cult", /atom/movable/screen/fullscreen/druqks)
	H.add_stress(/datum/stressevent/saw_wonder/cult)
	H.emote("scream")
	if(knockdown)
		H.Paralyze(2 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clear_cult_fullscreen), H), 2 SECONDS)

/proc/clear_cult_fullscreen(mob/user)
	user.clear_fullscreen("cult")

/turf/closed/wall/mineral/rogue/stone/unbreakable/space
	name = "???"
	desc = "???"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultsprites.dmi'
	icon_state = "cultwall"
	smooth = SMOOTH_FALSE

/turf/open/floor/rogue/underworld/space/quiet/cult
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultsprites.dmi'
	icon_state = "cultfloor"
	smooth = SMOOTH_FALSE
	slowdown = 0

/turf/open/floor/rogue/underworld/space/quiet/cult/Initialize(mapload)
	. = ..()
	dir = pick(GLOB.cardinals)

/particles/zizo_void
	icon = 'icons/effects/particles/particle.dmi'
	icon_state = "puff"
	width = 160
	height = 160
	count = 30
	spawning = 0.5
	lifespan = 3 SECONDS
	fade = 1 SECONDS
	color = "#2a0a3a"
	scale = 0.6
	position = generator("circle", 20, 36, UNIFORM_RAND)
	drift = generator("circle", 0, 0.3)

/proc/zizo_flicker(atom/A)
	set waitfor = FALSE
	for(var/i in 1 to 4)
		A.set_light_on(FALSE)
		A.update_light()
		sleep(rand(1, 3))
		if(QDELETED(A))
			return
		A.set_light_on(TRUE)
		A.update_light()
		sleep(rand(1, 3))
		if(QDELETED(A))
			return

/particles/zizo_burst
	icon = 'icons/effects/particles/particle.dmi'
	icon_state = "puff"
	width = 160
	height = 160
	count = 12
	spawning = 12
	lifespan = 1.4 SECONDS
	fade = 0.8 SECONDS
	color = "#2a0a3a"
	scale = 0.6
	grow = 0.03
	velocity = generator("circle", 1, 3)

/particles/zizo_shadow
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 1)
	count = 20
	spawning = 0.4
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	color = "#1a0a2a"
	position = generator("box", list(-8, -8, 0), list(8, 8, 0), UNIFORM_RAND)
	velocity = list(0, 0.4, 0)
	grow = 0.03

/particles/zizo_rot
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "ash_1" = 1)
	count = 40
	spawning = 0.4
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	color = "#7a2a2a"
	position = generator("box", list(-24, -16, 0), list(24, 16, 0), UNIFORM_RAND)
	velocity = list(0, 0.3, 0)
	grow = 0.02

/obj/effect/temp_visual/cult/rune_spawn/rune7/wide
	icon = 'modular_twilight_axis/icons/zizo_cult/effects/cult_effects.dmi'
	start_scale = 3.5

/obj/effect/temp_visual/zizo_crack
	icon = 'modular_twilight_axis/icons/zizo_cult/effects/eldritch.dmi'
	icon_state = "realitycrack"
	duration = 3.2 SECONDS

/obj/effect/temp_visual/zizo_ring
	icon = 'modular_twilight_axis/icons/zizo_cult/effects/eldritch.dmi'
	icon_state = "cosmic_ring"
	color = "#ff4040"
	duration = 1 SECONDS

/obj/effect/temp_visual/zizo_ring/Initialize(mapload)
	. = ..()
	transform = matrix() * 0.5
	animate(src, transform = matrix() * 3, alpha = 0, time = duration)

/obj/structure/reality_rend/Initialize(mapload)
	. = ..()
	GLOB.zizo_reality_rends += src
	add_filter("rend_ripple", 1, list(type = "ripple", size = 2, radius = 0, falloff = 1, repeat = 8))
	animate(get_filter("rend_ripple"), radius = 80, time = 4 SECONDS, loop = -1)
	animate(radius = 0, time = 0)
	new /obj/effect/abstract/particle_holder(src, /particles/zizo_void)
	START_PROCESSING(SSobj, src)
	var/turf/center = get_turf(src)
	for(var/turf/T in range(radius, center))
		if(isclosedturf(T) && !istype(T, /turf/closed/indestructible))
			turf_data[T] = T.type
			T.ChangeTurf(/turf/closed/wall/mineral/rogue/stone/unbreakable/space, flags = CHANGETURF_IGNORE_AIR)
			new /obj/effect/temp_visual/cult/turf(T)
		else if(isopenturf(T) && !istype(T, /turf/open/floor/rogue/underworld/space/quiet/cult))
			turf_data[T] = T.type
			T.ChangeTurf(/turf/open/floor/rogue/underworld/space/quiet/cult, flags = CHANGETURF_IGNORE_AIR)
			new /obj/effect/temp_visual/cult/turf/floor(T)

/obj/structure/reality_rend/process()
	if(length(turf_data) && prob(20))
		new /obj/effect/temp_visual/zizo_crack(pick(turf_data))

/obj/structure/reality_rend/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.zizo_reality_rends -= src
	for(var/turf/T in turf_data)
		T.ChangeTurf(turf_data[T], flags = CHANGETURF_IGNORE_AIR)
	turf_data.Cut()
	visible_message(span_danger("Lux fills the barren stone and returns lyfe to the land!"))
	playsound(src, 'sound/foley/breaksound.ogg', 50, TRUE)
	return ..()

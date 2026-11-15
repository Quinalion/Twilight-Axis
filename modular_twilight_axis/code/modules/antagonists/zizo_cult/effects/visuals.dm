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

/obj/effect/temp_visual/zizo_ring
	icon = 'modular_twilight_axis/icons/zizo_cult/effects/eldritch.dmi'
	icon_state = "cosmic_ring"
	color = "#ff4040"
	duration = 1 SECONDS

/obj/effect/temp_visual/zizo_ring/Initialize(mapload)
	. = ..()
	transform = matrix() * 0.5
	animate(src, transform = matrix() * 3, alpha = 0, time = duration)


/obj/effect/temp_visual/cult/ritual_channel
	icon = 'icons/effects/clan.dmi'
	icon_state = "summoning"
	dir = SOUTH
	randomdir = FALSE
	duration = 5 SECONDS

/obj/effect/temp_visual/cult/ritual_channel/Initialize(mapload, set_duration)
	if(set_duration)
		duration = set_duration
	return ..()

/obj/effect/temp_visual/cult/ritual_channel/fivesec

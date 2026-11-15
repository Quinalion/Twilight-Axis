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

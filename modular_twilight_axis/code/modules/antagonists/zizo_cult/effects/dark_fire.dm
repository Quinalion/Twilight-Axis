// TA EDIT - Cult dark fire
/datum/status_effect/fire_handler/fire_stacks/dark
	id = "fire_stacks_dark"
	moblight_type = null

/datum/status_effect/fire_handler/fire_stacks/dark/deal_damage(wait)
	owner.on_fire_stack(wait * 0.1, src)

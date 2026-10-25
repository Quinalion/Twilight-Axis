/datum/intent/axe/chop/heavy
	pen_guarded = PEN_MEDIUM

/datum/intent/sword/thrust/rapier/lunge/spec_on_apply_effect(mob/living/H, mob/living/user, params)
	apply_breach_pen(H)
	return ..()

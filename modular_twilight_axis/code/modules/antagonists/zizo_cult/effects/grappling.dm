// TA EDIT - Aspect grappling strength
/mob/living/proc/grapple_str()
	return HAS_TRAIT(src, TRAIT_PEAK_GRAPPLER) ? max(20, STASTR) : STASTR

/mob/living/proc/grapple_con()
	return HAS_TRAIT(src, TRAIT_PEAK_GRAPPLER) ? max(20, STACON) : STACON

/datum/component/wrestle_combat_tracker
	var/channeling_throw = FALSE

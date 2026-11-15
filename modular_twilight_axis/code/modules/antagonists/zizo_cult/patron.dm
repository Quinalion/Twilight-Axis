// TA EDIT - Lesser sigils are available to Zizo worshippers
/datum/patron/inhumen/zizo/on_gain(mob/living/pious)
	. = ..()
	add_verb(pious, list(/mob/living/carbon/human/proc/draw_sigil, /mob/living/carbon/human/proc/praise, /mob/living/carbon/human/proc/zizo_lore, /mob/living/carbon/human/proc/zizo_objectives))

/datum/patron/inhumen/zizo/on_loss(mob/living/pious)
	remove_verb(pious, list(/mob/living/carbon/human/proc/draw_sigil, /mob/living/carbon/human/proc/praise, /mob/living/carbon/human/proc/zizo_lore, /mob/living/carbon/human/proc/zizo_objectives))
	return ..()

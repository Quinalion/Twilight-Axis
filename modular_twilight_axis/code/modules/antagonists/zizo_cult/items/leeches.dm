/obj/item/natural/worms/leech
	var/mob/living/carbon/human/fed_from
	var/suppressed = FALSE
	var/pierce_armor = FALSE
	var/instant_apply = FALSE

/obj/item/natural/worms/leech/proc/fall_off()
	remove_from_host(host, istype(loc, /obj/item/bodypart) ? loc : null)

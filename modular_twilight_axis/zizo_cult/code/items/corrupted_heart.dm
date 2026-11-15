/obj/item/corruptedheart
	name = "corrupted heart"
	desc = "It sparkles with forbidden magic energy. It makes all the heart aches go away."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	w_class =  WEIGHT_CLASS_SMALL

/obj/item/corruptedheart/attack(mob/living/target, mob/living/user, params)
	if(!istype(user.patron, /datum/patron/inhumen/zizo))
		return
	if(istype(target.patron, /datum/patron/inhumen/zizo))
		target.blood_volume = BLOOD_VOLUME_MAXIMUM
		to_chat(target, span_notice("My elixir of life is stagnant once again."))
		qdel(src)
		return
	if(!do_after(user, 1 SECONDS, target))
		return
	if(target.cmode)
		to_chat(user, span_danger("Невозможно использовать сердце, когда цель напряжена"))
	target.Sleeping(40)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.silent += 80
	qdel(src)

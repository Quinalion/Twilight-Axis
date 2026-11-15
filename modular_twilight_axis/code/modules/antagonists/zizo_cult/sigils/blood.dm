// TA EDIT - Fresh blood can be used to draw sigils
/obj/effect/decal/cleanable/blood
	mouse_opacity = MOUSE_OPACITY_ICON

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/user)
	. = ..()
	if(!ishuman(user) || dry || !bloodiness)
		return
	var/mob/living/carbon/human/H = user
	if(H.incapacitated() || H.restrained() || !H.has_active_hand() || !H.Adjacent(src))
		return
	to_chat(H, span_notice("I get my hands bloody."))
	H.bloody_hands++
	H.update_inv_gloves()

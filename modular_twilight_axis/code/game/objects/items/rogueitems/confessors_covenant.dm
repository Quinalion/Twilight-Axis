/obj/item/paper/scroll/inquisitorial_oath
	name = "the confessor's covenant"
	desc = "An oath on parchment, stamped with an unfamiliar seal. \
		The words are written in brown ink. The first line reads \
		«Oath du Gévaudan»."
	icon_state = "slip_sealed"
	info = "Oath du Gévaudan<br>I swear to take into my flesh what my sworn \
		enemies would deny me."
	var/reading = FALSE

/obj/item/paper/scroll/inquisitorial_oath/update_icon_state()
	icon_state = "slip_sealed"

/obj/item/paper/scroll/inquisitorial_oath/attack_self(mob/user)
	if(reading || !ishuman(user) || !(src in user.held_items))
		return
	if(!user.can_read(src))
		return
	if(HAS_TRAIT(user, TRAIT_ORGAN_EATER))
		to_chat(user, span_notice("I already carry the hunger this oath offers."))
		return
	reading = TRUE
	to_chat(user, span_notice("I begin to recite the oath."))
	for(var/verse in 1 to 3)
		if(!do_after(user, 3 SECONDS, target = user) || QDELETED(src))
			break
		if(!(src in user.held_items) || user.stat != CONSCIOUS)
			break
		if(verse < 3)
			to_chat(user, span_notice("I recite another verse. The seal grows hot."))
			continue
		ADD_TRAIT(user, TRAIT_ORGAN_EATER, type)
		user.visible_message(span_warning("[src] crumbles to ash in [user]'s hands."))
		new /obj/effect/temp_visual/small_smoke(get_turf(user))
		qdel(src)
		return
	if(!QDELETED(src))
		reading = FALSE

/datum/inqports/reliquary/confessors_covenant
	name = "The Confessor's Covenant"
	item_type = /obj/item/paper/scroll/inquisitorial_oath
	marquescost = 20
	maximum = 1

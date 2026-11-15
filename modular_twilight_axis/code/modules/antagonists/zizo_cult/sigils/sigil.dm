/obj/effect/decal/cleanable/sigil
	name = "sigils"
	desc = "Strange runics. They hurt your eyes."
	icon_state = "center"
	icon = 'modular_twilight_axis/icons/zizo_cult/local/sigils.dmi'
	clean_type = CLEAN_TYPE_LIGHT_DECAL
	var/sigil_type

/obj/effect/decal/cleanable/sigil/examine(mob/user)
	. = ..()
	if(!sigil_type)
		return

	if(isliving(user))
		var/mob/living/living_user = user
		if(istype(living_user, /datum/patron/inhumen/zizo))
			to_chat(user, "It is of the [sigil_type] circle.")

/obj/effect/decal/cleanable/sigil/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(sigil_type == "Portal")
		return use_strand_passage(user)
	if(!sigil_type)
		return

	if(!istype(user.patron, /datum/patron/inhumen/zizo))
		return

	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/skeleton))
		to_chat(user, span_warning("Skelet not allowed."))
		return

	show_ritual_tgui(user)

/obj/effect/decal/cleanable/sigil/N
	icon_state = "N"

/obj/effect/decal/cleanable/sigil/NE
	icon_state = "NE"

/obj/effect/decal/cleanable/sigil/E
	icon_state = "E"

/obj/effect/decal/cleanable/sigil/SE
	icon_state = "SE"

/obj/effect/decal/cleanable/sigil/S
	icon_state = "S"

/obj/effect/decal/cleanable/sigil/SW
	icon_state = "SW"

/obj/effect/decal/cleanable/sigil/W
	icon_state = "W"

/obj/effect/decal/cleanable/sigil/NW
	icon_state = "NW"

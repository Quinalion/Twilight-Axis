/obj/effect/decal/cleanable/sigil
	name = "ritual circle"
	desc = "A ritual circle traced in blood."
	icon = 'modular_twilight_axis/zizo_cult/icons/effects/traps.dmi'
	icon_state = "center"
	SET_BASE_PIXEL(-32, -32)
	clean_type = CLEAN_TYPE_LIGHT_DECAL
	var/ritual_in_progress = FALSE
	var/legacy_segment = FALSE

/obj/effect/decal/cleanable/sigil/Initialize(mapload)
	if(legacy_segment)
		invisibility = INVISIBILITY_ABSTRACT
	. = ..()
	if(legacy_segment)
		return INITIALIZE_HINT_QDEL

/obj/effect/decal/cleanable/sigil/examine(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/living_user = user
		if(istype(living_user.patron, /datum/patron/inhumen/zizo))
			. += span_notice("Place the offerings on the indicated tiles and activate the center of the circle.")

/obj/effect/decal/cleanable/sigil/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!istype(user.patron, /datum/patron/inhumen/zizo))
		return
	if(user.mind?.has_antag_datum(/datum/antagonist/skeleton))
		to_chat(user, span_warning("Cult skeletons cannot perform rituals."))
		return
	if(ritual_in_progress)
		to_chat(user, span_warning("The circle is already in use."))
		return
	show_ritual_tgui(user)

// Existing maps still reference these segment paths.
/obj/effect/decal/cleanable/sigil/N
	legacy_segment = TRUE

/obj/effect/decal/cleanable/sigil/NE
	legacy_segment = TRUE

/obj/effect/decal/cleanable/sigil/E
	legacy_segment = TRUE

/obj/effect/decal/cleanable/sigil/SE
	legacy_segment = TRUE

/obj/effect/decal/cleanable/sigil/S
	legacy_segment = TRUE

/obj/effect/decal/cleanable/sigil/SW
	legacy_segment = TRUE

/obj/effect/decal/cleanable/sigil/W
	legacy_segment = TRUE

/obj/effect/decal/cleanable/sigil/NW
	legacy_segment = TRUE

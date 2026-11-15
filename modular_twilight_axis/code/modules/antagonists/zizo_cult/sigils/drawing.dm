/turf/open/floor/proc/can_generate_sigils(mob/M)
	var/list/required_turfs = list(src)
	for(var/direction in GLOB.alldirs)
		var/turf/open/floor/floor = get_step(src, direction)
		if(!istype(floor))
			to_chat(M, span_warning("There is not enough space to draw a sigil here."))
			return FALSE
		required_turfs += floor

	for(var/turf/open/floor/floor in required_turfs)
		for(var/obj/A in floor)
			if(istype(A, /obj/effect/decal/cleanable/sigil))
				to_chat(M, span_warning("There is already a sigil here."))
				return FALSE
			if(A.density && !(A.flags_1 & ON_BORDER_1))
				to_chat(M, span_warning("There is not enough space to draw a sigil here."))
				return FALSE

	return TRUE

/turf/open/floor/proc/generateSigils(mob/living/carbon/human/M)
	if(!M.can_draw_sigil() || !can_generate_sigils(M))
		return

	if(!do_after(M, HAS_TRAIT(M, TRAIT_BLOODBOUND) ? 1 SECONDS : 5 SECONDS, extra_checks = CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon/human, can_draw_sigil))))
		return

	return complete_sigil_drawing(M)

/turf/open/floor/proc/complete_sigil_drawing(mob/living/carbon/human/M)
	if(!M?.can_draw_sigil() || get_turf(M) != src || !can_generate_sigils(M))
		return FALSE

	if(!HAS_TRAIT(M, TRAIT_BLOODBOUND))
		M.bloody_hands--
	M.update_inv_gloves()
	var/obj/effect/decal/cleanable/sigil/C = new(src)
	C.sigil_type = "Ritual"
	playsound(M, 'sound/items/write.ogg', 100)
	var/static/list/sigil_types = list(
		"[NORTH]" = /obj/effect/decal/cleanable/sigil/N,
		"[SOUTH]" = /obj/effect/decal/cleanable/sigil/S,
		"[EAST]" = /obj/effect/decal/cleanable/sigil/E,
		"[WEST]" = /obj/effect/decal/cleanable/sigil/W,
		"[NORTHEAST]" = /obj/effect/decal/cleanable/sigil/NE,
		"[NORTHWEST]" = /obj/effect/decal/cleanable/sigil/NW,
		"[SOUTHEAST]" = /obj/effect/decal/cleanable/sigil/SE,
		"[SOUTHWEST]" = /obj/effect/decal/cleanable/sigil/SW,
	)
	for(var/direction in sigil_types)
		var/sigil_type = sigil_types[direction]
		new sigil_type(get_step(src, text2num(direction)))

	return TRUE

/mob/living/carbon/human/proc/can_draw_sigil()
	return !incapacitated() && !restrained() && has_active_hand() && (HAS_TRAIT(src, TRAIT_BLOODBOUND) || bloody_hands > 0)

/mob/living/carbon/human/proc/draw_sigil()
	set name = "Draw Sigil"
	set category = "ZIZO"
	if(!can_draw_sigil())
		return

	if(mind && mind.has_antag_datum(/datum/antagonist/skeleton))
		return

	if(!HAS_TRAIT(src, TRAIT_BLOODBOUND) && !bloody_hands)
		to_chat(src, span_danger("My hands aren't bloody enough."))
		return

	var/turf/open/floor/T = get_turf(src)
	if(istype(T))
		T.generateSigils(src)

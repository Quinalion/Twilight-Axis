// TA EDIT - Sigil drawing checks
/mob/living/carbon/human/proc/can_draw_sigil()
	return !incapacitated() && !restrained() && has_active_hand() && (HAS_TRAIT(src, TRAIT_BLOODBOUND) || bloody_hands > 0 || get_bleed_rate())

/turf/open/floor/proc/complete_sigil_drawing(mob/living/carbon/human/M, sigiltype = "Lesser")
	if(!M.can_draw_sigil() || get_turf(M) != src)
		return FALSE
	var/list/required_turfs = list(src)
	if(sigiltype != "Lesser")
		for(var/direction in GLOB.alldirs)
			required_turfs += get_step(src, direction)
	for(var/turf/T as anything in required_turfs)
		if(!istype(T, /turf/open/floor))
			return FALSE
		for(var/obj/A in T)
			if(istype(A, /obj/effect/decal/cleanable/sigil) || (A.density && !(A.flags_1 & ON_BORDER_1)))
				return FALSE
	if(!HAS_TRAIT(M, TRAIT_BLOODBOUND) && M.bloody_hands > 0)
		M.bloody_hands--
		M.update_inv_gloves()
	var/obj/effect/decal/cleanable/sigil/C = new(src)
	C.set_sigil_type(sigiltype)
	C.add_mob_blood(M)
	playsound(M, 'sound/items/write.ogg', 100)
	if(sigiltype != "Lesser")
		var/static/list/satellite_types = list(
			"[NORTH]" = /obj/effect/decal/cleanable/sigil/N,
			"[NORTHEAST]" = /obj/effect/decal/cleanable/sigil/NE,
			"[EAST]" = /obj/effect/decal/cleanable/sigil/E,
			"[SOUTHEAST]" = /obj/effect/decal/cleanable/sigil/SE,
			"[SOUTH]" = /obj/effect/decal/cleanable/sigil/S,
			"[SOUTHWEST]" = /obj/effect/decal/cleanable/sigil/SW,
			"[WEST]" = /obj/effect/decal/cleanable/sigil/W,
			"[NORTHWEST]" = /obj/effect/decal/cleanable/sigil/NW,
		)
		for(var/direction in satellite_types)
			var/satellite_type = satellite_types[direction]
			var/obj/effect/decal/cleanable/sigil/satellite = new satellite_type(get_step(src, text2num(direction)))
			satellite.add_mob_blood(M)
	return TRUE

/obj/effect/decal/cleanable/sigil
	name = "sigils"
	desc = "Strange runics. They hurt your eyes."
	icon_state = "center"
	icon = 'modular_twilight_axis/icons/zizo_cult/obj/sigils.dmi'
	var/sigil_type
	var/portal_id
	var/obj/effect/decal/cleanable/sigil/portal_link
	var/static/list/sigil_states = list("Lesser" = "lesser", "Portal" = "strand2", "Strand" = "strand", "Toil" = "toil", "Bite" = "bite", "Pitch" = "pitch", "Noise" = "noise", "Blood" = "blood", "Rot" = "rot")

/obj/effect/decal/cleanable/sigil/examine(mob/user)
	. = ..()
	if(!sigil_type)
		return
	if(isliving(user))
		var/mob/living/living_user = user
		if(istype(living_user.patron, /datum/patron/inhumen/zizo))
			to_chat(user, "It is of the [sigil_type] circle.")
			if(sigil_type == "Portal")
				var/area/current_area = get_area(src)
				var/info = "Passage #[portal_id] ([current_area.name])."
				if(portal_link)
					var/area/destination_area = get_area(portal_link)
					info += " Connected to #[portal_link.portal_id] ([destination_area.name])."
				else
					info += " Not connected."
				to_chat(user, info)

/obj/effect/decal/cleanable/sigil/proc/set_sigil_type(newtype)
	sigil_type = newtype
	if(icon_state == "center")
		icon_state = sigil_states[newtype] || "center"
	if(newtype == "Portal")
		GLOB.zizo_portals |= src
		if(!portal_id)
			portal_id = ++GLOB.zizo_portal_count
		icon_state = "strand2"
		update_icon()

/obj/effect/decal/cleanable/sigil/proc/choose_link(mob/user)
	var/list/choices = list()
	for(var/obj/effect/decal/cleanable/sigil/passage in GLOB.zizo_portals)
		if(passage != src)
			var/area/passage_area = get_area(passage)
			choices["#[passage.portal_id], [passage_area.name]"] = passage
	if(!length(choices))
		to_chat(user, span_notice("MAKE ANOTHER PASSAGE!"))
		return
	var/choice = tgui_input_list(user, "CONNECT TO ANOTHER PASSAGE", "ZIZO", choices)
	if(!choice)
		return
	var/obj/effect/decal/cleanable/sigil/connectee = choices[choice]
	if(QDELETED(connectee) || QDELETED(src))
		return
	if(portal_link)
		portal_link.portal_link = null
	if(connectee.portal_link)
		connectee.portal_link.portal_link = null
	portal_link = connectee
	connectee.portal_link = src
	to_chat(user, span_notice("PASSAGE #[portal_id] CONNECTED TO #[connectee.portal_id]."))

/obj/effect/decal/cleanable/sigil/attack_right(mob/user)
	. = ..()
	if(sigil_type == "Portal" && is_zizo(user))
		choose_link(user)

/obj/effect/decal/cleanable/sigil/Destroy()
	GLOB.zizo_portals -= src
	if(portal_link)
		portal_link.portal_link = null
		portal_link = null
	return ..()

/obj/effect/decal/cleanable/sigil/proc/collect_ingredients(datum/ritual/R)
	var/list/ingredients = list()
	var/list/requirements = list("[NORTH]" = R.n_req, "[SOUTH]" = R.s_req, "[EAST]" = R.e_req, "[WEST]" = R.w_req)
	for(var/direction in requirements)
		var/required_type = requirements[direction]
		if(!required_type)
			continue
		var/atom/movable/ingredient = find_ritual_ingredient(get_step(src, text2num(direction)), required_type)
		if(!ingredient)
			return null
		ingredients += ingredient
	if(R.center_requirement)
		var/atom/movable/ingredient = find_ritual_ingredient(get_turf(src), R.center_requirement)
		if(!ingredient)
			return null
		if(!R.keep_center)
			ingredients += ingredient
	return ingredients

/obj/effect/decal/cleanable/sigil/proc/consume_ingredients(datum/ritual/R)
	var/list/ingredients = collect_ingredients(R)
	if(isnull(ingredients))
		return FALSE
	for(var/atom/movable/ingredient as anything in ingredients)
		if(!ismob(ingredient))
			playsound(src, 'sound/foley/flesh_rem2.ogg', 30)
			consume_ritual_ingredient(ingredient)
	return TRUE

/obj/effect/decal/cleanable/sigil/attack_hand(mob/living/user)
	. = ..()
	if(!istype(user.patron, /datum/patron/inhumen/zizo))
		return
	if(sigil_type == "Greater" && !is_zizo(user))
		to_chat(user, span_warning("THIS SIGIL IS BEYOND ME."))
		return
	if(sigil_type == "Portal")
		var/obj/effect/decal/cleanable/sigil/dest = portal_link
		if(QDELETED(dest))
			to_chat(user, span_warning("Nothing connected. Right-click the sigil."))
			return
		var/turf/effect_turf = get_turf(user)
		var/poo = new /obj/effect/temp_visual/opengate(effect_turf, 2 SECONDS)
		playsound(user, 'sound/villain/newheart.ogg', 60, TRUE)
		if(!do_after(user, 2 SECONDS))
			qdel(poo)
			return
		if(QDELETED(dest) || !user.Adjacent(src))
			return
		var/turf/T = get_turf(dest)
		new /obj/effect/temp_visual/cult/blood/out(effect_turf)
		new /obj/effect/temp_visual/cult/blood(T)
		new /obj/effect/temp_visual/zizo_ring(effect_turf)
		new /obj/effect/temp_visual/zizo_ring(T)
		for(var/mob/living/L in range(1, src))
			do_teleport(L, T)
		return
	var/list/rituals_pre = list()
	switch(sigil_type)
		if("Lesser", "Greater")
			for(var/datum/ritual/ritual_type as anything in subtypesof(/datum/ritual/servantry) + subtypesof(/datum/ritual/transmutation) + subtypesof(/datum/ritual/fleshcrafting))
				if(initial(ritual_type.lesser) == (sigil_type == "Lesser"))
					rituals_pre += ritual_type
		if("Strand")
			rituals_pre = subtypesof(/datum/ritual/strand)
		if("Pitch")
			rituals_pre = subtypesof(/datum/ritual/pitch)
		if("Toil")
			rituals_pre = subtypesof(/datum/ritual/toil)
		if("Bite")
			rituals_pre = subtypesof(/datum/ritual/bite)
		if("Rot")
			rituals_pre = subtypesof(/datum/ritual/rot)
		if("Noise")
			rituals_pre = subtypesof(/datum/ritual/noise)
		if("Blood")
			rituals_pre = subtypesof(/datum/ritual/blood)
	if(!length(rituals_pre))
		return
	var/list/rituals = list()
	for(var/datum/ritual/ritual as anything in rituals_pre)
		if(ritual_available(user, ritual))
			rituals += initial(ritual.name)
	if(!length(rituals))
		to_chat(user, span_warning("I've no clue how to use this."))
		return

	var/ritualnameinput = input(user, "Rituals", "ZIZO") as null|anything in rituals
	if(!ritualnameinput)
		return
	var/datum/ritual/pickritual = LAZYACCESS(GLOB.ritualslist, ritualnameinput)
	if(!pickritual)
		return

	if(QDELETED(src) || !user.Adjacent(src) || user.incapacitated() || !ritual_available(user, pickritual.type))
		return
	if(!consume_ingredients(pickritual))
		to_chat(user, span_danger("Ritual requires: [pickritual.hugbox()]"))
		return

	var/obj/effect/abstract/particle_holder/burst = new(src, /particles/zizo_burst)
	QDEL_IN(burst, 1.4 SECONDS)
	for(var/atom/A in range(7, src))
		if(A.light_on && A.light_outer_range)
			zizo_flicker(A)
	user.playsound_local(user, 'modular_twilight_axis/sound/zizo_cult/vo/cult/tesa.ogg', 25)
	user.whisper("O'vena tesa...")
	pickritual.invoke(user, loc)

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

/turf/open/floor/proc/generateSigils(mob/living/carbon/human/M, sigiltype)
	if(!M.can_draw_sigil())
		return FALSE
	var/draw_time = HAS_TRAIT(M, TRAIT_BLOODBOUND) ? 1 SECONDS : 5 SECONDS
	if(sigiltype != "Lesser")
		draw_time *= 2
	if(!do_after(M, draw_time, extra_checks = CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon/human, can_draw_sigil))))
		return FALSE
	return complete_sigil_drawing(M, sigiltype)

/mob/living/carbon/human/proc/draw_sigil()
	set name = "Draw Sigil"
	set category = "ZIZO"
	if(!can_draw_sigil())
		return
	if(!HAS_TRAIT(src, TRAIT_BLOODBOUND) && !bloody_hands && !get_bleed_rate())
		to_chat(src, span_danger("My hands aren't bloody enough."))
		return
	var/static/list/cats = list("Strand" = /datum/ritual/strand, "Pitch" = /datum/ritual/pitch, "Toil" = /datum/ritual/toil, "Bite" = /datum/ritual/bite, "Rot" = /datum/ritual/rot, "Blood" = /datum/ritual/blood, "Noise" = /datum/ritual/noise)
	var/list/runes = list()
	for(var/datum/ritual/ritual_type as anything in subtypesof(/datum/ritual/servantry) + subtypesof(/datum/ritual/transmutation) + subtypesof(/datum/ritual/fleshcrafting))
		if(!ritual_available(src, ritual_type))
			continue
		if(initial(ritual_type.lesser))
			runes |= "Lesser"
		else if(is_zizo(src))
			runes |= "Greater"
	for(var/cat in cats)
		for(var/datum/ritual/ritual as anything in subtypesof(cats[cat]))
			if(ritual_available(src, ritual))
				runes += cat
				break
	if(!runes.len)
		to_chat(src, span_warning("I know no rites."))
		return
	var/choice = input("Sigil Type", "ZIZO") as null|anything in runes
	if(!choice)
		return
	var/turf/open/floor/T = get_turf(src)
	if(istype(T))
		T.generateSigils(src, choice)

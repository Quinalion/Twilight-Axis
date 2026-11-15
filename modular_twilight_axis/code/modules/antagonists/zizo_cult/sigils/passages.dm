// TA EDIT - Strand ritual passages
GLOBAL_LIST_EMPTY(zizo_passages)

/obj/effect/decal/cleanable/sigil
	var/obj/effect/decal/cleanable/sigil/portal_link

/obj/effect/decal/cleanable/sigil/proc/set_sigil_type(new_type)
	sigil_type = new_type
	if(new_type == "Portal")
		GLOB.zizo_passages |= src

/obj/effect/decal/cleanable/sigil/proc/choose_link(mob/living/user)
	var/list/choices = list()
	for(var/obj/effect/decal/cleanable/sigil/S as anything in GLOB.zizo_passages)
		if(S != src && !QDELETED(S))
			var/area/A = get_area(S)
			choices["[A.name] ([S.x], [S.y], [S.z])"] = S
	var/choice = tgui_input_list(user, "Choose a destination passage.", "Strand Passage", choices)
	if(!choice || QDELETED(src) || !user.Adjacent(src) || !is_zizo(user))
		return
	var/obj/effect/decal/cleanable/sigil/destination = choices[choice]
	if(QDELETED(destination))
		return
	if(portal_link)
		portal_link.portal_link = null
	if(destination.portal_link)
		destination.portal_link.portal_link = null
	portal_link = destination
	destination.portal_link = src

/obj/effect/decal/cleanable/sigil/attack_right(mob/user)
	. = ..()
	if(sigil_type == "Portal" && is_zizo(user))
		choose_link(user)

/obj/effect/decal/cleanable/sigil/proc/use_strand_passage(mob/living/user)
	if(GLOB.zizo_cult_aspect != "STRAND" || !is_zizo(user) || !user.Adjacent(src))
		return
	var/obj/effect/decal/cleanable/sigil/destination = portal_link
	if(QDELETED(destination))
		to_chat(user, span_warning("Right-click the passage to link it to a destination."))
		return
	if(!do_after(user, 2 SECONDS, target = src) || QDELETED(destination) || !is_zizo(user))
		return
	var/turf/target_turf = get_turf(destination)
	for(var/mob/living/L in range(1, src))
		do_teleport(L, target_turf)

/obj/effect/decal/cleanable/sigil/Destroy()
	GLOB.zizo_passages -= src
	if(portal_link)
		portal_link.portal_link = null
	portal_link = null
	return ..()

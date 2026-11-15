#define ZIZO_GATE_PULL_RANGE 50

/datum/status_effect/buff/zizo_gate_sense
	id = "zizo_gate_sense"
	duration = -1
	tick_interval = 15 SECONDS
	alert_type = null

/datum/status_effect/buff/zizo_gate_sense/tick()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/obj/structure/reality_rend/nearest_rend
	var/nearest_rend_dist = ZIZO_GATE_PULL_RANGE
	for(var/obj/structure/reality_rend/R as anything in GLOB.zizo_reality_rends)
		var/d = zizo_dist(H, R)
		if(d <= nearest_rend_dist)
			nearest_rend = R
			nearest_rend_dist = d
	if(!nearest_rend)
		H.remove_status_effect(/datum/status_effect/buff/zizo_gate_pull)
		return
	var/datum/status_effect/buff/zizo_gate_pull/pull = H.has_status_effect(/datum/status_effect/buff/zizo_gate_pull)
	if(!pull)
		pull = H.apply_status_effect(/datum/status_effect/buff/zizo_gate_pull)
	pull.target_rend = nearest_rend

/datum/status_effect/buff/zizo_gate_pull
	id = "zizo_gate_pull"
	duration = -1
	needs_processing = FALSE
	alert_type = /atom/movable/screen/alert/status_effect/buff/zizo_gate_pull
	var/obj/structure/reality_rend/target_rend

/atom/movable/screen/alert/status_effect/buff/zizo_gate_pull
	name = "UNREAL WORLD"
	desc = "THE REALMS BLEED."
	icon = 'modular_twilight_axis/icons/zizo_cult/effects/eldritch.dmi'
	icon_state = "eye_pulse"

/atom/movable/screen/alert/status_effect/buff/zizo_gate_pull/Click(location, control, params)
	. = ..()
	var/datum/status_effect/buff/zizo_gate_pull/pull = attached_effect
	if(!pull || QDELETED(pull.target_rend))
		return
	var/obj/structure/reality_rend/rend = pull.target_rend
	var/atom/dest = rend
	if(GLOB.zizo_fuges.len)
		var/choice = tgui_input_list(mob_viewer, "TRANSPORT?", "THE PATH BACK", list("Reality Rend", "Fuge"))
		if(!choice)
			return
		if(choice == "Fuge")
			dest = GLOB.zizo_fuges[1]
	to_chat(mob_viewer, span_notice("I AM TRANSPORTING! ANYONE I GRAB SHALL COME WITH!"))
	var/turf/origin = get_turf(mob_viewer)
	var/poo = new /obj/effect/temp_visual/opengate(origin, 10 SECONDS)
	playsound(mob_viewer, 'sound/villain/littlescary2.ogg', 60, TRUE)
	if(!do_after(mob_viewer, 10 SECONDS, target = mob_viewer))
		qdel(poo)
		return
	if(QDELETED(dest) || QDELETED(rend) || QDELETED(mob_viewer) || !isliving(mob_viewer))
		return
	if(zizo_dist(mob_viewer, rend) > ZIZO_GATE_PULL_RANGE)
		to_chat(mob_viewer, span_warning("TOO FAR!"))
		return
	var/mob/living/L = mob_viewer
	var/mob/living/grabbed = L.pulling
	if(!isliving(grabbed) || !grabbed.Adjacent(L))
		grabbed = null
	new /obj/effect/temp_visual/dir_setting/cult/phase/out(origin, L.dir)
	do_teleport(L, get_turf(dest), 1, asoundin = 'sound/magic/blink.ogg')
	new /obj/effect/temp_visual/dir_setting/cult/phase(get_turf(L), L.dir)
	if(grabbed)
		do_teleport(grabbed, get_turf(L), 1, asoundin = 'sound/magic/blink.ogg')

#undef ZIZO_GATE_PULL_RANGE

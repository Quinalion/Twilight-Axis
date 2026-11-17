/mob/living/proc/end_jaunt(obj/effect/dummy/phased_mob/slaughter/holder, turf/return_turf)
	if(QDELETED(holder))
		return
	forceMove(return_turf || get_turf(holder))
	var/obj/effect/temp_visual/dir_setting/cult/phase/P = new(get_turf(src), dir)
	P.color = "#2b0a3d"
	qdel(holder)


/obj/effect/proc_holder/spell/invoked/shadow_snuff
	name = "Extinguish"
	desc = "Extinguish the targeted fire or light and any burning objects it contains."
	range = 7
	overlay_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	action_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	overlay_state = "zizocandle"
	recharge_time = 2 SECONDS
	chargedloop = null

/obj/effect/proc_holder/spell/invoked/shadow_snuff/cast(list/targets, mob/living/user)
	. = ..()
	var/atom/target = targets[1]
	if(!target)
		return FALSE
	if(isobj(target))
		var/obj/O = target
		O.extinguish()
	for(var/obj/O in target.contents)
		O.extinguish()
	return TRUE

/obj/effect/dummy/phased_mob/slaughter/shadow/relaymove(mob/user, direction)
	var/turf/dest = get_step(src, direction)
	if(!dest || dest.get_lumcount() >= 0.75)
		to_chat(user, span_warning("THERE IS LIGHT THERE."))
		return
	forceMove(dest)

/obj/effect/proc_holder/spell/self/shadow_jaunt
	name = "Shadow Jaunt"
	desc = "Become invisible and move through walls for five seconds. Requires darkness and cannot enter brightly lit tiles."
	overlay_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	action_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	overlay_state = "zizocloud"
	recharge_time = 1 MINUTES
	chargedloop = null

/obj/effect/proc_holder/spell/self/shadow_jaunt/cast(list/targets, mob/user = usr)
	. = ..()
	if(!ishuman(user))
		revert_cast()
		return FALSE
	var/turf/T = get_turf(user)
	if(T.get_lumcount() >= 0.75)
		to_chat(user, span_warning("IT'S TOO BRIGHT!"))
		revert_cast()
		return FALSE
	var/obj/effect/dummy/phased_mob/slaughter/shadow/holder = new(T)
	var/obj/effect/temp_visual/dir_setting/cult/phase/out/P = new(T, user.dir)
	P.color = "#2b0a3d"
	new /obj/effect/temp_visual/decoy/fading/halfsecond(T, user)
	user.visible_message(span_warning("[user] melts into the shadows."))
	user.forceMove(holder)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, end_jaunt), holder), 5 SECONDS)
	return TRUE

/obj/effect/proc_holder/spell/invoked/projectile/toil_mend
	name = "Mending Bolt"
	desc = "Fire a bolt that heals another creature and repairs their worn equipment by twenty percent of its maximum integrity. Cannot target yourself."
	clothes_req = FALSE
	overlay_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	action_icon = 'modular_twilight_axis/zizo_cult/icons/mob/actions.dmi'
	overlay_state = "toil"
	sound = 'sound/magic/lightning.ogg'
	range = 7
	projectile_type = /obj/projectile/magic/mendbolt
	chargetime = 15
	recharge_time = 10 SECONDS
	chargedloop = null

/obj/projectile/magic/mendbolt
	name = "bolt of mending"
	tracer_type = /obj/effect/projectile/tracer/disabler
	color = "#ffb347"
	hitscan_light_color_override = "#ffb347"
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	light_color = "#ffb347"
	damage = 0
	nodamage = TRUE
	speed = 0.3
	flag = "magic"
	light_outer_range = 7

/obj/projectile/magic/mendbolt/on_hit(target)
	. = ..()
	if(ismob(target) && isliving(target))
		var/mob/living/L = target
		if(L.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		L.apply_status_effect(/datum/status_effect/buff/healing, 10, TRUE)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			for(var/obj/item/I in H.get_equipped_items())
				I.obj_integrity = min(I.obj_integrity + (I.max_integrity * 0.2), I.max_integrity)
		to_chat(L, span_notice("I AM MENDED!"))
		cult_mending_effect(L, 4)
	qdel(src)

/proc/cult_mending_effect(atom/movable/target, healings)
	var/datum/effect_system/spark_spread/S = new(target)
	S.set_up(3, 1, target)
	S.start()
	for(var/i in 1 to healings)
		new /obj/effect/temp_visual/heal(get_turf(target), "#ffb347")
	target.add_filter("cult_mending_glow", 2, list(type = "outline", color = "#ffb347", size = 2))
	target.transition_filter("cult_mending_glow", list(size = 0), 2 SECONDS)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/datum, remove_filter), "cult_mending_glow"), 2 SECONDS)

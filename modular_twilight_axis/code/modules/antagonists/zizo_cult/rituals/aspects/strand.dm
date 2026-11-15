/datum/intent/dream_beam
	name = "dream beam"
	blade_class = null
	icon_state = "inshoot"
	tranged = TRUE
	noaa = TRUE
	no_attack = TRUE
	warnie = "aimwarn"
	chargetime = 3 SECONDS
	chargedrain = 2
	charging_slowdown = 3
	no_early_release = TRUE
	chargedloop = /datum/looping_sound/invokegen

/datum/intent/dream_fling
	name = "fling"
	blade_class = null
	icon_state = "inmove"
	tranged = TRUE
	noaa = TRUE
	no_attack = TRUE
	chargetime = 1 SECONDS
	chargedrain = 1
	charging_slowdown = 2
	no_early_release = TRUE

/datum/intent/dream_fling/get_chargetime()
	var/obj/item/rogueweapon/zizowand/wand = masteritem
	if(istype(wand) && wand.flung)
		return chargetime
	return 0

/obj/projectile/magic/dream_beam
	name = "dream beam"
	tracer_type = /obj/effect/projectile/tracer/bloodsteal
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	guard_deflectable = TRUE
	expose_caster_on_deflect = TRUE
	damage = 100
	damage_type = BRUTE
	woundclass = BCLASS_STAB
	nodamage = FALSE
	speed = 0.3
	flag = "piercing"
	hitsound = 'sound/magic/obeliskbeam.ogg'
	light_color = "#9400D3"
	light_outer_range = 7
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	var/hits = 0

/obj/projectile/magic/dream_beam/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
	if(!ismob(target))
		qdel(src)
		return . || BULLET_ACT_HIT
	hits++
	damage = round(initial(damage) * 0.75)
	if(hits >= 4)
		qdel(src)

/obj/projectile/energy/dream_shroom
	name = "dream spore"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "arcyne_bolt"
	guard_deflectable = TRUE
	expose_caster_on_deflect = TRUE
	damage = 0
	nodamage = TRUE
	color = "#9b30ff"
	speed = MAGE_PROJ_FAST
	hitsound = null
	arcshot = TRUE

/obj/projectile/energy/dream_shroom/on_hit(target)
	..()
	var/turf/T = get_turf(src)
	if(!T || T.density)
		return
	var/obj/structure/zizo_bane/shroom = new(T)
	QDEL_IN(shroom, 2 MINUTES)

/datum/special_intent/dream_shroom
	name = "Dream Shroom"
	desc = "Shoot out a spore of Zizo's Bane!"
	use_clickloc = TRUE
	range = 7
	cooldown = 30 SECONDS

/datum/special_intent/dream_shroom/on_create()
	var/obj/projectile/energy/dream_shroom/spore = new(get_turf(howner))
	spore.firer = howner
	spore.fired_from = get_turf(howner)
	spore.def_zone = howner.zone_selected
	spore.range = max(1, get_dist_euclidian(click_loc, howner))
	spore.preparePixelProjectile(click_loc, howner)
	spore.fire()

/obj/item/rogueweapon/zizowand
	name = "witchwood"
	desc = "A gift from a snow elf queen to an almighty wizard. Once used to quell the sea itself into slumber."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultweapons32.dmi'
	icon_state = "zizowand"
	force = 15
	possible_item_intents = list(MACE_STRIKE, /datum/intent/dream_beam, /datum/intent/dream_fling)
	gripped_intents = null
	sharpness = IS_BLUNT
	wlength = WLENGTH_SHORT
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP
	associated_skill = /datum/skill/combat/arcyne
	wdefense = 4
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE
	smeltresult = null
	special = /datum/special_intent/dream_shroom
	var/fling_damage = 40
	var/datum/weakref/flung

/obj/item/rogueweapon/zizowand/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/soulbound_weapon, /datum/skill/combat/arcyne)

/obj/item/rogueweapon/zizowand/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -10,"sy" = -7,"nx" = 11,"ny" = -6,"wx" = -1,"wy" = -6,"ex" = 3,"ey" = -6,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 90,"sturn" = -90,"wturn" = -90,"eturn" = 90,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/obj/item/rogueweapon/zizowand/proc/clear_fling()
	var/obj/item/I = flung?.resolve()
	I?.remove_filter("dream_fling")
	flung = null

/obj/item/rogueweapon/zizowand/afterattack(atom/target, mob/living/user, flag)
	. = ..()
	if(!isliving(user) || get_dist(user, target) > 7)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(user.used_intent, /datum/intent/dream_beam))
		if(user.client?.chargedprog < 100)
			return
		playsound(user, 'sound/magic/soulshot.ogg', 100, TRUE)
		var/obj/projectile/magic/dream_beam/beam = new(get_turf(user))
		beam.firer = user
		beam.fired_from = get_turf(user)
		beam.def_zone = user.zone_selected
		beam.preparePixelProjectile(target, user)
		beam.fire()
		return
	if(!istype(user.used_intent, /datum/intent/dream_fling))
		return
	var/obj/item/held = flung?.resolve()
	if(!held)
		if(!isitem(target))
			return
		var/obj/item/I = target
		if(!isturf(I.loc) || I.anchored)
			return
		I.add_filter("dream_fling", 2, list("type" = "outline", "color" = "#9b30ff", "size" = 1))
		flung = WEAKREF(I)
		addtimer(CALLBACK(src, PROC_REF(clear_fling)), 15 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		return
	if(target == user || !isturf(held.loc))
		clear_fling()
		return
	if(user.client?.chargedprog < 100)
		return
	held.remove_filter("dream_fling")
	var/old_force = held.throwforce
	held.throwforce = fling_damage
	held.throw_at(target, 8, 2, user, TRUE, FALSE, VARSET_CALLBACK(held, throwforce, old_force))
	flung = null


/obj/effect/proc_holder/spell/invoked/dream_jaunt
	name = "Dream Jaunt"
	desc = "Bring yourself and whoever you hold into the dream."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "jaunt"
	range = 0
	movement_interrupt = FALSE
	chargedloop = null
	recharge_time = 60 SECONDS
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/dream_jaunt/cast(list/targets, mob/living/user)
	. = ..()
	if(!ishuman(user))
		return FALSE
	send_to_dream(user)
	if(ishuman(user.pulling))
		send_to_dream(user.pulling)
	return TRUE

/proc/send_to_dream(mob/living/carbon/human/target, status_type = /datum/status_effect/dream_teleport/strand)
	var/area/dream_area = GLOB.areas_by_type[/area/rogue/underworld/dream]
	var/turf/origin = get_turf(target)
	if(!dream_area || !origin)
		return
	var/list/safe_turfs = list()
	for(var/turf/T in get_area_turfs(dream_area))
		if(!T.density)
			safe_turfs += T
	if(!safe_turfs.len || !do_teleport(target, pick(safe_turfs)))
		return
	GLOB.players_in_dream |= target
	origin.visible_message(span_danger("[target] vanishes!"))
	playsound(origin, 'sound/misc/area.ogg')
	target.apply_status_effect(status_type, origin)

/datum/status_effect/dream_teleport/strand
	duration = 30 SECONDS

/datum/status_effect/dream_teleport/recall
	duration = 3 MINUTES

/mob/living/simple_animal/hostile/rogue/dreamfiend/nightmare
	faction = list("dream", "crabs", "zizo_cult")

/datum/status_effect/dream_teleport/strand/nightmare/on_creation(mob/living/new_owner, turf/origin)
	if(prob(50) && length(GLOB.zizo_reality_rends))
		var/list/near_rend = list()
		for(var/turf/open/T in range(4, pick(GLOB.zizo_reality_rends)))
			if(!T.density)
				near_rend += T
		if(length(near_rend))
			origin = pick(near_rend)
	new_owner.SetSleeping(0)
	summon_dreamfiend(new_owner, null, /mob/living/simple_animal/hostile/rogue/dreamfiend/nightmare)
	return ..(new_owner, origin)

/datum/status_effect/dream_teleport/strand/nightmare/on_remove()
	. = ..()
	for(var/mob/living/simple_animal/hostile/rogue/dreamfiend/nightmare/F in world)
		if(F.ai_controller?.blackboard[BB_MAIN_TARGET] == owner)
			qdel(F)

/datum/ritual/strand/dream_jaunt
	name = "Dream Jaunt"
	icon_type = /mob/living/simple_animal/hostile/rogue/dreamfiend/nightmare
	desc = "Learn a spell to teleport yourself and whoever you're holding into a pocket dimension for 30 seconds."
	passive = TRUE
	research_cost = 3

/datum/ritual/strand/dream_jaunt/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/dream_jaunt)
	return

/datum/ritual/strand/strandsend
	name = "Passage"
	icon_type = /obj/effect/decal/cleanable/sigil
	node_state = "strand2"
	desc = "Perform a rite to create a teleportation sigil. Activating it will teleport everything on the sigil to another teleportation sigil."
	center_requirement = /mob/living/carbon/human

/datum/ritual/strand/strandsend/invoke(mob/living/user, turf/center)
	var/obj/effect/decal/cleanable/sigil/S = locate() in center
	if(!S)
		return
	var/poo = new /obj/effect/temp_visual/opengate/fivesec(center)
	playsound(user, 'sound/villain/littlescary2.ogg', 60, TRUE)
	if(!do_after(user, 5 SECONDS))
		qdel(poo)
		return
	S.set_sigil_type("Portal")
	to_chat(user, span_notice("AN EYE IS A PASSAGE."))
	S.choose_link(user)

/datum/ritual/strand/strandrecall
	name = "Curse of Recall"
	icon_type = /obj/item/natural/worms/leech
	desc = "Teleport yourself and your target into a pocket dimension for 3 minutes. Anyone you or your target grabs is brought with. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/strand/strandrecall/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	var/mob/living/carbon/human/victim = remnant.fed_from
	if(!curse_target(victim))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	qdel(remnant)
	to_chat(user, span_notice("ALL MEN OBEY THE DREAMCALL. I HAVE 1 MINUTE TO PREPARE. ANYONE I AM GRABBING WILL BE BROUGHT WITH ME."))
	to_chat(victim, span_userdanger("I FEEL SOMETHING HORRIBLE COMING. I HAVE 1 MINUTE TO PREPARE. ANYONE I AM GRABBING WILL BE BROUGHT WITH ME."))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dreamcall), user, victim), 1 MINUTES)

/proc/dreamcall(mob/living/user, mob/living/victim)
	for(var/mob/living/M in list(user, victim))
		if(QDELETED(M) || !ishuman(M))
			continue
		send_to_dream(M, /datum/status_effect/dream_teleport/recall)
		if(ishuman(M.pulling))
			send_to_dream(M.pulling, /datum/status_effect/dream_teleport/recall)

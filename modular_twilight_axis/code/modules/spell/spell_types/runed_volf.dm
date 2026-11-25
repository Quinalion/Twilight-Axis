#define VOLF_SIGHT_COST 15
#define VOLF_SIGHT_COOLDOWN (12 SECONDS)
#define VOLF_SIGHT_DURATION (4 SECONDS)
#define VOLF_SIGHT_RANGE 7
#define VOLF_EFFECT_REFRESH (0.5 SECONDS)

#define VOLF_STEP_COST 22
#define VOLF_STEP_COOLDOWN (55 SECONDS)
#define VOLF_STEP_CHARGE (1 SECONDS)
#define VOLF_STEP_RANGE 7
#define VOLF_STEP_USES 3
#define VOLF_STEP_SOUND_VOLUME 8
#define VOLF_STEP_TRACE_DURATION (1 SECONDS)

#define VOLF_CLOAK_COST 25
#define VOLF_CLOAK_COOLDOWN (90 SECONDS)
#define VOLF_CLOAK_DURATION (5 SECONDS)
#define VOLF_CLOAK_FADE (0.5 SECONDS)
#define VOLF_CLOAK_COMBAT_LOCK (60 SECONDS)
#define VOLF_CLOAK_LIGHT_LIMIT 0.25

/datum/action/cooldown/spell/runed_volf
	button_icon = 'modular_twilight_axis/icons/mob/actions/classuniquespells/volf.dmi'
	background_icon = 'modular_twilight_axis/icons/mob/actions/classuniquespells/volf.dmi'
	primary_resource_type = SPELL_COST_STAMINA
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z
	sound = null
	charge_required = FALSE
	hide_charge_effect = TRUE
	has_visual_effects = FALSE
	ignore_combat_tag = TRUE
	self_cast_possible = FALSE

	var/round_uses_left = null

/datum/action/cooldown/spell/runed_volf/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	var/mob/living/caster = owner
	if(!istype(caster) || !isturf(caster.loc) || caster.buckled)
		return FALSE
	if(caster.cmode || caster.is_in_combat())
		if(feedback)
			to_chat(caster, span_warning("I need to be clear of the fight."))
		return FALSE
	if(!isnull(round_uses_left) && round_uses_left <= 0)
		if(feedback)
			to_chat(caster, span_warning("I have spent this rune for the day."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/runed_volf/after_cast(atom/cast_on)
	if(!isnull(round_uses_left))
		round_uses_left--
		to_chat(owner, span_notice("Uses of [name] left this round: [round_uses_left]."))
	return ..()

/datum/action/cooldown/spell/runed_volf/sight
	name = "Runed Sight"
	desc = "Hold still to sense living shapes through walls on this floor. Moving, fighting, or taking a hit breaks the vision."
	button_icon_state = "runedwalk"
	click_to_activate = FALSE
	self_cast_possible = TRUE
	primary_resource_cost = VOLF_SIGHT_COST
	cooldown_time = VOLF_SIGHT_COOLDOWN

/datum/action/cooldown/spell/runed_volf/sight/cast(atom/cast_on)
	var/mob/living/caster = owner
	if(!caster.client || caster.client.eye != caster || caster.lying)
		return FALSE
	if(HAS_TRAIT(caster, TRAIT_BLIND))
		return FALSE
	. = ..()
	return !!caster.apply_status_effect(/datum/status_effect/runed_volf/sight)

/datum/action/cooldown/spell/runed_volf/sight/Remove(mob/living/remove_from)
	remove_from?.remove_status_effect(/datum/status_effect/runed_volf/sight)
	return ..()

/datum/action/cooldown/spell/runed_volf/step
	name = "Runed Step"
	desc = "Slip to a clear tile in sight. A brief rune marks the trail. A step breaks Sneak and spends one of your limited uses for the round."
	button_icon_state = "runedblink"
	cast_range = VOLF_STEP_RANGE
	charge_required = TRUE
	channel_cast = TRUE
	charge_time = VOLF_STEP_CHARGE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z | SPELL_REQUIRES_NO_MOVE
	primary_resource_cost = VOLF_STEP_COST
	cooldown_time = VOLF_STEP_COOLDOWN
	round_uses_left = VOLF_STEP_USES

/datum/action/cooldown/spell/runed_volf/step/is_valid_target(atom/cast_on)
	if(!..() || !isturf(cast_on))
		return FALSE
	var/mob/living/caster = owner
	var/turf/start = caster.loc
	var/turf/destination = cast_on
	if(!istype(start) || !canStep(caster, start, destination))
		to_chat(caster, span_warning("I need a clear path to an empty tile within sight."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/runed_volf/step/proc/canStep(mob/living/caster, turf/start, turf/destination)
	if(destination == start || destination.z != start.z)
		return FALSE
	if(get_dist(start, destination) > cast_range || HAS_TRAIT(caster, TRAIT_BLIND))
		return FALSE
	if(!(destination in view(cast_range, start)))
		return FALSE
	if(arcyne_validate_blink_dest(destination, caster))
		return FALSE
	if(arcyne_validate_blink_path(start, destination))
		return FALSE
	if(destination.is_blocked_turf() || (locate(/mob/living) in destination))
		return FALSE
	var/turf/previous = start
	for(var/turf/step_tile in getline(start, destination))
		if(step_tile == start)
			continue
		if(step_tile.is_blocked_turf(exclude_mobs = TRUE))
			return FALSE
		if(!previous.Adjacent(step_tile, mover = caster))
			return FALSE
		previous = step_tile
	return TRUE

/datum/action/cooldown/spell/runed_volf/step/cast(atom/cast_on)
	if(!is_valid_target(cast_on))
		return FALSE
	var/mob/living/caster = owner
	var/turf/start = caster.loc
	var/turf/destination = cast_on
	if(caster.pulling || length(caster.grabbedby) || caster.lying)
		to_chat(caster, span_warning("I need to stand free to take the step."))
		return FALSE

	if(!do_teleport(caster, destination, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC))
		return FALSE
	if(caster.loc != destination)
		return FALSE
	caster.toggle_rogmove_intent(MOVE_INTENT_WALK, TRUE)
	caster.mob_timers[MT_FOUNDSNEAK] = world.time
	caster.update_sneak_invis(reset = TRUE)

	. = ..()
	new /obj/effect/temp_visual/blink/shadowstep/runed/volf_step(start)
	new /obj/effect/temp_visual/blink/shadowstep/runed/volf_step(destination)
	playsound(start, 'sound/magic/shadowstep.ogg', VOLF_STEP_SOUND_VOLUME, TRUE, -5)
	return TRUE

/obj/effect/temp_visual/blink/shadowstep/runed/volf_step
	duration = VOLF_STEP_TRACE_DURATION
	light_outer_range = 0

/datum/action/cooldown/spell/runed_volf/cloak
	name = "Runed Cloak"
	desc = "Slip into a short, soundless veil from cover. Attacking, taking a hit or sprinting ends it. Fighting leaves the rune dormant."
	button_icon_state = "runedcloak"
	click_to_activate = FALSE
	self_cast_possible = TRUE
	primary_resource_cost = VOLF_CLOAK_COST
	cooldown_time = VOLF_CLOAK_COOLDOWN

	var/combat_locked_until = 0
	var/last_health

/datum/action/cooldown/spell/runed_volf/cloak/Grant(mob/grant_to)
	. = ..()
	if(!owner)
		return
	var/mob/living/caster = owner
	last_health = caster.health
	RegisterSignal(owner, COMSIG_LIVING_COMBAT_TAG, PROC_REF(onCombat), override = TRUE)
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(onHit), override = TRUE)
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(onHealthUpdate), override = TRUE)

/datum/action/cooldown/spell/runed_volf/cloak/Remove(mob/living/remove_from)
	if(remove_from)
		var/list/combat_signals = list(COMSIG_LIVING_COMBAT_TAG, COMSIG_MOB_APPLY_DAMGE, COMSIG_LIVING_HEALTH_UPDATE)
		UnregisterSignal(remove_from, combat_signals)
		remove_from.remove_status_effect(/datum/status_effect/runed_volf/cloak)
	return ..()

/datum/action/cooldown/spell/runed_volf/cloak/proc/onCombat()
	SIGNAL_HANDLER
	combat_locked_until = world.time + VOLF_CLOAK_COMBAT_LOCK

/datum/action/cooldown/spell/runed_volf/cloak/proc/onHit(mob/living/source, damage)
	SIGNAL_HANDLER
	if(damage > 0)
		onCombat()

/datum/action/cooldown/spell/runed_volf/cloak/proc/onHealthUpdate(mob/living/source)
	SIGNAL_HANDLER
	if(source.health < last_health)
		onCombat()
	last_health = source.health

/datum/action/cooldown/spell/runed_volf/cloak/can_cast_spell(feedback = TRUE)
	if(!..())
		return FALSE
	if(world.time < combat_locked_until)
		if(feedback)
			to_chat(owner, span_warning("The rune has yet to quiet down after the fight."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/runed_volf/cloak/cast(atom/cast_on)
	var/mob/living/caster = owner
	var/turf/cover = caster.loc
	if(caster.m_intent != MOVE_INTENT_SNEAK || !istype(cover))
		to_chat(caster, span_warning("I need to be sneaking to draw the veil."))
		return FALSE
	if(cover.get_lumcount() >= VOLF_CLOAK_LIGHT_LIMIT)
		to_chat(caster, span_warning("The light here is too strong to draw the veil."))
		return FALSE
	. = ..()
	return !!caster.apply_status_effect(/datum/status_effect/runed_volf/cloak)

/datum/status_effect/runed_volf
	alert_type = null
	on_remove_on_mob_delete = TRUE
	tick_interval = VOLF_EFFECT_REFRESH

	var/last_health

/datum/status_effect/runed_volf/on_apply()
	. = ..()
	last_health = owner.health
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(onDamage))
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(onHealthUpdate))
	var/list/interruptions = list(
		COMSIG_LIVING_COMBAT_TAG,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_ATTACK_RANGED,
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOB_KICK_ATTACK,
		COMSIG_MOB_STATCHANGE,
		COMSIG_MOB_LOGOUT,
		COMSIG_MOB_BEFORE_SPELL_CAST,
	)
	RegisterSignals(owner, interruptions, PROC_REF(endRune))

/datum/status_effect/runed_volf/proc/onDamage(mob/living/source, damage)
	SIGNAL_HANDLER
	if(damage > 0)
		qdel(src)

/datum/status_effect/runed_volf/proc/onHealthUpdate(mob/living/source)
	SIGNAL_HANDLER
	if(source.health < last_health)
		qdel(src)
		return
	last_health = source.health

/datum/status_effect/runed_volf/proc/endRune()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/runed_volf/sight
	id = "runed_volf_sight"
	duration = VOLF_SIGHT_DURATION

	var/client/viewer
	var/list/markers = list()

/datum/status_effect/runed_volf/sight/on_apply()
	. = ..()
	viewer = owner.client
	RegisterSignals(owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED), PROC_REF(endRune))
	tick()

/datum/status_effect/runed_volf/sight/tick()
	if(!viewer || owner.client != viewer || viewer.eye != owner)
		qdel(src)
		return
	if(owner.cmode || owner.lying || HAS_TRAIT(owner, TRAIT_BLIND))
		qdel(src)
		return
	var/turf/origin = owner.loc
	if(!istype(origin))
		qdel(src)
		return

	var/list/screen_size = getviewsize(viewer.view)
	var/horizontal_radius = min(VOLF_SIGHT_RANGE, (screen_size[1] - 1) / 2)
	var/vertical_radius = min(VOLF_SIGHT_RANGE, (screen_size[2] - 1) / 2)
	var/list/occupied_tiles = findLivingTiles(origin, horizontal_radius, vertical_radius)

	for(var/turf/position as anything in markers)
		if(!occupied_tiles[position])
			var/atom/movable/screen/marker = markers[position]
			viewer.screen -= marker
			markers -= position
			qdel(marker)
	for(var/turf/position as anything in occupied_tiles)
		var/atom/movable/screen/runed_silhouette/marker = markers[position]
		if(!marker)
			marker = new
			markers[position] = marker
			viewer.screen += marker
		marker.pixel_x = (position.x - origin.x) * world.icon_size - viewer.pixel_x
		marker.pixel_y = (position.y - origin.y) * world.icon_size - viewer.pixel_y

/datum/status_effect/runed_volf/sight/proc/findLivingTiles(turf/origin, horizontal_radius, vertical_radius)
	var/list/occupied_tiles = list()
	for(var/mob/living/life in range(VOLF_SIGHT_RANGE, origin))
		if(life == owner || life.stat == DEAD || life.invisibility >= INVISIBILITY_MAXIMUM)
			continue
		var/turf/position = life.loc
		if(!istype(position) || position.z != origin.z)
			continue
		if(abs(position.x - origin.x) <= horizontal_radius && abs(position.y - origin.y) <= vertical_radius)
			occupied_tiles[position] = TRUE
	return occupied_tiles

/datum/status_effect/runed_volf/sight/on_remove()
	for(var/turf/position as anything in markers)
		var/atom/movable/screen/marker = markers[position]
		if(viewer)
			viewer.screen -= marker
		qdel(marker)
	markers.Cut()
	viewer = null
	return ..()

/atom/movable/screen/runed_silhouette
	name = "runed silhouette"
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0.75, 0.53, 0.92, 0)
	alpha = 190
	screen_loc = "CENTER,CENTER"
	plane = FULLSCREEN_PLANE
	layer = FULLSCREEN_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/status_effect/runed_volf/cloak
	id = "runed_volf_cloak"
	duration = VOLF_CLOAK_DURATION

	var/invisible_until

/datum/status_effect/runed_volf/cloak/on_apply()
	. = ..()
	invisible_until = world.time + duration
	owner.mob_timers[MT_INVISIBILITY] = invisible_until
	owner.rogue_sneaking = TRUE
	ADD_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, id)
	RegisterSignal(owner, COMSIG_MOB_BREAK_SNEAK, PROC_REF(endRune))
	RegisterSignals(owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOB_MOVESPEED_UPDATED), PROC_REF(onMove))
	animate(owner, alpha = 0, time = VOLF_CLOAK_FADE, easing = EASE_IN)
	owner.visible_message(span_notice("[owner]'s outline shimmers and slips out of sight."), span_notice("The wolf's veil swallows my outline."), vision_distance = 2)

/datum/status_effect/runed_volf/cloak/tick()
	if(owner.cmode || owner.m_intent == MOVE_INTENT_RUN)
		qdel(src)
	else if(owner.mob_timers[MT_INVISIBILITY] != invisible_until)
		qdel(src)

/datum/status_effect/runed_volf/cloak/proc/onMove()
	SIGNAL_HANDLER
	if(owner.m_intent == MOVE_INTENT_RUN)
		qdel(src)

/datum/status_effect/runed_volf/cloak/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_BREAK_SNEAK)
	REMOVE_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, id)
	if(owner.mob_timers[MT_INVISIBILITY] <= invisible_until)
		owner.mob_timers[MT_INVISIBILITY] = world.time
		if(!QDELETED(owner))
			animate(owner, alpha = initial(owner.alpha), time = 0)
			owner.update_sneak_invis(reset = TRUE)
	return ..()

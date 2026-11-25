/datum/action/cooldown/spell/runed_watch
	name = "Runed Watch"
	desc = "Trace a wolf's rune on a city door. For 30 seconds, the first \
		person other than you to cross its threshold disturbs the mark. \
		Stay within six paces on the same floor of the city to sense it."
	button_icon = 'modular_twilight_axis/icons/mob/actions/classuniquespells/volf.dmi'
	background_icon = 'modular_twilight_axis/icons/mob/actions/classuniquespells/volf.dmi'
	button_icon_state = "runedstasis"
	sound = null

	self_cast_possible = FALSE
	cast_range = 1
	charge_required = TRUE
	channel_cast = TRUE
	charge_time = CHARGETIME_MINOR
	cooldown_time = 45 SECONDS
	primary_resource_cost = SPELLCOST_UTILITY_BUFF
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z | SPELL_REQUIRES_NO_MOVE

	var/obj/structure/mineral_door/watched_door
	var/turf/watched_threshold
	var/watch_timer
	var/watch_duration = 30 SECONDS
	var/watch_range = 6

/datum/action/cooldown/spell/runed_watch/is_valid_target(atom/cast_on)
	if(!..())
		return FALSE
	var/obj/structure/mineral_door/door = cast_on
	if(!istype(door) || QDELETED(door) || !isturf(door.loc) || !door.anchored)
		return FALSE
	if(!isUrbanArea(door) || !isUrbanArea(owner))
		to_chat(owner, span_warning("The wolf's mark takes hold only in the city."))
		return FALSE
	return isturf(owner.loc) && owner.Adjacent(door)

/datum/action/cooldown/spell/runed_watch/cast(atom/cast_on)
	if(!is_valid_target(cast_on))
		return FALSE
	. = ..()
	clearWatch()
	watched_door = cast_on
	watched_threshold = watched_door.loc
	RegisterSignal(watched_door, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(clearWatch))
	RegisterSignal(watched_threshold, COMSIG_TURF_CHANGE, PROC_REF(clearWatch))
	RegisterSignal(watched_threshold, COMSIG_TURF_ENTERED, PROC_REF(onThresholdCrossed))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clearWatch))
	watch_timer = addtimer(CALLBACK(src, PROC_REF(clearWatch)), watch_duration, TIMER_STOPPABLE)
	var/witness_notice = span_notice("[owner] traces a mark on [watched_door].")
	var/caster_notice = span_notice("I set the wolf to watch [watched_door].")
	owner.visible_message(witness_notice, caster_notice, vision_distance = 2)
	return TRUE

/datum/action/cooldown/spell/runed_watch/Remove(mob/living/remove_from)
	clearWatch()
	return ..()

/datum/action/cooldown/spell/runed_watch/proc/isUrbanArea(atom/location)
	var/area/zone = get_area(location)
	return istype(zone, /area/rogue/indoors/town) \
		|| istype(zone, /area/rogue/indoors/shelter/town) \
		|| istype(zone, /area/rogue/outdoors/town) \
		|| istype(zone, /area/rogue/outdoors/exposed/town)

/datum/action/cooldown/spell/runed_watch/proc/onThresholdCrossed(turf/threshold, atom/movable/entrant)
	SIGNAL_HANDLER
	if(!ishuman(entrant) || entrant == owner)
		return
	var/mob/living/carbon/human/passerby = entrant
	if(passerby.stat == DEAD)
		return
	var/mob/living/caster = owner
	if(istype(caster) && caster.stat == CONSCIOUS && !caster.IsSleeping())
		var/turf/caster_turf = caster.loc
		if(istype(caster_turf) && caster_turf.z == threshold.z && isUrbanArea(caster))
			if(get_dist(caster_turf, threshold) <= watch_range)
				to_chat(caster, span_notice("My wolf's mark stirs. Someone crossed the doorway."))
	clearWatch()

/datum/action/cooldown/spell/runed_watch/proc/clearWatch()
	SIGNAL_HANDLER
	if(watch_timer)
		deltimer(watch_timer)
		watch_timer = null
	if(watched_threshold)
		UnregisterSignal(watched_threshold, list(COMSIG_TURF_ENTERED, COMSIG_TURF_CHANGE))
		watched_threshold = null
	if(watched_door)
		UnregisterSignal(watched_door, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
		watched_door = null
		UnregisterSignal(owner, COMSIG_LIVING_DEATH)

/datum/component/assassin_disguise
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/assassin_identity/original_identity
	var/datum/assassin_identity/pending_identity
	var/next_change = 0
	var/last_damage_time = -INFINITY
	var/changing = FALSE
	var/restoring = FALSE
	var/change_timer
	var/blur_timer
	var/stealth_until = 0

/datum/component/assassin_disguise/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/assassin_disguise/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMGE, PROC_REF(onDamage))

/datum/component/assassin_disguise/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMGE)

/datum/component/assassin_disguise/Destroy()
	deltimer(change_timer)
	deltimer(blur_timer)
	var/mob/living/carbon/human/assassin = parent
	if(ishuman(assassin) && !QDELETED(assassin))
		endStealth()
		if(original_identity)
			original_identity.applyTo(assassin)
		assassin.remove_filter("assassin_disguise")
	QDEL_NULL(pending_identity)
	QDEL_NULL(original_identity)
	return ..()

/datum/component/assassin_disguise/proc/onDamage(datum/source, damage)
	SIGNAL_HANDLER
	if(damage > 0)
		last_damage_time = world.time
		endStealth()

/datum/component/assassin_disguise/proc/endStealth()
	var/mob/living/assassin = parent
	if(stealth_until && assassin.mob_timers[MT_INVISIBILITY] == stealth_until)
		assassin.mob_timers[MT_INVISIBILITY] = world.time
		assassin.update_sneak_invis(reset = TRUE)
	stealth_until = 0

/datum/component/assassin_disguise/proc/assumeIdentity(
	mob/living/carbon/human/target)
	var/mob/living/carbon/human/assassin = parent
	if(changing || world.time < next_change)
		to_chat(assassin, span_warning("My borrowed flesh has not settled."))
		return FALSE
	if(!original_identity)
		original_identity = new(assassin)
	pending_identity = new(target)
	beginChange()
	return TRUE

/datum/component/assassin_disguise/proc/restoreIdentity()
	if(!original_identity || changing)
		return FALSE
	restoring = TRUE
	beginChange()
	return TRUE

/datum/component/assassin_disguise/proc/beginChange()
	var/mob/living/carbon/human/assassin = parent
	changing = TRUE
	next_change = world.time + 30 SECONDS
	assassin.add_filter("assassin_disguise", 1,
		list("type" = "blur", "size" = 0))
	animate(assassin.get_filter("assassin_disguise"), size = 3,
		time = 0.5 SECONDS)
	change_timer = addtimer(CALLBACK(src, PROC_REF(completeChange)),
		0.5 SECONDS, TIMER_STOPPABLE)

/datum/component/assassin_disguise/proc/completeChange()
	change_timer = null
	var/mob/living/carbon/human/assassin = parent
	if(restoring)
		original_identity.applyTo(assassin)
		QDEL_NULL(original_identity)
		restoring = FALSE
		to_chat(assassin, span_notice("My own face returns through the haze."))
	else
		pending_identity.applyTo(assassin)
		QDEL_NULL(pending_identity)
		to_chat(assassin, span_cult("The stolen flesh settles over my own."))
	animate(assassin.get_filter("assassin_disguise"), size = 0,
		time = 0.5 SECONDS)
	blur_timer = addtimer(CALLBACK(src, PROC_REF(finishChange)),
		0.5 SECONDS, TIMER_STOPPABLE)

/datum/component/assassin_disguise/proc/finishChange()
	blur_timer = null
	var/mob/living/carbon/human/assassin = parent
	assassin.remove_filter("assassin_disguise")
	changing = FALSE

/datum/component/assassin_disguise
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/assassin_identity/original_identity
	var/datum/assassin_identity/pending_identity
	var/next_change = 0
	var/last_damage_time = -INFINITY
	var/changing = FALSE
	var/change_timer
	var/change_step = 0
	var/original_pixel_w
	var/original_pixel_z
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
	var/mob/living/carbon/human/assassin = parent
	if(ishuman(assassin) && !QDELETED(assassin))
		endStealth()
		if(changing)
			finishChange()
		if(original_identity)
			original_identity.applyTo(assassin)
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

/datum/component/assassin_disguise/proc/beginChange()
	var/mob/living/carbon/human/assassin = parent
	changing = TRUE
	next_change = world.time + 30 SECONDS
	change_step = 0
	original_pixel_w = assassin.pixel_w
	original_pixel_z = assassin.pixel_z
	assassin.add_filter("assassin_disguise", 1,
		list("type" = "blur", "size" = 2))
	assassin.add_filter("assassin_disguise_flicker", 2,
		list("type" = "color", "color" = COLOR_WHITE))
	tickChange()

/datum/component/assassin_disguise/proc/tickChange()
	change_timer = null
	var/mob/living/carbon/human/assassin = parent
	if(QDELETED(assassin))
		return
	if(change_step >= 10)
		finishChange()
		return
	if(change_step == 5)
		completeChange()

	var/distortion = 1
	if(change_step >= 3 && change_step <= 7)
		distortion = 2
	assassin.modify_filter("assassin_disguise",
		list("size" = rand(1, 2) * distortion), update = FALSE)
	var/list/flicker_color = list(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, pick(0.4, 0.7, 1),
	)
	assassin.modify_filter("assassin_disguise_flicker",
		list("color" = flicker_color))
	assassin.pixel_w = original_pixel_w + pick(-2, 2) * distortion
	assassin.pixel_z = original_pixel_z + rand(-1, 1)
	change_step++
	change_timer = addtimer(CALLBACK(src, PROC_REF(tickChange)), 0.1 SECONDS, TIMER_STOPPABLE)

/datum/component/assassin_disguise/proc/completeChange()
	var/mob/living/carbon/human/assassin = parent
	pending_identity.applyTo(assassin)
	QDEL_NULL(pending_identity)
	to_chat(assassin, span_cult("The stolen flesh settles over my own."))

/datum/component/assassin_disguise/proc/finishChange()
	var/mob/living/carbon/human/assassin = parent
	assassin.remove_filter(list("assassin_disguise",
		"assassin_disguise_flicker"))
	assassin.pixel_w = original_pixel_w
	assassin.pixel_z = original_pixel_z
	changing = FALSE

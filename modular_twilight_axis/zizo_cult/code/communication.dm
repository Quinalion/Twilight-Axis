// TA EDIT START
/mob/living/carbon/human/proc/communicate()
	set name = "Communicate with Cult"
	set category = "ZIZO"
	if(!is_zizo_cult_member(src) || stat >= UNCONSCIOUS || !can_speak_vocal())
		return
	var/message = tgui_input_text(src, "What will you tell the cult?", "Cult Communion", max_length = MAX_MESSAGE_LEN)
	if(!message || !is_zizo_cult_member(src) || stat >= UNCONSCIOUS || !can_speak_vocal())
		return
	whisper("O schlet'a ty'schkotot ty'skvoro...")
	for(var/datum/mind/recipient as anything in get_zizo_cult_minds())
		if(!recipient.current)
			continue
		to_chat(recipient.current, span_purple("[html_encode(real_name)] speaks through the dark: [html_encode(message)]"))
		recipient.current.playsound_local(recipient.current, 'modular_twilight_axis/zizo_cult/sound/communication.ogg', 100)
	log_telepathy("[key_name(src)] used cult communion: [message]")

/mob/living/carbon/human/proc/cultist_number()
	set name = "Number of Cultists"
	set category = "ZIZO"
	if(mind && is_zizocultist(mind) && stat < UNCONSCIOUS)
		to_chat(src, span_notice("[length(SSmapping.retainer.cultists)] souls are sworn to the cult."))

/mob/living/carbon/human/proc/ascension_check()
	set name = "Ascension Check"
	set category = "ZIZO"
	if(!mind || !is_zizocultist(mind) || stat >= UNCONSCIOUS)
		return
	var/mob/living/carbon/human/sacrifice = get_zizo_ascension_sacrifice()
	var/offering = sacrifice ? "[sacrifice.real_name], [get_zizo_role_title(sacrifice)]" : "a crown"
	to_chat(src, span_notice("The final work demands [offering] on the northern sigil and [SSmapping.retainer.get_cult_ascension_required_cultists()] sworn cultists."))

/mob/living/carbon/human/proc/release_minion()
	set name = "Release Lackey"
	set category = "ZIZO"
	if(!mind || !is_zizocultist(mind) || stat >= UNCONSCIOUS)
		return
	var/list/candidates = list()
	for(var/datum/mind/cultist as anything in SSmapping.retainer.cultists)
		if(cultist.current && cultist.has_antag_datum(/datum/antagonist/zizocultist) && !is_zizocultist(cultist))
			candidates += cultist.current
	var/mob/living/carbon/human/target = tgui_input_list(src, "Whose service is at an end?", "Release Lackey", candidates)
	if(!target || alert(src, "End [target.real_name]'s service? This will destroy their body.", "Release Lackey", "Release", "Cancel") != "Release")
		return
	if(QDELETED(target) || !mind || !is_zizocultist(mind) || stat >= UNCONSCIOUS || !is_zizo(target) || is_zizocultist(target.mind))
		return
	visible_message(span_danger("[src] closes a hand. [target]'s body begins to unravel."))
	to_chat(target, span_userdanger("My service ends. The Dark Lady gathers what remains."))
	var/datum/mind/released_mind = target.mind
	target.gib()
	released_mind.remove_antag_datum(/datum/antagonist/zizocultist)
// TA EDIT END

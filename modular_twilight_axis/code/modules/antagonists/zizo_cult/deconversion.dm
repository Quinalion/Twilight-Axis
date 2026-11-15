// TA EDIT - Voluntary cleansing on Astrata and Psydon runes
/proc/choose_zizo_cleansing(mob/living/user, atom/rune, patron_type)
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in get_turf(rune))
		if(is_zizo(H))
			targets += H
	var/mob/living/carbon/human/target = input(user, "Whom will you cleanse?", "Cleansing") as null|anything in targets
	return cleanse_zizo(user, target, rune, patron_type)

/proc/cleanse_zizo(mob/living/user, mob/living/carbon/human/target, atom/rune, patron_type)
	if(QDELETED(target) || !user.Adjacent(rune) || get_turf(target) != get_turf(rune))
		return FALSE
	for(var/chant in list("Reject the Dark Lady!", "Let your soul be free!", "Be cleansed of her corruption!"))
		if(!do_after(user, 5 SECONDS, target = rune))
			return FALSE
		user.say(chant)
	var/datum/antagonist/zizocultist/cult = target.mind?.has_antag_datum(/datum/antagonist/zizocultist)
	if(!cult || !cult.islesser || target.stat == DEAD || get_turf(target) != get_turf(rune))
		return FALSE
	if(tgui_alert(target, "Will you refuse the Dark Lady and free your soul?", "Cleansing", list("Yield", "Resist")) != "Yield")
		return FALSE
	if(QDELETED(rune) || QDELETED(target) || QDELETED(cult) || target.stat == DEAD || !user.Adjacent(rune) || get_turf(target) != get_turf(rune))
		return FALSE
	to_chat(target, span_userdanger("I am free from the Dark Lady's service."))
	cult.on_removal()
	target.set_patron(patron_type)
	target.say("Praise [target.patron.name]!", forced = "deconversion")
	target.emote("agony", forced = TRUE)
	target.Stun(3 SECONDS)
	target.Knockdown(3 SECONDS)
	user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
	return TRUE

/obj/effect/decal/cleanable/roguerune/god/psydon
	rituals = list(
		/datum/runeritual/silver_blessing::name = /datum/runeritual/silver_blessing,
		/datum/runeritual/zizo_cleansing::name = /datum/runeritual/zizo_cleansing,
	)

/datum/runeritual/zizo_cleansing
	name = "Rite of Cleansing"
	required_atoms = list(/mob/living/carbon/human = 1)

/datum/runeritual/zizo_cleansing/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/target = selected_atoms[1]
	selected_atoms -= target
	var/obj/effect/decal/cleanable/roguerune/god/psydon/rune = locate() in loc
	if(!rune)
		return FALSE
	return cleanse_zizo(user, target, rune, /datum/patron/old_god)

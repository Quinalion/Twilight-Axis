/datum/emote/living/carbon/human/praise
	key = "praise"
	emote_type = EMOTE_AUDIBLE
	show_runechat = TRUE
	key_third_person = "славит Зизо"
	message = "славит <span class='bold'>Зизо</span>!"

/datum/emote/living/carbon/human/praise/can_run_emote(mob/living/user, status_check = TRUE, intentional = FALSE)
	if(!HAS_TRAIT(user, TRAIT_CABAL))
		return FALSE
	if(status_check && (user.stat >= UNCONSCIOUS || !user.can_speak_vocal()))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/praise/get_sound(mob/living/user)
	return pick(
		'modular_twilight_axis/zizo_cult/sound/praise1.ogg',
		'modular_twilight_axis/zizo_cult/sound/praise2.ogg',
		'modular_twilight_axis/zizo_cult/sound/praise3.ogg',
		'modular_twilight_axis/zizo_cult/sound/praise4.ogg',
		'modular_twilight_axis/zizo_cult/sound/praise5.ogg',
		'modular_twilight_axis/zizo_cult/sound/praise6.ogg',
	)

/datum/emote/living/carbon/human/praise/run_emote(mob/living/user, params, type_override, intentional, targetted, animal, quiet = FALSE)
	. = ..()
	if(.)
		record_round_statistic(STATS_ZIZO_PRAISED)

/mob/living/carbon/human/proc/emote_praise()
	set name = TA_EMOTE_NAME_EMOTE_PRAISE
	set category = "Emotes"

	emote("praise", intentional = TRUE)

/datum/stressevent/triumph_noise
	timer = 10 MINUTES
	stressadd = 3
	desc = span_red("The memory of my triumph turns to rot!")

/mob/living/carbon/proc/zizo_noise_effects()
	if(prob(5))
		var/hallucination_type = pick(
			/datum/hallucination/message,
			/datum/hallucination/sounds,
			/datum/hallucination/weird_sounds,
			/datum/hallucination/voices,
			/datum/hallucination/fire,
			/datum/hallucination/chat,
			/datum/hallucination/townannouncement,
			/datum/hallucination/battle,
			/datum/hallucination/fake_alert,
		)
		new hallucination_type(src, FALSE)
	roll_streak_freakout()

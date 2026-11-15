/datum/status_effect/debuff/fleshmend_exhaustion
	id = "fleshmend_tax"
	duration = 15 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend_tax
	effectedstats = list(STATKEY_STR = -2, STATKEY_SPD = -2, STATKEY_CON = -2)

/atom/movable/screen/alert/status_effect/fleshmend_tax
	name = "Истощение плоти"
	desc = "Ваше тело было исцелено магией Зизо, но цена была высока. Сила, выносливость и скорость снижены."
	icon_state = "debuff"

/datum/status_effect/debuff/arcynestolen
	id = "arcynestolen"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/arcynestolen
	duration = 30 MINUTES

/datum/status_effect/debuff/arcynestolen/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, id)

/datum/status_effect/debuff/arcynestolen/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, id)

/atom/movable/screen/alert/status_effect/debuff/arcynestolen
	name = "Stolen arcyne"
	desc = "This cultists is stolen my magic.. Maybe it will come back later.."

/datum/status_effect/buff/cultlight
	id = "cultlight"
	alert_type = /atom/movable/screen/alert/status_effect/buff/cultlight
	effectedstats = list(STATKEY_SPD = 1)

/atom/movable/screen/alert/status_effect/buff/cultlight
	name = "Cult light armor"
	desc = "Robe of my queen makes me speedy!"
	icon_state = "buff"

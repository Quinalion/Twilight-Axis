/datum/status_effect/debuff/fleshmend_exhaustion
	id = "fleshmend_tax"
	duration = 15 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend_tax
	effectedstats = list(STATKEY_STR = -2, STATKEY_SPD = -2, STATKEY_CON = -2)

/atom/movable/screen/alert/status_effect/fleshmend_tax
	name = "Fleshmend Exhaustion"
	desc = "Strength, Speed and Constitution are reduced by 2 for fifteen minutes after Restore Flesh."
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
	name = "Stolen Arcyne"
	desc = "Spellcasting is disabled for thirty minutes."

/datum/status_effect/buff/cultlight
	id = "cultlight"
	alert_type = /atom/movable/screen/alert/status_effect/buff/cultlight
	effectedstats = list(STATKEY_SPD = 1)

/atom/movable/screen/alert/status_effect/buff/cultlight
	name = "Cult Light Armor"
	desc = "Cult armor increases Speed by 1 while worn."
	icon_state = "buff"

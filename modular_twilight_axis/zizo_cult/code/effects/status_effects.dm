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

/datum/status_effect/cult_painless
	id = "cult_painless"
	duration = -1
	alert_type = null
	effectedstats = list(STATKEY_WIL = 1)

/datum/status_effect/cult_painless/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOPAIN, id)

/datum/status_effect/cult_painless/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOPAIN, id)
	return ..()

/datum/status_effect/cult_immortality
	id = "cult_immortality"
	duration = -1
	alert_type = null
	effectedstats = list(STATKEY_STR = -3, STATKEY_SPD = -3, STATKEY_WIL = -3)
	var/list/granted_traits = list(TRAIT_NOPAIN, TRAIT_NOLIMBDISABLE, TRAIT_HARDDISMEMBER, TRAIT_NODEATH, TRAIT_TOXIMMUNE, TRAIT_NOBREATH, TRAIT_BLOODLOSS_IMMUNE, TRAIT_ZOMBIE_IMMUNE, TRAIT_WOUNDREGEN, TRAIT_SPELLCOCKBLOCK, TRAIT_NOSOFTCRIT, TRAIT_NOHUNGER, TRAIT_NOSLEEP)

/datum/status_effect/cult_immortality/on_apply()
	. = ..()
	for(var/trait in granted_traits)
		ADD_TRAIT(owner, trait, id)

/datum/status_effect/cult_immortality/on_remove()
	for(var/trait in granted_traits)
		REMOVE_TRAIT(owner, trait, id)
	return ..()

/datum/status_effect/cult_painless/be_replaced()
	REMOVE_TRAIT(owner, TRAIT_NOPAIN, id)
	return ..()

/datum/status_effect/cult_immortality/be_replaced()
	for(var/trait in granted_traits)
		REMOVE_TRAIT(owner, trait, id)
	return ..()

/datum/status_effect/buff/cultlight
	var/obj/item/source_item

/datum/status_effect/buff/cultlight/on_creation(mob/living/new_owner, obj/item/source)
	source_item = source
	return ..()

// TA EDIT START
/datum/status_effect/cult_lackey
	id = "cult_lackey"
	duration = -1
	alert_type = null
	effectedstats = list(STATKEY_STR = 2, STATKEY_INT = -2)

/datum/status_effect/cult_leader
	id = "cult_leader"
	duration = -1
	alert_type = null
	effectedstats = list(STATKEY_STR = 4, STATKEY_PER = 2, STATKEY_WIL = 1, STATKEY_CON = 2, STATKEY_SPD = 1, STATKEY_INT = 1)
// TA EDIT END

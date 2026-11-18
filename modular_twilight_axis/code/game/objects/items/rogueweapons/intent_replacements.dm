/datum/intent/cleaving_blow
	parent_type = /datum/intent/sword/cut/zwei/cleave
	name = "cleaving blow"
	desc = "Drive a chopping blow through two foes standing in line."
	blade_class = BCLASS_CHOP
	animname = "chop"

/datum/intent/reaching_thrust
	parent_type = /datum/intent/sword/thrust/estoc/lunge
	name = "reaching thrust"
	desc = "Extend your blade to strike a foe up to two paces away."

/proc/resolveTwilightWeaponIntent(intent_entry)
	var/intent_type = intent_entry
	if(istype(intent_entry, /datum/intent))
		var/datum/intent/intent = intent_entry
		intent_type = intent.type
	if(ispath(intent_type, /datum/intent/axe/chop/heavy))
		return /datum/intent/cleaving_blow
	if(ispath(intent_type, /datum/intent/sword/cut/sabre/heavy))
		return /datum/intent/cleaving_blow
	if(ispath(intent_type, /datum/intent/sword/cut/falx/heavy))
		return /datum/intent/cleaving_blow
	if(ispath(intent_type, /datum/intent/sword/thrust/rapier/lunge))
		return /datum/intent/reaching_thrust
	return intent_type

/proc/createTwilightWeaponIntent(intent_entry, mob/owner, obj/item/weapon)
	var/intent_type = resolveTwilightWeaponIntent(intent_entry)
	if(!ispath(intent_type, /datum/intent))
		return null
	if(weapon)
		return new intent_type(owner, weapon)
	return new intent_type(owner)

/datum/intent/proc/applyTwilightWeaponReplacement()
	var/replacement_type = resolveTwilightWeaponIntent(type)
	if(replacement_type == type)
		return
	var/datum/intent/replacement = new replacement_type()
	var/static/list/replaced_fields = list(
		"name", "desc", "icon", "icon_state", "attack_verb", "animname",
		"blade_class", "hitsound", "canparry", "candodge", "chargetime",
		"swingdelay", "swingdelay_type", "clickcd", "damfactor", "penfactor",
		"reach", "effective_range", "effective_range_type", "item_d_type",
		"intent_intdamage_factor", "demolition_mod", "no_early_release",
		"misscost", "releasedrain",
	)
	for(var/field in replaced_fields)
		var/value = replacement.vars[field]
		if(islist(value))
			var/list/values = value
			value = values.Copy()
		vars[field] = value
	if(istype(cleave))
		qdel(cleave)
	cleave = replacement.cleave?.type
	qdel(replacement)

// Direct construction bypasses the weapon factory and still needs translation.
/datum/intent/axe/chop/heavy/New(Mastermob, Masteritem)
	applyTwilightWeaponReplacement()
	return ..()

/datum/intent/sword/cut/sabre/heavy/New(Mastermob, Masteritem)
	applyTwilightWeaponReplacement()
	return ..()

/datum/intent/sword/cut/falx/heavy/New(Mastermob, Masteritem)
	applyTwilightWeaponReplacement()
	return ..()

/datum/intent/sword/thrust/rapier/lunge/New(Mastermob, Masteritem)
	applyTwilightWeaponReplacement()
	return ..()

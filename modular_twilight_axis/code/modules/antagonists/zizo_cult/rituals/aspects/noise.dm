/mob/living/proc/end_jaunt(obj/effect/dummy/phased_mob/slaughter/holder, turf/return_turf)
	if(QDELETED(holder))
		return
	forceMove(return_turf || get_turf(holder))
	var/obj/effect/temp_visual/dir_setting/cult/phase/P = new(get_turf(src), dir)
	P.color = "#2b0a3d"
	qdel(holder)

/mob/living/simple_animal/spook_spirit
	name = "???"
	desc = "Don't look at this."
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	invisibility = INVISIBILITY_OBSERVER
	density = FALSE
	incorporeal_move = TRUE
	movement_type = FLYING
	base_intents = list(INTENT_HELP)
	health = 500
	maxHealth = 500
	ai_controller = null

/mob/living/simple_animal/spook_spirit/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPELLCOCKBLOCK, TRAIT_GENERIC)

/mob/living/simple_animal/spook_spirit/canZMove(direction, turf/target)
	return TRUE

/mob/living/simple_animal/spook_spirit/verb/spirit_up()
	set category = "Spook"
	set name = "Move Up"
	if(zMove(UP, TRUE))
		to_chat(src, span_notice("I drift upwards."))

/mob/living/simple_animal/spook_spirit/verb/spirit_down()
	set category = "Spook"
	set name = "Move Down"
	if(zMove(DOWN, TRUE))
		to_chat(src, span_notice("I drift downwards."))

/mob/living/simple_animal/spook_spirit/ex_act()
	return

/mob/living/simple_animal/spook_spirit/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/mob/living/simple_animal/spook_spirit/fire_act()
	return

/datum/ritual/noise/thermalvis
	name = "Spook"
	desk = "Learn a spell to phase-walk through walls, leaving your body behind. Your eyes now see the living through walls."
	passive = TRUE

/datum/ritual/noise/thermalvis/apply_passive(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_THERMAL_VISION, TRAIT_GENERIC)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/spook_scry)
	return

/obj/effect/proc_holder/spell/self/spook_scry
	name = "Spook"
	desc = "Leave your body behind and observe the world unhindered for 20 seconds."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "zizocloud"
	recharge_time = 30 SECONDS
	chargedloop = null

/obj/effect/proc_holder/spell/self/spook_scry/charge_check(mob/user)
	return charge_counter >= recharge_time

/obj/effect/proc_holder/spell/self/spook_scry/cast(list/targets, mob/user = usr)
	. = ..()
	if(!ishuman(user))
		revert_cast()
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!H.mind)
		revert_cast()
		return FALSE
	var/mob/living/simple_animal/spook_spirit/spirit = new(get_turf(H))
	H.visible_message(span_warning("[H] falls limp!"))
	H.mind.transfer_to(spirit)
	addtimer(CALLBACK(src, PROC_REF(end_spook), H, spirit), 20 SECONDS)
	return TRUE

/obj/effect/proc_holder/spell/self/spook_scry/proc/end_spook(mob/living/carbon/human/H, mob/living/simple_animal/spook_spirit/spirit)
	if(QDELETED(H))
		qdel(spirit)
		return
	if(spirit.mind)
		spirit.mind.transfer_to(H)
	qdel(spirit)

/mob/living/simple_animal/pet/cat/rogue/black/witch
	base_intents = list(/datum/intent/simple/claw/witch_cat)
	melee_damage_lower = 2
	melee_damage_upper = 5
	armor_penetration = PEN_MEDIUM
	hud_type = /datum/hud/dextrous
	held_items = list(null, null)
	var/mob/living/carbon/human/body
	var/list/bitten = list()

/mob/living/simple_animal/pet/cat/rogue/black/witch/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPELLCOCKBLOCK, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_ZJUMP, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOFALLDAMAGE2, TRAIT_GENERIC)
	pass_flags |= PASSTABLE | PASSGRILLE
	STAPER = 15
	see_in_dark = 12
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

/mob/living/simple_animal/pet/cat/rogue/black/witch/UnarmedAttack(atom/A, proximity)
	var/mob/living/carbon/human/victim = A
	var/bleed_before = 0
	if(istype(victim))
		bleed_before = victim.get_bleed_rate()
	. = ..()
	if(istype(victim) && !is_zizo(victim) && victim.get_bleed_rate() > bleed_before && !(victim in bitten))
		bitten += victim
		to_chat(src, span_notice("I collect [victim]'s blood! The cat will drop a remnant leech after the spell ends."))

/mob/living/simple_animal/pet/cat/rogue/black/witch/Destroy()
	if(mind)
		if(QDELETED(body))
			ghostize()
		else
			mind.transfer_to(body)
	for(var/mob/living/carbon/human/victim in bitten)
		var/obj/item/natural/worms/leech/remnant = new(get_turf(src))
		remnant.fed_from = victim
		remnant.blood_storage = remnant.blood_maximum
		remnant.update_icon()
	return ..()

/mob/living/simple_animal/pet/cat/rogue/black/witch/death(gibbed)
	qdel(src)

/obj/effect/proc_holder/spell/self/witch_possess
	name = "Witchery"
	desc = "Possess cat, or return to body. Biting people collects their blood for remnants."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "tame_deadite"
	recharge_time = 10 SECONDS
	chargedloop = null
	ignore_cockblock = TRUE
	var/mob/living/simple_animal/pet/cat/rogue/black/witch/cat

/obj/effect/proc_holder/spell/self/witch_possess/charge_check(mob/user, feedback = TRUE)
	if(user == cat)
		return TRUE
	return ..()

/obj/effect/proc_holder/spell/self/witch_possess/cast(list/targets, mob/user = usr)
	. = ..()
	if(user == cat)
		qdel(cat)
		return TRUE
	if(!ishuman(user) || !user.mind)
		revert_cast()
		return FALSE
	cat = new(get_turf(user))
	cat.body = user
	user.visible_message(span_warning("[user] falls limp!"))
	user.mind.transfer_to(cat)
	return TRUE

/datum/ritual/noise/witchery
	name = "Witchery"
	desk = "Learn to summon a black cat. You are able to remotely possess it at any time and see through its eyes. Biting people collects their blood for remnants."
	passive = TRUE

/datum/ritual/noise/witchery/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/witch_possess)
	return

/datum/ritual/noise/forgettongue
	name = "Curse of Babel"
	desk = "Curse your target to forget the common tongue and become illiterate. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/noise/forgettongue/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	if(!curse_target(remnant.fed_from))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	remnant.fed_from.remove_language(/datum/language/common)
	remnant.fed_from.adjust_skillrank(/datum/skill/misc/reading, -6, TRUE)
	to_chat(remnant.fed_from, span_danger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	remnant.fed_from.emote("scream")
	qdel(remnant)
	to_chat(user, span_notice("IT EATS AWAY MEANING AND LEAVES NOTHING BUT NOISE."))

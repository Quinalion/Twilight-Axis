/mob/living/carbon/human
	var/au_bord_injected = FALSE

/obj/item/au_bord_injector
	name = "Injecteur \"Au Bord\""
	desc = "A single-use iron syringe marked with an Otavan cross and a skull. \
		An intoxicating scent seeps from it even while sealed."
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "injector_ready"
	w_class = WEIGHT_CLASS_TINY
	grid_width = 32
	grid_height = 32
	var/spent = FALSE

/obj/item/au_bord_injector/examine(mob/user)
	. = ..()
	if(spent || !HAS_TRAIT(user, TRAIT_INQUISITION))
		return
	var/list/examination = .
	var/description_index = examination.Find(span_info(desc))
	if(description_index)
		examination[description_index] = span_info("A single-use iron syringe filled with a near-lethal dose of stimulants. \
			Baothan cultists use such mixtures in their rites. \
			Their work is in the right hands now.")

/obj/item/au_bord_injector/attack_self(mob/user)
	if(ishuman(user))
		inject(user, user)

/obj/item/au_bord_injector/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return TRUE
	if(!ishuman(target))
		return FALSE
	inject(target, user)
	return TRUE

/obj/item/au_bord_injector/proc/inject(
	mob/living/carbon/human/recipient, mob/living/user,
)
	if(spent || recipient.stat == DEAD || !(src in user.held_items))
		return
	if(!recipient.can_inject(user, TRUE))
		return
	if(recipient != user && !do_after(user, 2 SECONDS, target = recipient))
		return
	if(QDELETED(src) || QDELETED(recipient) || spent || recipient.stat == DEAD)
		return
	if(!(src in user.held_items))
		return
	if(recipient != user && !user.Adjacent(recipient))
		return
	if(!recipient.can_inject(user, TRUE))
		return

	spent = TRUE
	icon_state = "injector_used"
	desc = "An empty iron syringe marked with an Otavan cross."
	user.update_inv_hands()
	user.visible_message(span_warning("[user] injects [recipient] with [src]."))

	if(recipient.au_bord_injected)
		recipient.remove_status_effect(/datum/status_effect/buff/au_bord)
		if(recipient.can_heartattack())
			recipient.set_heartattack(TRUE)
			to_chat(recipient, span_userdanger("My heart stops!"))
		return

	recipient.au_bord_injected = TRUE
	recipient.apply_status_effect(/datum/status_effect/buff/au_bord)

/datum/status_effect/buff/au_bord
	id = "au_bord"
	duration = 110 SECONDS
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/au_bord
	effectedstats = list(
		STATKEY_STR = 2,
		STATKEY_PER = 2,
		STATKEY_INT = 2,
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_SPD = 2,
		STATKEY_LCK = 2,
	)

/datum/status_effect/buff/au_bord/on_apply()
	if(!..())
		return FALSE
	owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/druqks)
	return TRUE

/datum/status_effect/buff/au_bord/on_remove()
	owner.clear_fullscreen(id)
	return ..()

/datum/status_effect/buff/au_bord/tick()
	if(owner.stat == DEAD)
		return
	owner.stamina_add(-6)
	if(HAS_TRAIT(owner, TRAIT_NOHEAL) || HAS_TRAIT(owner, TRAIT_IRONMAN))
		return
	var/healing = HAS_TRAIT(owner, TRAIT_HALFHEAL) ? 1 : 2
	owner.adjustBruteLoss(-healing)
	owner.adjustFireLoss(-healing)

/atom/movable/screen/alert/status_effect/au_bord
	name = "Au Bord"
	desc = "My senses reel, but my strength has not yet left me."
	icon_state = "drunk"

/datum/inqports/supplies/au_bord
	name = "Injecteur \"Au Bord\""
	item_type = /obj/item/au_bord_injector
	marquescost = 8

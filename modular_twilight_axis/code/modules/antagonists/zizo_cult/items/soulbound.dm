/datum/component/soulbound_weapon
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/weakref/owner_ref
	var/skill_path

/datum/component/soulbound_weapon/Initialize(skill_path_type)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	skill_path = skill_path_type
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))

/datum/component/soulbound_weapon/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot != ITEM_SLOT_HANDS || !ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/weapon = parent
	if(!owner_ref)
		for(var/obj/effect/proc_holder/spell/self/recall_bound/old in H.mind?.spell_list)
			if(!QDELETED(old.weapon))
				to_chat(H, span_danger("[uppertext(weapon)] REFUSES ME. I AM ALREADY BOUND TO ANOTHER!"))
				H.dropItemToGround(weapon)
				return
		owner_ref = WEAKREF(H)
		if(skill_path)
			H.adjust_skillrank_up_to(skill_path, SKILL_LEVEL_MASTER)
		to_chat(H, span_danger("I feel [weapon] bind itself to me!"))
		var/obj/effect/proc_holder/spell/self/recall_bound/recall = new
		recall.weapon = weapon
		recall.name = "Recall [weapon.name]"
		H.mind?.AddSpell(recall)
		return
	if(owner_ref.resolve() == H)
		return
	to_chat(H, span_danger("[uppertext(weapon)] HATES ME!"))
	H.dropItemToGround(weapon)

/obj/item/rogueweapon/huntingknife/idagger/steel/zizo/conjured
	associated_skill = /datum/skill/combat/arcyne

/obj/item/rogueweapon/sword/long/zizo/conjured
	associated_skill = /datum/skill/combat/arcyne

/datum/action/cooldown/spell/conjure_arcyne_ward/zizo
	name = "Inhumen Ward"
	desc = "Conjure an inhumen ward - an upgraded arcyne ward hardened with dark magic. \
	This ward is entirely invisible until damaged, unlike other wards. 400 integrity. \
	Otherwise functions as a standard arcyne ward - yields coverage to real armor, does not regenerate. \
	Cast again to dismiss. Cooldown begins when dismissed or destroyed."
	button_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	button_icon_state = "ZIZO"
	source_aspect = null
	invocation_type = INVOCATION_NONE
	dismiss_invocation = ""
	regen_invocation = ""
	ward_type = /obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/zizo
	var/hidden = TRUE

/datum/action/cooldown/spell/conjure_arcyne_ward/zizo/before_cast(atom/cast_on)
	var/mob/living/carbon/human/H = owner
	if((!conjured_ward || QDELETED(conjured_ward)) && H.skin_armor)
		to_chat(H, span_warning("Already warded!"))
		return SPELL_CANCEL_CAST
	return ..()

/obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/zizo
	var/hidden = TRUE
	name = "inhumen ward"
	desc = "An arcyne ward hardened with dark magic."
	arcyne_armor_tier = ARCYNE_WARD_TIER_GREATER + 1
	armor = ARMOR_BRIGANDINE
	max_integrity = 400
	hidden = TRUE
	ward_color = "#7a1fa2"

/obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/zizo/flash_ward()
	if(!ward_owner)
		return
	hidden = FALSE
	ward_owner.remove_filter("zizo_ward_glow")
	ward_owner.add_filter("zizo_ward_glow", 2, list("type" = "outline", "color" = ward_color, "alpha" = 80, "size" = 1))
	addtimer(CALLBACK(src, PROC_REF(clear_flash)), 30 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/zizo/clear_flash()
	hidden = TRUE
	ward_owner?.remove_filter("zizo_ward_glow")

/obj/item/clothing/suit/roguetown/armor/manual/arcyne_ward/zizo/cleanup_ward()
	ward_owner?.remove_filter("zizo_ward_glow")
	return ..()

/datum/action/cooldown/spell/form_blade/avantyne
	name = "Avantyne Blade"
	desc = "Conjure an avantyne dagger or sword. Cycle the form with Shift+G. Cast again to dispel it."
	button_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	button_icon_state = "ZIZO"
	attunement_school = null
	primary_resource_type = SPELL_COST_NONE
	invocation_type = INVOCATION_NONE
	shared_cooldown = "avantyne_blade"
	outline_color = "#2b0a3d"
	cooldown_time = 10 SECONDS
	associated_stat = null
	weapon_cast_penalized = FALSE
	ignore_armor_penalty = TRUE
	spell_requirements = SPELL_REQUIRES_HUMAN
	forms = list(
		list("label" = "Dagger", "weapon" = /obj/item/rogueweapon/huntingknife/idagger/steel/zizo/conjured),
		list("label" = "Sword", "weapon" = /obj/item/rogueweapon/sword/long/zizo/conjured),
	)

/datum/action/cooldown/spell/form_blade/avantyne/cast(atom/cast_on)
	if(QDELETED(conjured_weapon))
		return ..()
	conjured_weapon.visible_message(span_warning("[conjured_weapon] crumbles away!"))
	qdel(conjured_weapon)
	conjured_weapon = null
	return TRUE

/obj/effect/proc_holder/spell/self/recall_bound
	name = "Recall Weapon"
	desc = "Call your bound weapon to your hand."
	overlay_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	action_icon = 'modular_twilight_axis/icons/zizo_cult/mob/actions/zizomiracles.dmi'
	overlay_state = "ZIZO"
	recharge_time = 30 SECONDS
	chargedloop = null
	var/obj/item/weapon

/obj/effect/proc_holder/spell/self/recall_bound/cast(list/targets, mob/user = usr)
	. = ..()
	if(QDELETED(weapon))
		to_chat(user, span_warning("MY WEAPON IS GONE."))
		revert_cast()
		return FALSE
	if(weapon in user.held_items)
		to_chat(user, span_warning("I'M ALREADY HOLDING IT."))
		revert_cast()
		return FALSE
	var/obj/item/bodypart/part = weapon.loc
	if(istype(part))
		part.remove_embedded_object(weapon)
	else if(ismob(weapon.loc))
		var/mob/M = weapon.loc
		M.dropItemToGround(weapon)
	weapon.forceMove(get_turf(weapon))
	weapon.visible_message(span_warning("[weapon] suddenly disappears!"))
	if(!user.put_in_hands(weapon))
		weapon.forceMove(user.drop_location())
	user.visible_message(span_warning("[weapon] suddenly appears in [user]'s hand!"))
	return TRUE

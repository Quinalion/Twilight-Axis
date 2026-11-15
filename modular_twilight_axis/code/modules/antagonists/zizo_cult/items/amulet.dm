/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult
	name = "balefully enchanted psycross"
	desc = "An enchanted inverted psycross worn by followers of Zizo."
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/on_mob/zcross.dmi'
	icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/zcross.dmi'
	icon_state = "zcross"
	slot_flags = ITEM_SLOT_RING
	sellprice = 0
	max_integrity = 180
	body_parts_covered = COVERAGE_FULL | COVERAGE_HEAD_NOSE | NECK | HANDS | FEET
	armor = ARMOR_CULTNECK
	blade_dulling = DULLING_BASHCHOP
	blocksound = PLATEHIT
	break_sound = 'sound/foley/breaksound.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	armor_class = ARMOR_CLASS_LIGHT
	unenchantable = TRUE
	anvilrepair = null
	equip_delay_self = 5 SECONDS
	unequip_delay_self = 5 SECONDS

/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ICON)

/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!M.can_equip(src, slot, disable_warning, bypass_equip_delay_self))
		return FALSE

	if(slot == SLOT_WRISTS || (wrist_display && slot != SLOT_NECK))
		mob_overlay_icon = 'icons/roguetown/clothing/onmob/wrists.dmi'
		sleeved = 'icons/roguetown/clothing/onmob/wrists.dmi'
	else
		mob_overlay_icon = initial(mob_overlay_icon)
		sleeved = initial(sleeved)

	return TRUE

/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult/Initialize()
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "CROSS")

/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS, HERESYDESC_ZIZO_ICON)

/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_RING || slot == SLOT_NECK || SLOT_WRISTS)
		ADD_TRAIT(user, TRAIT_ZIZOSIGHT, TRAIT_GENERIC)

/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult/dropped(mob/living/carbon/human/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_ZIZOSIGHT, TRAIT_GENERIC)

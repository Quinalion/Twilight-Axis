/obj/item/clothing/cloak/half/shadowcloak/cult
	name = "balefully enchanted cloak"
	desc = "A dark cloak bound with the enchantments of Zizo."
	icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/zcloakicon.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/on_mob/zcloakonmob.dmi'
	icon_state = "zcloak"
	body_parts_covered = ARMS|CHEST|VITALS
	armor = ARMOR_PADDED

/obj/item/clothing/cloak/half/shadowcloak/cult/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "CLOAK")

/obj/item/clothing/cloak/half/shadowcloak/cult/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/suit/roguetown/shirt/robe/unholy/cult
	name = "balefully enchanted robes"
	desc = "Robes bound with the enchantments of Zizo."
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	allowed_sex = list(MALE, FEMALE)
	icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/zrobeicon.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/on_mob/zrobeonmob.dmi'
	icon_state = "zonmod"
	item_state = "zonmod"
	allowed_race = ALL_RACES_TYPES
	sleeved = null
	body_parts_covered = COVERAGE_ALL_BUT_HANDFEET
	sellprice = 0
	smeltresult = null

/obj/item/clothing/suit/roguetown/shirt/robe/unholy/cult/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "ROBE")

/obj/item/clothing/suit/roguetown/shirt/robe/unholy/cult/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

/obj/item/clothing/suit/roguetown/shirt/robe/unholy/cult/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_ARMOR)
		user.apply_status_effect(/datum/status_effect/buff/cultlight)

/obj/item/clothing/suit/roguetown/shirt/robe/unholy/cult/dropped(mob/living/carbon/human/user)
	. = ..()
	if(istype(user) && user?.wear_armor == src)
		user.remove_status_effect(/datum/status_effect/buff/cultlight)

/obj/item/clothing/head/roguetown/roguehood/unholy/cult
	name = "balefully enchanted hood"
	desc = "A hood bound with the enchantments of Zizo."
	icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/warlock.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/local/clothes/on_mob/warlock.dmi'
	icon_state = "warlockhood"
	adjustable = CANT_CADJUST
	toggle_icon_state = FALSE
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	smeltresult = null
	sellprice = 0

	body_parts_covered = NECK|HAIR|EARS|HEAD

/obj/item/clothing/head/roguetown/roguehood/unholy/cult/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "HOOD")

/obj/item/clothing/head/roguetown/roguehood/unholy/cult/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_ALARMING, HERESYDESC_ZIZO_ARMOR)

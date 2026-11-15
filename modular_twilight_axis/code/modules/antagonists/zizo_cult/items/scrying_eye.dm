/obj/item/scrying/eye
	name = "accursed eye"
	desc = "It is pulsating."
	icon = 'modular_twilight_axis/icons/zizo_cult/legacy/scryeye.dmi'
	icon_state ="scryeye"
	cooldown = 10 MINUTES
/obj/item/scrying/eye/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "EYE")

/obj/item/scrying/eye/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS, HERESYDESC_ZIZO_RELIC)

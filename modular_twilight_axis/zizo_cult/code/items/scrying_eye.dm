/obj/item/scrying/eye
	name = "accursed eye"
	desc = "It is pulsating."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/misc.dmi'
	icon_state ="scrying_eye"
	cooldown = 10 MINUTES

/obj/item/scrying/eye/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/cursed_item, TRAIT_CABAL, "EYE")

/obj/item/scrying/eye/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS, HERESYDESC_ZIZO_RELIC)

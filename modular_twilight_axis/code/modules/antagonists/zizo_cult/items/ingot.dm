/obj/item/ingot/steel/zizo
	name = "cursed ancient ingot"
	desc = "There are legends about the appearance of this ingot..."
	icon = 'modular_twilight_axis/icons/zizo_cult/legacy/zingot.dmi'
	icon_state = "zalloy"
	smeltresult = /obj/item/ingot/steel/zizo
	sellprice = 0

/obj/item/ingot/steel/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS, HERESYDESC_ZIZO_MISC)

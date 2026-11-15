/obj/item/ingot/steel/zizo
	name = "fused avantyne wafer"
	desc = "A thin fragment of fused avantyne, formed from steel and bone."
	icon = 'icons/roguetown/items/ore.dmi'
	icon_state = "ingotavantyne"
	smeltresult = /obj/item/ingot/steel/zizo
	sellprice = 0

/obj/item/ingot/steel/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS, HERESYDESC_ZIZO_MISC)

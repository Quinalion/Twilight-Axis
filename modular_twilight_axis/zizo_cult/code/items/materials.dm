/obj/item/ingot/steel/zizo
	name = "corrupted avantyne wafer"
	desc = "A thin fragment of corrupted avantyne, formed from steel and bone."
	icon = 'modular_twilight_axis/zizo_cult/icons/obj/corrupted_avantyne_wafer.dmi'
	icon_state = "corrupted_avantyne_wafer"
	smeltresult = /obj/item/ingot/steel/zizo
	sellprice = 0

/obj/item/ingot/steel/zizo/get_examine_highlight_status()
	return list(EXAMINEHIGHLIGHT_HERESYSEVERITY_SUSPICIOUS, HERESYDESC_ZIZO_MISC)

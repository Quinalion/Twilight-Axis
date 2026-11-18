/obj/item/organ/breasts
	name = "breasts"
	icon_state = "severedtail" //placeholder
	visible_organ = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BREASTS
	organ_dna_type = /datum/organ_dna/breasts
	accessory_type = /datum/sprite_accessory/breasts/pair
	var/breast_size = DEFAULT_BREASTS_SIZE

/obj/item/organ/breasts/get_cache_key()
	return "[..()]-[breast_size]"

/obj/item/organ/breasts/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/breasts/breasts_dna = organ_dna
	breasts_dna.breast_size = breast_size

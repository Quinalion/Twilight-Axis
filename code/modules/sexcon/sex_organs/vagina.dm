/obj/item/organ/vagina
	name = "vagina"
	icon_state = "severedtail" //placeholder
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_VAGINA
	organ_dna_type = /datum/organ_dna/vagina
	accessory_type = /datum/sprite_accessory/vagina/human
	var/pregnant = FALSE
	var/fertility = TRUE

/obj/item/organ/vagina/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/vagina/vagina_dna = organ_dna
	vagina_dna.fertility = fertility

/obj/item/organ/vagina/proc/be_impregnated(mob/living/carbon/human/father)
	if(pregnant)
		return
	if(!owner)
		return
	if(owner.stat == DEAD)
		return
	if(pregnant)
		to_chat(owner, span_love("I feel a surge of warmth in my belly again..."))
		return
	to_chat(owner, span_love("I feel a surge of warmth in my belly, I’m definitely pregnant!"))
	pregnant = TRUE

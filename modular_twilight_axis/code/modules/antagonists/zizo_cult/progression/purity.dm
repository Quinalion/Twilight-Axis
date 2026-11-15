// TA EDIT - Pure-lux role assignments
/datum/advclass
	var/pure_heart = FALSE

/datum/advclass/absolver
	pure_heart = TRUE

/datum/advclass/psydoniantemplar
	pure_heart = TRUE

/datum/advclass/confessor
	pure_heart = TRUE

/datum/advclass/disciple
	pure_heart = TRUE

/datum/advclass/psyaltrist
	pure_heart = TRUE

/datum/advclass/sojourner
	pure_heart = TRUE

/datum/advclass/cleric
	pure_heart = TRUE

/datum/advclass/cleric/paladin
	pure_heart = TRUE

/datum/advclass/cleric/missionary
	pure_heart = TRUE

/datum/advclass/keeper
	pure_heart = TRUE

/datum/advclass/martyr
	pure_heart = TRUE

/datum/advclass/acolyte
	pure_heart = TRUE

/datum/advclass/bishop
	pure_heart = TRUE

/datum/advclass/templar/crusader
	pure_heart = TRUE

/datum/advclass/squire/lancer
	pure_heart = TRUE

/datum/advclass/squire/footman
	pure_heart = TRUE

/datum/advclass/squire/skirmisher
	pure_heart = TRUE

/datum/advclass/mercenary/warscholar
	pure_heart = TRUE

/datum/advclass/heir/daring
	pure_heart = TRUE

/datum/advclass/heir/bookworm
	pure_heart = TRUE

/datum/advclass/heir/aristocrat
	pure_heart = TRUE

/datum/advclass/heir/inbred
	pure_heart = TRUE

/datum/advclass/heir/scamp
	pure_heart = TRUE

/datum/advclass/archivist
	pure_heart = TRUE

/datum/advclass/shophand
	pure_heart = TRUE

/datum/advclass/vagabond_excommunicated
	pure_heart = TRUE

/datum/advclass/vagabond_mage
	pure_heart = TRUE

/datum/charflaw/virgin
	name = "Virgin"
	desc = "Dark forces lust after my purity!"

/datum/charflaw/virgin/apply_post_equipment(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.virginity = TRUE
	H.purity = TRUE

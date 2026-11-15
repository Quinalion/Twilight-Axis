/datum/outfit/job/roguetown/cult/skeleton/pre_equip(mob/living/carbon/human/H)
	..()

	H.set_patron(/datum/patron/inhumen/zizo)

	H.possible_rmb_intents = list(/datum/rmb_intent/feint,\
	/datum/rmb_intent/aimed,\
	/datum/rmb_intent/riposte,\
	/datum/rmb_intent/strong,\
	/datum/rmb_intent/weak)
	H.swap_rmb_intent(num=1)

	var/datum/antagonist/new_antag = new /datum/antagonist/skeleton()
	H.mind.add_antag_datum(new_antag)

	H.grant_language(/datum/language/undead)

	var/datum/language_holder/language_holder = H.get_language_holder()
	language_holder.selected_default_language = /datum/language/undead
/datum/outfit/job/roguetown/cult/skeleton/zizoid
	wrists = /obj/item/clothing/wrists/roguetown/bracers/zizo
	armor =  /obj/item/clothing/suit/roguetown/armor/plate/full/zizo
	pants = /obj/item/clothing/under/roguetown/platelegs/zizo/heavy
	head = /obj/item/clothing/head/roguetown/helmet/skullcap/cult
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/zizo
	neck = /obj/item/clothing/neck/roguetown/bevor/zizo
	gloves = /obj/item/clothing/gloves/roguetown/plate/zizo/heavy
/datum/outfit/job/roguetown/cult/skeleton/zizoid/raider/pre_equip(mob/living/carbon/human/H)
	..()

	H.STASTR = rand(9, 13)
	H.STAWIL = rand(8, 12)
	H.STACON = rand(8, 13)
	H.STAINT = rand(1, 3)
	H.STAPER = rand(10, 12)
	H.STALUC = rand(8, 12)

	shirt = prob(50) ? /obj/item/clothing/suit/roguetown/armor/chainmail/aalloy : /obj/item/clothing/suit/roguetown/armor/chainmail/paalloy
	r_hand = /obj/item/rogueweapon/sword/zizo

	H.energy = H.max_energy
	H.mind.AddSpell(new /datum/action/cooldown/spell/mending)
	H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/fetch)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)

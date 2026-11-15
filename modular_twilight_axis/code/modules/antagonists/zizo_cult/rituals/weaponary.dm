/datum/ritual/weaponary
	abstract_type = /datum/ritual/weaponary

/datum/ritual/weaponary/zsteel
	name = "Создание стали"
	desk = "Ритуал, который позволяет создать сталь из простых кусочков"
	center_requirement = /obj/item/scrap

	s_req = /obj/item/scrap
	w_req = /obj/item/scrap
	e_req = /obj/item/scrap

/datum/ritual/weaponary/zsteel/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

	new /obj/item/ingot/steel(center)

/datum/ritual/weaponary/zingot
	name = "Создание проклятого слитка"
	desk = "Ритуал, который позволяет призвать древние слитки, которые могут быть полезны.."
	center_requirement = /obj/item/ingot/steel

	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone
	w_req = /obj/item/natural/bone

/datum/ritual/weaponary/zingot/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

	new /obj/item/ingot/steel/zizo(center)

/datum/ritual/weaponary/cross
	name = "Призыв амулета Зизо"
	desk = "Призывает особый крест Зизо, который и защитит, и одарит Её милостинью."
	center_requirement = /obj/item/clothing/neck/roguetown/psicross

	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone
	w_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone

/datum/ritual/weaponary/cross/invoke(mob/living/user, turf/center)
	. = ..()
	new /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult(center)
	to_chat(user, span_notice("The psycross is transmuted into an amulet of Zizo."))

/datum/ritual/weaponary/repaircross
	name = "Восполнить амулет"
	desk = "Восполняет амулет зизо, возвращая его защиту."
	center_requirement = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult

	w_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone

/datum/ritual/weaponary/repaircross/invoke(mob/living/user, turf/center)
	. = ..()
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

	new /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult(center)
	to_chat(user, span_notice("Крест вновь может защитить вас.."))

/datum/ritual/weaponary/zdagger
	name = "Создание проклятого кинжала Зизо"
	desk = "Призывает кинжал Зизо, который может содержать в себе яд."
	center_requirement = /obj/item/rogueweapon/huntingknife/idagger

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/zdagger/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

	new /obj/item/rogueweapon/huntingknife/idagger/steel/cursed(center)

/datum/ritual/weaponary/summonweapon
	name = "Создание длинного меча"
	desk = "Призывает длинный меч Зизо."
	center_requirement = /obj/item/rogueweapon/sword/long

	e_req = /obj/item/ingot/steel/zizo
	w_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonweapon/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/sword/long/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonaxe
	name = "Создание боевого топора"
	desk = "Призывает особо-острый боевой топор."
	center_requirement = /obj/item/rogueweapon/stoneaxe

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonaxe/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/stoneaxe/battle/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonegreataxe
	name = "Создание двустороннего двуручного топора"
	desk = "Призывает особо-острый боевой двуручный топор."
	center_requirement = /obj/item/rogueweapon/stoneaxe/battle/zizo

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonegreataxe/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/greataxe/steel/doublehead/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonasword
	name = "Создание поглощающего меча"
	desk = "Призывает меч, который ворует жизненную энергию."
	center_requirement = /obj/item/rogueweapon/sword

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonasword/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/sword/sabre/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonmace
	name = "Призыв булавы"
	desk = "Призывает особую булаву Зизо."
	center_requirement = /obj/item/rogueweapon/mace

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonmace/invoke(mob/living/user, turf/center)

	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/mace/steel/zizo(center)

	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonshield
	name = "Создание щита"
	desk = "Призывает длинный меч Зизо."
	center_requirement = /obj/item/rogueweapon/shield/tower

	e_req = /obj/item/ingot/steel/zizo
	w_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonshield/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/shield/tower/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonneant
	name = "Призыв Косы"
	desk = "Призывает Особую косу Зизо."
	center_requirement = /obj/item/rogueweapon/scythe

	w_req = /obj/item/ingot/steel/zizo
	e_req = /obj/item/ingot/steel/zizo
	n_req = /obj/item/reagent_containers/lux
	s_req = /obj/item/natural/bone

/datum/ritual/weaponary/summonneant/invoke(mob/living/user, turf/center)

	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/zizo/neant(center)

	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonoutfit
	name = "Призыв робы культа и веревки"
	desk = "Призывает снаряжение культа. Легкая роба, капюшон и веревка."
	center_requirement = /obj/item/natural/cloth

	n_req = /obj/item/natural/hide

/datum/ritual/weaponary/summonoutfit/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/clothing/head/roguetown/helmet/skullcap/cult(center)

	new /obj/item/clothing/suit/roguetown/armor/leather/studded/cult(center)

	new /obj/item/rope(center)

	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

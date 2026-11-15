/datum/ritual/weaponary
	abstract_type = /datum/ritual/weaponary

/datum/ritual/weaponary/zsteel
	name = "Create Steel"
	desk = "Combine four pieces of iron scrap into a steel ingot."
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
	name = "Create Fused Avantyne Wafer"
	desk = "Transform a steel ingot and four bones into a fused avantyne wafer."
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
	name = "Create Fused Avantyne Psycross"
	desk = "Transform a psycross and four bones into a protective fused avantyne psycross."
	center_requirement = /obj/item/clothing/neck/roguetown/psicross

	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone
	w_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone

/datum/ritual/weaponary/cross/invoke(mob/living/user, turf/center)
	. = ..()
	new /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult(center)
	to_chat(user, span_notice("The psycross is transmuted into a fused avantyne psycross."))

/datum/ritual/weaponary/repaircross
	name = "Restore Fused Avantyne Psycross"
	desk = "Replace a fused avantyne psycross with a new one at full integrity."
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
	to_chat(user, span_notice("The fused avantyne psycross is restored."))

/datum/ritual/weaponary/zdagger
	name = "Transmute Dagger"
	desk = "Transform a dagger and a fused avantyne wafer into a fused avantyne dagger."
	center_requirement = /obj/item/rogueweapon/huntingknife/idagger

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/zdagger/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

	new /obj/item/rogueweapon/huntingknife/idagger/steel/cursed(center)

/datum/ritual/weaponary/summonweapon
	name = "Transmute Longsword"
	desk = "Transform a longsword and two fused avantyne wafers into a fused avantyne longsword."
	center_requirement = /obj/item/rogueweapon/sword/long

	e_req = /obj/item/ingot/steel/zizo
	w_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonweapon/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/sword/long/zizo/cult(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonaxe
	name = "Transmute Battle Axe"
	desk = "Transform a stone axe and a fused avantyne wafer into a fused avantyne battle axe."
	center_requirement = /obj/item/rogueweapon/stoneaxe

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonaxe/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/stoneaxe/battle/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonegreataxe
	name = "Transmute Great Axe"
	desk = "Transform a fused avantyne battle axe and a fused avantyne wafer into a fused avantyne double-headed greataxe."
	center_requirement = /obj/item/rogueweapon/stoneaxe/battle/zizo

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonegreataxe/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/greataxe/steel/doublehead/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonasword
	name = "Transmute Sabre"
	desk = "Transform a sword and a fused avantyne wafer into a fused avantyne sabre."
	center_requirement = /obj/item/rogueweapon/sword

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonasword/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/sword/sabre/zizo(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonmace
	name = "Transmute Mace"
	desk = "Transform a mace and a fused avantyne wafer into a fused avantyne mace."
	center_requirement = /obj/item/rogueweapon/mace

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonmace/invoke(mob/living/user, turf/center)

	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()

	new /obj/item/rogueweapon/mace/steel/zizo(center)

	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/weaponary/summonshield
	name = "Transmute Tower Shield"
	desk = "Transform a tower shield and two fused avantyne wafers into a fused avantyne tower shield."
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
	name = "Transmute Scythe"
	desk = "Transform a scythe, two fused avantyne wafers, lux and a bone into a fused avantyne scythe that fires projectiles."
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
	name = "Summon Fused Avantyne Vestments"
	desk = "Create a fused avantyne hood, fused avantyne robe and a rope."
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

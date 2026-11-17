/datum/ritual/weaponary
	abstract_type = /datum/ritual/weaponary
	book_category = "Weaponry"
	crafting_effects = TRUE

/datum/ritual/weaponary/zsteel
	outputs = list(/obj/item/ingot/steel)
	name = "Create Steel"
	description = "Combine four pieces of iron scrap into a steel ingot."
	center_requirement = /obj/item/scrap

	s_req = /obj/item/scrap
	w_req = /obj/item/scrap
	e_req = /obj/item/scrap

/datum/ritual/weaponary/zingot
	outputs = list(/obj/item/ingot/steel/zizo)
	name = "Create Corrupted Avantyne Wafer"
	description = "Transform a steel ingot and four bones into a corrupted avantyne wafer."
	center_requirement = /obj/item/ingot/steel

	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone
	w_req = /obj/item/natural/bone

/datum/ritual/weaponary/cross
	outputs = list(/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult)
	success_message = "The psycross is transmuted into an unholy psycross."
	name = "Create Unholy Psycross"
	description = "Transform a psycross and four bones into a protective unholy psycross."
	center_requirement = /obj/item/clothing/neck/roguetown/psicross

	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone
	w_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone

/datum/ritual/weaponary/repaircross
	outputs = list(/obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult)
	success_message = "The unholy psycross is restored."
	name = "Restore Unholy Psycross"
	description = "Replace an unholy psycross with a new one at full integrity."
	center_requirement = /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy/cult

	w_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone

/datum/ritual/weaponary/zdagger
	outputs = list(/obj/item/rogueweapon/huntingknife/idagger/steel/cursed)
	name = "Transmute Dagger"
	description = "Transform a dagger and a corrupted avantyne wafer into a corrupted avantyne dagger."
	center_requirement = /obj/item/rogueweapon/huntingknife/idagger

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonweapon
	outputs = list(/obj/item/rogueweapon/sword/long/zizo/cult)
	name = "Transmute Longsword"
	description = "Transform a longsword and two corrupted avantyne wafers into a corrupted avantyne longsword."
	center_requirement = /obj/item/rogueweapon/sword/long

	e_req = /obj/item/ingot/steel/zizo
	w_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonaxe
	outputs = list(/obj/item/rogueweapon/stoneaxe/battle/zizo)
	name = "Transmute Battle Axe"
	description = "Transform a stone axe and a corrupted avantyne wafer into a corrupted avantyne battle axe."
	center_requirement = /obj/item/rogueweapon/stoneaxe

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonegreataxe
	outputs = list(/obj/item/rogueweapon/greataxe/steel/doublehead/zizo)
	name = "Transmute Great Axe"
	description = "Transform a corrupted avantyne battle axe and a corrupted avantyne wafer into a corrupted avantyne double-headed greataxe."
	center_requirement = /obj/item/rogueweapon/stoneaxe/battle/zizo

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonasword
	outputs = list(/obj/item/rogueweapon/sword/sabre/zizo)
	name = "Transmute Sabre"
	description = "Transform a sword and a corrupted avantyne wafer into a corrupted avantyne sabre."
	center_requirement = /obj/item/rogueweapon/sword

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonmace
	outputs = list(/obj/item/rogueweapon/mace/steel/zizo)
	name = "Transmute Mace"
	description = "Transform a mace and a corrupted avantyne wafer into a corrupted avantyne mace."
	center_requirement = /obj/item/rogueweapon/mace

	n_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonshield
	outputs = list(/obj/item/rogueweapon/shield/tower/zizo)
	name = "Transmute Tower Shield"
	description = "Transform a tower shield and two corrupted avantyne wafers into a corrupted avantyne tower shield."
	center_requirement = /obj/item/rogueweapon/shield/tower

	e_req = /obj/item/ingot/steel/zizo
	w_req = /obj/item/ingot/steel/zizo

/datum/ritual/weaponary/summonneant
	outputs = list(/obj/item/rogueweapon/zizo/neant)
	name = "Transmute Scythe"
	description = "Transform a scythe, two corrupted avantyne wafers, lux and a bone into a corrupted avantyne scythe that fires projectiles."
	center_requirement = /obj/item/rogueweapon/scythe

	w_req = /obj/item/ingot/steel/zizo
	e_req = /obj/item/ingot/steel/zizo
	n_req = /obj/item/reagent_containers/lux
	s_req = /obj/item/natural/bone

/datum/ritual/weaponary/summonoutfit
	outputs = list(/obj/item/clothing/head/roguetown/roguehood/unholy/cult, /obj/item/clothing/suit/roguetown/shirt/robe/unholy/cult, /obj/item/rope)
	name = "Summon Unholy Vestments"
	description = "Create an unholy hood, unholy robes and a rope."
	center_requirement = /obj/item/natural/cloth

	n_req = /obj/item/natural/hide

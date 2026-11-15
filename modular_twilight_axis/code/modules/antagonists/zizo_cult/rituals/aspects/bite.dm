/datum/intent/spear/cut/scythe
	reach = 3
	damfactor = 1

/obj/item/rogueweapon/spear/bite
	force = 20
	force_wielded = 30
	possible_item_intents = list(SPEAR_BASH)
	gripped_intents = list(/datum/intent/spear/cut/scythe, SPEAR_BASH, MACE_STRIKE)
	name = "snow scythe"
	desc = "An oversized scythe used to harvest giant mushrooms. Born to underdark farmers, she explored every nook and cranny of the ancient caverns."
	icon_state = "silverpeasantscythe"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultweapons64.dmi'
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	bigboy = TRUE
	gripsprite = TRUE
	wlength = WLENGTH_GREAT
	w_class = WEIGHT_CLASS_BULKY
	minstr = 8
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE
	associated_skill = /datum/skill/combat/arcyne
	max_blade_int = 9999
	anvilrepair = /datum/skill/craft/carpentry
	smeltresult = null
	walking_stick = TRUE
	wdefense = 6
	thrown_bclass = BCLASS_BLUNT
	throwforce = 10
	special = /datum/special_intent/scythe_cone

/obj/item/rogueweapon/spear/bite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/soulbound_weapon, /datum/skill/combat/arcyne)

/datum/special_intent/scythe_cone
	name = "Snow Stance"
	desc = "Use a strong attack to coat the earth with running frost."
	tile_coordinates = list(
		list(0,0),
		list(-1,1), list(0,1), list(1,1),
		list(-2,2), list(-1,2), list(0,2), list(1,2), list(2,2)
	)
	post_icon_state = "shieldsparkles"
	pre_icon_state = "frost"
	delay = 0.6 SECONDS
	cooldown = 25 SECONDS
	stamcost = 20
	var/dam = 15

/datum/special_intent/scythe_cone/apply_hit(turf/T)
	for(var/mob/living/carbon/human/L in get_hearers_in_view(0, T))
		if(L != howner)
			apply_generic_weapon_damage(L, dam, "slash", BODY_ZONE_CHEST, bclass = BCLASS_CUT)
			L.apply_status_effect(/datum/status_effect/buff/frostbite)
	..()

/obj/item/rogueweapon/spear/bite/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.7,"sx" = -7,"sy" = 2,"nx" = 7,"ny" = 3,"wx" = -2,"wy" = 1,"ex" = 1,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 30,"eturn" = -30,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.7,"sx" = 5,"sy" = -3,"nx" = -5,"ny" = -2,"wx" = -5,"wy" = -1,"ex" = 3,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 7,"sturn" = -7,"wturn" = 16,"eturn" = -22,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)


/datum/ritual/bite/necromancy
	name = "Necromancy"
	icon_type = /obj/item/natural/bone
	desc = "Learn necromancy spells and the ability to use dark crystals to summon sentient skeletons."
	passive = TRUE
	spells = list(/datum/action/cooldown/spell/gravemark, /datum/action/cooldown/spell/minion_order, /datum/action/cooldown/spell/raise_undead_formation/zizo_cult, /datum/action/cooldown/spell/bonechill, /datum/action/cooldown/spell/bonemend)

/datum/ritual/bite/necromancy/apply_passive(mob/living/carbon/human/H)
	H.mind.current.faction |= "[H.name]_faction"
	H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_EXPERT)
	H.mind.RemoveSpell(/datum/action/cooldown/spell/raise_undead_formation/zizo_cult/lesser)

/datum/ritual/bite/resurrection
	name = "Resurrection"
	icon_type = /obj/item/organ/heart
	desc = "Place the target on the middle sigil to revive them. Requires a dark crystal on the north sigil, or else they come back as a Greater Deadite. Greater deadites are intelligent and capable of using items and weaponry, but suffer all the other drawbacks of being a deadite. They are not guaranteed to be loyal."
	center_requirement = /mob/living/carbon/human
	research_cost = 5

/datum/ritual/bite/resurrection/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/corpse = locate() in center.contents
	if(!corpse || corpse.stat != DEAD || !corpse.mind)
		to_chat(user, span_warning("YOU NEED A CORPSE."))
		return
	playsound(get_turf(corpse), 'sound/magic/magnet.ogg', 80, TRUE)
	var/obj/item/necro_relics/necro_crystal/crystal = locate() in get_step(center, NORTH)
	if(crystal)
		qdel(crystal)
		corpse.revive(full_heal = TRUE, admin_revive = TRUE)
		ADD_TRAIT(corpse, TRAIT_ROTMAN, TRAIT_GENERIC)
		corpse.visible_message(span_notice("[corpse] is returned to lyfe!"))
		return
	corpse.blood_volume = BLOOD_VOLUME_NORMAL
	corpse.setOxyLoss(0, updating_health = FALSE)
	corpse.setToxLoss(0, updating_health = FALSE)
	corpse.adjustBruteLoss(-INFINITY, updating_health = FALSE)
	corpse.adjustFireLoss(-INFINITY, updating_health = FALSE)
	corpse.heal_wounds(INFINITY)
	corpse.zombie_check_can_convert()
	var/datum/antagonist/zombie/Z = corpse.mind.has_antag_datum(/datum/antagonist/zombie)
	if(Z)
		Z.wake_zombie(TRUE)
	REMOVE_TRAIT(corpse, TRAIT_CHUNKYFINGERS, "/datum/antagonist/zombie")
	REMOVE_TRAIT(corpse, TRAIT_ZOMBIE_SPEECH, "/datum/antagonist/zombie")
	corpse.emote("scream")
	to_chat(corpse, span_userdanger("I FEEL MORE COMPETENT THAN THE AVERAGE DEADITE."))

/datum/ritual/bite/thanatophobia
	name = "Curse of Thanatophobia"
	icon_type = /obj/item/natural/worms/leech
	desc = "The target becomes extremely afraid of skeletons and corpses. Lasts 10 minutes. Requires a leech that fed from your target."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE
	research_cost = 5

/datum/ritual/bite/thanatophobia/invoke(mob/living/user, turf/center)
	var/obj/item/natural/worms/leech/remnant = find_remnant(user, center)
	if(!remnant)
		return
	if(!curse_target(remnant.fed_from))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	remnant.fed_from.apply_status_effect(/datum/status_effect/debuff/thanatophobia)
	to_chat(remnant.fed_from, span_danger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	remnant.fed_from.emote("scream")
	qdel(remnant)
	to_chat(user, span_notice("THEY SHALL FEAR MY DOMAIN!"))

/datum/status_effect/debuff/thanatophobia
	id = "thanatophobia"
	duration = 10 MINUTES
	tick_interval = 10 SECONDS
	alert_type = null

/datum/status_effect/debuff/thanatophobia/tick()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H))
		return
	for(var/mob/living/L in view(5, H))
		if(L == H)
			continue
		if(L.stat == DEAD || L.mind?.has_antag_datum(/datum/antagonist/skeleton))
			to_chat(H, span_userdanger("I MUST NOT DIE! I CAN NOT BEAR TO SEE THE DEAD!"))
			H.emote("scream")
			H.adjustStaminaLoss(10)
			step_away(H, L, 10)
			break

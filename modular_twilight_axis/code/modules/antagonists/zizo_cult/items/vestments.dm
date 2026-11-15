/obj/item/clothing/cloak/cultrobe
	name = "zizo robe"
	desc = "A very heavy robe made of protective fabric. It has a hood."
	icon = 'modular_twilight_axis/icons/zizo_cult/modular_deserttown_icons_clothing_shadowcloak.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/modular_deserttown_icons_clothing_onmob_shadowcloak.dmi'
	icon_state = "warlock"
	sleeved = 'modular_twilight_axis/icons/zizo_cult/modular_deserttown_icons_clothing_onmob_shadowcloak.dmi'
	color = null
	body_parts_covered = CHEST|GROIN|ARM_LEFT|ARM_RIGHT|LEG_LEFT|LEG_RIGHT
	armor = ARMOR_LEATHER
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	hoodtype = /obj/item/clothing/head/hooded/cultrobehood
	toggle_icon_state = FALSE
	var/empowered = FALSE
	var/active_item = FALSE
	var/regen_timer
	var/last_hit = -5 MINUTES
	is_cult = TRUE

/obj/item/clothing/cloak/cultrobe/take_damage(damage_amount, damage_type = BRUTE, damage_flag, sound_effect, attack_dir, armor_penetration)
	last_hit = world.time
	return ..()

/obj/item/clothing/cloak/cultrobe/Initialize(mapload)
	. = ..()
	GLOB.cult_robes += src
	if(/datum/ritual/fleshcrafting/ascend in GLOB.zizo_researchable)
		empower()
	regen()

/obj/item/clothing/cloak/cultrobe/Destroy()
	GLOB.cult_robes -= src
	deltimer(regen_timer)
	return ..()

/obj/item/clothing/head/hooded/cultrobehood
	name = "hood"
	desc = "Evil ass ZIZO hood."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/zizohead.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/zizohead.dmi'
	icon_state = "warlockhood"
	item_state = "warlockhood"
	slot_flags = ITEM_SLOT_HEAD
	dynamic_hair_suffix = ""
	body_parts_covered = HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	block2add = FOV_BEHIND
	armor = ARMOR_LEATHER
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	is_cult = TRUE

/obj/item/clothing/head/hooded/cultrobehood/empowered
	max_integrity = 400
	icon_state = "ewarlockhood"
	item_state = "ewarlockhood"

/obj/item/clothing/cloak/cultrobe/equipped(mob/living/user, slot)
	. = ..()
	if(slot == SLOT_CLOAK && is_zizo(user))
		user.apply_status_effect(/datum/status_effect/zizo_regen/robe)
	if(slot != SLOT_CLOAK || !empowered || active_item)
		return
	active_item = TRUE
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	for(var/stat in MOBSTATS)
		H.change_stat(stat, 2)

/obj/item/clothing/cloak/cultrobe/dropped(mob/living/user)
	..()
	user?.remove_status_effect(/datum/status_effect/zizo_regen/robe)
	if(!active_item)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	for(var/stat in MOBSTATS)
		H.change_stat(stat, -2)
	active_item = FALSE

/obj/item/clothing/cloak/cultrobe/proc/empower()
	if(empowered)
		return
	empowered = TRUE
	max_integrity = 400
	obj_integrity = max_integrity
	icon_state = "ewarlock"
	hoodtype = /obj/item/clothing/head/hooded/cultrobehood/empowered
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(!active_item)
			active_item = TRUE
			for(var/stat in MOBSTATS)
				H.change_stat(stat, 2)
		to_chat(H, span_userdanger("MY ROBE THRUMS WITH DARK POWER!"))
		H.update_inv_cloak()
		if(hoodtoggled)
			ToggleHood(H)
			ToggleHood(H)

/obj/item/clothing/cloak/cultrobe/proc/regen()
	if(QDELETED(src))
		return
	var/amount = 5
	if(empowered)
		amount = 15
	if(obj_integrity < max_integrity && world.time >= last_hit + 5 MINUTES)
		obj_integrity = min(obj_integrity + amount, max_integrity)
		if(obj_broken)
			obj_fix(full_repair = FALSE)
	regen_timer = addtimer(CALLBACK(src, PROC_REF(regen)), 1 MINUTES, TIMER_STOPPABLE)



/obj/item/clothing
	var/is_cult = FALSE

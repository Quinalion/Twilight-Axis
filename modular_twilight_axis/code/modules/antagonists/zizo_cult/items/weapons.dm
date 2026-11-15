/datum/intent/dagger/thrust/cult
	penfactor = PEN_BSTEEL

/datum/intent/dagger/cut/cult
	penfactor = PEN_BSTEEL

/datum/intent/sword/cut/sabre/cult
	penfactor = PEN_BSTEEL

/datum/intent/sword/thrust/sabre/cult
	penfactor = PEN_BSTEEL

/obj/item/rogueweapon/sword/long/noise
	name = "madman blade"
	desc = ""
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultweapons64.dmi'
	icon_state = "hagsword"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE
	associated_skill = /datum/skill/combat/arcyne
	max_blade_int = 9999
	force = 25
	force_wielded = 35
	smeltresult = null
	sheathe_icon = "hagsword"
	special = /datum/special_intent/madman_delusion

/obj/item/rogueweapon/sword/long/noise/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/soulbound_weapon, /datum/skill/combat/arcyne)

/obj/item/rogueweapon/sword/long/noise/attack(mob/living/M, mob/living/user)
	update_force_dynamic()
	force_dynamic += force_dynamic * max(M.get_stress_amount(), 0) / 30
	return ..()

/datum/special_intent/madman_delusion
	name = "Cruelty"
	desc = "Induce a maddened state in the foe. It drives them to commit unspeakable violence against ally and foe alike."
	tile_coordinates = list(list(0,0))
	use_clickloc = TRUE
	respect_adjacency = FALSE
	range = 6
	post_icon_state = "strike"
	pre_icon_state = "trap"
	delay = 0.5 SECONDS
	cooldown = 30 SECONDS
	stamcost = 20
	var/dam = 15
	var/frenzy_duration = 8 SECONDS

/datum/special_intent/madman_delusion/apply_hit(turf/T)
	for(var/mob/living/carbon/human/L in get_hearers_in_view(0, T))
		if(L != howner && L.stat != DEAD)
			apply_generic_weapon_damage(L, dam, "slash", BODY_ZONE_HEAD, bclass = BCLASS_CUT)
			if(HAS_TRAIT(L, TRAIT_IN_FRENZY))
				continue
			L.enter_frenzymod()
			addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living/carbon, exit_frenzymod)), frenzy_duration)
	..()

/obj/item/rogueweapon/huntingknife/idagger/steel/pitch
	var/active_intents =	list(/datum/intent/dagger/thrust/cult,/datum/intent/dagger/cut/cult)
	var/inactive_intents = list()

/obj/item/rogueweapon/huntingknife/idagger/steel/blood
	name = "slave knife"
	desc = "A blade wielded by blood-pit slaves in the chaotic age after PSYDON's death. This one is permanently wet with blood."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultweapons32.dmi'
	icon_state = "graggardagger"
	sheathe_icon = "graggardagger"
	force = 25
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE
	associated_skill = /datum/skill/combat/arcyne
	max_blade_int = 9999
	smeltresult = null
	possible_item_intents =	list(/datum/intent/dagger/thrust/cult,/datum/intent/dagger/cut/cult)

/obj/item/rogueweapon/huntingknife/idagger/steel/blood/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/soulbound_weapon, /datum/skill/combat/arcyne)

/obj/item/rogueweapon/huntingknife/idagger/steel/pitch
	name = "astrata-touched dagger"
	desc = "This dagger once pierced the Sun Queen's heart."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultweapons32.dmi'
	icon_state = "fdagger"
	sheathe_icon = "fdagger"
	force = 30
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE
	associated_skill = /datum/skill/combat/arcyne
	max_blade_int = 9999
	smeltresult = null
	special = /datum/special_intent/zizo_ignite_dagger

/obj/item/rogueweapon/huntingknife/idagger/steel/pitch/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/soulbound_weapon, /datum/skill/combat/arcyne)

/datum/special_intent/zizo_ignite_dagger
	name = "Ignite Dagger"
	desc = "Channel the power of Pitch within the dagger to heat it to an incredible degree."
	cooldown = 60 SECONDS
	stamcost = 25

/datum/special_intent/zizo_ignite_dagger/on_create()
	. = ..()
	howner.visible_message(span_warning("[iparent]'s blade begins to glow intensely in [howner]'s grasp!"))
	var/obj/item/rogueweapon/huntingknife/idagger/steel/pitch/W = iparent
	active_timer = addtimer(CALLBACK(src, PROC_REF(effect_expire)), 30 SECONDS, TIMER_STOPPABLE)
	W.damtype = BURN
	W.force -= 15
	W.update_force_dynamic()
	if("[W.icon_state]_active" in icon_states(W.icon))
		W.icon_state = "[W.icon_state]_active"
	W.inactive_intents = W.possible_item_intents
	W.possible_item_intents = W.active_intents
	howner.update_a_intents()
	howner.regenerate_icons()
	playsound(W.loc, 'sound/items/firelight.ogg', 100)

/datum/special_intent/zizo_ignite_dagger/proc/effect_expire()
	howner.visible_message(span_warning("[iparent]'s blade cools down!"))
	var/obj/item/rogueweapon/huntingknife/idagger/steel/pitch/W = iparent
	W.damtype = BRUTE
	W.force += 15
	W.update_force_dynamic()
	W.icon_state = initial(W.icon_state)
	W.possible_item_intents = W.inactive_intents
	howner.update_a_intents()
	howner.regenerate_icons()
	playsound(W.loc, 'sound/items/firesnuff.ogg', 100)

/obj/item/rogueweapon/sword/sabre/rot
	name = "mortal blade"
	desc = "Once a righteous blade wielded by a fair maiden. No longer."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultweapons32.dmi'
	icon_state = "poisonsabre"
	force = 30
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE
	associated_skill = /datum/skill/combat/arcyne
	max_blade_int = 9999
	var/active_intents =	list(/datum/intent/sword/cut/sabre/cult, /datum/intent/sword/thrust/sabre/cult)
	var/inactive_intents = list()
	parrysound = list('sound/combat/parry/bladed/bladedthin (1).ogg', 'sound/combat/parry/bladed/bladedthin (2).ogg', 'sound/combat/parry/bladed/bladedthin (3).ogg')
	sellprice = 50
	smeltresult = null
	special = /datum/special_intent/zizo_coat_blade

/obj/item/rogueweapon/sword/sabre/rot/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/soulbound_weapon, /datum/skill/combat/arcyne)

/datum/special_intent/zizo_coat_blade
	name = "Coat Blade"
	desc = "Channel the power of Rot within this sabre to render it as toxic as it once was."
	cooldown = 120 SECONDS
	stamcost = 25

/datum/special_intent/zizo_coat_blade/on_create()
	. = ..()
	howner.visible_message(span_warning("[iparent]'s blade forms a solid layer of poison in [howner]'s grasp!"))
	var/obj/item/rogueweapon/sword/sabre/rot/W = iparent
	active_timer = addtimer(CALLBACK(src, PROC_REF(effect_expire)), 30 SECONDS, TIMER_STOPPABLE)
	W.damtype = TOX
	W.force -= 22
	W.update_force_dynamic()
	W.inactive_intents = W.possible_item_intents
	W.possible_item_intents = W.active_intents
	howner.update_a_intents()
	W.icon_state = "poisonsabre_active"
	howner.regenerate_icons()
	playsound(W.loc, 'sound/misc/lava_death.ogg', 100)

/datum/special_intent/zizo_coat_blade/proc/effect_expire()
	howner.visible_message(span_warning("[iparent]'s coating of toxins falls to the dirt!"))
	var/obj/item/rogueweapon/sword/sabre/rot/W = iparent
	W.damtype = BRUTE
	W.force += 22
	W.possible_item_intents = W.inactive_intents
	howner.update_a_intents()
	W.update_force_dynamic()
	W.icon_state = "poisonsabre"
	playsound(W.loc, 'sound/magic/bladescrape.ogg', 100)

/obj/item/rogueweapon/mace/maul/toil
	name = "forgotten tool"
	desc = "A wrench used by an artificer-thief in the the ancient age of Aeon."
	icon_state = "bronzewrench"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultweapons64.dmi'
	force = 25
	force_wielded = 40
	wdefense_wbonus = 5
	minstr = 8
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE
	associated_skill = /datum/skill/combat/arcyne
	w_class = WEIGHT_CLASS_BULKY
	smeltresult = null
	swingsound = BLUNTWOOSH_LARGE
	gripsprite = TRUE
	wlength = WLENGTH_LONG
	wbalance = WBALANCE_HEAVY
	grid_width = null
	grid_height = null
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	bigboy = TRUE
	gripsprite = TRUE
	walking_stick = TRUE
	var/list/obj/structure/toilturret/turrets = list()
	var/max_turrets = 3

/obj/item/rogueweapon/mace/maul/toil/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/soulbound_weapon, /datum/skill/combat/arcyne)

/obj/item/rogueweapon/mace/maul/toil/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS || !user.mind)
		return
	user.mind.AddSpell(new /datum/action/cooldown/spell/deploy_turret)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/self/direct_turrets)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/self/scrap_turrets)

/obj/item/rogueweapon/mace/maul/toil/dropped(mob/user, silent)
	. = ..()
	if(!user.mind)
		return
	user.mind.RemoveSpell(/datum/action/cooldown/spell/deploy_turret)
	user.mind.RemoveSpell(/obj/effect/proc_holder/spell/self/direct_turrets)
	user.mind.RemoveSpell(/obj/effect/proc_holder/spell/self/scrap_turrets)

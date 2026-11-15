/datum/ritual/transmutation
	abstract_type = /datum/ritual/transmutation

/datum/ritual/transmutation/allseeingeye
	name = "All-seeing Eye"
	icon_type = /obj/item/scrying/eye
	desc = "Create an eye to scry through."
	is_cultist_ritual = TRUE
	center_requirement = /obj/item/organ/eyes

/datum/ritual/transmutation/allseeingeye/invoke(mob/living/user, turf/center)
	new /obj/item/scrying/eye(center)
	to_chat(user, span_notice("The All-seeing Eye. To see beyond sight."))

/datum/ritual/transmutation/cross
	lesser = TRUE
	name = "Summon Amulet of Zizo"
	icon_type = /obj/item/clothing/neck/roguetown/psicross/inhumen
	desc = "Create a Zizo Amulet."
	center_requirement = /obj/item/clothing/neck/roguetown/psicross

/datum/ritual/transmutation/cross/invoke(mob/living/user, turf/center)
	new /obj/item/clothing/neck/roguetown/psicross/inhumen(center)
	to_chat(user, span_notice("The psycross is transmuted into an amulet of Zizo."))

/datum/ritual/transmutation/raiseshrine
	lesser = TRUE
	name = "Raise Profane Shrine"
	icon_type = /obj/item/grown/log/tree/small
	desc = "Raise an inverted cross as a shrine to ZIZO. Used in completing objectives."
	center_requirement = /obj/item/grown/log/tree/small

/datum/ritual/transmutation/raiseshrine/invoke(mob/living/user, turf/center)
	new /obj/structure/fluff/psycross/zizocross(center)
	to_chat(user, span_notice("The wooden log is transmuted into an inverted psycross."))
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/cultist = user
	var/area/A = get_area(center)
	if(istype(A, /area/rogue/indoors/town/church))
		complete_zgoal(cultist, /datum/zizogoal/profaneshrine_church)
	if(istype(A, /area/rogue/indoors/town/tavern))
		complete_zgoal(cultist, /datum/zizogoal/profaneshrine_tavern)
	if(istype(A, /area/rogue/indoors/town/bath))
		complete_zgoal(cultist, /datum/zizogoal/profaneshrine_bath)
	if(istype(A, /area/rogue/indoors/town/academy) || istype(A, /area/rogue/indoors/town/magician))
		complete_zgoal(cultist, /datum/zizogoal/profaneshrine_academy)
	if(is_zizo_graveyard(center))
		complete_zgoal(cultist, /datum/zizogoal/profaneshrine_graveyard)

/datum/ritual/transmutation/criminalstool
	lesser = TRUE
	name = "Criminal's Tool"
	icon_type = /obj/item/soap/cult
	desc = "Create soap to clean runes with."
	center_requirement = /obj/item/natural/cloth

/datum/ritual/transmutation/criminalstool/invoke(mob/living/user, turf/center)
	new /obj/item/soap/cult(center)
	to_chat(user, span_notice("The Criminal's Tool. Could be useful for hiding tracks or getting rid of sigils."))

/obj/item/soap/cult
	name = "accursed soap"
	desc = "It is pulsating."
	color = LIGHT_COLOR_BLOOD_MAGIC

/datum/ritual/transmutation/propaganda
	lesser = TRUE
	name = "Remnant Leech"
	icon_type = /obj/item/natural/worms/leech/propaganda
	desc = "Create a leech that attaches silently onto targets. Used for curses."
	center_requirement = /obj/item/natural/worms/leech
	n_req = /obj/item/paper
	s_req = /obj/item/natural/feather
	research_cost = 2

/datum/ritual/transmutation/propaganda/invoke(mob/living/user, turf/center)
	new /obj/item/natural/worms/leech/propaganda(center)
	to_chat(user, span_notice("A leech to steal their souls."))

/obj/item/natural/worms/leech/propaganda
	name = "accursed leech"
	desc = "A leech like none other."
	icon_state = "leech"
	drainage = 0
	blood_sucking = 0
	suppressed = TRUE
	pierce_armor = TRUE
	instant_apply = TRUE
	embedding = list(
		"embed_chance" = 100,
		"embedded_unsafe_removal_time" = 0,
		"embedded_pain_chance" = 0,
		"embedded_fall_chance" = 0,
		"embedded_bloodloss"= 0,
	)

/obj/item/natural/worms/leech/propaganda/on_embed_life(mob/living/user, obj/item/bodypart/bodypart)
	if(!host && user)
		host = user
		if(ishuman(user))
			fed_from = user
		addtimer(CALLBACK(src, PROC_REF(fall_off)), 30 SECONDS)
	. = ..()
	if(!user)
		return
	if(iscarbon(user))
		var/mob/living/carbon/V = user
		if(prob(5))
			record_round_statistic(STATS_ZIZO_PRAISED)
			V.say(pick( \
				"PRAISE ZIZO!", \
				"DEATH TO THE TEN...", \
				"Astrata will fail!", \
				"The Ten cannot stop me!", \
				"Zizo shows the way!", \
				"The Dark Lady has shown me the truth!", \
				"My life for Zizo...", \
				"Curse your Beast God!", \
				"Noc's magick is nothing to Zizo!", \
				"Abyssor is but a grain of salt!", \
				"Pestra is the most foul of goddesses!", \
				"Ravox's justice is flawed and dull!", \
				"Rip the Sun Tyrant from the sky!", \
				"Xylix is the tongue that must be severed off!", \
				"Cast Malum into the fires of hell!", \
				"The only truth there is lies with the Dark Elves!", \
				"I will defile Necra's dead, a thousand times!", \
				"I will butcher the Ten like Necra butchered Psydon!", \
				"Snuff out the beating hearts of Eora!"))
		V.add_stress(/datum/stressevent/leechcult)

/datum/ritual/transmutation/silencerleech
	name = "Silencing Leech"
	icon_type = /obj/item/natural/worms/leech/silencer
	desc = "Transmute a leech to silence the voice of whoever you attach it to."
	center_requirement = /obj/item/natural/worms/leech
	n_req = /obj/item/paper
	s_req = /obj/item/natural/feather
	research_cost = 2

/datum/ritual/transmutation/silencerleech/invoke(mob/living/user, turf/center)
	new /obj/item/natural/worms/leech/silencer(center)
	to_chat(user, span_notice("A leech to steal their voice."))

/obj/item/natural/worms/leech/silencer
	name = "muzzling leech"
	icon_state = "leech"
	drainage = 0
	blood_sucking = 0
	pierce_armor = TRUE
	instant_apply = TRUE
	embedding = list(
		"embed_chance" = 100,
		"embedded_unsafe_removal_time" = 5 SECONDS,
		"embedded_pain_chance" = 0,
		"embedded_fall_chance" = 0,
		"embedded_bloodloss"= 0,
	)

/obj/item/natural/worms/leech/silencer/on_embed_life(mob/living/user, obj/item/bodypart/bodypart)
	if(host || !user)
		return
	host = user
	if(ishuman(user))
		fed_from = user
	ADD_TRAIT(user, TRAIT_MUTE, "silencer_leech")
	to_chat(user, span_userdanger("MY VOICE GOES STILL!"))
	addtimer(CALLBACK(src, PROC_REF(fall_off)), 2 MINUTES)

/obj/item/natural/worms/leech/silencer/forceMove(atom/newloc)
	. = ..()
	if(!is_embedded && host)
		REMOVE_TRAIT(host, TRAIT_MUTE, "silencer_leech")
		host = null

/obj/item/natural/worms/leech/silencer/Destroy()
	if(host)
		REMOVE_TRAIT(host, TRAIT_MUTE, "silencer_leech")
		host = null
	return ..()

/datum/ritual/transmutation/invademind
	lesser = TRUE
	name = "Invade Mind"
	icon_type = /obj/item/natural/feather
	desc = "Send an anonymous message into someone's head."
	center_requirement = /obj/item/natural/feather

/datum/ritual/transmutation/invademind/invoke(mob/living/user, turf/center)
	var/info = input(user, "What shall the message be?", "ZIZO")
	var/target_name = input(user, "To whom do we send this message?", "ZIZO") as null|text
	if(!target_name)
		return
	for(var/mob/living/carbon/human/HL in GLOB.human_list)
		if(HL.real_name == target_name)
			to_chat(HL, "<i>You hear a voice in your head... <b>[info]</i></b>")

/datum/ritual/transmutation/summonoutfit
	lesser = TRUE
	name = "Summon Cult Outfit"
	icon_type = /obj/item/clothing/head/roguetown/helmet/skullcap/cult
	desc = "Conjure an ominous outfit that provides some defense."
	center_requirement = /obj/item/natural/cloth

/datum/ritual/transmutation/summonoutfit/invoke(mob/living/user, turf/center)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/item/clothing/head/roguetown/helmet/skullcap/cult(center)
	new /obj/item/clothing/cloak/half/cult(center)
	new /obj/item/rope/chain(center)
	playsound(center, pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/obj/item/clothing/head/roguetown/helmet/skullcap/cult
	name = "ominous hood"
	desc = "It echoes with ominous laughter. Worn over a skullcap"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/zizohead.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/zizohead.dmi'
	icon_state = "warlock"
	dynamic_hair_suffix = ""
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

	body_parts_covered = NECK|HAIR|EARS|HEAD

/obj/item/clothing/cloak/half/cult
	name = "ominous cloak"
	icon = 'modular_twilight_axis/icons/zizo_cult/modular_deserttown_icons_clothing_shadowcloak.dmi'
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/modular_deserttown_icons_clothing_onmob_shadowcloak.dmi'
	icon_state = "cultcloak"
	color = null
	sleeved = 'modular_twilight_axis/icons/zizo_cult/modular_deserttown_icons_clothing_onmob_shadowcloak.dmi'
	desc = "Those who wear, thy should beware, for those who do; never come back as who they once were again."
	body_parts_covered = ARMS|CHEST

/datum/ritual/transmutation/summonarmor
	name = "Summon Darksteel Armor"
	icon_type = /obj/item/clothing/suit/roguetown/armor/plate/full/zizo
	desc = "Conjure a set of unremovable darksteel plate. Trains you in heavy armor and grants mending. Requires a dark crystal."
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/necro_relics/necro_crystal
	w_req = /obj/item/ingot/steel
	e_req = /obj/item/ingot/steel

/datum/ritual/transmutation/summonarmor/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(target.stat == DEAD)
		target.gib(FALSE, FALSE, FALSE)
		return
	ADD_TRAIT(target, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	target.equipOutfit(/datum/outfit/job/roguetown/darksteelrite)
	playsound(center, pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/transmutation/summonfuge
	name = "Summon Fuge"
	icon_type = /obj/structure/fuge
	desc = "Conjure a machine to pull items in from other realms. Must be raised where the WORLD feels UNREAL."
	is_cultist_ritual = TRUE
	research_cost = 0

/datum/ritual/transmutation/summonfuge/invoke(mob/living/user, turf/center)
	if(GLOB.zizo_fuges.len)
		to_chat(user, span_warning("THERE CAN ONLY BE ONE."))
		return
	var/near_rend = FALSE
	for(var/obj/structure/reality_rend/R as anything in GLOB.zizo_reality_rends)
		if(zizo_dist(R, center) <= 50)
			near_rend = TRUE
			break
	if(!near_rend)
		to_chat(user, span_warning(" MUST BE PLACED WHERE THE WORLD MUST FEEL UNREAL."))
		return
	to_chat(user, span_notice("The rite begins. Remain still."))
	var/poo = new /obj/effect/temp_visual/opengate(center)
	playsound(user, 'sound/villain/littlescary.ogg', 100, TRUE)
	if(!do_after(user, 10 SECONDS))
		qdel(poo)
		return
	if(GLOB.zizo_fuges.len)
		to_chat(user, span_warning("THERE CAN ONLY BE ONE."))
		return
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/structure/fuge(center)


/datum/ritual/transmutation/summonweapon
	lesser = TRUE
	name = "Summon Weapons"
	icon_type = /obj/item/rogueweapon/sword/long/zizo
	desc = "Learn a spell to conjure an avantyne dagger or sword. Consumes a dark crystal to learn."
	passive = TRUE
	research_item = /obj/item/necro_relics/necro_crystal
	research_cost = 3

/datum/ritual/transmutation/summonweapon/apply_passive(mob/living/carbon/human/H)
	H.mind.AddSpell(new /datum/action/cooldown/spell/form_blade/avantyne)
	H.adjust_skillrank_up_to(/datum/skill/combat/arcyne, SKILL_LEVEL_EXPERT)
	return

/datum/ritual/transmutation/lessernecromancy
	lesser = TRUE
	name = "Lesser Necromancy"
	icon_type = /obj/item/natural/bone
	desc = "Become an initiate in the teachings of Necromancy. Consumes a dark crystal to learn."
	research_item = /obj/item/necro_relics/necro_crystal
	passive = TRUE
	research_cost = 3
	spells = list(/datum/action/cooldown/spell/gravemark, /datum/action/cooldown/spell/minion_order, /datum/action/cooldown/spell/raise_undead_formation/zizo_cult/lesser, /datum/action/cooldown/spell/bonechill, /datum/action/cooldown/spell/bonemend)

/datum/ritual/transmutation/lessernecromancy/apply_passive(mob/living/carbon/human/H)
	H.mind.current.faction |= "[H.name]_faction"
	H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_APPRENTICE)

/datum/ritual/transmutation/hiddenward
	lesser = TRUE
	name = "Inhumen Ward"
	icon_type = /datum/action/cooldown/spell/conjure_arcyne_ward/zizo
	desc = "Learn a spell to conjure a strong, invisible ward. Consumes a dark crystal to learn."
	passive = TRUE
	research_item = /obj/item/necro_relics/necro_crystal
	research_cost = 3
	spells = list(/datum/action/cooldown/spell/conjure_arcyne_ward/zizo)

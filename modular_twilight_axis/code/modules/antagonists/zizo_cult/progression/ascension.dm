/datum/ritual/fleshcrafting/ascend
	name = "ASCEND!"
	icon_type = /obj/item/clothing/head/roguetown/crown/zizo
	desc = "Sacrifice the ruler on the north side and a person with pure lux on the south side. Must be performed inside the keep. The ruler must be kept on the profane altar for 5 minutes to Ascend. Alerts everyone."
	center_requirement = /mob/living/carbon/human
	center_desc = "the one to ascend"
	n_req = /mob/living/carbon/human
	n_desc = "the ruler"
	s_req = /mob/living/carbon/human
	s_desc = "one of pure lux"
	is_cultist_ritual = TRUE

/obj/effect/proc_holder/spell/bloodcrawl/ascendant
	recharge_time = 1 MINUTES
	invocations = list("Kri'tha mak!")
	invocation_type = "shout"
	gesture_required = TRUE

/datum/ritual/fleshcrafting/ascend/invoke(mob/living/user, turf/center)
	var/area/rogue/ritual_area = get_area(center)
	if(!istype(ritual_area) || !ritual_area.keep_area)
		to_chat(user, span_warning("The ascension must be performed within the keep. The ruler must lie on the north side. A person with pure lux must lie on the south side."))
		return
	var/mob/living/carbon/human/cultist = locate() in center.contents
	if(!cultist || cultist != user || !is_zizo(cultist))
		return
	var/mob/living/carbon/human/RULER = SSticker.rulermob
	if(!RULER || RULER.loc != get_step(center, NORTH))
		to_chat(user, span_warning("The ascension must be performed within the keep. The ruler must lie on the north side. A person with pure lux must lie on the south side."))
		return
	var/mob/living/carbon/human/cleric = locate() in get_step(center, SOUTH)
	if(!cleric || cleric.purity == FALSE || cleric.stat == DEAD)
		to_chat(user, span_warning("The ascension must be performed within the keep. The ruler must lie on the north side. A person with pure lux must lie on the south side."))
		return
	cleric.visible_message(span_danger("[cleric] withers and dies!"))
	cleric.death()
	RULER.Unconscious(6 MINUTES)
	priority_announce("Incomprehensible evil arises from within the keep! To arms, the end is near!", title = "ZIZO", sound = 'sound/villain/seen_wonder.ogg')
	var/datum/particle_weather/storm = new /datum/particle_weather/blood_rain_storm
	SSParticleWeather.runningWeather = storm
	storm.start()
	var/obj/structure/raver/altar/altar = new(RULER.loc)
	altar.buckle_mob(RULER, TRUE, FALSE)
	RULER.apply_status_effect(/datum/status_effect/zizo_ascension, cultist, altar)
	to_chat(user, span_boldnotice("THE RULER MUST REMAIN UPON THE ALTAR AT ALL COSTS!"))

/obj/structure/raver/altar
	name = "profane altar"
	desc = "HELL'S GORGE HATH BROKEN!"
	max_integrity = 600

/obj/structure/raver/altar/post_buckle_mob(mob/living/M)
	return

/obj/structure/raver/altar/examine(mob/user)
	return list("[name]. [desc]")

/datum/status_effect/zizo_ascension
	id = "zizo_ascension"
	duration = -1
	tick_interval = 5 SECONDS
	var/mob/living/carbon/human/cultist
	var/obj/structure/raver/altar/altar
	var/elapsed = 0

/datum/status_effect/zizo_ascension/on_creation(mob/living/new_owner, mob/living/carbon/human/leader, obj/structure/raver/altar/device)
	cultist = leader
	altar = device
	. = ..()

/datum/status_effect/zizo_ascension/tick()
	if(QDELETED(cultist) || cultist.stat == DEAD || QDELETED(altar) || owner.loc != altar.loc || owner.buckled != altar || !is_zizo(cultist))
		ascension_fail()
		return
	elapsed += 5
	if(elapsed >= 300)
		zizo_ascend(cultist)
		owner.gib()
		qdel(altar)
		qdel(src)

/datum/status_effect/zizo_ascension/proc/ascension_fail()
	priority_announce("The sky brightens! The ritual is foiled!", title = "PEACE", sound = 'sound/misc/triumph.ogg')
	qdel(altar)
	qdel(src)

/proc/zizo_ascend(mob/living/carbon/human/cultist)
	if(QDELETED(cultist) || !cultist.mind)
		return
	SSmapping.retainer.cult_ascended = TRUE
	to_chat(cultist, span_userdanger("I HAVE DONE IT! I HAVE REACHED A HIGHER FORM! ZIZO SMILES UPON ME WITH MALICE IN HER EYES TOWARD THE ONES WHO LACK KNOWLEDGE AND UNDERSTANDING!"))
	for(var/datum/action/A as anything in cultist.actions.Copy())
		qdel(A)
	cultist.mind.RemoveAllSpells()
	var/mob/living/simple_animal/hostile/retaliate/rogue/zizo_ascendant/ascendant = new(get_turf(cultist))
	cultist.mind.transfer_to(ascendant)
	qdel(cultist)
	priority_announce("The sky blackens, a dark day for Twilight Axis.", title = "Ascension", sound = 'sound/villain/dreamer_win.ogg')
	SSvote.initiate_vote("endround", "ZIZO", null)
	for(var/mob/living/carbon/human/V in GLOB.human_list)
		if(V.mind in SSmapping.retainer.cultists)
			V.add_stress(/datum/stressevent/lovezizo)
		else
			V.add_stress(/datum/stressevent/hatezizo)

/obj/item/clothing/head/roguetown/crown/zizo
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/zizohead.dmi'
	name = "Zizo Crown"
	desc = "FOR THE ASCENDANT."
	mob_overlay_icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/zizohead.dmi'
	icon_state = "zcrown"

/obj/effect/proc_holder/spell/targeted/touch/cleave
	name = "Cleave"
	desc = "Kill."
	clothes_req = FALSE
	overlay_state = "gravemark"
	recharge_time = 15 SECONDS
	chargedloop = null
	hand_path = /obj/item/melee/touch_attack/cleave
	cost = 0
	hide_charge_effect = TRUE
	gesture_required = TRUE

/obj/item/melee/touch_attack/cleave
	name = "reaping hand"
	desc = "Touch a foe to sever their head."
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "grabbing_greyscale"
	color = "#8a13bd"

/obj/item/melee/touch_attack/cleave/attack_self()
	attached_spell.remove_hand()

/obj/item/melee/touch_attack/cleave/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/spelltarget = target
	if(psydont(spelltarget))
		to_chat(user, span_danger("They are wearing silver, it resists the dark magick!"))
		return
	to_chat(spelltarget, span_danger("YOU HAVE A TERRIBLE FEELING ABOUT THIS. GET AWAY!"))
	if(!do_after(user, 3 SECONDS, target = spelltarget))
		return
	var/obj/item/bodypart/head/head = spelltarget.get_bodypart("head")
	if(head)
		head.dismember()
	spelltarget.visible_message(span_danger("[user] makes a horizontal cut with their hand and [spelltarget]'s head pops off!"))
	attached_spell.remove_hand()

/obj/effect/proc_holder/spell/targeted/touch/ascended_heal
	name = "Blessing"
	desc = "Heal."
	clothes_req = FALSE
	overlay_state = "gravemark"
	recharge_time = 10 SECONDS
	chargedloop = null
	hand_path = /obj/item/melee/touch_attack/ascended_heal
	cost = 0
	hide_charge_effect = TRUE
	gesture_required = TRUE

/obj/item/melee/touch_attack/ascended_heal
	name = "mending hand"
	desc = "Touch someone to heal them."
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "grabbing_greyscale"
	color = "#8a13bd"

/obj/item/melee/touch_attack/ascended_heal/attack_self()
	attached_spell.remove_hand()

/obj/item/melee/touch_attack/ascended_heal/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target))
		return
	var/mob/living/spelltarget = target
	if(spelltarget.stat == DEAD)
		to_chat(user, span_warning("They're dead. Resurrect them."))
		return
	if(!do_after(user, 3 SECONDS, target = spelltarget))
		return
	spelltarget.revive(full_heal = TRUE, admin_revive = TRUE)
	spelltarget.visible_message(span_notice("[user] mends [spelltarget] in a flash of light!"))
	explosion(get_turf(spelltarget), flash_range = 7)
	attached_spell.remove_hand()

/obj/effect/proc_holder/spell/targeted/touch/true_resurrection
	name = "True Resurrection"
	desc = "Bring them back."
	clothes_req = FALSE
	overlay_state = "gravemark"
	recharge_time = 30 SECONDS
	chargedloop = null
	hand_path = /obj/item/melee/touch_attack/true_resurrection
	cost = 0
	hide_charge_effect = TRUE
	gesture_required = TRUE

/obj/item/melee/touch_attack/true_resurrection
	name = "reviving hand"
	desc = "Touch the dead to bring them back."
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "grabbing_greyscale"
	color = "#8a13bd"

/obj/item/melee/touch_attack/true_resurrection/attack_self()
	attached_spell.remove_hand()

/obj/item/melee/touch_attack/true_resurrection/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target))
		return
	var/mob/living/spelltarget = target
	if(spelltarget.stat != DEAD)
		to_chat(user, span_warning("They still live."))
		return
	if(!do_after(user, 3 SECONDS, target = spelltarget))
		return
	spelltarget.revive(full_heal = TRUE, admin_revive = TRUE)
	ADD_TRAIT(spelltarget, TRAIT_ROTMAN, TRAIT_GENERIC)
	spelltarget.visible_message(span_notice("[user] drags [spelltarget] back from death!"))
	explosion(get_turf(spelltarget), flash_range = 7)
	attached_spell.remove_hand()

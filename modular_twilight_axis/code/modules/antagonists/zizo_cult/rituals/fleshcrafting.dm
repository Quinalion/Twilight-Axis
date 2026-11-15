/datum/ritual/fleshcrafting
	abstract_type = /datum/ritual/fleshcrafting

/datum/ritual/fleshcrafting/bunnylegs
	name = "Сильные ноги"
	desk = "Даёт возможность прыгать довольно-таки высоко.."
	cultist_number = 6

	center_book = "Культист"
	center_requirement = /mob/living/carbon/human

	w_req = /obj/item/bodypart/l_leg
	e_req = /obj/item/bodypart/r_leg
	n_req = /obj/item/alch/airdust

	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/bunnylegs/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	ADD_TRAIT(target, TRAIT_ZJUMP, TRAIT_GENERIC)
	to_chat(target, span_notice("I feel like my legs have become stronger."))

/datum/ritual/fleshcrafting/fleshmend
	name = "Плотолечение"
	desk = "Одаривает цель полным исцелением."
	center_book = "Пострадавший"
	center_requirement = /mob/living/carbon/human
	n_req =  /obj/item/alch/viscera
	s_req = /obj/item/alch/calendula

/datum/ritual/fleshcrafting/fleshmend/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(!target.mind)
		to_chat(user, span_warning("They are not worth saving."))
		return
	if(!target.mind.active)
		to_chat(user, span_warning("They are unresponsive to my attempts. For now."))
		return
	if(alert(target, "The Dark Lady reaches out to you. Will you take her help?", "Fleshmend", "Embrace me", "I'll be on my own") != "Embrace me")
		to_chat(user, span_notice("[target] refuses her help."))
		return
	target.playsound_local(target, 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
	if((!HAS_TRAIT(target, TRAIT_DNR) && !HAS_TRAIT(target, TRAIT_NECRAS_VOW)) || target.stat != DEAD)
		target.fully_heal()
		target.regenerate_limbs()
		target.heal_wounds(500)
		if(target.stat == DEAD)
			target.revive()
		target.apply_status_effect(/datum/status_effect/debuff/fleshmend_exhaustion)
		to_chat(target, span_notice("ZIZO EMPOWERS ME!"))

/datum/ritual/fleshcrafting/darkeyes
	name = "Глаза ночи"
	desk = "Заменяет глаза на особые, которые крайне хорошо видят в темноте, но имеют одно НО.."
	center_requirement = /mob/living/carbon/human

	w_req = /obj/item/alch/viscera
	e_req = /obj/item/natural/bundle/bone
	n_req = /obj/item/organ/eyes

/datum/ritual/fleshcrafting/darkeyes/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	ADD_TRAIT(target, TRAIT_ZIZOEYES, TRAIT_GENERIC)
	to_chat(target, span_notice("Я больше не боюсь темноты. Но теперь мне стоит скрывать мои глаза.."))

/datum/ritual/fleshcrafting/undead
	name = "Реликвия некроманта"
	desk = "Принеся дары Ей, можно будет получить особый кристалл."
	ritual_limit = 2
	number_cultist_for_add_limit = 2
	center_requirement = /obj/item/natural/glass_shard

	w_req = /obj/item/organ/brain
	e_req = /obj/item/organ/brain
	n_req = /obj/item/alch/bone
	s_req = /obj/item/natural/bundle/bone

	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/undead/invoke(mob/living/user, turf/center)

	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/item/necro_relics/necro_crystal(center)
	playsound(get_turf(center), pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)

/datum/ritual/fleshcrafting/nopain
	name = "Безболезненный бой"
	desk = "Вы перестанете чувствовать боль за счет сильной веры своей жертвы в Псайдона"
	center_requirement = /mob/living/carbon/human
	center_book = "Культист"
	north_book = "Верующий-клирик в Псайдона"
	center_requirement = /mob/living/carbon/human

	n_req = /mob/living/carbon/human

/datum/ritual/fleshcrafting/nopain/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	var/mob/living/carbon/human/victim = locate() in get_step(center, NORTH)

	if(victim.has_status_effect(/datum/status_effect/debuff/devitalised))
		to_chat(target, span_danger("Его душа уже осквернена..."))
		return
	if(victim.patron.type != /datum/patron/old_god)
		to_chat(target, span_danger("Нужен тот, кто верует в Псайдона..."))
		return
	if(victim.patron.type == /datum/patron/old_god)
		ADD_TRAIT(target, TRAIT_NOPAIN, TRAIT_GENERIC)
		to_chat(target, span_notice("За счет его силы люкса, я теперь не чувствую боли!"))
		to_chat(victim, span_danger("О нет.. За счет силы моей веры они стали сильнее.. Что же мне делать дальше.."))
		target.change_stat(STATKEY_WIL, 1)
		victim.apply_status_effect(/datum/status_effect/debuff/devitalised)
		victim.Stun(30)
		victim.Knockdown(30)
		victim.Sleeping(60)

/datum/ritual/fleshcrafting/immortality
	name = "Несовершенное бессмертие"
	desk = "Принеся в жертву аасимара, вы получите множество сил, но и заплатите определенную цену."
	center_book = "Культист"
	north_book = "Живой аасимар"
	center_requirement = /mob/living/carbon/human

	n_req = /mob/living/carbon/human

/datum/ritual/fleshcrafting/immortality/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	var/mob/living/carbon/human/victim = locate() in get_step(center, NORTH)
	if(!(is_species(victim, /datum/species/aasimar)))
		return
	if(victim.has_status_effect(/datum/status_effect/debuff/devitalised))
		to_chat(target, span_notice("This aasimar is already used in ritual..."))
		return
	victim.apply_status_effect(/datum/status_effect/debuff/devitalised)
	victim.Stun(30)
	victim.Knockdown(30)
	ADD_TRAIT(user, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NOLIMBDISABLE, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_HARDDISMEMBER, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NODEATH, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_BLOODLOSS_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_ZOMBIE_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_WOUNDREGEN, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_SPELLCOCKBLOCK, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NOSOFTCRIT, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(user, TRAIT_NOSLEEP, TRAIT_GENERIC)
	to_chat(target, span_notice("ZIZO EMPOWERS ME!! SOMETHING HAS GONE WRONG, THE RITUAL FAILED BUT WHAT IT LEFT ME WITH IS STILL POWER!!"))
	target.change_stat(STATKEY_STR, -3)
	target.change_stat(STATKEY_SPD, -3)
	target.change_stat(STATKEY_WIL, -3)
	target.Knockdown(5 SECONDS)
	target.emote("agony", forced = TRUE)
	target.mind.AddSpell(new /obj/effect/proc_holder/spell/self/zizo_regenerate)

/datum/ritual/fleshcrafting/fleshform
	name = "Боевая плоть"
	desk = "Превращает жертву в глупую живую плоть."
	cultist_number = 2
	center_requirement = /mob/living/carbon/human
	center_book = "Жертва"

	n_req = /obj/item/organ/heart
	is_cultist_ritual = TRUE

/datum/ritual/fleshcrafting/fleshform/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(is_zizocultist(target.mind))
		to_chat(target, span_danger("I'm not letting my strongest follower become a mindless brute."))
		return

	if(!target.ckey || !target.mind)
		var/list/candidates = pollGhostCandidates("Do you want to play as cultistic flesh?", null, null, null, 10 SECONDS, POLL_IGNORE_LICH_SKELETON)
		if(!LAZYLEN(candidates))
			to_chat(user, span_warning("The depths are hollow."))
			return

		var/mob/dead/mob = pick(candidates)
		if(!istype(mob))
			return

		if(istype(mob, /mob/dead/new_player))
			var/mob/dead/new_player/new_player = mob
			new_player.close_spawn_windows()

		target.key = mob.key

	to_chat(target, span_warning("SOON I WILL BECOME A HIGHER FORM!"))
	addtimer(CALLBACK(src, PROC_REF(flesh_convert), target, center), 5 SECONDS)

/datum/ritual/fleshcrafting/fleshform/proc/flesh_convert(mob/living/victim, turf/place)
	if(QDELETED(victim))
		return
	if(place != get_turf(victim))
		return
	if(!victim.mind)
		return
	var/mob/living/trl = new /mob/living/simple_animal/hostile/retaliate/blood(place)
	victim.mind.transfer_to(trl)
	victim.gib()

/datum/ritual/fleshcrafting/gutted
	name = "Потрошение"
	desk = "Потрошит труп, вынимая все органы и отрубая все конечности."
	center_requirement = /mob/living/carbon/human
	center_book = "Мертвое тело"

/datum/ritual/fleshcrafting/gutted/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(target.stat != DEAD)
		return
	target.take_overall_damage(500)
	center.visible_message(span_danger("[target] is lifted up into the air and multiple scratches, incisions and deep cuts start etching themselves into their skin as all of their internal organs spill on the floor below!"))
	var/atom/drop_location = target.drop_location()
	for(var/obj/item/organ/organ as anything in target.internal_organs)
		organ.Remove(target)
		organ.forceMove(drop_location)
	var/obj/item/bodypart/chest/cavity = target.get_bodypart(BODY_ZONE_CHEST)
	if(cavity.cavity_item)
		cavity.cavity_item.forceMove(drop_location)
		cavity.cavity_item = null
	for(var/obj/item/bodypart/part as anything in target.bodyparts)
		part.drop_limb()
	if(target.has_status_effect(/datum/status_effect/debuff/devitalised))
		to_chat(user, span_danger("Он уже выпотрошен"))
		return
	new /obj/item/natural/bundle/bone(center)
	new /obj/item/natural/bundle/bone(center)
	target.apply_status_effect(/datum/status_effect/debuff/devitalised)

/datum/ritual/servantry
	abstract_type = /datum/ritual/servantry

/datum/ritual/servantry/convert
	name = "Convert Lackey"
	desk = "Recruit the target as a cult lackey. Cannot target yourself, an existing cult member, a cult skeleton, the ruler, church or Inquisition members, targets immune to conversion or someone wearing a silver psycross."
	center_book = "Non-cultist target"
	center_requirement = /mob/living/carbon/human
	is_cultist_ritual = TRUE

/datum/ritual/servantry/convert/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(target == user)
		return
	if(is_zizocultist(target.mind) || is_zizolackey(target.mind))
		to_chat(user, span_danger("Он уже мой лакей!"))
		return
	if(target.mind.assigned_role == "Gnoll")
		to_chat(user, span_danger("Это граггарское отродье, оно не заслуживает быть моим лакеем..."))
	if(HAS_TRAIT(target, TRAIT_SILVER_WEAK))
		to_chat(user, span_danger("Мне нужны лишь живые..."))
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/skeleton))
		to_chat(user, span_danger("Мертвые слуги уже принадлежат Зизо, их не нужно обращать."))
		return
	if(istype(target.wear_neck, /obj/item/clothing/neck/roguetown/psicross/silver) || istype(target.wear_wrists, /obj/item/clothing/neck/roguetown/psicross/silver))
		to_chat(user, span_danger("Он носит серебрянный крест! Он мешает мне обратить его..."))
		return

	var/datum/antagonist/zizocultist/PR = user.mind.has_antag_datum(/datum/antagonist/zizocultist)
	if(!PR)
		return
	target.Immobilize(3 SECONDS)
	to_chat(target, span_notice("Правда! Она.. ОНА ОТРКЫЛАСЬ МНЕ! Они совсем не плохие... Я... Должен помогать им!"))
	PR.add_cultist(target.mind)
	target.emote("praise")
	target.playsound_local(target, 'modular_twilight_axis/sound/zizo_cult/local/tesa.ogg', 25)
	target.whisper("O'vena tesa...")
	log_game("[key_name(target)] was converted to Zizoid Lackey by [key_name(PR.owner.current)]")
	message_admins("[key_name(target)] was converted to Zizoid Lackey by [key_name(PR.owner.current)]")

/datum/ritual/servantry/zizofication
	name = "Convert Worshipper"
	desk = "Offer a living target conversion to the faith of Zizo without granting cult membership. Accepting changes their patron; refusing shocks and incapacitates them. Cannot target cult skeletons."
	center_requirement = /mob/living/carbon/human
	center_book = "Living non-skeleton target"

/datum/ritual/servantry/zizofication/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents

	if(!target)
		return

	if(target.stat == DEAD)
		to_chat(user, span_danger("Он должен быть живым..."))
		return

	var/list/options = list(
		"Yield",
		"Resist"
	)
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/skeleton))
		to_chat(user, span_danger("В пустых глазницах уже сияет воля Зизо. Просветление им не нужно."))
		return

	var/chosen = tgui_input_list(target, "Do you yield to the darkness?", "You are shown the path of Zizo.", options)

	if(!chosen)
		convert_resist(target)
		return

	if(chosen == "Yield")
		convert_yield(target)
	else if(chosen == "Resist")
		convert_resist(target)

/datum/ritual/servantry/zizofication/proc/convert_yield(mob/living/carbon/human/target)
	target.Immobilize(3 SECONDS)
	target.set_patron(/datum/patron/inhumen/zizo)
	to_chat(target, span_notice("Зизо... Она... Она теперь укажет мне верный путь..."))
	target.emote("praise")
	target.playsound_local(target, 'modular_twilight_axis/sound/zizo_cult/local/tesa.ogg', 25)
	target.whisper("O'vena tesa...")
	log_game("[key_name(target)] was converted to Zizoid by zizoid!")
	message_admins("[key_name(target)] was converted to Zizoid by zizoid!]")

/datum/ritual/servantry/zizofication/proc/convert_resist(mob/living/carbon/human/target)
	target.Immobilize(3 SECONDS)
	target.visible_message(span_danger("[target] трясется, отказываясь от Зизо!"))
	to_chat(target, span_reallybigredtext("Прими Её путь! СЕЙЧАС ЖЕ!"))
	if(target.electrocute_act(10))
		target.emote("painscream")
	log_game("[key_name(target)] was resist to convert by zizoid")

/datum/ritual/servantry/skeletaljaunt
	name = "Raise Cult Skeleton"
	desk = "Transform the target into a cult skeleton, replacing their equipment, skills and spells. If the body has no player, recruit a volunteer spirit to control it. Cannot target yourself or the cult leader."
	ritual_limit = 2
	number_cultist_for_add_limit = 2
	center_book = "Target to transform"
	center_requirement = /mob/living/carbon/human

	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone
	w_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone

	is_cultist_ritual = TRUE

/datum/ritual/servantry/skeletaljaunt/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return

	if(target == user)
		return

	if(target.mind && is_zizocultist(target.mind))
		to_chat(target, span_danger("I will not let my followers become mindless brutes."))
		return

	if(!target.ckey || !target.mind)
		var/list/candidates = pollGhostCandidates("Do you want to play as skeleton?", ROLE_LICH_SKELETON, null, null, 10 SECONDS, POLL_IGNORE_LICH_SKELETON)
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

	if(target.skills)
		target.skills.known_skills = list()
		target.skills.skill_experience = list()
		target.status_traits = list()

	while(target.mind.spell_list.len)
		var/obj/effect/proc_holder/spell/S = target.mind.spell_list[1]
		target.mind.spell_list -= S
		qdel(S)

	while(target.mob_spell_list.len)
		var/obj/effect/proc_holder/spell/S2 = target.mob_spell_list[1]
		target.mob_spell_list -= S2
		qdel(S2)

	target.unequip_everything()
	var/datum/job/summon_job = SSjob.GetJobType(/datum/job/roguetown/skeleton/zizoid)
	target.mind?.set_assigned_role(summon_job)
	summon_job.after_spawn(target, target.client)

	var/datum/advclass/cult/skeleton/zizoid/raider/class = new
	class.equipme(target)
	qdel(class)

	target.choose_name_popup("SKELETON")
	ADD_TRAIT(target, TRAIT_CABAL, TRAIT_GENERIC)

	to_chat(target, span_userdanger("I am returned to serve. I will obey, so that I may return to rest."))
	to_chat(target, span_userdanger("My master is [user]."))

/datum/ritual/servantry/thecall
	name = "Abduct Target"
	desk = "Bring a person whose face you know to this sigil after three seconds. Requires their exact name and an unblocked destination. Cannot abduct the ruler, church members, nobles, the retinue, regents, courtiers or anyone wearing a silver psycross."
	ritual_limit = 2
	number_cultist_for_add_limit = 2
	center_requirement = /obj/item/bedsheet
	is_cultist_ritual = TRUE

	w_req = /obj/item/bodypart/l_leg
	e_req = /obj/item/bodypart/r_leg
	n_req = /obj/item/alch/matricaria
	s_req = /obj/item/reagent_containers/food/snacks/grown/manabloom

/datum/ritual/servantry/thecall/invoke(mob/living/user, turf/center)

	var/input = input(user, "Who we need to kidnap?", "TELEPORT")
	if(!input)
		return
	for(var/mob/living/carbon/human/human in GLOB.human_list)
		if(human.real_name == input)
			if(!user.mind?.do_i_know(name = human.real_name))
				to_chat(user, span_warning("I didn't saw his face."))
				return
			if(!human)
				return

			if(human == SSticker.rulermob)
				return

			if(human.mind?.assigned_role in GLOB.church_positions)
				to_chat(human, span_warning("I sense an unholy presence loom near my soul."))
				to_chat(user, span_danger("They are protected..."))
				return

			if(human.mind?.assigned_role in GLOB.noble_positions)
				to_chat(human, span_warning("I sense an unholy presence loom near my soul."))
				to_chat(user, span_danger("They are protected..."))
				return

			if(human.mind?.assigned_role in GLOB.retinue_positions)
				to_chat(human, span_warning("I sense an unholy presence loom near my soul."))
				to_chat(user, span_danger("They are protected..."))
				return

			if(human.mind?.assigned_role in GLOB.regency_positions)
				to_chat(human, span_warning("I sense an unholy presence loom near my soul."))
				to_chat(user, span_danger("They are protected..."))
				return

			if(human.mind?.assigned_role in GLOB.courtier_positions)
				to_chat(human, span_warning("I sense an unholy presence loom near my soul."))
				to_chat(user, span_danger("They are protected..."))
				return

			if(istype(human.wear_neck, /obj/item/clothing/neck/roguetown/psicross/silver) || istype(human.wear_wrists, /obj/item/clothing/neck/roguetown/psicross/silver))
				to_chat(user, span_danger("They are wearing silver, it resists the dark magick!"))
				return

			if(!HAS_TRAIT(human, TRAIT_NOSLEEP))
				to_chat(human, span_userdanger("I'm so sleepy..."))
				human.SetSleeping(5 SECONDS)
			else
				to_chat(human, span_userdanger("My eyes close on their own!"))
				human.set_eyes_closed(TRUE)

			addtimer(CALLBACK(src, PROC_REF(kidnap), human, center), 3 SECONDS)

/datum/ritual/servantry/thecall/proc/kidnap(mob/living/victim, turf/to_go)
	if(QDELETED(victim))
		return
	if(to_go.is_blocked_turf(TRUE))
		return
	victim.SetSleeping(0)
	to_chat(victim, span_warning("This isn't my bed... Where am I?!"))
	victim.playsound_local(victim, pick('sound/misc/jumphumans (1).ogg','sound/misc/jumphumans (2).ogg','sound/misc/jumphumans (3).ogg'), 100)
	if (!istype(victim, /mob/living/carbon/human/dummy))
		victim.forceMove(to_go)

/datum/ritual/servantry/falseappearance
	name = "Randomize Appearance"
	desk = "Permanently randomize the target's appearance. Does not provide a way to restore their previous appearance. Cannot target undead."
	center_book = "Non-undead target"
	center_requirement = /mob/living/carbon/human

	n_req = /obj/item/bodypart/head
	s_req = /obj/item/rogueweapon/huntingknife/stoneknife
	e_req = /obj/item/rogueweapon/huntingknife/stoneknife
	w_req = /obj/item/rogueweapon/huntingknife/stoneknife

/datum/ritual/servantry/falseappearance/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	if(!target)
		return
	if(target.mob_biotypes & MOB_UNDEAD)
		to_chat(user, span_warning("The fruits of her work prevent me from changing my appearance..."))
		return
	target.randomize_human_appearance(include_donator = FALSE)
	target.regenerate_clothes()
	target.update_body()

/datum/ritual/servantry/heartache
	name = "Summon Corrupted Heart"
	desk = "Create a single-use heart. A Zizo worshipper can use it to replenish another worshipper's blood, or to put another target to sleep and temporarily silence them."
	center_requirement = /obj/item/organ/heart

	s_req = /obj/item/alch/sinew
	w_req = /obj/item/alch/viscera

	is_cultist_ritual = TRUE

/datum/ritual/servantry/heartache/invoke(mob/user, turf/center)
	new /obj/item/corruptedheart(center)
	to_chat(user, span_notice("A corrupted heart. When used on a non-enlightened mortal their heart shall ache and they will be immobilized and too stunned to speak. Perfect for getting new soon-to-be enlightened. Now, just don't use it at the combat ready."))

/datum/ritual/servantry/luxstol
	name = "Extract Lux"
	desk = "Extract lux from a living target, leaving them devitalised and briefly incapacitated. Produces refined lux from an aasimar, moss lux from a hag or feytouched target, and impure lux otherwise. Cannot drain cultists, Zizo worshippers, cult skeletons, tieflings, dullahans, mindless targets or anyone already devitalised."
	center_requirement = /mob/living/carbon/human
	center_book = "Living target with undrained lux"

/datum/ritual/servantry/luxstol/invoke(mob/living/user, turf/center)
	. = ..()
	var/mob/living/carbon/human/target = locate() in center.contents
	var/apply_greater = FALSE
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/skeleton))
		to_chat(user, span_danger("Это скелет, в нем уже не может быть частички души..."))
		return
	if(!target.mind)
		to_chat(user, span_danger("Зизо отвергает это тело."))
		return
	if(is_zizocultist(target.mind) || is_zizolackey(target.mind))
		to_chat(user, span_danger("Зизо не может отдать частичку души своего же последователя..."))
		return
	if(target.patron.type == /datum/patron/inhumen/zizo)
		to_chat(user, span_danger("Зизо не может отдать частичку души своего же последователя..."))
		return
	if(target.has_status_effect(/datum/status_effect/debuff/devitalised))
		to_chat(user, span_danger("Его душа уже осквернена..."))
		return
	if(target.stat == DEAD)
		to_chat(user, span_danger("Он уже мертв..."))
		return
	if(!target.has_extractable_lux())
		to_chat(user, span_danger("Его душа слишком слаба, чтобы отдать частичку..."))
		return FALSE
	if(istiefling(target) || isdullahan(target))
		to_chat(user, span_danger("Его люкс инфернальный. Это не сработает."))
		return FALSE
	if(isaasimar(target) && !(HAS_TRAIT(target, TRAIT_ANCIENT_HAG) || HAS_TRAIT(target, TRAIT_FEYTOUCHED)))
		new /obj/item/reagent_containers/lux(target.loc)
		apply_greater = TRUE
	else if(HAS_TRAIT(target, TRAIT_ANCIENT_HAG) || HAS_TRAIT(target, TRAIT_FEYTOUCHED))
		new /obj/item/reagent_containers/lux_moss(target.loc)
	else
		new /obj/item/reagent_containers/lux_impure(target.loc)
	target.Stun(30)
	target.Knockdown(30)
	target.Sleeping(60)
	target.apply_status_effect((apply_greater ? /datum/status_effect/debuff/devitalised/greater : /datum/status_effect/debuff/devitalised))

/datum/ritual/servantry/devotionretrv
	name = "Restore Devotion"
	desk = "Restore 250 devotion to the cleric at the center of the sigil."
	center_book = "Cleric with a devotion pool"
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone

/datum/ritual/servantry/devotionretrv/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = locate() in center.contents
	target.devotion?.update_devotion(250)

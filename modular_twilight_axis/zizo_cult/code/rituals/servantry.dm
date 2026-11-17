// TA EDIT START
/datum/ritual/servantry
	abstract_type = /datum/ritual/servantry
	book_category = "Servantry"

/datum/ritual/servantry/convert
	name = "Convert Lackey"
	description = "Recruit a living target as a cult lackey. Cannot target yourself, existing cult members or servants, the ruler, church or Inquisition members, targets immune to conversion or someone carrying a silver psycross."
	center_book = "Living non-cultist target"
	center_requirement = /mob/living/carbon/human
	is_cultist_ritual = TRUE

/datum/ritual/servantry/convert/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	if(!target?.mind || target == user || target.stat == DEAD || is_zizo_cult_member(target) || target.mind.has_antag_datum(/datum/antagonist/skeleton) || psydont(target))
		return FALSE
	var/datum/antagonist/zizocultist/cultist = new
	var/eligible = cultist.can_be_owned(target.mind)
	qdel(cultist)
	return eligible

/datum/ritual/servantry/convert/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	var/datum/antagonist/zizocultist/cultist = user.mind.has_antag_datum(/datum/antagonist/zizocultist)
	if(!cultist?.add_cultist(target.mind))
		to_chat(user, span_warning("The bond will not take. This soul cannot join us."))
		return FALSE
	target.Immobilize(3 SECONDS)
	to_chat(target, span_notice("Death was never the end. Her work is mine to carry."))
	target.emote("praise")
	log_game("[key_name(user)] converted [key_name(target)] into a Zizoid Lackey.")
	message_admins("[key_name_admin(user)] converted [key_name_admin(target)] into a Zizoid Lackey.")
	return TRUE

/datum/ritual/servantry/zizofication
	name = "Convert Worshipper"
	description = "Offer a living target the faith of Zizo without granting cult membership. Accepting changes their patron; refusing shocks and incapacitates them. Cannot target skeletons."
	center_requirement = /mob/living/carbon/human
	center_book = "Living non-skeleton target"
	var/yielded = FALSE

/datum/ritual/servantry/zizofication/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target?.mind && target.stat != DEAD && !target.mind.has_antag_datum(/datum/antagonist/skeleton) && !istype(target.patron, /datum/patron/inhumen/zizo)

/datum/ritual/servantry/zizofication/prepare(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	yielded = tgui_input_list(target, "The Dark Lady offers a path beyond death. Will you follow?", "Zizo's Call", list("Yield", "Resist")) == "Yield"
	return TRUE

/datum/ritual/servantry/zizofication/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	target.Immobilize(3 SECONDS)
	if(yielded)
		target.set_patron(/datum/patron/inhumen/zizo)
		to_chat(target, span_notice("I turn from the Ten. The Dark Lady's work shall endure."))
		target.emote("praise")
	else
		target.visible_message(span_danger("[target] shudders against an unseen pull."))
		to_chat(target, span_danger("A cold hand closes around my heart. I refuse Her call."))
		if(target.electrocute_act(10))
			target.emote("painscream")
	log_game("[key_name(user)] offered [key_name(target)] conversion to Zizo: [yielded ? "accepted" : "refused"].")
	message_admins("[key_name_admin(user)] offered [key_name_admin(target)] conversion to Zizo: [yielded ? "accepted" : "refused"].")
	return TRUE

/datum/ritual/servantry/skeletaljaunt
	name = "Raise Cult Skeleton"
	description = "Transform the target into a skeleton using an existing lich skeleton class. Replace their equipment, skills and spells. An unoccupied body requires a volunteer spirit. Cannot target yourself, a skeleton or the cult leader."
	ritual_limit = 2
	number_cultist_for_add_limit = 2
	center_book = "Target to transform"
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone
	w_req = /obj/item/natural/bone
	e_req = /obj/item/natural/bone
	is_cultist_ritual = TRUE
	var/skeleton_class

/datum/ritual/servantry/skeletaljaunt/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target && target != user && !target.mind?.has_antag_datum(/datum/antagonist/zizocultist/leader) && !target.mind?.has_antag_datum(/datum/antagonist/skeleton)

/datum/ritual/servantry/skeletaljaunt/prepare(mob/living/user, turf/center)
	if(!prepare_spirit(user, "Serve Zizo's cult as a skeleton?"))
		return FALSE
	var/list/classes = list()
	var/list/class_types = list(/datum/advclass/greater_skeleton/lich/legionnaire, /datum/advclass/greater_skeleton/lich/ballistiares, /datum/advclass/greater_skeleton/lich/bulwark, /datum/advclass/greater_skeleton/lich/sapper)
	for(var/datum/advclass/class_type as anything in class_types)
		classes[initial(class_type.name)] = class_type
	var/mob/living/carbon/human/target = get_target()
	var/chosen = tgui_input_list(target.client ? target : volunteer, "Choose the service your bones will bear.", "Cult Skeleton", classes)
	skeleton_class = classes[chosen]
	return !!skeleton_class

/datum/ritual/servantry/skeletaljaunt/invoke(mob/living/user, turf/center)
	if(!claim_spirit())
		return FALSE
	var/mob/living/carbon/human/target = get_target()
	return target.become_cult_skeleton(user.mind, skeleton_class)

/datum/ritual/servantry/thecall
	name = "Abduct Target"
	description = "Bring a known person to the sigil after three seconds. Requires their exact name and an unblocked destination. Cannot abduct the ruler, church members, nobles, retinue, regents, courtiers or someone carrying a silver psycross."
	ritual_limit = 2
	number_cultist_for_add_limit = 2
	center_requirement = /obj/item/bedsheet
	is_cultist_ritual = TRUE
	w_req = /obj/item/bodypart/l_leg
	e_req = /obj/item/bodypart/r_leg
	n_req = /obj/item/alch/matricaria
	s_req = /obj/item/reagent_containers/food/snacks/grown/manabloom
	var/mob/living/carbon/human/victim

/datum/ritual/servantry/thecall/prepare(mob/living/user, turf/center)
	var/chosen_name = tgui_input_text(user, "Whose face do you call to mind? Enter their exact name.", "Abduct Target", max_length = MAX_NAME_LEN)
	if(!chosen_name || !user.mind?.do_i_know(name = chosen_name))
		to_chat(user, span_warning("I cannot call a face I have never known."))
		return FALSE
	for(var/mob/living/carbon/human/target in GLOB.human_list)
		if(target.real_name == chosen_name)
			victim = target
			break
	return validate(user, center)

/datum/ritual/servantry/thecall/validate(mob/living/user, turf/center)
	if(center.is_blocked_turf(TRUE))
		return FALSE
	if(!victim)
		return TRUE
	if(QDELETED(victim) || victim == user || victim == SSticker.rulermob || psydont(victim))
		return FALSE
	var/role = get_zizo_role_title(victim)
	return !(role in GLOB.church_positions) && !(role in GLOB.noble_positions) && !(role in GLOB.retinue_positions) && !(role in GLOB.regency_positions) && !(role in GLOB.courtier_positions)

/datum/ritual/servantry/thecall/invoke(mob/living/user, turf/center)
	if(!victim)
		return FALSE
	if(!HAS_TRAIT(victim, TRAIT_NOSLEEP))
		victim.SetSleeping(5 SECONDS)
	else
		victim.set_eyes_closed(TRUE)
	to_chat(victim, span_userdanger("The dark gathers behind my eyelids. Something calls my name."))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(zizo_abduct_target), WEAKREF(victim), center), 3 SECONDS)
	return TRUE

/proc/zizo_abduct_target(datum/weakref/victim_ref, turf/destination)
	var/mob/living/victim = victim_ref.resolve()
	if(!victim || !destination || destination.is_blocked_turf(TRUE) || istype(victim, /mob/living/carbon/human/dummy))
		return
	victim.SetSleeping(0)
	victim.forceMove(destination)
	to_chat(victim, span_warning("Cold stone beneath me. This is no place I know."))
	playsound(victim, pick('sound/misc/jumphumans (1).ogg', 'sound/misc/jumphumans (2).ogg', 'sound/misc/jumphumans (3).ogg'), 100)

/datum/ritual/servantry/falseappearance
	name = "Randomize Appearance"
	description = "Permanently randomize a living target's appearance. Does not restore their previous appearance. Cannot target undead."
	center_book = "Living non-undead target"
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/bodypart/head
	s_req = /obj/item/rogueweapon/huntingknife/stoneknife
	e_req = /obj/item/rogueweapon/huntingknife/stoneknife
	w_req = /obj/item/rogueweapon/huntingknife/stoneknife

/datum/ritual/servantry/falseappearance/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target?.dna && target.stat != DEAD && !(target.mob_biotypes & MOB_UNDEAD)

/datum/ritual/servantry/falseappearance/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	target.randomize_human_appearance(include_donator = FALSE)
	target.regenerate_clothes()
	target.update_body()
	to_chat(target, span_notice("My old face falls away. Her work wears another shape."))
	return TRUE

/datum/ritual/servantry/heartache
	name = "Summon Corrupted Heart"
	description = "Create a single-use heart. A Zizo worshipper can use it to replenish another worshipper's blood, or to put another target to sleep and temporarily silence them."
	center_requirement = /obj/item/organ/heart
	s_req = /obj/item/alch/sinew
	w_req = /obj/item/alch/viscera
	is_cultist_ritual = TRUE
	outputs = list(/obj/item/corruptedheart)
	success_message = "A borrowed heartbeat stirs beneath my fingers."

/datum/ritual/servantry/luxstol
	name = "Extract Lux"
	description = "Drain lux from a living target, leaving them devitalised and briefly incapacitated. Aasimar yield refined lux; hag and feytouched targets yield moss lux; others yield impure lux. Cannot drain cult members or servants, Zizo worshippers, undead, tieflings, dullahans, mindless targets or someone already devitalised."
	center_requirement = /mob/living/carbon/human
	center_book = "Living target with undrained lux"

/datum/ritual/servantry/luxstol/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target?.mind && target.stat != DEAD && !is_zizo_cult_member(target) && !istype(target.patron, /datum/patron/inhumen/zizo) && !(target.mob_biotypes & MOB_UNDEAD) && !target.has_status_effect(/datum/status_effect/debuff/devitalised) && target.has_extractable_lux() && !istiefling(target) && !isdullahan(target)

/datum/ritual/servantry/luxstol/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	var/greater = FALSE
	if(HAS_TRAIT(target, TRAIT_ANCIENT_HAG) || HAS_TRAIT(target, TRAIT_FEYTOUCHED))
		new /obj/item/reagent_containers/lux_moss(center)
	else if(isaasimar(target))
		new /obj/item/reagent_containers/lux(center)
		greater = TRUE
	else
		new /obj/item/reagent_containers/lux_impure(center)
	drain_zizo_ritual_lux(target, greater)
	to_chat(target, span_danger("A thread of my soul is drawn into the dark."))
	to_chat(user, span_notice("The stolen spark will further Her work."))
	return TRUE

/datum/ritual/servantry/devotionretrv
	name = "Restore Devotion"
	description = "Restore 250 devotion to the living cleric at the center of the sigil."
	center_book = "Living cleric with a devotion pool"
	center_requirement = /mob/living/carbon/human
	n_req = /obj/item/natural/bone
	s_req = /obj/item/natural/bone

/datum/ritual/servantry/devotionretrv/validate(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	return target?.devotion && target.stat != DEAD

/datum/ritual/servantry/devotionretrv/invoke(mob/living/user, turf/center)
	var/mob/living/carbon/human/target = get_target()
	target.devotion.update_devotion(250)
	to_chat(target, span_notice("My prayer returns from the dark, answered."))
	return TRUE
// TA EDIT END

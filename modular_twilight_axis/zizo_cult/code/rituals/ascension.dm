// TA EDIT START
/datum/ritual/fleshcrafting/ascend
	name = "Ascend"
	description = "Transform the cult leader into an ascended flesh creature and start an end-of-round vote. Requires one cultist per six roundstart players, rounded down with a minimum of one. Sacrifice the highest-priority living target on the northern sigil: Bishop, ruler, Hand, Prince or Princess, Marshal, Court Magician, Knight Captain, then Steward. If none remain alive, offer a crown instead."
	center_requirement = /mob/living/carbon/human
	center_book = "Cult leader performing the ritual"
	north_book = "Highest-priority living sacrifice, or a crown if none remain"
	is_cultist_ritual = TRUE
	var/mob/living/carbon/human/sacrifice
	var/obj/item/clothing/head/roguetown/crown/crown

/datum/ritual/fleshcrafting/ascend/bind_ingredients(turf/center)
	if(!..())
		return FALSE
	if(invoker?.loc == center)
		ingredients["center"] = invoker
	sacrifice = get_zizo_ascension_sacrifice()
	if(!sacrifice)
		crown = locate() in get_step(center, NORTH)
	return TRUE

/datum/ritual/fleshcrafting/ascend/required_cultists()
	return SSmapping.retainer.get_cult_ascension_required_cultists()

/datum/ritual/fleshcrafting/ascend/validate(mob/living/user, turf/center)
	if(SSmapping.retainer.cult_ascended || get_target() != user || !is_zizocultist(user.mind))
		return FALSE
	if(sacrifice)
		return !QDELETED(sacrifice) && sacrifice == get_zizo_ascension_sacrifice() && sacrifice.stat != DEAD && sacrifice.loc == get_step(center, NORTH)
	return !get_zizo_ascension_sacrifice() && !QDELETED(crown) && crown.loc == get_step(center, NORTH)

/datum/ritual/fleshcrafting/ascend/invoke(mob/living/user, turf/center)
	if(sacrifice)
		sacrifice.gib()
	else
		qdel(crown)
	SSmapping.retainer.cult_ascended = TRUE
	addomen(OMEN_ASCEND)
	to_chat(user, span_userdanger("The last veil parts. Death shall have no dominion."))
	var/mob/living/ascended = new /mob/living/simple_animal/hostile/retaliate/blood/ascended(center)
	user.mind.transfer_to(ascended)
	user.gib()
	priority_announce("The heavens darken. Something has risen beyond the reach of the Ten.", "Ascension", 'sound/misc/zizo.ogg')
	for(var/mob/living/carbon/human/witness in GLOB.human_list)
		witness.add_stress(is_zizo_cult_member(witness) ? /datum/stressevent/lovezizo : /datum/stressevent/hatezizo)
	SSvote.started_time = world.time - CONFIG_GET(number/vote_delay) - 10
	SSvote.initiate_vote("endround", "Cult Ascension")
	return TRUE
// TA EDIT END

/datum/ritual/blood/transfuse
	name = "Sigil Expertise"
	icon_type = /obj/effect/decal/cleanable/sigil
	node_state = "center"
	desc = "Draw sigils much faster, and without bloody hands."
	passive = TRUE
	research_cost = 2

/datum/ritual/blood/transfuse/apply_passive(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_BLOODBOUND, TRAIT_GENERIC)
	return

/datum/ritual/blood/bloodsnare
	name = "Blood Snare"
	icon_type = /obj/effect/decal/cleanable/sigil
	node_state = "lesser"
	desc = "Create a translucent sigil trap that harms whoever steps onto it. Organs create a poison trap, weapons create a stunning trap, and anything else creates a bleeding trap."
	center_requirement = /obj/item
	keep_center = TRUE

/datum/ritual/blood/bloodsnare/invoke(mob/living/user, turf/center)
	var/effect = "bleed"
	if(locate(/obj/structure/rune_ward/zizo) in center)
		return FALSE
	if(locate(/obj/item/organ) in center)
		effect = "poison"
	else if(locate(/obj/item/rogueweapon) in center)
		effect = "stun"
	for(var/obj/item/I in center)
		qdel(I)
	for(var/obj/effect/decal/cleanable/sigil/sig in range(1, center))
		qdel(sig)
	new /obj/effect/temp_visual/opengate(center, 1.5 SECONDS)
	var/obj/structure/rune_ward/zizo/T = new(center)
	T.effect = effect
	T.owner_ref = WEAKREF(user)
	T.owner_name = user.real_name
	T.owner_ckey = user.ckey || "no ckey"
	to_chat(user, span_notice("THE SIGIL FADES. IT IS READY."))

/datum/status_effect/bloodlink
	id = "bloodlink"
	duration = 10 MINUTES
	tick_interval = 5 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bloodlink
	var/mob/living/carbon/human/partner

/datum/status_effect/bloodlink/on_creation(mob/living/new_owner, mob/living/carbon/human/linked)
	partner = linked
	. = ..()

/datum/status_effect/bloodlink/on_apply()
	. = ..()
	to_chat(owner, span_danger("WHAT A HORRIBLE NITE TO HAVE A CURSE."))
	owner.emote("scream")

/datum/status_effect/bloodlink/tick()
	if(QDELETED(partner) || partner.stat == DEAD)
		qdel(src)
		return
	if(get_dist(owner, partner) > 7)
		owner.adjustOxyLoss(4)
		owner.Jitter(4)
		if(prob(30))
			to_chat(owner, span_danger("My chest aches! Where is [partner.real_name]?!"))

/atom/movable/screen/alert/status_effect/bloodlink
	name = "Blood Bond"
	desc = "OUR HEARTS BEAT AS ONE. I MUST BE NEAR THEM."
	icon_state = "debuff"

/datum/ritual/blood/bloodbond
	name = "Curse of Blood"
	icon_type = /obj/item/natural/worms/leech
	desc = "Curse two targets to slowly die when apart from each other. Requires two leeches that fed from separate targets."
	center_requirement = /obj/item/natural/worms/leech
	keep_center = TRUE

/datum/ritual/blood/bloodbond/invoke(mob/living/user, turf/center)
	var/list/found = list()
	for(var/obj/item/natural/worms/leech/L in center)
		if(L.fed_from && L.blood_storage > 0 && !QDELETED(L.fed_from) && L.fed_from.stat != DEAD)
			found += L
	if(found.len < 2)
		to_chat(user, span_warning("This rite needs two leeches."))
		return
	var/obj/item/natural/worms/leech/L1 = found[1]
	var/obj/item/natural/worms/leech/L2 = found[2]
	var/mob/living/carbon/human/A = L1.fed_from
	var/mob/living/carbon/human/B = L2.fed_from
	if(A == B)
		to_chat(user, span_warning("You can not bind someone to theirself. Fool!"))
		return
	if(A.has_status_effect(/datum/status_effect/buff/curse_immunity) || B.has_status_effect(/datum/status_effect/buff/curse_immunity))
		to_chat(user, span_warning("THEY ARE PROTECTED FROM FURTHER CURSES."))
		return
	curse_target(A)
	curse_target(B)
	A.apply_status_effect(/datum/status_effect/bloodlink, B)
	B.apply_status_effect(/datum/status_effect/bloodlink, A)
	qdel(L1)
	qdel(L2)
	to_chat(user, span_notice("I BIND [A] AND [B], THEIR HEARTS BEAT AS ONE."))

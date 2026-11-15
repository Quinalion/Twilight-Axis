/obj/item/inqhound
	name = "HOUND"
	desc = "Our foes have surrendered themselves to destruction. Uses alchemical vials to produce blood vials for the SNIFFER."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/items/misc.dmi'
	icon_state = "hound"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_HIP
	grid_width = 64
	grid_height = 32
	obj_flags_ignore = TRUE
	item_flags = NOBLUDGEON
	var/bottles = 0
	var/max_bottles = 5
	var/list/obj/item/bloodvial/vials = list()

/obj/item/inqhound/proc/update_hound_icon()
	icon_state = "hound"

/obj/item/inqhound/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/reagent_containers/glass/bottle/alchemical))
		return ..()
	if(bottles >= max_bottles)
		to_chat(user, span_warning("[src] is full!"))
		return
	qdel(I)
	bottles++

/obj/item/inqhound/attack_right(mob/user)
	. = ..()
	if(!length(vials))
		to_chat(user, span_warning("[src] is empty."))
		return
	var/obj/item/bloodvial/V = vials[1]
	vials -= V
	user.put_in_hands(V)
	update_hound_icon()

/obj/item/inqhound/attack_obj(obj/O, mob/living/user)
	var/list/blood = O.return_blood_DNA()
	if(!length(blood))
		to_chat(user, span_warning("[src] finds nothing."))
		return TRUE
	if(!bottles)
		to_chat(user, span_warning("[src] is empty."))
		return TRUE
	icon_state = "hound_active"
	var/success = do_after(user, 3 SECONDS, target = O)
	var/list/final_blood = O.return_blood_DNA()
	if(!success || !length(final_blood))
		update_hound_icon()
		return TRUE
	bottles--
	var/obj/item/bloodvial/V = new(src)
	V.blood_dna = final_blood.Copy()
	V.name = "vial of blood ([english_list(V.blood_dna)])"
	vials += V
	to_chat(user, span_notice("[src] fills a vial."))
	update_hound_icon()
	return TRUE

/obj/item/bloodvial
	name = "vial of blood"
	desc = "A collected blood sample."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/items/misc.dmi'
	icon_state = "hound_vial_full"
	w_class = WEIGHT_CLASS_TINY
	var/list/blood_dna
	var/mob/living/carbon/human/target
	var/expiry

/obj/item/bloodvial/Initialize(mapload)
	. = ..()
	expiry = world.time + 10 MINUTES

/obj/item/bloodvial/examine(mob/user)
	. = ..()
	if(world.time > expiry)
		. += span_warning("It is rotten and shall not work.")
	else
		. += span_notice("The blood shall rot in [round((expiry - world.time) / (1 MINUTES))] minutes.")

/obj/item/inqscanner
	name = "SNIFFER"
	desc = "For we have the greater wisdom. Utilizes blood vials from the HOUND to track targets."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/items/misc.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	grid_width = 32
	grid_height = 32
	var/obj/item/bloodvial/vial

/obj/item/inqscanner/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/bloodvial))
		return ..()
	if(vial)
		to_chat(user, span_warning("[src] is full!"))
		return
	var/obj/item/bloodvial/V = I
	if(world.time > V.expiry)
		to_chat(user, span_warning("The blood is rotten!"))
		qdel(V)
		return
	if(!V.target)
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.dna && (H.dna.unique_enzymes in V.blood_dna))
				V.target = H
				break
	if(!V.target)
		to_chat(user, span_warning("[src] can't find anything!"))
		qdel(V)
		return
	user.transferItemToLoc(V, src)
	vial = V

/obj/item/inqscanner/attack_right(mob/user)
	. = ..()
	if(!vial)
		return
	user.put_in_hands(vial)
	vial = null

/obj/item/inqscanner/attack_self(mob/living/user)
	if(!vial || world.time > vial.expiry)
		if(vial)
			to_chat(user, span_warning("The vial has gone rotten."))
			qdel(vial)
		else
			to_chat(user, span_warning("[src] can't find anything."))
		vial = null
		return
	var/mob/living/carbon/human/target = vial.target
	if(GLOB.zizo_proxy[target] && !prob(25))
		target = GLOB.zizo_proxy[target]
	if(!target || QDELETED(target) || target.stat == DEAD)
		to_chat(user, span_warning("[src] can't find anything."))
		qdel(vial)
		vial = null
		return
	var/dist = get_dist(user, target)
	if(dist <= 9)
		to_chat(user, span_notice("[src] is too close to the scent!"))
	else
		var/list/info = get_locator_info(user, target)
		to_chat(user, span_notice("[src] pulls towards the [info["dir"]]. The scent feels [info["proximity"]][info["z"]]."))



/datum/inqports/supplies/hound
	name = "HOUND DEVICE"
	item_type = /obj/item/inqhound
	marquescost = 2

/datum/inqports/supplies/scanner
	name = "SNIFFER DEVICE"
	item_type = /obj/item/inqscanner
	marquescost = 2

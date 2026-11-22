/obj/item/lockpick/inquisitorial_vice
	name = "penitent's key"
	desc = "A set of fine steel lockpicks known in Otava as «Clé du Pénitent». \
		It comes with a compact steam ram for breaking locks and bolts."
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "lockpick"
	max_integrity = 200
	obj_flags = CAN_BE_HIT
	picklvl = 2
	anvilrepair = /datum/skill/craft/blacksmithing
	always_destroy = FALSE
	var/ram_enabled = FALSE
	var/ram_busy = FALSE

/obj/item/lockpick/inquisitorial_vice/examine(mob/user)
	. = ..()
	if(!HAS_TRAIT(user, TRAIT_INQUISITION))
		return
	var/list/examination = .
	var/description_index = examination.Find(span_info(desc))
	if(description_index)
		examination[description_index] = span_info("The «Clé du Pénitent» is a set of fine lockpicks issued to trusted \
			agents of the Inquisition. Its steam ram has taken more than one \
			careless hand.")

/obj/item/lockpick/inquisitorial_vice/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click it in hand to switch between the pick and ram.")
	. += span_info("The ram breaks a door and costs 50 integrity per use.")

/obj/item/lockpick/inquisitorial_vice/rmb_self(mob/user, keybind = FALSE)
	if(ram_busy || !(src in user.held_items))
		return
	ram_enabled = !ram_enabled
	var/mode = ram_enabled ? "ram" : "lockpick"
	to_chat(user, span_notice("I ready the [mode]."))

/obj/item/lockpick/inquisitorial_vice/pre_attack(
	atom/target, mob/living/user, params,
)
	if(..())
		return TRUE
	if(!ram_enabled)
		return FALSE
	var/static/list/door_types = list(
		/obj/structure/mineral_door,
		/obj/structure/roguetent,
		/obj/structure/floordoor,
		/obj/structure/gate,
	)
	if(!is_type_in_list(target, door_types))
		return FALSE
	var/obj/structure/door = target
	if(ram_busy || !door.density || !user.Adjacent(door))
		return TRUE
	if(obj_integrity < 50 || obj_broken)
		to_chat(user, span_warning("The ram needs repairs."))
		return TRUE
	if(!door.max_integrity || (door.resistance_flags & INDESTRUCTIBLE))
		to_chat(user, span_warning("The ram cannot break this door."))
		return TRUE

	ram_busy = TRUE
	var/completed = do_after(user, 5, target = door)
	if(QDELETED(src))
		return TRUE
	ram_busy = FALSE
	if(!completed || QDELETED(door) || door.obj_destroyed || !door.density)
		return TRUE
	if(!(src in user.held_items) || !user.Adjacent(door) || obj_integrity < 50)
		return TRUE

	obj_integrity -= 50
	if(!obj_integrity)
		obj_break()
	user.visible_message(span_danger("[user] smashes [door] with [src]!"))
	playsound(door, 'sound/combat/hits/onwood/destroywalldoor.ogg', 100, TRUE)
	log_combat(user, door, "breached with", src)
	door.obj_destruction(BRUTE)
	return TRUE

/datum/inqports/equipment/penitents_key
	name = "Penitent's Key"
	item_type = /obj/item/lockpick/inquisitorial_vice
	marquescost = 12
	maximum = 2

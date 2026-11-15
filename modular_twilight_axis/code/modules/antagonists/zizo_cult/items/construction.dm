/turf/closed/wall/mineral/rogue/stone/space
	name = "???"
	desc = "???"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultsprites.dmi'
	icon_state = "cultwall"
	smooth = SMOOTH_FALSE

/obj/structure/illusory_wall
	density = FALSE
	opacity = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/illusory_wall/Initialize(mapload, turf/closed/wall/copied)
	. = ..()
	if(!copied)
		return
	icon = copied.icon
	icon_state = copied.icon_state
	name = copied.name
	desc = copied.desc

/obj/item/cultbrick
	name = "dark shards"
	desc = "You could use these to make something."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "shard_small3"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	var/amount = 5
	var/maxamount = 15

/obj/item/cultbrick/Initialize(mapload)
	. = ..()
	update_shard_icon()

/obj/item/cultbrick/proc/update_shard_icon()
	if(amount >= 11)
		icon_state = "shard_large1"
	else if(amount >= 6)
		icon_state = "shard_medium2"
	else
		icon_state = "shard_small3"

/obj/item/cultbrick/examine(mob/user)
	. = ..()
	. += span_notice("There are [amount] shards in the stack.")

/obj/item/cultbrick/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/cultbrick))
		var/obj/item/cultbrick/B = W
		if(amount + B.amount > maxamount)
			B.amount = (amount + B.amount) - maxamount
			amount = maxamount
			B.update_shard_icon()
			to_chat(user, span_warning("There's not enough space in [src]."))
		else
			to_chat(user, span_notice("I add [W] to [src]."))
			amount += B.amount
			qdel(B)
		update_shard_icon()
		return
	return ..()

/obj/item/cultbrick/attack_right(mob/user)
	if(!amount)
		return
	switch(amount)
		if(2)
			var/obj/item/cultbrick/A = new(src.loc)
			var/obj/item/cultbrick/B = new(src.loc)
			A.amount = 1
			B.amount = 1
			user.put_in_hands(A)
			user.put_in_hands(B)
			qdel(src)
		else
			amount -= 1
			update_shard_icon()
			var/obj/item/cultbrick/F = new(src.loc)
			F.amount = 1
			user.put_in_hands(F)
			user.visible_message(span_notice("[user] removes a shard from [src]."), span_notice("I remove a shard from [src]."))

/obj/item/cultbrick/attack_self(mob/living/user)
	if(!amount)
		return
	var/turf/T = get_step(user, user.dir)
	if(!istype(T))
		to_chat(user, span_warning("There's no room to build there."))
		return
	if(T.density && !istype(T, /turf/closed/wall) && !(locate(/obj/structure/mineral_door) in T))
		to_chat(user, span_warning("There's no room to build there."))
		return
	var/nearby_fuge = FALSE
	for(var/obj/structure/fuge/F in range(7, get_turf(user)))
		nearby_fuge = TRUE
		break
	if(nearby_fuge == FALSE)
		to_chat(user, span_warning("THIS MUST BE NEAR A FUGE!"))
		return
	var/choice = input(user, "BUILD", "ZIZO") as null|anything in list("Wall", "Door", "Illusory Wall")
	if(!choice || !amount)
		return
	var/turf/closed/wall/copied
	if(choice == "Illusory Wall")
		var/list/walls = list()
		for(var/turf/closed/wall/W in range(2, user))
			if(W != T)
				walls[W.name] = W
		if(!length(walls))
			to_chat(user, span_warning("NO WALLS NEARBY."))
			return
		var/pick = input(user, "COPY WALL", "ZIZO") as null|anything in walls
		if(!pick)
			return
		copied = walls[pick]
	if(choice == "Door")
		for(var/obj/structure/mineral_door/wood/donjon/stone/cult/D in range(2, T))
			if(get_turf(D) != T)
				to_chat(user, span_warning("ANOTHER DOOR IS TOO CLOSE!"))
				return
	if(!do_after(user, 10 SECONDS, target = T))
		return
	if(!amount)
		return
	var/obj/structure/mineral_door/old_door = locate() in T
	if(old_door)
		qdel(old_door)
	if(istype(T, /turf/closed/wall))
		T.ChangeTurf(/turf/open/floor/rogue/underworld/space/quiet/cult)
	switch(choice)
		if("Wall")
			T.ChangeTurf(/turf/closed/wall/mineral/rogue/stone/space)
			new /obj/effect/temp_visual/cult/turf(T)
		if("Door")
			new /obj/structure/mineral_door/wood/donjon/stone/cult(T)
			new /obj/effect/temp_visual/cult/door(T)
		if("Illusory Wall")
			new /obj/structure/illusory_wall(T, copied)
			new /obj/effect/temp_visual/cult/turf(T)
	playsound(T, 'sound/foley/breaksound.ogg', 50, TRUE)
	amount--
	if(amount <= 0)
		qdel(src)
	else
		update_shard_icon()

/obj/structure/mineral_door/wood/donjon/stone/cult
	name = "strange door"
	desc = "What is this...? A door?"
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultsprites.dmi'
	icon_state = "cult"
	base_state = "cult"
	over_state = "cultopen"

/obj/structure/mineral_door/wood/donjon/stone/cult/onkick(mob/user)
	to_chat(user, span_warning("[src] doesn't budge, no matter how hard I kick."))

/obj/structure/mineral_door/wood/donjon/stone/cult/TryToSwitchState(mob/living/user)
	if(!is_zizo(user))
		to_chat(user, span_warning("[src] won't budge, no matter how I push."))
		return FALSE
	. = ..()
	new /obj/effect/temp_visual/cult/door(loc)

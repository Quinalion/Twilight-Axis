/obj/item/explosive/impact/inquisitorial_burst
	name = "martyr's thorns"
	desc = "A spiked powder charge known in Otava as «Hérisson». \
		It looks every bit as fearsome as it is."
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "grenade"

/obj/item/explosive/impact/inquisitorial_burst/blast(turf/center, forced)
	var/list/landing_tiles = list()
	for(var/turf/open/tile in view(3, center))
		if(get_dist(center, tile) < 2)
			continue
		if(istype(tile, /turf/open/transparent/openspace))
			continue
		if(tile.is_blocked_turf())
			continue
		landing_tiles += tile
	for(var/number in 1 to min(6, length(landing_tiles)))
		var/turf/tile = pick_n_take(landing_tiles)
		new /obj/item/inquisitorial_caltrop(tile)
	playsound(center, 'sound/misc/explode/incendiary (1).ogg', 100, TRUE)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(3, center)
	smoke.start()

/obj/item/inquisitorial_caltrop
	name = "caltrop"
	desc = "A small iron thorn that always lands with a point upwards."
	icon = 'modular_twilight_axis/icons/roguetown/items/misc.dmi'
	icon_state = "caltrop"
	w_class = WEIGHT_CLASS_TINY
	grid_width = 32
	grid_height = 32

/obj/item/inquisitorial_caltrop/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/caltrop/inquisitorial)

/datum/component/caltrop/inquisitorial/Crossed(datum/source, atom/movable/crosser)
	if(!ishuman(crosser))
		return
	var/mob/living/carbon/human/victim = crosser
	if(victim.buckled || (victim.movement_type & FLYING) || victim.get_taur_tail())
		return
	if(HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		return
	var/zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/leg = victim.get_bodypart(zone)
	if(!leg || leg.status == BODYPART_ROBOTIC)
		return

	var/footwear = victim.shoes
	var/feet_covered = victim.wear_armor?.body_parts_covered & FEET
	feet_covered |= victim.wear_pants?.body_parts_covered & FEET
	var/barefoot = !footwear && !feet_covered
	if(barefoot && HAS_TRAIT(victim, TRAIT_HARDSOLE))
		return
	var/damage = 8
	var/plate_boots = istype(footwear, /obj/item/clothing/shoes/roguetown/boots/armor)
	if(footwear && !plate_boots)
		damage = 3
	victim.apply_damage(damage, BRUTE, zone)
	if(barefoot)
		victim.Knockdown(2 SECONDS)
	if(world.time >= cooldown)
		victim.visible_message(span_warning("[victim] steps on [parent]!"))
		cooldown = world.time + 1 SECONDS

/datum/inqports/equipment/martyrs_thorns
	name = "Martyr's Thorns"
	item_type = /obj/item/explosive/impact/inquisitorial_burst
	marquescost = 6

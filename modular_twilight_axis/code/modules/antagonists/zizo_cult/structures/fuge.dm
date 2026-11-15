/obj/structure/fuge
	name = "fuge"
	desc = ""
	icon = 'icons/effects/clan.dmi'
	icon_state = "teleport"
	density = FALSE
	anchored = TRUE
	max_integrity = 300
	var/busy = FALSE
	var/radius = 1
	var/list/turf_data = list()
	var/list/obj/structure/pylon/pylons = list()
	var/list/obj/structure/raver/ravers = list()

	var/static/list/recipes = list(
		list("Dark Shards", /obj/item/cultbrick, 40 SECONDS, null, FALSE),
		list("Zizo Robe", /obj/item/clothing/cloak/cultrobe, 90 SECONDS, null, FALSE),
		list("Snow Scythe (Bite)", /obj/item/rogueweapon/spear/bite, 90 SECONDS, "BITE", TRUE),
		list("Mortal Blade (Rot)", /obj/item/rogueweapon/sword/sabre/rot, 90 SECONDS, "ROT", TRUE),
		list("Forgotten Tool (Toil)", /obj/item/rogueweapon/mace/maul/toil, 90 SECONDS, "TOIL", TRUE),
		list("Witchwood (Strand)", /obj/item/rogueweapon/zizowand, 90 SECONDS, "STRAND", TRUE),
		list("Madman Blade (Noise)", /obj/item/rogueweapon/sword/long/noise, 90 SECONDS, "NOISE", TRUE),
		list("Slave Knife (Blood)", /obj/item/rogueweapon/huntingknife/idagger/steel/blood, 90 SECONDS, "BLOOD", TRUE),
		list("Astrata-Touched Dagger (Pitch)", /obj/item/rogueweapon/huntingknife/idagger/steel/pitch, 90 SECONDS, "PITCH", TRUE),
		list("Accursed Leech", /obj/item/natural/worms/leech/propaganda, 40 SECONDS, null, FALSE),
		list("Muzzling Leech", /obj/item/natural/worms/leech/silencer, 40 SECONDS, null, FALSE),
	)

/obj/structure/fuge/attack_hand(mob/living/user)
	if(!is_zizo(user))
		return ..()
	if(busy)
		to_chat(user, span_warning("IT'S WORKING!!! WAIT!!!"))
		return
	var/list/menu = list()
	for(var/list/Rtype in recipes)
		if(Rtype[4] && !(Rtype[4] in GLOB.zizo_bestowed))
			continue
		if(Rtype[5] && (Rtype[2] in GLOB.zizo_summoned))
			continue
		menu["[Rtype[1]] - [Rtype[3] / 10] seconds"] = Rtype
	if(!length(menu))
		return
	var/choice = tgui_input_list(user, "PRODUCE AN ITEM", "FUGE", menu)
	if(!choice || busy)
		return
	var/list/Rtype = menu[choice]
	busy = TRUE
	icon_state = "teleport_trigger"
	visible_message(span_danger("The fuge begins production!"))
	addtimer(CALLBACK(src, PROC_REF(finish_pull), Rtype[2], Rtype[5]), Rtype[3])

/obj/structure/fuge/proc/finish_pull(spawn_type, unrepeatable)
	busy = FALSE
	icon_state = "teleport"
	if(unrepeatable)
		GLOB.zizo_summoned |= spawn_type
	var/atom/produced = spawn_type
	new spawn_type(get_turf(src))
	visible_message(span_danger("The fuge disgorges [initial(produced.name)]!"))
	playsound(src, 'sound/magic/blink.ogg', 40, TRUE)

/obj/structure/fuge/Initialize(mapload)
	. = ..()
	GLOB.zizo_fuges += src
	var/turf/center = get_turf(src)
	for(var/turf/T in range(radius, center))
		if(isclosedturf(T) && !istype(T, /turf/closed/indestructible))
			turf_data[T] = T.type
			T.ChangeTurf(/turf/closed/wall/mineral/rogue/stone/space, flags = CHANGETURF_IGNORE_AIR)
			new /obj/effect/temp_visual/cult/turf(T)
		else if(isopenturf(T) && !istype(T, /turf/open/floor/rogue/underworld/space/quiet/cult))
			turf_data[T] = T.type
			T.ChangeTurf(/turf/open/floor/rogue/underworld/space/quiet/cult, flags = CHANGETURF_IGNORE_AIR)
			new /obj/effect/temp_visual/cult/turf/floor(T)

/obj/structure/fuge/Destroy()
	GLOB.zizo_fuges -= src
	for(var/obj/structure/pylon/P as anything in pylons.Copy())
		qdel(P)
	pylons = null
	for(var/obj/structure/raver/R as anything in ravers.Copy())
		qdel(R)
	ravers = null
	for(var/turf/T in turf_data)
		T.ChangeTurf(turf_data[T], flags = CHANGETURF_IGNORE_AIR)
	turf_data.Cut()
	return ..()

/datum/ritual/transmutation/summonpylon
	name = "Summon Pylon"
	icon_type = /obj/structure/pylon
	desc = "Conjure a device that siphons life essence from random people to create dark crystals. The target is given hints towards the pylon's location. Must be near a Fuge."
	is_cultist_ritual = TRUE
	center_requirement = /obj/item/candle/candlestick/gold
	research_cost = 5

/datum/ritual/transmutation/summonpylon/invoke(mob/living/user, turf/center)
	var/obj/structure/fuge/nearby_fuge
	for(var/obj/structure/fuge/F in range(5, center))
		nearby_fuge = F
		break
	if(!nearby_fuge)
		to_chat(user, span_warning("THIS MUST BE NEAR A FUGE!"))
		return
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/structure/pylon(center, nearby_fuge)

/obj/structure/pylon
	name = "pylon"
	desc = "Herein is proven the false customs of the others."
	icon = 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultsprites.dmi'
	icon_state = "cult_pylon"
	density = TRUE
	anchored = TRUE
	max_integrity = 250
	var/obj/structure/fuge/fuge
	var/datum/beam/beam
	var/busy = FALSE

/obj/structure/pylon/Initialize(mapload, obj/structure/fuge/linked_fuge)
	. = ..()
	fuge = linked_fuge
	if(fuge)
		LAZYADD(fuge.pylons, src)
		beam = fuge.Beam(src, "blood", 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultsprites.dmi', time = INFINITY)

/obj/structure/pylon/Destroy()
	qdel(beam)
	beam = null
	fuge?.pylons -= src
	fuge = null
	return ..()

/obj/structure/pylon/attack_hand(mob/living/user)
	. = ..()
	if(!. && is_zizo(user))
		to_chat(user, span_warning("USE A LEECH THAT HAS FED ON SOMEONE ON ME."))

/obj/structure/pylon/attackby(obj/item/I, mob/living/user)
	var/obj/item/natural/worms/leech/remnant = I
	if(!istype(remnant) || !is_zizo(user))
		return ..()
	if(busy)
		to_chat(user, span_warning("WORKING! WAIT!!!"))
		return
	if(!remnant.fed_from)
		to_chat(user, span_warning("THIS LEECH HASN'T FED ON ANYONE."))
		return
	var/mob/living/carbon/human/target = remnant.fed_from
	if(QDELETED(target) || target.stat == DEAD || target.has_status_effect(/datum/status_effect/debuff/pylon_drain))
		to_chat(user, span_warning("CAN'T FIND ANYONE."))
		return
	qdel(remnant)
	busy = TRUE
	var/datum/status_effect/debuff/pylon_drain/drain = target.apply_status_effect(/datum/status_effect/debuff/pylon_drain)
	drain.pylon = src
	to_chat(user, span_notice("IT LATCHES ONTO [uppertext(target)]. IT WILL PRODUCE A DARK CRYSTAL IN 5 MINUTES. THEY MIGHT FIND THE PYLON."))
	visible_message(span_danger("[src] vibrates menacingly!"))

/datum/status_effect/debuff/pylon_drain
	id = "pylon_drain"
	duration = 5 MINUTES
	tick_interval = 5 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/debuff/pylon_drain
	var/obj/structure/pylon/pylon

/atom/movable/screen/alert/status_effect/debuff/pylon_drain
	name = "BEING DRAINED"
	desc = "THE ZIZO CULT IS STEALING MY LUX THROUGH THE ETHER!"

/datum/status_effect/debuff/pylon_drain/tick()
	if(!pylon || QDELETED(pylon))
		qdel(src)
		return
	if(!prob(10))
		return
	var/mob/living/carbon/human/H = owner
	switch(rand(1, 2))
		if(1)
			var/list/info = get_locator_info(H, pylon)
			to_chat(H, span_danger("...I feel a tugging from [uppertext(info["dir"])]...[uppertext(info["proximity"])][uppertext(info["z"])]..."))
		if(2)
			var/list/nearby_items = list()
			for(var/obj/item/I in range(3, pylon))
				nearby_items += I
			if(!length(nearby_items))
				return
			var/obj/item/picked = pick(nearby_items)
			if(prob(50))
				to_chat(H, span_danger("...[uppertext(picked.name)]..."))
			else
				to_chat(H, span_danger("...[picked.desc]..."))

/datum/status_effect/debuff/pylon_drain/on_remove()
	. = ..()
	if(!pylon || QDELETED(pylon))
		return
	pylon.busy = FALSE
	if(duration != -1 && world.time >= duration && !QDELETED(owner) && owner.stat != DEAD)
		if(owner.has_status_effect(/datum/status_effect/debuff/devitalised) || owner.has_status_effect(/datum/status_effect/debuff/devitalised/lux_ripped))
			return FALSE
		owner.apply_status_effect(/datum/status_effect/debuff/devitalised)
		owner.Jitter(4)
		owner.emote("scream")
		playsound(owner, 'sound/gore/flesh_eat_04.ogg', 40, TRUE)
		to_chat(owner, span_danger("THE LUX IS TORN FROM YOUR SOUL."))
		new /obj/item/necro_relics/necro_crystal(get_turf(pylon))
	playsound(pylon, 'sound/magic/blink.ogg', 40, TRUE)

/datum/ritual/transmutation/summonraver
	name = "Summon Raver"
	icon_type = /obj/structure/raver
	desc = "Conjure a device to drain the lux of sacrifices. Buckle a victim to the raver and it shall consume their lux. Afterwards, a cultist can buckle to it and receive powerful body enhancements. Must be near a Fuge."
	center_requirement = /obj/item/natural/worms
	is_cultist_ritual = TRUE
	research_cost = 5

/datum/ritual/transmutation/summonraver/invoke(mob/living/user, turf/center)
	var/obj/structure/fuge/nearby_fuge
	for(var/obj/structure/fuge/F in range(5, center))
		nearby_fuge = F
		break
	if(!nearby_fuge)
		to_chat(user, span_warning("THIS MUST BE BUILT NEAR A FUGE."))
		return
	var/datum/effect_system/spark_spread/S = new(center)
	S.set_up(1, 1, center)
	S.start()
	new /obj/structure/raver(center, nearby_fuge)

/obj/structure/raver
	name = "raver"
	desc = "There's sharp barbs on the squirming mass. You could put someone in it, if you're evil."
	icon = 'icons/effects/clan.dmi'
	icon_state = "flesh_grip"
	density = TRUE
	anchored = TRUE
	max_integrity = 250
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = 0
	buckleverb = "strap"
	var/obj/structure/fuge/fuge
	var/datum/beam/beam
	var/material = 0

/obj/structure/raver/Initialize(mapload, obj/structure/fuge/linked_fuge)
	. = ..()
	fuge = linked_fuge
	if(fuge)
		LAZYADD(fuge.ravers, src)
		beam = fuge.Beam(src, "blood", 'modular_twilight_axis/icons/zizo_cult/roguetown/cult/cultsprites.dmi', time = INFINITY)

/obj/structure/raver/Destroy()
	qdel(beam)
	beam = null
	fuge?.ravers -= src
	fuge = null
	return ..()

/obj/structure/raver/mouse_buckle_handling(mob/living/M, mob/living/user)
	return user_buckle_mob(M, user, check_loc = FALSE)

/obj/structure/raver/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!is_zizo(buckled_mob))
		var/escape_time = 30 SECONDS
		if(buckled_mob.restrained())
			escape_time = 1 MINUTES
		to_chat(user, span_warning("The raver clenches around you! It's hard to wriggle free!"))
		if(!do_after(user, escape_time, target = src))
			return
	return ..()

/obj/structure/raver/examine(mob/user)
	. = ..()
	if(is_zizo(user))
		. += span_notice("It has enough lux for [material] grafts.")

/obj/structure/raver/post_buckle_mob(mob/living/M)
	. = ..()
	if(is_zizo(M))
		INVOKE_ASYNC(src, PROC_REF(graft), M)
		return
	if(M.has_status_effect(/datum/status_effect/debuff/devitalised) || M.has_status_effect(/datum/status_effect/debuff/devitalised/lux_ripped))
		visible_message(span_warning("[M] has no lux left to give."))
		return
	if(!M.mind?.key)
		visible_message(span_warning("[M] has no soul."))
		return
	M.apply_status_effect(/datum/status_effect/raver_corruption, src)
	playsound(src, 'sound/foley/butcher.ogg', 80, TRUE)

/obj/structure/raver/proc/graft(mob/living/carbon/human/H)
	if(!ishuman(H))
		return
	if(!material)
		to_chat(H, span_warning("THE RAVER HAS NO LUX. BUCKLE A SACRIFICE ONTO IT."))
		return
	var/static/list/options = list(
		"Grafted Heart (BLEED & DISMEMBER IMMUNITY)" = /obj/item/organ/zizo_graft/bleed,
		"Grafted Brain (UNCONSCIOUS IMMUNITY)" = /obj/item/organ/zizo_graft/crit,
		"Grafted Lungs (ENHANCED FATIGUE)" = /obj/item/organ/zizo_graft/fatigue,
		"Grafted Liver (HEALING FACTOR)" = /obj/item/organ/zizo_graft/health,
	)
	var/list/menu = list()
	for(var/name in options)
		var/obj/item/organ/zizo_graft/graft_type = options[name]
		if(!H.getorganslot(initial(graft_type.slot)))
			menu += name
	if(!length(menu))
		to_chat(H, span_warning("I AM COMPLETE."))
		return
	var/choice = tgui_input_list(H, "RECEIVE A GRAFT", "RAVER", menu)
	if(!choice || H.buckled != src || !material)
		return
	H.apply_status_effect(/datum/status_effect/raver_corruption/graft, src)
	var/grafted = do_after(H, 10 SECONDS, target = src)
	H.remove_status_effect(/datum/status_effect/raver_corruption)
	if(!grafted)
		return
	var/organ_path = options[choice]
	var/obj/item/organ/zizo_graft/organ = new organ_path
	organ.Insert(H)
	ADD_TRAIT(H, TRAIT_MONSTROUS, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_WEAK, TRAIT_GENERIC)
	material--
	to_chat(H, span_userdanger("THE RAVER JAMS THE GRAFT INTO MY FLESH!"))
	H.emote("scream")
	unbuckle_mob(H, force = TRUE)

/obj/item/organ/zizo_graft
	name = "grafted organ"
	desc = "Unnatural! Unsightly! Zizo's touch is upon it!"
	icon = 'icons/obj/surgery.dmi'
	zone = BODY_ZONE_CHEST
	var/list/graft_traits = list()
	var/energy = 0
	var/heal = 0

/obj/item/organ/zizo_graft/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	for(var/trait in graft_traits)
		ADD_TRAIT(M, trait, "zizo_graft")

/obj/item/organ/zizo_graft/Remove(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	for(var/trait in graft_traits)
		REMOVE_TRAIT(M, trait, "zizo_graft")
	return ..()

/obj/item/organ/zizo_graft/on_life()
	. = ..()
	if(!owner)
		return
	if(energy)
		owner.energy_add(energy)
		owner.adjustStaminaLoss(-energy / 5)
	if(heal)
		owner.heal_overall_damage(heal, heal)
		owner.heal_wounds(heal)

/obj/item/organ/zizo_graft/bleed
	name = "grafted heart"
	icon_state = "heartcon-on"
	slot = "zizo_graft_bleed"
	graft_traits = list(TRAIT_BLOODLOSS_IMMUNE, TRAIT_NODISMEMBER)

/obj/item/organ/zizo_graft/crit
	name = "grafted brain"
	icon_state = "brain-con"
	slot = "zizo_graft_crit"
	graft_traits = list(TRAIT_NOHARDCRIT, TRAIT_NOSOFTCRIT)

/obj/item/organ/zizo_graft/fatigue
	name = "grafted lungs"
	icon_state = "lungs-con"
	slot = "zizo_graft_fatigue"
	energy = 25

/obj/item/organ/zizo_graft/health
	name = "grafted liver"
	icon_state = "liver-con"
	slot = "zizo_graft_health"
	heal = 1.5

/datum/status_effect/zizo_regen
	id = "zizo_regen"
	duration = -1
	tick_interval = 2 SECONDS
	alert_type = null
	var/energy = 0

/datum/status_effect/zizo_regen/tick()
	owner.energy_add(energy)
	owner.adjustStaminaLoss(-energy / 5)

/datum/status_effect/zizo_regen/robe
	id = "zizo_robe_regen"
	energy = 10

/obj/structure/raver/post_unbuckle_mob(mob/living/M)
	. = ..()
	M.remove_status_effect(/datum/status_effect/raver_corruption)

/datum/status_effect/raver_corruption
	id = "raver_corruption"
	duration = -1
	tick_interval = 3 SECONDS
	alert_type = null
	var/obj/structure/raver/raver
	var/elapsed = 0
	var/graft = FALSE

/datum/status_effect/raver_corruption/graft
	graft = TRUE

/datum/status_effect/raver_corruption/on_creation(mob/living/new_owner, obj/structure/raver/device)
	raver = device
	. = ..()

/datum/status_effect/raver_corruption/on_apply()
	. = ..()
	owner.overlay_fullscreen("raver", /atom/movable/screen/fullscreen/brute, 4)
	owner.add_filter("raver_glow", 1, list(type = "outline", color = "#8b0000", size = 1))
	owner.add_filter("raver_warp", 2, list(type = "wave", x = 2, y = 2, size = 3, offset = 0))
	animate(owner.get_filter("raver_warp"), offset = 6, time = 2 SECONDS, loop = -1)
	animate(offset = 0, time = 0)

/datum/status_effect/raver_corruption/on_remove()
	. = ..()
	owner.clear_fullscreen("raver")
	owner.clear_fullscreen("raver_flash")
	owner.remove_filter("raver_glow")
	owner.remove_filter("raver_warp")

/datum/status_effect/raver_corruption/tick()
	if(QDELETED(raver) || owner.buckled != raver || (is_zizo(owner) && !graft))
		qdel(src)
		return
	if(!graft)
		owner.adjustStaminaLoss(5)
	owner.Jitter(4)
	shake_camera(owner, 6, 1)
	owner.do_jitter_animation(300)
	owner.overlay_fullscreen("raver_flash", /atom/movable/screen/fullscreen/painflash)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, clear_fullscreen), "raver_flash"), 4)
	playsound(raver, pick('sound/gore/flesh_eat_01.ogg', 'sound/gore/flesh_eat_02.ogg', 'sound/gore/flesh_eat_03.ogg', 'sound/gore/flesh_eat_04.ogg', 'sound/gore/flesh_eat_05.ogg', 'sound/gore/flesh_eat_06.ogg'), 70, TRUE)
	if(prob(40))
		playsound(raver, pick('sound/combat/fracture/fracturewet (1).ogg', 'sound/combat/fracture/fracturewet (2).ogg', 'sound/combat/fracture/fracturewet (3).ogg', 'sound/foley/flesh_rem.ogg', 'sound/foley/gross.ogg', 'sound/surgery/organ1.ogg', 'sound/surgery/organ2.ogg'), 70, TRUE)
	new /obj/effect/temp_visual/dir_setting/bloodsplatter(get_turf(raver), pick(GLOB.cardinals))
	if(owner.client)
		for(var/i in 1 to 3)
			var/turf/start = get_turf(pick(range(3, owner)))
			var/d = pick(GLOB.cardinals)
			var/dx = 0
			var/dy = 0
			if(d == EAST)
				dx = 32
			else if(d == WEST)
				dx = -32
			else if(d == NORTH)
				dy = 32
			else
				dy = -32
			var/image/bug = image('modular_twilight_axis/icons/zizo_cult/roguetown/cult/ravermeat.dmi', start, pick("bloodling_stage_1", "bloodling_stage_2"), ABOVE_MOB_LAYER)
			bug.dir = d
			owner.client.images += bug
			animate(bug, pixel_x = dx, pixel_y = dy, time = 3 SECONDS)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clear_curse_eye), owner.client, bug), 3 SECONDS)
	if(owner.client && prob(50))
		var/image/eye = image('modular_twilight_axis/icons/zizo_cult/effects/eldritch.dmi', pick(range(3, owner)), "eye_open", ABOVE_ALL_MOB_LAYER)
		owner.client.images += eye
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clear_curse_eye), owner.client, eye), 3 SECONDS)
	if(prob(15))
		owner.emote(pick("scream", "pain"))
		to_chat(owner, span_userdanger(pick("THEY'RE CRAWLING ON ME...", "IT'S WRIGGLING INTO MY SKIN...", "THE BARBS SINK INTO MY FLESH...")))
	elapsed += 3
	if(elapsed >= 60 && !graft)
		raver_finish_corruption(owner, raver)
		qdel(src)

/proc/raver_finish_corruption(mob/living/carbon/human/H, obj/structure/raver/R)
	if(QDELETED(H) || is_zizo(H))
		return
	if(!QDELETED(R))
		R.unbuckle_mob(H, force = TRUE)
	if(!absorb_lux(H, get_turf(H), FALSE))
		return
	if(!QDELETED(R))
		R.material += 2
		R.visible_message(span_danger("[R] drinks [H]'s lux and swells!"))
		playsound(R, 'sound/combat/gib (1).ogg', 80, TRUE)

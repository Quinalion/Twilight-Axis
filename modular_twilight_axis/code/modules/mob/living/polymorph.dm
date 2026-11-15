/mob/living/carbon/human/proc/randomize_human_appearance(randomise_flags = ALL, include_donator = TRUE)
	if(!dna)
		return

	if(randomise_flags & RANDOMIZE_SPECIES)
		var/rando_race = GLOB.species_list[pick(get_selectable_species(include_donator))]
		set_species(new rando_race(), FALSE)

	var/datum/species/species = dna.species

	if(NOEYESPRITES in species?.species_traits)
		randomise_flags &= ~RANDOMIZE_EYE_COLOR

	if(randomise_flags & RANDOMIZE_GENDER)
		gender = species.sexes ? pick(MALE, FEMALE) : PLURAL

	if(randomise_flags & RANDOMIZE_AGE)
		age = pick(species.possible_ages)

	if(randomise_flags & RANDOMIZE_NAME)
		real_name = species.random_name(gender, TRUE)

	if(randomise_flags & RANDOMIZE_SKIN_TONE)
		var/list/skin_list = species.get_skin_list()
		skin_tone = pick_assoc(skin_list)

	if(randomise_flags & RANDOMIZE_EYE_COLOR)
		var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
		eyes.eye_color = random_eye_color()

/mob/living/proc/set_eyes_closed(closed)
	if(eyesclosed == closed)
		return

	eyesclosed = closed

	if(eyesclosed)
		become_blind("eyelids")
	else
		cure_blind("eyelids")

	if(hud_used)
		var/atom/movable/screen/eye_intent/eyet = locate() in hud_used.static_inventory
		eyet.update_icon(UPDATE_ICON)

/mob/living/proc/wabbajack(what_to_randomize, change_flags = WABBAJACK)
	if(stat == DEAD || (status_flags & GODMODE))
		return

	if(SEND_SIGNAL(src, COMSIG_LIVING_PRE_WABBAJACKED, what_to_randomize) & STOP_WABBAJACK)
		return

	ADD_TRAIT(src,TRAIT_HANDS_BLOCKED, TRAIT_GENERIC)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_ABSTRACT

	var/list/item_contents = list()

	for(var/obj/item/item in src)
		if(!dropItemToGround(item))
			qdel(item)
			continue
		item_contents += item

	var/mob/living/new_mob

	var/static/list/possible_results = list(
		WABBAJACK_HUMAN,
		WABBAJACK_ANIMAL,
	)

	what_to_randomize ||= pick(possible_results)

	switch(what_to_randomize)

		if(WABBAJACK_ANIMAL)
			var/picked_animal = pick(
				/mob/living/simple_animal/hostile/retaliate/bat,
				/mob/living/simple_animal/hostile/retaliate/rogue/chicken,
				/mob/living/simple_animal/hostile/retaliate/rogue/cow,
				/mob/living/simple_animal/hostile/retaliate/rogue/goat,
				/mob/living/simple_animal/hostile/retaliate/rogue/spider,
				/mob/living/simple_animal/pet/cat,
				/mob/living/simple_animal/hostile/retaliate/rogue/mudcrab/cabbit,
			)
			new_mob = new picked_animal(loc)

		if(WABBAJACK_HUMAN)
			var/mob/living/carbon/human/new_human = new(loc)

			if(prob(50))
				var/list/chooseable_races = list()
				for(var/datum/species/species_type as anything in subtypesof(/datum/species))
					if(initial(species_type.changesource_flags) & change_flags)
						chooseable_races += species_type

				if(length(chooseable_races))
					new_human.set_species(pick(chooseable_races))

			new_human.randomize_human_appearance(~RANDOMIZE_SPECIES)
			new_human.update_body()
			new_human.dna.update_dna_identity()
			new_mob = new_human

		else
			stack_trace("wabbajack() was called without an invalid randomization choice. ([what_to_randomize])")

	if(!new_mob)
		return

	to_chat(src, span_hypnophrase(span_big("Your form morphs into that of a [what_to_randomize]!")))

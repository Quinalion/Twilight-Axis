#define ZIZO_CULT_BLACKLISTED_ROLES list(\
		"Grand Duke",\
		"Marshal",\
		"Merchant",\
		"Bishop",\
		"Martyr",\
		"Hand",\
		"Steward",\
		"Knight Captain",\
		"Knight",\
		"Templar",\
		"Sergeant",\
		"Inquisitor",\
		"Absolver",\
		"Veteran",\
		"Bathmaster",\
		"Bandit",\
		"Guildmaster",\
		"Court Magician",\
		"Keeper",\
		"Orthodoxist",\
		"Druid",\
		"Acolyte",\
		"Man at Arms",\
		"Squire",\
		"Prince",\
		"Wretch",\
	)

/datum/round_event_control/antagonist/solo/zizo_cult
	name = "Zizo cult"
	tags = list(
		TAG_COMBAT,
		TAG_HAUNTED,
		TAG_VILLIAN,
	)
	roundstart = TRUE
	antag_flag = ROLE_CULT
	antag_datum = /datum/antagonist/zizocultist
	shared_occurence_type = SHARED_HIGH_THREAT

	storyteller_antag_flags = STORYTELLER_ANTAG_VILLAIN | STORYTELLER_ANTAG_ROUNDSTART

	base_antags = 1
	maximum_antags = 5
	denominator = 40
	weight = 2
	max_occurrences = 1
	earliest_start = 0 SECONDS
	typepath = /datum/round_event/antagonist/solo/zizo_cult
	restricted_roles = ZIZO_CULT_BLACKLISTED_ROLES

/datum/round_event/antagonist/solo/zizo_cult/add_datum_to_mind(datum/mind/antag_mind)
	// TA EDIT START
	antag_mind.add_antag_datum(/datum/antagonist/zizocultist/roundstart)
	// TA EDIT END

#undef ZIZO_CULT_BLACKLISTED_ROLES

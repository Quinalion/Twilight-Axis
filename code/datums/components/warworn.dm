/datum/component/warworn
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/quiet_until
	var/next_memory = 0
	var/pending_memory
	var/memory_expires = 0

/datum/component/warworn/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	quiet_until = world.time + 1 MINUTES

/datum/component/warworn/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_LIFE, PROC_REF(onLife))
	RegisterSignal(parent, COMSIG_CARBON_SOUNDBANG, PROC_REF(onSoundbang))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMGE, PROC_REF(onDamage))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_WARWORN),
		PROC_REF(onTraitRemoved))

/datum/component/warworn/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_HUMAN_LIFE,
		COMSIG_CARBON_SOUNDBANG,
		COMSIG_MOB_APPLY_DAMGE,
		SIGNAL_REMOVETRAIT(TRAIT_WARWORN),
	))
	return ..()

/datum/component/warworn/proc/onTraitRemoved(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/warworn/proc/onSoundbang(
	mob/living/carbon/human/source, list/intensity)
	SIGNAL_HANDLER
	if(!source.can_hear() || intensity[1] <= 0)
		return
	rememberLater("thunder")

/datum/component/warworn/proc/onDamage(datum/source, damage)
	SIGNAL_HANDLER
	if(damage > 0)
		rememberLater("aftermath")

/datum/component/warworn/proc/rememberLater(memory)
	pending_memory = memory
	memory_expires = world.time + 5 MINUTES
	quiet_until = world.time + 1 MINUTES

/datum/component/warworn/proc/onLife(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_WARWORN))
		qdel(src)
		return
	if(world.time >= memory_expires)
		pending_memory = null
	if(!source.client || source.stat != CONSCIOUS || source.cmode \
		|| source.is_in_combat() || source.incapacitated())
		quiet_until = world.time + 1 MINUTES
		return
	// Delay recollections so they cannot interrupt a fight.
	if(world.time < quiet_until || world.time < next_memory)
		return
	if(!pending_memory && !source.resting)
		return
	var/memory = pending_memory
	if(!memory)
		memory = "watch"
	to_chat(source, span_notice("<b>An old campaign:</b> \
		[getMemoryText(source, memory)]"))
	pending_memory = null
	next_memory = world.time + rand(3 MINUTES, 5 MINUTES)

/datum/component/warworn/proc/getMemoryText(
	mob/living/carbon/human/source, memory)
	var/static/list/reminders = list(
		"thunder" = "The noise has passed. I remember another volley.",
		"aftermath" = "An old field dressing comes to mind.",
		"watch" = "At rest, I find myself remembering the old watch.",
	)
	var/numb = HAS_TRAIT(source, TRAIT_NOMOOD)
	var/detached = HAS_TRAIT(source, TRAIT_DETACHED)
	var/fractured = HAS_TRAIT(source, TRAIT_PSYCHOSIS)
	var/recollection
	if(numb && detached && fractured)
		recollection = pick(
			"The names will not stay in order. I count them without grief.",
			"My memories have no faces now. Only numbers, plainly kept.",
			"Even the old whispers sound like a muster. I feel nothing.",
		)
	else if(numb && detached)
		recollection = pick(
			"I remember the tally of the dead, but not how grief felt.",
			"Each missing name is a fact. I have no tears left to give.",
			"I learned to bind a wound as others learn to mend a sleeve.",
		)
	else if(fractured)
		recollection = pick(
			"Faces and names belong to different years in my memory.",
			"I remember a command in a voice that was buried long ago.",
			"The same remembered march ends in a different field each time.",
		)
	else
		recollection = pick(
			"I remember waiting for a name that was never called.",
			"Wet wool, powder smoke, a letter left unfinished.",
			"I can still recall the weight of a comrade's empty coat.",
		)
	if(numb && !detached)
		recollection += " The memory brings no swell of feeling."
	else if(detached && !numb)
		recollection += " Nothing of it reaches my face."
	return "[reminders[memory]] [recollection]"

/datum/ritual/transmutation
	abstract_type = /datum/ritual/transmutation
	book_category = "Transmutation"

/datum/ritual/transmutation/allseeingeye
	name = "Create Scrying Eye"
	description = "Transform a pair of eyes into a scrying eye for remote observation."
	outputs = list(/obj/item/scrying/eye)
	center_requirement = /obj/item/organ/eyes
	success_message = "The eye opens upon a place beyond my sight."

/datum/ritual/transmutation/book
	name = "Create Ritual Tome"
	description = "Replace a book with a cult ritual tome listing rituals and their requirements."
	outputs = list(/obj/item/recipe_book/zizo)
	center_requirement = /obj/item/book/rogue
	success_message = "Her forbidden work takes root upon the page."

/datum/ritual/transmutation/criminalstool
	name = "Create Cleansing Soap"
	description = "Create soap for cleaning blood, stains and sigils."
	outputs = list(/obj/item/soap/cult)
	center_requirement = /obj/item/natural/cloth
	success_message = "The blood may be washed away. The work remains."

/datum/ritual/transmutation/invademind
	name = "Send Telepathic Message"
	description = "Send a message to a person by their exact name. Consume a sheet of paper only if the recipient is found."
	center_requirement = /obj/item/paper
	var/message
	var/mob/living/carbon/human/recipient

/datum/ritual/transmutation/invademind/prepare(mob/living/user, turf/center)
	message = tgui_input_text(user, "What will you whisper into the dark?", "Telepathic Message", max_length = MAX_MESSAGE_LEN)
	if(!message)
		return FALSE
	var/recipient_name = tgui_input_text(user, "Enter the recipient's exact name.", "Telepathic Message", max_length = MAX_NAME_LEN)
	for(var/mob/living/carbon/human/target in GLOB.human_list)
		if(target.real_name == recipient_name)
			recipient = target
			return TRUE
	to_chat(user, span_warning("No soul answers to that name."))
	return FALSE

/datum/ritual/transmutation/invademind/validate(mob/living/user, turf/center)
	return !recipient || (!QDELETED(recipient) && (recipient in GLOB.human_list))

/datum/ritual/transmutation/invademind/invoke(mob/living/user, turf/center)
	if(!recipient)
		return FALSE
	to_chat(recipient, span_notice("A voice threads through my thoughts: [html_encode(message)]"))
	log_telepathy("[key_name(user)] sent a ritual message to [key_name(recipient)]: [message]")
	return TRUE

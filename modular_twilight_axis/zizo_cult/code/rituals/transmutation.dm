/datum/ritual/transmutation
	abstract_type = /datum/ritual/transmutation
	book_category = "Transmutation"

/datum/ritual/transmutation/allseeingeye
	outputs = list(/obj/item/scrying/eye)
	success_message = "The All-seeing Eye. To see beyond sight."
	name = "Create Scrying Eye"
	description = "Transform a pair of eyes into a scrying eye for remote observation."
	center_requirement = /obj/item/organ/eyes

/datum/ritual/transmutation/book
	outputs = list(/obj/item/recipe_book/zizo)
	success_message = "Now you know how to make another ritual..."
	name = "Create Ritual Tome"
	description = "Replace a book with a cult ritual tome listing rituals and their requirements."
	center_requirement = /obj/item/book/rogue

/datum/ritual/transmutation/criminalstool
	outputs = list(/obj/item/soap/cult)
	success_message = "The Criminal's Tool. Could be useful for hiding tracks or getting rid of sigils."
	name = "Create Cleansing Soap"
	description = "Create soap for cleaning blood, stains and sigils."
	center_requirement = /obj/item/natural/cloth

/datum/ritual/transmutation/invademind
	name = "Send Telepathic Message"
	description = "Send a message to a person by their exact name. Consumes a sheet of paper."
	center_requirement = /obj/item/paper

/datum/ritual/transmutation/invademind
	var/message
	var/recipient

/datum/ritual/transmutation/invademind/prepare(mob/living/user, turf/center)
	message = tgui_input_text(user, "Enter the message.", "Telepathic Message")
	if(!message)
		return FALSE
	recipient = tgui_input_text(user, "Enter the recipient's exact name.", "Telepathic Message")
	return !!recipient

/datum/ritual/transmutation/invademind/invoke(mob/living/user, turf/center)
	for(var/mob/living/carbon/human/target in GLOB.human_list)
		if(target.real_name == recipient)
			to_chat(target, span_notice("You hear a voice in your head: [html_encode(message)]"))

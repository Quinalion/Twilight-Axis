/datum/ritual/transmutation
	abstract_type = /datum/ritual/transmutation
	book_category = "Transmutation"

/datum/ritual/transmutation/allseeingeye
	name = "Create Scrying Eye"
	desk = "Transform a pair of eyes into a scrying eye for remote observation."
	center_requirement = /obj/item/organ/eyes

/datum/ritual/transmutation/allseeingeye/invoke(mob/living/user, turf/center)
	. = ..()
	new /obj/item/scrying/eye(center)
	to_chat(user, span_notice("The All-seeing Eye. To see beyond sight."))

/datum/ritual/transmutation/book
	name = "Create Ritual Tome"
	desk = "Replace a book with a cult ritual tome listing rituals and their requirements."
	center_requirement = /obj/item/book/rogue

/datum/ritual/transmutation/book/invoke(mob/living/user, turf/center)
	. = ..()

	new /obj/item/recipe_book/zizo(center)

	to_chat(user, span_notice("Now you know how to make another ritual..."))

/datum/ritual/transmutation/criminalstool
	name = "Create Cleansing Soap"
	desk = "Create soap for cleaning blood, stains and sigils."
	center_requirement = /obj/item/natural/cloth

/datum/ritual/transmutation/criminalstool/invoke(mob/living/user, turf/center)
	new /obj/item/soap/cult(center)
	to_chat(user, span_notice("The Criminal's Tool. Could be useful for hiding tracks or getting rid of sigils."))

/datum/ritual/transmutation/invademind
	name = "Send Telepathic Message"
	desk = "Send a message to a person by their exact name. Consumes a sheet of paper."
	center_requirement = /obj/item/paper

/datum/ritual/transmutation/invademind/invoke(mob/living/user, turf/center)
	var/text = tgui_input_text(user, "ENTER MESSAGE", "MESSAGE")

	if(!text)
		return

	var/input = input(user, "To whom do we send this message?", "ZIZO")
	if(!input)
		return
	for(var/mob/living/carbon/human/HL in GLOB.human_list)
		if(HL.real_name == input)
			to_chat(HL, "<i>You hear a voice in your head... <b>[text]</i></b>")

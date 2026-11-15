/mob/living/carbon/human/proc/communicate()
	set name = "Communicate with Cult"
	set category = "ZIZO"

	if(stat >= UNCONSCIOUS || !can_speak_vocal())
		return

	var/mob/living/carbon/human/H = src
	var/speak = input("What do you speak of?", "ZIZO") as text|null
	if(!speak)
		return
	whisper("O schlet'a ty'schkotot ty'skvoro...")
	sleep(5)
	if(stat >= UNCONSCIOUS || !can_speak_vocal())
		return
	whisper("[speak]")

	for(var/datum/mind/V in SSmapping.retainer.cultists)
		to_chat(V, "<span style = \"font-size:110%; font-weight:bold\"><span style = 'color:#8a13bd'>A message from </span><span style = 'color:#[H.voice_color]'>[src.real_name]</span>: [speak]</span>")
		playsound_local(V.current, 'modular_twilight_axis/sound/zizo_cult/local/skvor.ogg',100)

	log_telepathy("[key_name(src)] used cultist telepathy to say: [speak]")

/mob/living/carbon/human/proc/cultist_number()
	set name = "Number of Cultists"
	set category = "ZIZO"

	if(stat >= UNCONSCIOUS || !can_speak_vocal())
		return

	var/mob/living/carbon/human/H = src

	to_chat(H, "Number of cultists: [SSmapping.retainer.cultist_number]")

/mob/living/carbon/human/proc/ascension_check()
	set name = "Ascension Check"
	set category = "ZIZO"

	if(stat >= UNCONSCIOUS || !can_speak_vocal())
		return

	var/mob/living/carbon/human/H = src

	var/required_cultists = SSmapping.retainer.get_cult_ascension_required_cultists()

	var/sacrifice_info = "the Crown"
	var/target_role = "Crown"

	if(SSticker.rulermob && istype(SSticker.rulermob, /mob/living/carbon/human))
		var/mob/living/carbon/human/ruler = SSticker.rulermob
		if(ruler.stat != DEAD)
			if(ruler.gender == "male")
				sacrifice_info = "[ruler.real_name] (Grand Duke)"
				target_role = "Grand Duke"
			else
				sacrifice_info = "[ruler.real_name] (Grand Duchess)"
				target_role = "Grand Duchess"

	if(target_role == "Crown")
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.stat == DEAD)
				continue
			var/role_title
			if(HL.mind && HL.mind.assigned_role)
				if(istext(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role
				else if(istype(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Bishop")
				sacrifice_info = "[HL.real_name] (Bishop)"
				target_role = "Bishop"
				break

	if(target_role == "Crown")
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.stat == DEAD)
				continue
			var/role_title
			if(HL.mind && HL.mind.assigned_role)
				if(istext(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role
				else if(istype(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Hand")
				sacrifice_info = "[HL.real_name] (Hand)"
				target_role = "Hand"
				break

	if(target_role == "Crown")
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.stat == DEAD)
				continue
			var/role_title
			if(HL.mind && HL.mind.assigned_role)
				if(istext(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role
				else if(istype(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Prince" || role_title == "Princess")
				sacrifice_info = "[HL.real_name] ([role_title])"
				target_role = role_title
				break

	if(target_role == "Crown")
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.stat == DEAD)
				continue
			var/role_title
			if(HL.mind && HL.mind.assigned_role)
				if(istext(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role
				else if(istype(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Marshal")
				sacrifice_info = "[HL.real_name] (Marshal)"
				target_role = "Marshal"
				break

	if(target_role == "Crown")
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.stat == DEAD)
				continue
			var/role_title
			if(HL.mind && HL.mind.assigned_role)
				if(istext(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role
				else if(istype(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Court Magician")
				sacrifice_info = "[HL.real_name] (Court Magician)"
				target_role = "Court Magician"
				break

	if(target_role == "Crown")
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.stat == DEAD)
				continue
			var/role_title
			if(HL.mind && HL.mind.assigned_role)
				if(istext(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role
				else if(istype(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Knight Captain")
				sacrifice_info = "[HL.real_name] (Knight Captain)"
				target_role = "Knight Captain"
				break

	if(target_role == "Crown")
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.stat == DEAD)
				continue
			var/role_title
			if(HL.mind && HL.mind.assigned_role)
				if(istext(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role
				else if(istype(HL.mind.assigned_role))
					role_title = HL.mind.assigned_role.title
				else
					role_title = null
			else
				role_title = null
			if(role_title == "Steward")
				sacrifice_info = "[HL.real_name] (Steward)"
				target_role = "Steward"
				break

	to_chat(H, "To ascend, you need to sacrifice [sacrifice_info] and have at least [required_cultists] cultists.")

/mob/living/carbon/human/proc/release_minion()
	set name = "Release Lackey"
	set category = "ZIZO"

	var/list/mob/living/carbon/human/possible = list()
	for(var/datum/mind/V in SSmapping.retainer.cultists)
		if(V.special_role == "Zizoid Lackey")
			possible |= V.current

	var/mob/living/carbon/human/choice = input(src, "Whom do you no longer have use for?", "TWILIGHT AXIS") as null|anything in possible
	if(choice)
		var/alert = alert(src, "Are you sure?", "TWILIGHT AXIS", "Yes", "Cancel")
		if(alert == "Yes")
			visible_message(span_danger("[src] reaches out, ripping up [choice]'s soul!</span>"))
			to_chat(choice, span_danger("I HAVE FAILED MY LEADER! I HAVE FAILED ZIZO! NOTHING ELSE BUT DEATH REMAINS FOR ME NOW!"))
			sleep(20)
			choice.gib()
			SSmapping.retainer.cultists -= choice.mind
			SSmapping.retainer.cultist_number -= 1

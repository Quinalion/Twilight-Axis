#define LIST_PRAISE_ZIZO list("Praise Zizo!", "Hail Zizo!", "Glory to the Pale Lady!", "ZIZO! ZIZO! ZIZO!")

/mob/living/carbon/human/proc/praise()
	set name = "Praise the Dark Lady!"
	set category = "ZIZO"

	if(stat >= UNCONSCIOUS || !can_speak_vocal())
		return
	say(pick(LIST_PRAISE_ZIZO), spans = list("god_zizo"), sanitize = FALSE, language = /datum/language/undead)
	playsound(src, 'modular_twilight_axis/sound/zizo_cult/vo/cult/praise.ogg', 45, 1)
	log_say("[src] has praised zizo! (zizo cultist verb)")
	if(istype(get_area(src), /area/rogue/indoors/town/church))
		complete_zgoal(src, /datum/zizogoal/worshipzizo_church)
	if(istype(get_area(src), /area/rogue/indoors/town/garrison))
		complete_zgoal(src, /datum/zizogoal/worshipzizo_garrison)
	if(istype(get_area(src), /area/rogue/indoors/town/warden))
		complete_zgoal(src, /datum/zizogoal/worshipzizo_warden)
	var/observers = 0
	for(var/mob/living/carbon/human/L in hearers(7, src))
		if(L != src && L.stat != DEAD && L.mind && !is_zizo(L))
			observers++
	if(observers > 2)
		complete_zgoal(src, /datum/zizogoal/worshipzizo)

/mob/living/carbon/human/proc/zizo_objectives()
	set name = "Secret Objectives"
	set category = "ZIZO"

	if(!length(zizo_goals))
		reroll_goals(src)
	for(var/datum/zizogoal/gl in zizo_goals)
		if(gl.complete)
			to_chat(src, "<B>[gl.name]:</B> [gl.desc]<BR><B>COMPLETED.</B><BR>")
		else
			to_chat(src, "<B>[gl.name]:</B> [gl.desc]<BR><B>[gl.reward] SECRETS.</B><BR>")

/mob/living/carbon/human/proc/zizo_targets_list()
	set name = "Secrets"
	set category = "ZIZO"

	var/list/lines = list("<B>ANYONE CAN BE SACRIFICED OR CONVERTED</B>, except fellow cultists + bandits & wretches. The ruler may ONLY be sacrificed during the final ascension ritual.")
	if(length(GLOB.gate_targets))
		lines += "<B>GATE TARGETS:</B>"
		for(var/mob/living/carbon/human/T in GLOB.gate_targets)
			lines += "- [T.real_name] ([T.mind?.assigned_role])"
		for(var/atype in GLOB.zizo_bestow_areas)
			var/area/A = atype
			lines += "GATE RITE LOCATION: [initial(A.name)]"
	lines += "<B>GUIDE:</B> Place the sacrifice in the center of a servantry sigil. Sacrifice requires a fellow cultist holding a knife & standing upon the sigil. Conversion requires a fellow cultist on the sigil, if there is more than 3 members in the cult. Gate targets have a dark eye above them. Use heartaches to seek them."
	to_chat(src, jointext(lines, "<BR>"))

/mob/living/carbon/human/proc/communicate()
	set name = "Communicate with Cult"
	set category = "ZIZO"

	if(stat >= UNCONSCIOUS || !can_speak_vocal())
		return

	var/speak = input("What do you speak of?", "ZIZO") as text|null
	if(!speak)
		return
	whisper("O schlet'a ty'schkotot ty'skvoro...")
	sleep(5)
	if(stat >= UNCONSCIOUS || !can_speak_vocal())
		return
	whisper("[speak]")

	for(var/datum/mind/V in SSmapping.retainer.cultists)
		to_chat(V, "<span style = \"font-size:110%; font-weight:bold\"><span style = 'color:#8a13bd'>A message from </span><span style = 'color:#[voice_color]'>[real_name]</span>: [speak]</span>")
		playsound_local(V.current, 'modular_twilight_axis/sound/zizo_cult/vo/cult/skvor.ogg', 100)

	log_say("[key_name(src)] used cultist telepathy to say: [speak]")

#undef LIST_PRAISE_ZIZO

/mob/living/carbon/human/proc/zizo_lore()
	set name = "Research"
	set category = "ZIZO"
	GLOB.zizo_research.ui_interact(src)

// TA EDIT - Cultist character setup
GLOBAL_LIST_EMPTY(zizo_setups)

/datum/zizo_setup
	var/mob/living/carbon/human/user
	var/datum/mind/cult_mind
	var/list/stats = list()
	var/list/defaults = list()
	var/chosen_trait
	var/budget = 20
	var/static/list/stat_keys = list(STATKEY_STR, STATKEY_PER, STATKEY_INT, STATKEY_CON, STATKEY_WIL, STATKEY_SPD)

/datum/zizo_setup/New(mob/living/carbon/human/H, points = 20)
	user = H
	cult_mind = H.mind
	budget = points
	var/waited = 0
	while(!QDELETED(H) && !H.advjob)
		sleep(1 SECONDS)
		waited += 1 SECONDS
		if(QDELETED(H) || waited > 120 SECONDS)
			qdel(src)
			return
	if(QDELETED(H) || !H.mind || !is_zizo(H))
		qdel(src)
		return
	for(var/key in stat_keys)
		stats[key] = H.get_stat_level(key)
		for(var/datum/status_effect/S in H.status_effects)
			stats[key] -= S.effectedstats[key]
		defaults[key] = stats[key]
		if(H.statpack && !islist(H.statpack.stat_array[key]))
			budget += H.statpack.stat_array[key] * statweight(key)
	GLOB.zizo_setups += src
	open_menu()

/datum/zizo_setup/proc/statweight(key)
	if(key == STATKEY_STR || key == STATKEY_SPD)
		return 2
	return 1

/datum/zizo_setup/proc/statspent()
	. = 0
	for(var/key in stat_keys)
		. += (stats[key] - 10) * statweight(key)

/datum/zizo_setup/proc/open_menu()
	var/contents = "Points remaining: [budget - statspent()]</center><BR>"
	contents += "--------------<BR>"
	for(var/key in stat_keys)
		contents += "<b>[capitalize(key)]</b> ([statweight(key)]x): [stats[key]] "
		contents += "<a href='?src=[REF(src)];raise=[key]'>\[+\]</a> "
		contents += "<a href='?src=[REF(src)];lower=[key]'>\[-\]</a><BR>"
	contents += "--------------<BR>"
	contents += "<b>Choose a trait:</b><BR>"
	contents += "<a href='?src=[REF(src)];trait=dodge'>Dodge Expert</a><BR>"
	contents += "<a href='?src=[REF(src)];trait=heavy'>Critical Resistance</a><BR>"
	contents += "Chosen: [chosen_trait]<BR>"
	contents += "--------------<BR>"
	contents += "<center><a href='?src=[REF(src)];confirm=1'>\[CONFIRM\]</a></center>"
	var/datum/browser/popup = new(user, "antagsetup", "Take Up Arms", 300, 420)
	popup.set_content(contents)
	popup.open(FALSE)

/datum/zizo_setup/Topic(href, href_list)
	if(usr != user || QDELETED(user) || user.mind != cult_mind || cult_mind?.current != user || !is_zizo(user) || user.incapacitated())
		return
	if(href_list["raise"])
		var/key = href_list["raise"]
		if((key in stat_keys) && stats[key] < 20 && (budget - statspent()) >= statweight(key))
			stats[key] += 1
		open_menu()
	if(href_list["lower"])
		var/key = href_list["lower"]
		if((key in stat_keys) && stats[key] > defaults[key])
			stats[key] -= 1
		open_menu()
	if(href_list["trait"])
		if(href_list["trait"] == "dodge")
			chosen_trait = TRAIT_DODGEEXPERT
		if(href_list["trait"] == "heavy")
			chosen_trait = TRAIT_CRITICAL_RESISTANCE
		open_menu()
	if(href_list["confirm"])
		if(!chosen_trait || statspent() > budget)
			to_chat(user, span_warning("Choose a trait."))
			return
		var/list/applied = list()
		for(var/key in stat_keys)
			var/diff = stats[key] - defaults[key]
			if(diff)
				user.change_stat(key, diff)
				applied[key] = diff
		ADD_TRAIT(user, chosen_trait, "zizo_setup")
		user.mind?.zizo_setup_stats = applied
		user.mind?.zizo_setup_trait = chosen_trait
		GLOB.zizo_setups -= src
		user << browse(null, "window=antagsetup")
		qdel(src)


/datum/zizo_setup/Destroy()
	GLOB.zizo_setups -= src
	user = null
	return ..()

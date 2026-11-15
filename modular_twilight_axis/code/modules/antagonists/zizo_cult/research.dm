/proc/ritual_available(mob/living/carbon/human/user, datum/ritual/ritual)
	if(!user?.mind || initial(ritual.abstract_type) == ritual)
		return FALSE
	if(initial(ritual.needs_aspect) && !(initial(ritual.needs_aspect) in GLOB.zizo_bestowed))
		return FALSE
	if(!(ritual in user.mind.zizo_researched))
		return FALSE
	if((initial(ritual.is_cultist_ritual) || !initial(ritual.lesser)) && !is_zizo(user))
		return FALSE
	if(ritual.passive == TRUE)
		return FALSE
	return TRUE

/proc/zizo_award(mob/M, amt)
	if(!ishuman(M) || !M.mind)
		return
	var/mob/living/carbon/human/H = M
	H.mind.zizo_points += amt
	to_chat(M, span_boldnotice("SECRETS UNVEILED. (+[amt])"))


/datum/zizo_research/ui_status(mob/living/carbon/human/user)
	if(!ishuman(user) || !user.mind || !istype(user.patron, /datum/patron/inhumen/zizo))
		return UI_CLOSE
	return ..()

/datum/zizo_research/ui_state(mob/user)
	return GLOB.always_state

/datum/zizo_research/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ZizoResearch", "ZIZO", 700, 600)
		ui.open()

/datum/zizo_research/ui_data(mob/user)
	var/list/data = list("points" = user.mind.zizo_points)
	var/list/nodes = list()
	for(var/ritualtype in GLOB.zizo_researchable)
		var/datum/ritual/R = ritualtype
		if((R.is_cultist_ritual || !R.lesser) && !is_zizo(user))
			continue
		var/obj/item/needed = initial(R.research_item)
		var/list/node = list("path" = ritualtype, "name" = initial(R.name), "desc" = R.desc, "cost" = initial(R.research_cost), "aspect" = R.needs_aspect, "lesser" = R.lesser)
		if(ispath(R.icon_type, /datum/action))
			var/datum/action/shown_action = R.icon_type
			node["icon"] = shown_action.button_icon
			node["state"] = shown_action.button_icon_state
		else if(ispath(R.icon_type, /obj/effect/proc_holder/spell))
			var/obj/effect/proc_holder/spell/shown_spell = R.icon_type
			node["icon"] = shown_spell.overlay_icon
			node["state"] = shown_spell.overlay_state
		else
			var/atom/shown = R.icon_type
			node["icon"] = shown.icon
			node["state"] = shown.icon_state
		if(R.node_state)
			node["state"] = R.node_state
		node["done"] = (ritualtype in user.mind.zizo_researched)
		node["disabled"] = (R.needs_aspect && !(R.needs_aspect in GLOB.zizo_bestowed))
		if(needed)
			node["item"] = uppertext(initial(needed.name))
		nodes += list(node)
	data["knowledge"] = nodes
	return data

/datum/zizo_research/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/user = usr
	if(action != "research" || !ishuman(user) || !user.mind || user.incapacitated() || !istype(user.patron, /datum/patron/inhumen/zizo))
		return
	var/ritualtype = text2path(params["path"])
	if(!ritualtype || (ritualtype in user.mind.zizo_researched) || !(ritualtype in GLOB.zizo_researchable))
		return
	var/datum/ritual/R = new ritualtype
	if((R.is_cultist_ritual || !R.lesser) && !is_zizo(user))
		qdel(R)
		return
	if(R.needs_aspect && !(R.needs_aspect in GLOB.zizo_bestowed))
		qdel(R)
		return
	if(user.mind.zizo_points < initial(R.research_cost))
		to_chat(user, span_warning("NOT ENOUGH SECRETS."))
		qdel(R)
		return
	var/obj/item/needed = R.research_item
	if(needed)
		var/obj/item/held = locate(needed) in user.held_items
		if(!held)
			to_chat(user, span_warning("I MUST HOLD A [uppertext(initial(needed.name))] TO DISCOVER THIS."))
			qdel(R)
			return
		qdel(held)
	user.mind.zizo_points -= initial(R.research_cost)
	user.mind.zizo_researched |= ritualtype
	for(var/spell in R.spells)
		if(!user.mind.has_spell(spell))
			user.mind.AddSpell(new spell)
	if(R.passive)
		R.apply_passive(user)
	to_chat(user, span_boldnotice("EUREKA! I DISCOVER [uppertext(R.name)]!"))
	qdel(R)
	return TRUE

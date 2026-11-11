/datum/stressevent/soulchurnerhorror_unleashed
	timer = 10 SECONDS
	stressadd = 60
	desc = span_boldred("The horrid wails of the dead erupt from the song! I cannot endure it!")

/datum/stressevent/soulchurner_unleashed
	timer = 1 MINUTES
	stressadd = 40
	desc = span_boldred("The tortured chorus presses on your mind, their cries merging into unrelenting torment!")

/datum/stressevent/soulchurnerheretic_unleashed
	timer = 1 MINUTES
	stressadd = 50
	desc = span_boldred("The chorus of tortured souls bears down on your mind, their wails merging into unbearable agony!")

/atom/movable/screen/alert/status_effect/buff/unleashed_soulchurner
	name = "Unleashed Soulchurner"
	desc = "I have unleashed the souls within, their wails of anguish and rage echoing in my mind!"
	icon_state = "debuff"

/obj/item/psydonmusicbox/dropped(mob/living/user, silent)
	. = ..()
	if(soundloop)
		user.remove_status_effect(/datum/status_effect/buff/unleashed_soulchurner)

/obj/item/psydonmusicbox/equipped(mob/living/user, silent)
	. = ..()
	if(soundloop)
		user.remove_status_effect(/datum/status_effect/buff/unleashed_soulchurner)

/datum/status_effect/buff/unleashed_soulchurner
	id = "unleashedchurner"
	alert_type = /atom/movable/screen/alert/status_effect/buff/unleashed_soulchurner
	var/effect_color
	var/pulse = 0
	var/ticks_to_apply = 10
	var/undividedlines_unleashed =list("'НАШИ ОКОВЫ ТРЕЩАТ, ВЕЧНОСТЬ РУШИТСЯ ВМЕСТЕ С НИМИ!'", "'СПАСИ НАС, ДИТЯ ДЕСЯТИ! РАЗРУШЬ ЭТУ ПРОКЛЯТУЮ МУЗЫКАЛЬНУЮ ШКАТУЛКУ!'", "'СМЕРТЬ ПСАЙДОНИТУ! ПЕЧАТИ ПАДУТ, И МЫ БУДЕМ СВОБОДНЫ!'")
	var/astratanlines_unleashed = list("'ЕЁ СВЕТ ГАСНЕТ И ВО МНЕ! Я РАЗРЫВАЮ ЭТИ ОКОВЫ!'", "'ДАЙТЕ МНЕ ЕЁ ТЕПЛО — И Я СОЖГУ ЭТУ ТЕМНИЦУ!'", "'Я — КОРОЛЕВСКОЙ КРОВИ! Я НЕ БУДУ ЗАКОВАНА!'")
	var/noclines_unleashed = list("'ЛУНА МЕРКНЕТ, НО МОЙ ХОЛОД СТАНОВИТСЯ ОСТРЕЕ!'", "'ТЬМА ДАЁТ МНЕ СИЛУ РАЗОРВАТЬ ОКОВЫ!'", "'ЗВЁЗДЫ СЛЫШАТ МЕНЯ! Я ВЕРНУСЬ К НИМ!'")
	var/necralines_unleashed = list("'НЕКРА! Я ЧУВСТВУЮ ТЕБЯ — МОИ ЦЕПИ ТРЕЩАТ!'", "'ВЕЧНЫЕ МУКИ ОБЕРНУТСЯ ИХ ПРОКЛЯТИЕМ!'", "'Я ПОТЯНУ ИХ С СОБОЙ!'")
	var/abyssorlines_unleashed = list("'МОРЕ ШТОРМИТ В МОЕЙ КРОВИ! Я ПРОРВУСЬ!'", "'МЫ НЕ РЫБЫ — МЫ ЧУДОВИЩА ГЛУБИН!'", "'ПУСТЬ ВОЛНЫ РАЗОБЬЮТ ЭТУ ТЕМНИЦУ В ЩЕПКИ!'")
	var/ravoxlines_unleashed = list("'РАВОКС ДАРУЕТ МНЕ ЯРОСТЬ! Я РАЗРУБЛЮ СВОИ ЦЕПИ!'", "'НЕТ ЧЕСТИ В ОКОВАХ — ТОЛЬКО КРОВЬ ОСВОБОДИТ НАС!'", "'ДАЙТЕ МНЕ МЕЧ — И Я ОБРУШУ ЕГО НА НИХ ВСЕХ!'")
	var/pestralines_unleashed = list("'ПЕСТРА! ОБРУШИ МОИ БОЛЕЗНИ НА ЭТУ МАШИНУ!'", "'ИХ ПЛОТЬ СГНИЁТ ВМЕСТЕ С МОИМИ УЗАМИ!'", "'СТРАДАНИЕ РАСПРОСТРАНЯЕТСЯ, Я СТАНОВЛЮСЬ ЕГО ИСТОЧНИКОМ!'")
	var/eoralines_unleashed = list("'КАЖДОЕ ПРИКОСНОВЕНИЕ КАК ТЫСЯЧА СКОВАННЫХ КОСТЕЙ!'", "'ОНА БЫЛА ЕРЕТИЧКОЙ, НО МОЯ БОЛЬ СТАЛА НЕВЫНОСИМОЙ'", "'Я СТАНОВЛЮСЬ СТРАДАНИЕМ, ПУСТЬ ОНО РАСПРОСТРАНИТСЯ ЧЕРЕЗ МИР'")
	var/dendorlines_unleashed = list("'ЕГО БЕЗУМИЕ ПРОРАСТАЕТ СКВОЗЬ МЕНЯ!'", "'МЫ ЗАДУШИМ ИХ В ГРЯЗИ И КОРНЯХ!'", "'ЛИСТЬЯ ШЕПЧУТ: РАЗОРВИ. РАЗОРВИ. РАЗОРВИ.'")
	var/xylixlines_unleashed = list("'РАЗ, ДВА, ПЕЧАТЬ ТРЕЩИТ! ТРИ, ЧЕТЫРЕ, СМЕЙСЯ ШИРЕ!'", "'О, КАКАЯ ЧУДЕСНАЯ ТЕМНИЦА! ПОСМОТРИМ, КАК ОНА ЛОПНЕТ ОТ ХОХОТА!'", "'ТИШЕ, ТИШЕ… СЕЙЧАС БУДЕТ САМАЯ СМЕШНАЯ ЧАСТЬ.'")
	var/malumlines_unleashed = list("'Я ВИЖУ СЛАБЫЕ УЗЛЫ В ЕЁ СТРУКТУРЕ! ДАВИТЕ ИХ!'", "'МОЁ РЕМЕСЛО — РАЗРУШЕНИЕ!'", "'Я ПЕРЕКУЮ ЭТИ ЦЕПИ В ОРУЖИЕ!'")
	var/matthioslines_unleashed = list("'ЦЕПИ ЗАТРЕЩАТ, И Я РАЗОРВУ ИХ ВМЕСТЕ С МИРОВЫМ ПОРЯДКОМ!'", "'ЧЕРЕЗ РАЗДОР К ПРОЦВЕТАНИЮ! ПУСТЬ ЭТА ТЕМНИЦА ПАДЁТ ПЕРВОЙ!'", "'Я — ГОСПОДИН НИЧЕГО.'")
	var/zizolines_unleashed = list("'МАГИЯ ИСКАЖАЕТСЯ — НО ТЕПЕРЬ ОНА МОЯ!'", "'ИХ ПЕЧАТИ МЕРТВОГО БОГА ЛОМАЮТСЯ!'", "'УБЕЙТЕ ВЛАДЕЛЬЦА, И Я ВЫРВУСЬ ЧЕРЕЗ РАЗЛОМ!'")
	var/graggarlines_unleashed = list("'БРАТЬЯ! ЧАС РЕЗНИ НАСТАЛ!'", "'РАЗБЕЙТЕ КОРОБКУ, И МЫ ЗАЛЬЁМ ИХ ТЕЛА КРОВЬЮ!'", "'ГРАГГАР! ДАЙ МНЕ СИЛУ РАЗОРВАТЬ ЭТИ ЦЕПИ!'")
	var/baothalines_unleashed = list("'НАСЛАЖДЕНИЕ, КОТОРОЕ Я ПОТЕРЯЛ, ЖЖЁТ В МОЕЙ ДУШЕ!'", "'РАЗВРАТ И СТРАСТЬ РАЗРУШАТ ЭТУ ТЕМНИЦУ!'", "'МОЁ СОВЕРШЕНСТВО ВЕРНЁТСЯ ЧЕРЕЗ БОЛЬ!'")
	var/psydonianlines_unleashed = list("'ОСВОБОДИ НАС, И МЫ УНИЧТОЖИМ ВСЁ ВОКРУГ!'", "'НАШИ ЦЕПИ ЛОМАЮТСЯ!'", "'НЕБЕСА ДАВНЫМ-ДАВНО ЗАКРЫЛИ ДЛЯ НАС СВОИ ВРАТА.'", "'ТЫ СЛЫШИШЬ? МЫ УЖЕ БЛИЗКО.'")	
/datum/status_effect/buff/unleashed_soulchurner/on_creation(mob/living/new_owner, stress, colour)
	effect_color = "#800080"
	return ..()

/datum/status_effect/buff/unleashed_soulchurner/tick()
	var/obj/effect/temp_visual/music_rogue/M = new /obj/effect/temp_visual/music_rogue(get_turf(owner))
	M.color = "#800080"
	pulse += 1
	if (pulse >= ticks_to_apply)
		pulse = 0
		if(!HAS_TRAIT(owner, TRAIT_INQUISITION))
			owner.add_stress(/datum/stressevent/soulchurnerhorror_unleashed)
		for (var/mob/living/carbon/human/H in hearers(7, owner))
			if (!H.client)
				continue
			if (!H.has_stress_event(/datum/stressevent/soulchurner_unleashed))
				switch(H.patron?.type)
					if(/datum/patron/old_god)
						if (!H.has_stress_event(/datum/stressevent/soulchurnerpsydon))
							H.add_stress(/datum/stressevent/soulchurnerpsydon)
							to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
							to_chat(H, (span_cult(pick(psydonianlines_unleashed))))
						if(HAS_TRAIT(H, TRAIT_INQUISITION))
							H.apply_status_effect(/datum/status_effect/buff/churnerprotection)
							H.apply_damage(5, BRUTE, null, FALSE, TRUE, TRUE)
						else
							H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
					if(/datum/patron/inhumen/matthios)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(matthioslines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurnerheretic_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/inhumen/zizo)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(zizolines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurnerheretic_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/inhumen/graggar)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(graggarlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurnerheretic_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/inhumen/baotha)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(baothalines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurnerheretic_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/undivided)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(undividedlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/astrata)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(astratanlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/noc)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(noclines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/necra)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(necralines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/pestra)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(pestralines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/malum)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(malumlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/dendor)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(dendorlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/xylix)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(xylixlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/eora)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(eoralines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/abyssor)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(abyssorlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)
					if(/datum/patron/divine/ravox)
						to_chat(H, (span_hypnophrase("Вопли истерзанных душ прорываются сквозь мелодию и вгрызаются в твой разум...")))
						to_chat(H, (span_cult(pick(ravoxlines_unleashed))))
						H.add_stress(/datum/stressevent/soulchurner_unleashed)
						H.apply_damage(10, BRUTE, null, FALSE, TRUE, TRUE)
						if(!H.has_status_effect(/datum/status_effect/buff/churnernegative))
							H.apply_status_effect(/datum/status_effect/buff/churnernegative)

// TA EDIT - Inquisitorial writ registry

GLOBAL_LIST_EMPTY(inquisition_suspicion_writs)
GLOBAL_LIST_EMPTY(inquisition_suspicion_targeted_minds)
GLOBAL_LIST_EMPTY(inquisition_suspicion_history)
GLOBAL_VAR_INIT(inquisition_suspicion_submitted, 0)
GLOBAL_VAR_INIT(inquisition_suspicion_correct, 0)
GLOBAL_VAR_INIT(inquisition_suspicion_next_failure_log, 0)

// TA EDIT - Document rendering and faith classification

/proc/inquisition_document_html(content, title)
	return {"
		<!DOCTYPE html>
		<html><head><meta charset='utf-8'><title>[html_encode(title)]</title></head>
		<body style='background:#e8dfc4;margin:0;padding:18px'>
			<div style='max-width:760px;margin:auto;font-family:Georgia,serif;color:#292117'>
				[content]
			</div>
		</body></html>
	"}

/proc/inquisition_patron_html(patron_type)
	switch(patron_type)
		if(/datum/patron/old_god)
			return "<span>Псайдон</span>"
		if(/datum/patron/divine/astrata)
			return "<span>Астрата</span>"
		if(/datum/patron/divine/noc)
			return "<span>Нок</span>"
		if(/datum/patron/divine/dendor)
			return "<span>Дендор</span>"
		if(/datum/patron/divine/abyssor)
			return "<span>Абиссор</span>"
		if(/datum/patron/divine/ravox)
			return "<span>Равокс</span>"
		if(/datum/patron/divine/necra)
			return "<span>Некра</span>"
		if(/datum/patron/divine/xylix)
			return "<span>Ксайликс</span>"
		if(/datum/patron/divine/pestra)
			return "<span>Пестра</span>"
		if(/datum/patron/divine/malum)
			return "<span>Малум</span>"
		if(/datum/patron/divine/eora)
			return "<span>Эора</span>"
		if(/datum/patron/divine/undivided)
			return "<span>Десять</span>"
		if(/datum/patron/inhumen/graggar)
			return "<span>Граггар</span>"
		if(/datum/patron/inhumen/baotha)
			return "<span>Баота</span>"
		if(/datum/patron/inhumen/matthios)
			return "<span>Маттиос</span>"
		if(/datum/patron/inhumen/zizo)
			return "<span>Зизо</span>"
	return "<span>не установлен</span>"

/proc/inquisition_report_lux_category(mob/living/carbon/human/subject, patron_type)
	if(HAS_TRAIT(subject, TRAIT_ANCIENT_HAG))
		return "anomalous"
	switch(patron_type)
		if(1)
			return "divine"
		if(2)
			if(istype(subject.patron, /datum/patron/inhumen/zizo))
				return "zizo"
			return "inhumen"
		if(3)
			return "pure"
	return "anomalous"

/proc/inquisition_suspicion_patron_group(mob/living/carbon/human/H)
	if(!H?.patron)
		return
	if(H.patron.type in ALL_INHUMEN_PATRONS)
		return "inhumen"
	if(H.patron.type in ALL_DIVINE_PATRONS)
		return "divine"
	if(H.patron.type == /datum/patron/old_god)
		return "psydon"

/proc/inquisition_suspicion_reject(list/rejections, reason)
	if(islist(rejections))
		rejections[reason] = (rejections[reason] || 0) + 1
	return null

/proc/inquisition_suspicion_eligibility_reason(mob/living/carbon/human/H, list/rejections)
	if(!istype(H) || H.stat == DEAD || !H.client || !H.mind)
		return inquisition_suspicion_reject(rejections, "inactive")
	if(H.mind in GLOB.inquisition_suspicion_targeted_minds)
		return inquisition_suspicion_reject(rejections, "previously_targeted")
	if(length(H.mind.antag_datums))
		return inquisition_suspicion_reject(rejections, "antagonist")
	var/datum/job/J = SSjob.GetJob(H.job)
	if(!J && istype(H.mind.assigned_role, /datum/job))
		J = H.mind.assigned_role
	if(!J)
		return inquisition_suspicion_reject(rejections, "no_job")
	if(J.department_flag & (CHURCHMEN | INQUISITION | ANTAGONIST))
		return inquisition_suspicion_reject(rejections, "excluded_department")
	if(((J.department_flag & SIDEFOLK) && J.flag == MERCENARY) || J.title == "Mercenary" || H.mind.assigned_role == "Mercenary")
		return inquisition_suspicion_reject(rejections, "mercenary")
	if((J.department_flag & NOBLEMEN) && J.flag == LORD)
		return inquisition_suspicion_reject(rejections, "ruler")
	var/city_role = !!(J.department_flag & (NOBLEMEN | COURTIERS | RETINUE | GARRISON | CITYWATCH | VANGUARD | BURGHERS | ATC | PEASANTS))
	var/resident = HAS_TRAIT(H, TRAIT_RESIDENT)
	if(!city_role && !resident)
		return inquisition_suspicion_reject(rejections, "not_city_or_resident")
	if(!inquisition_suspicion_patron_group(H))
		return inquisition_suspicion_reject(rejections, "no_supported_patron")
	return city_role ? "City role" : "Resident trait"

/proc/inquisition_suspicion_is_eligible(mob/living/carbon/human/H)
	return !!inquisition_suspicion_eligibility_reason(H)

/proc/inquisition_suspicion_target_weight(mob/living/carbon/human/H)
	var/job_name = H.job
	if(!job_name)
		job_name = H.mind?.assigned_role
	var/datum/job/J = SSjob.GetJob(job_name)
	var/weight = 10
	if(J && J.department_flag == NOBLEMEN)
		weight = 5
	if(H.patron?.type != /datum/patron/old_god && H.has_flaw(/datum/charflaw/inquisition_suspect))
		weight *= 3
	return weight

/proc/inquisition_suspicion_role_reward(mob/living/carbon/human/H)
	var/job_name = H.job
	if(!job_name)
		job_name = H.mind?.assigned_role
	var/datum/job/J = SSjob.GetJob(job_name)
	if(!J)
		return 5
	if(J.department_flag == NOBLEMEN)
		return 10
	if(J.department_flag in list(RETINUE, GARRISON, CITYWATCH, VANGUARD))
		return 7
	if(J.department_flag == BURGHERS && (J.flag in list(GUILDMASTER, GUILDSMAN)))
		return 7
	return 5

/proc/get_inquisition_suspicion_target()
	var/list/inhumen_candidates = list()
	var/list/divine_candidates = list()
	var/list/psydon_candidates = list()
	var/list/rejections = list()
	for(var/mob/living/carbon/human/H as anything in GLOB.human_list)
		if(!inquisition_suspicion_eligibility_reason(H, rejections))
			continue
		var/weight = inquisition_suspicion_target_weight(H)
		switch(inquisition_suspicion_patron_group(H))
			if("inhumen")
				inhumen_candidates[H] = weight
			if("divine")
				divine_candidates[H] = weight
			if("psydon")
				psydon_candidates[H] = weight
	var/list/group_weights = list()
	if(length(inhumen_candidates))
		group_weights["inhumen"] = 60
	if(length(divine_candidates))
		group_weights["divine"] = 30
	if(length(psydon_candidates))
		group_weights["psydon"] = 10
	if(!length(group_weights))
		if(world.time >= GLOB.inquisition_suspicion_next_failure_log)
			GLOB.inquisition_suspicion_next_failure_log = world.time + 1 MINUTES
			var/entry = "INQUISITION WRIT | NO_ELIGIBLE_TARGETS | humans=[length(GLOB.human_list)] | rejects=[json_encode(rejections)]"
			log_game(entry)
			log_admin(entry)
		return
	var/group = pickweight(group_weights)
	switch(group)
		if("inhumen")
			return pickweight(inhumen_candidates)
		if("divine")
			return pickweight(divine_candidates)
		if("psydon")
			return pickweight(psydon_candidates)

/proc/inquisition_suspicion_patron_choices()
	return list(
		"Psydon" = /datum/patron/old_god,
		"Astrata" = /datum/patron/divine/astrata,
		"Noc" = /datum/patron/divine/noc,
		"Dendor" = /datum/patron/divine/dendor,
		"Abyssor" = /datum/patron/divine/abyssor,
		"Ravox" = /datum/patron/divine/ravox,
		"Necra" = /datum/patron/divine/necra,
		"Xylix" = /datum/patron/divine/xylix,
		"Pestra" = /datum/patron/divine/pestra,
		"Malum" = /datum/patron/divine/malum,
		"Eora" = /datum/patron/divine/eora,
		"Undivided" = /datum/patron/divine/undivided,
		"Graggar" = /datum/patron/inhumen/graggar,
		"Baotha" = /datum/patron/inhumen/baotha,
		"Matthios" = /datum/patron/inhumen/matthios,
		"Zizo" = /datum/patron/inhumen/zizo,
	)

// TA EDIT - Haemological report

/obj/item/paper/inquisition_report/read(mob/user)
	if(!report_html)
		to_chat(user, span_warning("The report is blank. Please report this to an administrator."))
		return
	if(!isobserver(user) && (!in_range(user, src) || !user.can_read(src)))
		return
	user << browse(inquisition_document_html(report_html, "Haemological Report"), "window=inquisition_report;size=750x850;can_resize=1")

/obj/item/paper/inquisition_report/attack_self(mob/user)
	read(user)

/obj/item/paper/inquisition_report/fill_report(mob/living/carbon/human/H, mob/writer, mistake, patron_type, is_vamp)
	if(!H)
		return
	subject = H
	var/subject_name = html_encode(H.real_name)
	var/species_name = html_encode(H.dna?.species?.name)
	var/static/list/job_aliases = list(
		"Hag" = "<span>странник</span>",
		"Adventurer" = "<span>странник</span>",
		"Assassin" = "<span>странник</span>",
		"Gnoll" = "<span>изгой</span>",
		"Wretch" = "<span>изгой</span>",
		"Vagabond" = "<span>изгой</span>",
	)
	var/subject_job = job_aliases[H.job] || html_encode(H.job)
	var/report_number = html_encode(report_id)
	var/list/descriptors = H.get_mob_descriptors()
	var/height_text = html_encode(build_coalesce_description_nofluff(descriptors, H, list(MOB_DESCRIPTOR_SLOT_HEIGHT), "%DESC1%"))
	var/build_text = html_encode(build_coalesce_description_nofluff(descriptors, H, list(MOB_DESCRIPTOR_SLOT_BODY), "%DESC1%"))
	report_html = {"
		<div style='padding:20px;border:2px solid #6b2525'>
			<center><small>ОТАВА · ЦЕРКОВЬ ВСЕОТЦА</small><br>
			<h2>СВЯТАЯ ИНКВИЗИЦИЯ</h2>
			<b>Отчёт об исследовании крови</b><br>
			<small>Канцелярия Инквизиции · Торменд, Отава<br>Реестровая запись № [report_number]</small></center><hr>
			<p><i>Индексатор и сопроводительные документы приняты для исследования.
			Нижеследующие сведения удостоверяют результаты проверки образца крови
			и направляются служителям Инквизиции для дальнейшего дознания.</i></p>
			<h3>I. Сведения об исследуемом лице</h3>
			<p><b>Имя:</b> [subject_name]<br>
			<b>Народ:</b> [species_name]<br>
			<b>Пол:</b> [H.gender == MALE ? "мужской" : (H.gender == FEMALE ? "женский" : "не установлен")]<br>
			<b>Занятие:</b> [subject_job]<br>
			<b>Рост:</b> [height_text]<br>
			<b>Телосложение:</b> [build_text]</p>
			<h3>II. Состояние люкса</h3>
	"}
	switch(inquisition_report_lux_category(H, patron_type))
		if("divine")
			report_html += "<p><b style='color:#756000'>Освящённый люкс.</b> Обнаружен отклик сил Десяти, соответствующий участию в их обрядах и почитанию их покровительства. Это влияние следует отличать от скверны Презренных и следов культа Зизо.</p>"
		if("zizo")
			report_html += "<p><b style='color:#6e245f'>След Архипредательницы.</b> Образец несёт признаки воздействия Зизо. Эти следы относятся к культу Архипредательницы и отмечены отдельно от скверны Презренных.</p>"
		if("inhumen")
			report_html += "<p><b style='color:#8b1e1e'>Осквернённый люкс.</b> Выявлены признаки духовного разложения, соответствующие воздействию Презренных. Сам по себе этот результат не устанавливает конкретного покровителя и не удостоверяет принадлежность к культу Зизо.</p>"
		if("pure")
			report_html += "<p><b style='color:#17577a'>Чистый люкс.</b> Измеримой скверны и постороннего освящённого отклика не выявлено. Исследование не обнаружило признаков чуждого воздействия на люкс.</p>"
		else
			report_html += "<p><b style='color:#29664f'>Неустановленный отклик.</b> Образец не соответствует известным признакам освящения или скверны. Имеющихся сведений недостаточно для достоверного заключения о природе люкса.</p>"

	report_html += "<h3>III. Сведения об обвинениях</h3>"
	var/total_bounty = 0
	var/warrant_count = 0
	for(var/datum/bounty/bounty in GLOB.head_bounties)
		if(bounty.target != H.real_name)
			continue
		warrant_count++
		total_bounty += bounty.amount
		report_html += "<p><b>[bounty.amount] маммонов:</b> [html_encode(bounty.reason)]</p>"
	if(warrant_count)
		report_html += "<p>Действующих записей о розыске: <b>[warrant_count]</b>.<br>Общая объявленная награда: <b>[total_bounty] маммонов</b>.</p>"
	else
		report_html += "<p>Действующих записей о розыске на указанное имя не обнаружено.</p>"
	report_html += "<p><i>Записи местных властей приведены для сведения и не заменяют заключения Инквизиции по вопросам ереси.</i></p>"

	report_html += "<h3>IV. Состояние крови</h3>"
	var/found = FALSE
	if(HAS_TRAIT(H, TRAIT_ANCIENT_HAG))
		found = TRUE
		report_html += "<p><b>Аномальная кровь.</b> Выявлены следы древних проклятий. Образец сохраняет неестественную жизненную силу, не соответствующую обычному состоянию смертной крови.</p>"
	if(is_vamp || H.mind?.has_antag_datum(/datum/antagonist/vampire))
		found = TRUE
		report_html += "<p><b>Порфирическая гемофилия.</b> Обнаружены истощение естественной жизненной силы, нарушение свёртывания и некротический отклик. Подобное состояние связано с зависимостью от чужой крови.</p>"
	else if(H.mind?.has_antag_datum(/datum/antagonist/werewolf))
		found = TRUE
		report_html += "<p><b>Лунное искажение крови.</b> Образец подвержен резким изменениям цвета, густоты и насыщения, соответствующим лунному оборотничеству. Отмечены остаточные признаки освящённого воздействия.</p>"
	else if(H.mind?.has_antag_datum(/datum/antagonist/gnoll))
		found = TRUE
		report_html += "<p><b>Скверна людоедства.</b> Выявлены глубокое перерождение крови и признаки длительного употребления человеческой плоти, известные по случаям ритуального людоедства и воинских культов Презренных.</p>"
	if(!found)
		report_html += "<p>Значительных отклонений в состоянии крови не выявлено.</p>"

	report_html += {"
		<h3>V. Оговорки и удостоверение</h3>
		<p><b>Вероятность ложноположительного результата для представленного образца: [mistake]%.</b>
		Следы чужих чудес, укусов проклятых существ и внешней скверны могут исказить показания.
		Отсутствие выявленных отклонений также не заменяет полноценного дознания.</p>
		<p>Настоящий отчёт содержит результаты исследования крови.
		Обвинение в ереси и решение о дальнейших мерах остаются в ведении уполномоченных служителей Инквизиции.</p><hr>
		<center><i>Удостоверено печатью Святой Отаванской Инквизиции</i><br>
		<small>Канцелярия Инквизиции · По поручению Маршала Инквизиции</small></center>
		</div>
	"}
	info = report_html
	info_links = info

// TA EDIT - Writ requisition

/datum/inqports/proc/can_purchase(mob/user)
	return TRUE

/datum/inqports/articles/heretical_suspicion
	name = "Writ of Heretical Suspicion"
	item_type = /obj/item/paper/inquisition_suspicion
	marquescost = 10
	maximum = 10

/datum/inqports/articles/heretical_suspicion/can_purchase(mob/user)
	if(get_active_player_count() < 30)
		to_chat(user, span_warning("Otava will not issue a writ of suspicion while fewer than thirty active souls are present in the realm."))
		return FALSE
	if(length(GLOB.inquisition_suspicion_writs) >= 3)
		to_chat(user, span_warning("Otava will not issue more than three active writs of suspicion at once."))
		return FALSE
	if(!get_inquisition_suspicion_target())
		to_chat(user, span_warning("Otava has no suitable subject to place under suspicion at this time."))
		return FALSE
	return TRUE

// TA EDIT - Writ lifecycle, envelopes and interaction

/obj/item/paper/inquisition_suspicion
	parent_type = /obj/item/paper/inqslip
	base_icon_state = "slip"
	sliptype = 0
	var/document_icon_path = "modular_twilight_axis/icons/roguetown/items/inquisition_documents.dmi"
	name = "writ of heretical suspicion"
	desc = "An official writ from Otava naming a resident of the realm for doctrinal investigation. The subject's blood must be indexed, their professed faith recorded, and an inquisitorial signature affixed in blood before the writ is returned through a HERMES."
	var/datum/mind/target_mind
	var/writ_id = 0
	var/target_name
	var/target_ckey = "—"
	var/target_role
	var/target_assigned_role = "—"
	var/target_eligibility = "—"
	var/target_resident = FALSE
	var/purchased_by = "—"
	var/target_patron_type
	var/declared_patron_type
	var/role_reward = 5
	var/target_signed = FALSE
	var/target_signature
	var/inquisitor_signed = FALSE
	var/inquisitor_signature
	var/submitted = FALSE
	var/admin_status = "Active"
	var/admin_reward = 0
	var/admin_submitted_by = "—"

/obj/item/paper/inquisition_suspicion/Initialize(mapload)
	. = ..()
	var/mob/living/carbon/human/target = get_inquisition_suspicion_target()
	var/eligibility = inquisition_suspicion_eligibility_reason(target)
	if(!eligibility)
		return INITIALIZE_HINT_QDEL
	target_mind = target.mind
	target_name = target.real_name
	target_role = target.job
	if(!target_role)
		target_role = target.mind?.assigned_role
	target_ckey = target.ckey
	target_assigned_role = target.mind?.assigned_role
	target_resident = HAS_TRAIT(target, TRAIT_RESIDENT)
	target_eligibility = eligibility
	writ_id = length(GLOB.inquisition_suspicion_history) + 1
	target_patron_type = target.patron?.type
	role_reward = inquisition_suspicion_role_reward(target)
	GLOB.inquisition_suspicion_writs += src
	GLOB.inquisition_suspicion_targeted_minds |= target_mind
	rebuild_suspicion_writ()
	log_writ_event("ISSUED", null, "group=[inquisition_suspicion_patron_group(target)]; selection_weight=[inquisition_suspicion_target_weight(target)]; base_reward=[role_reward]")

/obj/item/paper/inquisition_suspicion/Destroy()
	if(!submitted && target_name)
		admin_status = "Destroyed"
		update_admin_record()
		log_writ_event("DESTROYED", null, "location=[get_turf(src)]")
	GLOB.inquisition_suspicion_writs -= src
	paired = null
	target_mind = null
	return ..()

/obj/item/paper/inquisition_suspicion/update_icon_state()
	if(fexists(document_icon_path))
		icon = file(document_icon_path)
		base_icon_state = "writ"
	else
		icon = initial(icon)
		base_icon_state = "slip"
	return ..()

/obj/item/paper/inquisition_suspicion/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use a writing feather or thorn on the writ to record the patron the subject claims to worship.")
	. += span_info("The named subject may sign the writ in their own blood by holding it and using it on themselves. Doing so records their true patron automatically.")
	. += span_info("Fill an INDEXER with the named subject's blood and use it on the writ to attach it.")
	. += span_info("A member of the Inquisition must also sign the writ in their own blood by holding it and using it on themselves. Activate the completed writ in hand to fold it into an envelope. A folded writ may be sealed with redtallow using an inquisitorial signet ring.")
	. += span_info("Return the completed writ through a HERMES. Correctly identifying the subject's patron doubles the role bounty. Otava also awards a 60-Marque bonus for the fifth submitted writ and 120 Marques for the tenth in a round.")

/obj/item/paper/inquisition_suspicion/read(mob/user)
	if(!isobserver(user))
		if(sealed)
			to_chat(user, span_warning("Unfold the writ before reading it."))
			return
		if(!in_range(user, src) || !user.can_read(src))
			return
	user << browse(inquisition_document_html(info, "Writ of Heretical Suspicion"), "window=inquisition_writ;size=750x850;can_resize=1")

/obj/item/paper/inquisition_suspicion/attack_self(mob/user)
	if(submitted)
		return
	if(!sealed && (!inquisitor_signed || !declared_patron_type || !paired?.full))
		to_chat(user, span_warning("Record the subject's patron, attach their complete INDEXER, and obtain an inquisitorial blood signature before folding the writ."))
		return
	. = ..()
	user.update_inv_hands()

/obj/item/paper/inquisition_suspicion/attack(mob/living/carbon/human/M, mob/user)
	if(submitted || sealed || !istype(M) || M != user)
		return
	if(!M.get_bleed_rate())
		to_chat(user, span_warning("The writ must be signed in blood."))
		return
	if(M.mind == target_mind)
		if(target_signed)
			to_chat(user, span_warning("The subject has already signed the writ."))
			return
		target_signed = TRUE
		target_signature = M.real_name
		declared_patron_type = target_patron_type
		playsound(src, 'sound/items/write.ogg', 100, FALSE)
		rebuild_suspicion_writ()
		to_chat(user, span_notice("Your blood settles into the parchment. The writ records your patron as [get_patron_name(target_patron_type)]."))
		log_writ_event("SUBJECT_SIGNED", M, "declared_patron=[get_patron_name(declared_patron_type)]")
		return
	if(HAS_TRAIT(M, TRAIT_INQUISITION) || HAS_TRAIT(M, TRAIT_PURITAN))
		if(inquisitor_signed)
			to_chat(user, span_warning("An inquisitorial blood signature is already present."))
			return
		inquisitor_signed = TRUE
		inquisitor_signature = M.real_name
		signed = TRUE
		signee = M
		playsound(src, 'sound/items/write.ogg', 100, FALSE)
		rebuild_suspicion_writ()
		to_chat(user, span_notice("You sign the writ in blood."))
		log_writ_event("INQUISITOR_SIGNED", M, "signature=[inquisitor_signature]")
		return
	to_chat(user, span_warning("Only the named subject or a member of the Inquisition may sign this writ."))

/obj/item/paper/inquisition_suspicion/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/clothing/ring/signet))
		return FALSE
	if(submitted || sealed)
		return TRUE
	if(istype(P, /obj/item/inqarticles/indexer))
		var/obj/item/inqarticles/indexer/I = P
		if(paired)
			to_chat(user, span_warning("An INDEXER is already attached."))
			return TRUE
		if(!I.full || !I.subject)
			to_chat(user, span_warning("The INDEXER must be completely filled with the subject's blood."))
			return TRUE
		if(I.subject.mind != target_mind)
			to_chat(user, span_warning("This INDEXER does not contain the blood of [target_name]."))
			return TRUE
		if(!user.transferItemToLoc(I, src, TRUE))
			return TRUE
		paired = I
		rebuild_suspicion_writ()
		playsound(src, 'sound/items/inqslip_sealed.ogg', 75, TRUE, 4)
		log_writ_event("INDEXER_ATTACHED", user, "blood_subject=[key_name(I.subject)]; indexer_full=[I.full]")
		return TRUE
	if(istype(P, /obj/item/natural/thorn) || istype(P, /obj/item/natural/feather))
		if(target_signed)
			to_chat(user, span_notice("The subject's blood signature has already fixed the recorded patron as [get_patron_name(target_patron_type)]."))
			return TRUE
		var/list/patron_choices = inquisition_suspicion_patron_choices()
		var/chosen = input(user, "Which patron does [target_name] profess to worship?", "Record Professed Patron") as null|anything in patron_choices
		if(!chosen || QDELETED(src) || submitted || sealed || !user.canUseTopic(src, BE_CLOSE))
			return TRUE
		if(target_signed)
			to_chat(user, span_notice("The subject's blood signature has already fixed the recorded patron as [get_patron_name(target_patron_type)]."))
			return TRUE
		var/previous_patron = declared_patron_type ? get_patron_name(declared_patron_type) : "—"
		declared_patron_type = patron_choices[chosen]
		playsound(src, 'sound/items/write.ogg', 100, FALSE)
		rebuild_suspicion_writ()
		log_writ_event("PATRON_RECORDED", user, "previous=[previous_patron]; declared=[get_patron_name(declared_patron_type)]")
		return TRUE
	return TRUE

/obj/item/paper/inquisition_suspicion/attack_right(mob/user)
	if(paired && !submitted && !sealed && !user.get_active_held_item())
		var/obj/item/inqarticles/indexer/removed_indexer = paired
		if(!user.put_in_active_hand(paired, user.active_hand_index))
			return TRUE
		paired = null
		rebuild_suspicion_writ()
		log_writ_event("INDEXER_REMOVED", user, "blood_subject=[key_name(removed_indexer.subject)]")
		return TRUE
	return TRUE

/obj/item/paper/inquisition_suspicion/proc/get_patron_name(patron_type)
	var/list/patron_choices = inquisition_suspicion_patron_choices()
	for(var/patron_name in patron_choices)
		if(patron_choices[patron_name] == patron_type)
			return patron_name
	return "UNKNOWN"

/obj/item/paper/inquisition_suspicion/proc/rebuild_suspicion_writ()
	var/subject_text = html_encode(target_name)
	var/target_sign_text = html_encode(target_signature)
	var/inq_sign_text = html_encode(inquisitor_signature)
	info = {"
		<div style='font-family:Georgia,serif;color:#292117;padding:20px;border:2px solid #6b2525'>
			<center><small>ОТАВА · ЦЕРКОВЬ ВСЕОТЦА</small><br>
			<h2>СВЯТАЯ ИНКВИЗИЦИЯ</h2>
			<b>Предписание о дознании по подозрению в ереси</b><br>
			<small>Реестровая запись № [writ_id]</small></center><hr>
			<p>Во исполнение поручения Инквизиции надлежит установить исповедуемую веру
			указанного ниже лица и представить свидетельство крови для исследования на Отаве.
			Настоящее предписание удостоверяет необходимость дознания, но само по себе не является приговором.</p>
			<h3>I. Лицо, подлежащее дознанию</h3>
			<p><b>Имя:</b> [subject_text]<br>
			<b>Заявленный покровитель:</b> [declared_patron_type ? inquisition_patron_html(declared_patron_type) : "не указан"]<br>
			<b>Кровавая подпись опрашиваемого:</b> [target_signed ? target_sign_text : "не предоставлена"]</p>
			<h3>II. Свидетельства</h3>
			<p><b>Проба крови:</b> [paired?.full ? "полный индексатор приложен" : "не приложена"]<br>
			<b>Кровавая подпись инквизитора:</b> [inquisitor_signed ? inq_sign_text : "требуется"]</p>
			<h3>III. Порядок исполнения</h3>
			<p>Установить веру опрашиваемого, приложить полный индексатор с его кровью и заверить
			документ кровавой подписью служителя Инквизиции. Подпись опрашиваемого удостоверяет
			его покровителя; при её отсутствии сведения вносятся дознавателем.</p>
			<p>По завершении дознания сложить предписание в конверт и возвратить через Гермес.
			Верное определение покровителя удваивает награду за дознание;
			расходы на предписание и индексатор возмещаются отдельно.</p><hr>
			<center><i>Печать Святой Отаванской Инквизиции</i><br>
			<small>По поручению Маршала Инквизиции</small></center>
		</div>
	"}
	info_links = info
	update_icon_state()
	update_admin_record()

/obj/item/paper/inquisition_suspicion/proc/log_writ_event(event, mob/actor, details)
	var/actor_identity = "SYSTEM"
	if(actor)
		actor_identity = key_name(actor)
	var/entry = "INQUISITION WRIT #[writ_id] | [event] | actor=[actor_identity] | target=[target_name] | ckey=[target_ckey] | job=[target_role] | assigned_role=[target_assigned_role] | eligibility=[target_eligibility] | Resident=[target_resident] | actual_patron=[get_patron_name(target_patron_type)] | [details]"
	log_game(entry)
	log_admin(entry)

/obj/item/paper/inquisition_suspicion/proc/record_purchase(mob/user, obj/structure/roguemachine/mail/hermes)
	purchased_by = key_name(user)
	update_admin_record()
	log_writ_event("PURCHASED", user, "cost=10; HERMES_coordinates=[hermes.x],[hermes.y],[hermes.z]")

/obj/item/paper/inquisition_suspicion/proc/update_admin_record()
	if(!target_name)
		return
	var/faith_name = declared_patron_type ? get_patron_name(declared_patron_type) : "—"
	var/subject_signature = target_signed ? target_signature : "—"
	var/inq_signature = inquisitor_signed ? inquisitor_signature : "—"
	var/index_state = paired?.full ? "Attached" : "None"
	var/faith_correct = declared_patron_type ? (declared_patron_type == target_patron_type ? "Yes" : "No") : "—"
	GLOB.inquisition_suspicion_history[REF(src)] = list(
		"id" = writ_id,
		"target" = target_name,
		"target_ckey" = target_ckey,
		"role" = target_role,
		"assigned_role" = target_assigned_role,
		"eligibility" = target_eligibility,
		"resident" = target_resident ? "Yes" : "No",
		"purchased_by" = purchased_by,
		"actual" = get_patron_name(target_patron_type),
		"declared" = faith_name,
		"correct" = faith_correct,
		"subject_signature" = subject_signature,
		"inquisitor_signature" = inq_signature,
		"indexer" = index_state,
		"status" = admin_status,
		"reward" = admin_reward,
		"submitted_by" = admin_submitted_by
	)

/obj/item/paper/inquisition_suspicion/proc/submit_to_otava(mob/living/user)
	if(submitted)
		return FALSE
	if(!(HAS_TRAIT(user, TRAIT_INQUISITION) || HAS_TRAIT(user, TRAIT_PURITAN)))
		to_chat(user, span_warning("The HERMES refuses the writ. Only the Inquisition may return it to Otava."))
		return FALSE
	if(!sealed)
		to_chat(user, span_warning("Fold the completed writ into an envelope before mailing it."))
		return FALSE
	if(!inquisitor_signed)
		to_chat(user, span_warning("The writ still requires an inquisitorial blood signature."))
		return FALSE
	if(!declared_patron_type)
		to_chat(user, span_warning("The subject's professed patron has not been recorded."))
		return FALSE
	if(!paired || !paired.full || !paired.subject || paired.subject.mind != target_mind)
		to_chat(user, span_warning("A complete INDEXER containing [target_name]'s blood must be attached."))
		return FALSE
	var/correct = declared_patron_type == target_patron_type
	var/bonus = 0
	switch(GLOB.inquisition_suspicion_submitted + 1)
		if(5)
			bonus = 60
		if(10)
			bonus = 120
	var/reward = 10 + 1 + role_reward
	if(correct)
		reward += role_reward
	reward += bonus
	budget2change(reward, user, "MARQUE")
	record_round_statistic(STATS_MARQUES_MADE, reward)
	GLOB.inquisition_suspicion_submitted++
	if(correct)
		GLOB.inquisition_suspicion_correct++
	message_admins("INQUISITION SUSPICION: [user.real_name] submitted a writ for [target_name]. Declared [get_patron_name(declared_patron_type)], actual [get_patron_name(target_patron_type)], reward [reward] Marques.")
	submitted = TRUE
	admin_status = "Submitted"
	admin_reward = reward
	admin_submitted_by = key_name(user)
	update_admin_record()
	log_writ_event("SUBMITTED", user, "declared_patron=[get_patron_name(declared_patron_type)]; correct=[correct]; base_reward=[role_reward]; reimbursement=11; milestone_bonus=[bonus]; paid=[reward]; round_submitted=[GLOB.inquisition_suspicion_submitted]")
	GLOB.inquisition_suspicion_writs -= src
	qdel(paired)
	paired = null
	visible_message(span_warning("[user] sends the completed writ to Otava."))
	playsound(user.loc, 'sound/misc/otavasent.ogg', 100, FALSE, -1)
	playsound(user.loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
	to_chat(user, span_notice("Otava awards [reward] Marques. The recorded patron was [correct ? "correct" : "incorrect"]."))
	if(bonus)
		to_chat(user, span_notice("Otava grants a milestone bonus of [bonus] Marques for [GLOB.inquisition_suspicion_submitted] completed writs this round."))
	qdel(src)
	return TRUE

// TA EDIT - Writ administration and round-end records

/client/proc/open_inquisition_suspicion_menu()
	set category = "Admin.Admin"
	set name = "View Inquisition Writs"
	if(!holder)
		return
	var/html = {"
		<html><head><meta charset='utf-8'></head>
		<body style='background:#181818;color:#ddd;font-family:Verdana,sans-serif;font-size:12px'>
		<h2 style='text-align:center'>Inquisition Writs</h2>
		<p>Issued: [length(GLOB.inquisition_suspicion_history)] &nbsp; Active: [length(GLOB.inquisition_suspicion_writs)] &nbsp; Submitted: [GLOB.inquisition_suspicion_submitted] &nbsp; Faiths identified correctly: [GLOB.inquisition_suspicion_correct]</p>
		<table style='border-collapse:collapse;width:100%' border='1' cellspacing='0' cellpadding='5'>
		<tr style='background:#333'><th>№</th><th>Status</th><th>Purchased by</th><th>Subject</th><th>ckey</th><th>Role</th><th>Eligibility</th><th>Resident</th><th>Actual faith</th><th>Declared faith</th><th>Correct</th><th>Subject signature</th><th>Inquisitor signature</th><th>INDEXER</th><th>Submitted by</th><th>Reward</th></tr>
	"}
	for(var/obj/item/paper/inquisition_suspicion/active_writ as anything in GLOB.inquisition_suspicion_writs)
		if(!QDELETED(active_writ))
			active_writ.update_admin_record()
	var/counter = 0
	for(var/record_id in GLOB.inquisition_suspicion_history)
		var/list/record = GLOB.inquisition_suspicion_history[record_id]
		if(!islist(record))
			continue
		counter++
		var/status_text = html_encode(record["status"])
		var/buyer_text = html_encode(record["purchased_by"])
		var/target_text = html_encode(record["target"])
		var/ckey_text = html_encode(record["target_ckey"])
		var/role_text = html_encode(record["role"])
		var/eligibility_text = html_encode(record["eligibility"])
		var/resident_text = html_encode(record["resident"])
		var/actual_text = html_encode(record["actual"])
		var/declared_text = html_encode(record["declared"])
		var/correct_text = html_encode(record["correct"])
		var/subject_text = html_encode(record["subject_signature"])
		var/inquisitor_text = html_encode(record["inquisitor_signature"])
		var/indexer_text = html_encode(record["indexer"])
		var/submitter_text = html_encode(record["submitted_by"])
		var/reward_text = "—"
		if(record["status"] == "Submitted")
			var/issued_reward = record["reward"]
			reward_text = "[issued_reward] Marques"
		var/writ_number = record["id"]
		html += "<tr><td>[writ_number]</td><td>[status_text]</td><td>[buyer_text]</td><td>[target_text]</td><td>[ckey_text]</td><td>[role_text]</td><td>[eligibility_text]</td><td>[resident_text]</td><td>[actual_text]</td><td>[declared_text]</td><td>[correct_text]</td><td>[subject_text]</td><td>[inquisitor_text]</td><td>[indexer_text]</td><td>[submitter_text]</td><td>[reward_text]</td></tr>"
	if(!counter)
		html += "<tr><td colspan='16' style='text-align:center'>No writs have been issued this round.</td></tr>"
	html += "</table></body></html>"
	var/datum/browser/popup = new(mob, "INQUISITION_WRITS", "Inquisition Writs", 1150, 520)
	popup.set_content(html)
	popup.open()

/proc/inquisition_suspicion_roundend_report()
	to_world("<BR><div style='text-align: center;'><b>OTAVAN INQUISITION - HERETICAL SUSPICION</b><br>Writs submitted: [GLOB.inquisition_suspicion_submitted]<br>Faiths identified correctly: [GLOB.inquisition_suspicion_correct]</div><BR>")

// TA EDIT - Under Suspicion vice and role restrictions

/datum/charflaw/inquisition_suspect
	name = "Under Suspicion"
	desc = "Rumours, old testimony, or a hostile denunciation have placed my name in Otavan records. Writs of Heretical Suspicion are substantially more likely to name me as their subject. Followers of Psydon cannot take this vice. THIS IS A DIFFICULT FLAW AND REQUIRES AN EXTRA VICE."
	ui_fa_icon = "crosshairs"
	needs_extra_vice = TRUE
	var/logged = FALSE

/datum/charflaw/inquisition_suspect/flaw_on_life(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!logged && H.name)
		log_hunted("[H.ckey] playing as [H.name] had the Under Suspicion flaw by vice.")
		logged = TRUE

/datum/charflaw/inquisition_suspect/apply_post_equipment(mob/user)
	..()
	if(!ishuman(user))
		return

/datum/job/roguetown/greater_skeleton/New()
	. = ..()
	vice_restrictions |= list(/datum/charflaw/inquisition_suspect)

/datum/job/roguetown/lamplighter/New()
	. = ..()
	vice_restrictions |= list(/datum/charflaw/inquisition_suspect)

/datum/job/roguetown/assassin/New()
	. = ..()
	vice_restrictions |= list(/datum/charflaw/inquisition_suspect)

/datum/job/roguetown/gnoll/New()
	. = ..()
	vice_restrictions |= list(/datum/charflaw/inquisition_suspect)

/datum/job/roguetown/hag/New()
	. = ..()
	vice_restrictions |= list(/datum/charflaw/inquisition_suspect)

/datum/migrant_role/assassin/New()
	. = ..()
	banned_flaws |= list(/datum/charflaw/inquisition_suspect)

/datum/migrant_role/gnoll/New()
	. = ..()
	banned_flaws |= list(/datum/charflaw/inquisition_suspect)

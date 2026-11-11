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

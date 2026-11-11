/obj/item/paper/inquisition_suspicion/test_document/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	flags_1 |= INITIALIZED_1
	return INITIALIZE_HINT_NORMAL

/obj/item/paper/inquisition_suspicion/test_document/update_admin_record()
	return

/obj/item/paper/inquisition_suspicion/test_document/log_writ_event(event, mob/actor, details)
	return

/datum/unit_test/inquisition_documents/Run()
	var/mob/living/carbon/human/subject = allocate(/mob/living/carbon/human)
	subject.patron = GLOB.patronlist[/datum/patron/inhumen/zizo]
	TEST_ASSERT_NOTNULL(subject.patron, "Zizo must be registered")
	TEST_ASSERT_EQUAL(inquisition_report_lux_category(subject, 2), "zizo", "Zizo must be distinct from the Inhumen")
	subject.patron = GLOB.patronlist[/datum/patron/inhumen/baotha]
	TEST_ASSERT_EQUAL(inquisition_report_lux_category(subject, 2), "inhumen", "Other Inhumen patrons must retain their category")
	subject.patron = GLOB.patronlist[/datum/patron/old_god]
	TEST_ASSERT_EQUAL(inquisition_report_lux_category(subject, 3), "pure", "Psydonic samples must remain pure")
	TEST_ASSERT_EQUAL(inquisition_report_lux_category(subject, 2), "inhumen", "False positives must not reveal a Zizo affiliation")
	TEST_ASSERT_EQUAL(inquisition_report_lux_category(subject, 1), "divine", "Divine readings must retain their category")
	ADD_TRAIT(subject, TRAIT_ANCIENT_HAG, TRAIT_GENERIC)
	TEST_ASSERT_EQUAL(inquisition_report_lux_category(subject, 2), "anomalous", "Anomalous blood must retain priority")
	REMOVE_TRAIT(subject, TRAIT_ANCIENT_HAG, TRAIT_GENERIC)

	var/obj/item/paper/inquisition_report/report = allocate(/obj/item/paper/inquisition_report)
	subject.real_name = "<script>test</script>"
	report.report_id = "TEST"
	report.fill_report(subject, subject, 25, 3, FALSE)
	TEST_ASSERT(findtext(report.report_html, "&lt;script&gt;"), "Subject names must be escaped in the report")
	TEST_ASSERT(!findtext(report.report_html, subject.real_name), "Raw markup must not enter the report")
	TEST_ASSERT_EQUAL(report.info, report.report_html, "The paper content must match the generated report")

	var/obj/item/paper/inquisition_suspicion/test_document/writ = allocate(/obj/item/paper/inquisition_suspicion/test_document)
	TEST_ASSERT(istype(writ, /obj/item/paper/inqslip), "Writs must use the common inquisitorial envelope type")
	writ.document_icon_path = "missing-inquisition-test.dmi"
	writ.target_name = subject.real_name
	writ.rebuild_suspicion_writ()
	TEST_ASSERT(findtext(writ.info, "&lt;script&gt;"), "Subject names must be escaped in the writ")
	writ.attack_self(subject)
	TEST_ASSERT(!writ.sealed, "An incomplete writ must not fold")

	var/obj/item/inqarticles/indexer/indexer = allocate(/obj/item/inqarticles/indexer)
	indexer.full = TRUE
	writ.paired = indexer
	indexer.forceMove(writ)
	writ.inquisitor_signed = TRUE
	writ.signed = TRUE
	writ.declared_patron_type = /datum/patron/old_god
	writ.update_icon_state()
	TEST_ASSERT_EQUAL(writ.icon_state, "slip_indexer_signed", "Missing modular sprites must fall back to existing document states")
	writ.attack_self(subject)
	TEST_ASSERT(writ.sealed, "A completed writ must fold into an envelope")
	TEST_ASSERT_EQUAL(writ.icon_state, "slip_unsealed", "Folding must change the sprite")
	writ.attack_right(subject)
	TEST_ASSERT_EQUAL(writ.paired, indexer, "A folded envelope must retain its indexer")
	var/obj/item/inqarticles/indexer/other_indexer = allocate(/obj/item/inqarticles/indexer)
	writ.attackby(other_indexer, subject, null)
	TEST_ASSERT_EQUAL(writ.paired, indexer, "A folded envelope must reject indexer changes")
	writ.attack_self(subject)
	TEST_ASSERT(!writ.sealed, "An unwaxed envelope must unfold")
	writ.attack_self(subject)
	writ.waxed = TRUE
	writ.update_icon_state()
	TEST_ASSERT_EQUAL(writ.icon_state, "slip_sealed", "Wax sealing must change the sprite")
	writ.attack_self(subject)
	TEST_ASSERT(writ.sealed, "A wax-sealed envelope must stay closed")

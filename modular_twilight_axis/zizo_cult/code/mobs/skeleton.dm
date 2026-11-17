/mob/living/carbon/human/proc/become_cult_skeleton(datum/mind/master, skeleton_class)
	if(!mind || !master || !ispath(skeleton_class, /datum/advclass/greater_skeleton/lich))
		return FALSE
	if(!mind.has_antag_datum(/datum/antagonist/skeleton) && !mind.add_antag_datum(/datum/antagonist/skeleton))
		return FALSE
	mind.zizo_master = master
	for(var/datum/spell as anything in mind.spell_list.Copy())
		mind.RemoveSpell(spell)
	for(var/obj/effect/proc_holder/spell/spell as anything in mob_spell_list.Copy())
		RemoveSpell(spell)
	if(skills)
		skills.known_skills = list()
		skills.skill_experience = list()
	unequip_everything()
	revive(TRUE, TRUE)
	regenerate_limbs()
	INVOKE_ASYNC(src, PROC_REF(become_skeleton))
	set_patron(/datum/patron/inhumen/zizo)
	faction |= list(FACTION_UNDEAD, "cult")
	ambushable = FALSE
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/roguetown/greater_skeleton/lich))
	job = null
	if(!is_zizo(src))
		mind.special_role = "Cult Skeleton"
	add_verb(src, /mob/living/carbon/human/proc/communicate)
	var/datum/advclass/class = new skeleton_class
	class.applies_post_equipment = FALSE
	mind.picked_advclass = class
	set_advsetup(TRUE)
	class.equipme(src)
	if(cmode && client)
		SSdroning.play_combat_music('sound/music/combat_cult.ogg', client)
	to_chat(src, span_userdanger("The Dark Lady has recalled my bones. I serve [html_encode(master.current?.real_name || master.name)] and the cult's ascension."))
	return TRUE

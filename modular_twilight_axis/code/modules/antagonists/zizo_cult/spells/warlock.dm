/proc/grant_poke_spell_zizo_warlock(mob/living/carbon/human/user)
	var/list/poke_options = list("Wyrmfire" = /datum/action/cooldown/spell/projectile/fireball/barrage, "Lightning Bolt" = /datum/action/cooldown/spell/projectile/lightning_bolt, "Rimecast" = /datum/action/cooldown/spell/projectile/rimecast, "Void Beam" = /datum/action/cooldown/spell/void_beam)
	var/poke_choice = tgui_input_list(user, "Choose your greater spell.", "Arcyne Progress", poke_options)
	if(!poke_choice || !user.mind)
		return
	var/spell_path = poke_options[poke_choice]
	user.mind.AddSpell(new spell_path)

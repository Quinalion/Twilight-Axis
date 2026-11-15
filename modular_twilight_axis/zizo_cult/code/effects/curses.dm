/datum/status_effect/buff/curse_immunity
	id = "curse_immunity"
	duration = 15 MINUTES
	alert_type = null

/proc/curse_target(mob/living/target, show = TRUE)
	if(!target || target.has_status_effect(/datum/status_effect/buff/curse_immunity))
		return FALSE
	target.apply_status_effect(/datum/status_effect/buff/curse_immunity, 15 MINUTES)
	if(!show)
		return TRUE
	target.playsound_local(target, 'sound/vo/mobs/ghost/whisper (1).ogg', 60, FALSE)
	if(target.client)
		var/image/eye = image('modular_twilight_axis/zizo_cult/icons/effects/effects.dmi', target, "eye_open", ABOVE_ALL_MOB_LAYER)
		eye.pixel_y = 32
		target.client.images += eye
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clear_curse_eye), target.client, eye), 4 SECONDS)
	return TRUE

/proc/clear_curse_eye(client/C, image/eye)
	C?.images -= eye

/proc/recolor_accessory(accessory_type, hex)
	var/datum/sprite_accessory/A = SPRITE_ACCESSORY(accessory_type)
	var/list/colors = list()
	for(var/i in 1 to A.color_keys)
		colors += "#[hex]"
	return color_list_to_string(colors)

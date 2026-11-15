// TA EDIT - Cult research tome
/obj/item/recipe_book/zizo
	name = "tome of dark rituals"
	icon = 'modular_twilight_axis/lore/icons/books.dmi'
	icon_state = "zizo_guide_0"

/obj/item/recipe_book/zizo/attack_self(mob/user)
	GLOB.zizo_research.ui_interact(user)

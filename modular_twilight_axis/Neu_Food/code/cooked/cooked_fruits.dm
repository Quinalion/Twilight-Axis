/obj/item/reagent_containers/food/snacks/rogue/fruit/banana_baked
	name = "baked banana"
	desc = "A soft baked banana with golden edges."
	icon = 'modular_twilight_axis/Neu_Food/icons/cooked/fruits2.dmi'
	icon_state = "banana_baked"
	dish_type = DISH_FRUIT
	faretype = FARE_FINE
	tastes = list("baked banana" = 1)
	rotprocess = SHELFLIFE_DECENT
	materia = list(/datum/materia_aspect/plant)

/obj/item/reagent_containers/food/snacks/rogue/fruit/banana_chocolate
	name = "chocolate-covered banana"
	desc = "A baked banana coated in chocolate, served as a sweet in Otava."
	icon = 'modular_twilight_axis/Neu_Food/icons/cooked/fruits2.dmi'
	icon_state = "banana_choko3"
	cuisine = CUISINE_OTAVAIS
	dish_type = DISH_SWEET | DISH_FRUIT
	faretype = FARE_FINE
	tastes = list("baked banana" = 1, "rich chocolate" = 1)
	list_reagents = list(
		/datum/reagent/consumable/nutriment = NUTRITION_QUARTER_MEAL,
	)
	rotprocess = SHELFLIFE_DECENT
	eat_effect = /datum/status_effect/buff/sweet
	materia = list(/datum/materia_aspect/plant)

/datum/food_recipe/chocolate_banana
	name = "chocolate-covered banana"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fruit/banana_baked
	ingredients = list(/obj/item/reagent_containers/food/snacks/chocolate/slice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/fruit/banana_chocolate
	inline_ancestry = TRUE

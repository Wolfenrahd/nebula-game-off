extends VBoxContainer

func set_planet_name(text) -> void:
	$Name.text = "Planet: " + text

func set_biome_name(text) -> void:
	$Biome.text = "Biome: " + text

func set_atmosphere_name(text) -> void:
	$Atmosphere.text = "Atmosphere: " + text

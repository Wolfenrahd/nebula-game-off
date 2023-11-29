extends PanelContainer

var current_planet :Planet = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_planet(planet: Planet) -> void:
	current_planet = planet
	$VBoxContainer/Name.text = planet.name
	$VBoxContainer/Biome.text = Planet.BIOME_NAMES[planet.data.biome]
	$VBoxContainer/Atmosphere.text = Planet.ATMOSPHERE_NAMES[planet.data.atmosphere]
	$VBoxContainer/Food.text = "Food: " + str(planet.data.food)
	$VBoxContainer/Materials.text = "Materials: " + str(planet.data.materials)
	$VBoxContainer/Wealth.text = "Wealth: " + str(planet.data.wealth)
	$VBoxContainer/Units.text = "Units:\n" + "\tCitizens: " + str(planet.data.citizens)

func update_info() -> void:
	if visible and current_planet != null:
		$VBoxContainer/Food.text = "Food: " + str(current_planet.data.food)
		$VBoxContainer/Materials.text = "Materials: " + str(current_planet.data.materials)
		$VBoxContainer/Wealth.text = "Wealth: " + str(current_planet.data.wealth)
		$VBoxContainer/Units.text = "Units:\n" + "\tCitizens: " + str(current_planet.data.citizens)

extends Node

var dev_mode = false

var rng = RandomNumberGenerator.new()

var save_slot

var unlockables = [
	"air_jump_unlocked",
	"wall_climbing_unlocked",
	"teleport_unlocked",
	"missiles_unlocked"]

signal no_health
signal max_health_changed
signal health_changed

const FACTION_NAME_PARTS := {
	"colors": {
		"Blue": Color.BLUE,
		"Crimson": Color.RED,
		"Green": Color.GREEN,
		"Gold": Color.GOLD,
		"Aqua": Color.AQUA
	},
	"adjectives": [
		"Strong",
		"Great",
		"Noble",
		"Holy"
	],
	"nouns": [
		"Shield",
		"Raiders",
		"Wings",
		"Coalition",
		"Empire",
		"Blades",
		"Force",
		"Republic"
	]
}

var max_health = 3 : set = set_max_health
func set_max_health(value):
	max_health = value
	max_health_changed.emit()
	save_data["run_data"]["max_health"] = value

var health = max_health : set = set_health
func set_health(value):
	health = clamp(value, 0, max_health)
	health_changed.emit()
	if health <= 0: no_health.emit()
	save_data["run_data"]["health"] = value


var new_run_data = {
	"wall_jump_unlocked" : false,
	"max_health" : max_health,
	"health" : health,
	"current_location" : "res://levels/world.tscn",
	"current_planet" : {},
	"space_location" : Vector2(-1000,0),
	"first_take_off" : true,
	"zone_seeds": [],
	"star_map_size": Vector2(8, 8),
	"current_zone_coords": Vector2(0, 0),
	"zones": [],
	"factions": [
		"citizens",
		"merchants",
		"mercenaries",
		"bounty_hunters",
		"hunters",
		"nobles",
		"soldiers"
	],
	"government_factions": {}
}

var new_save_data = {
	"save_name" : "New Save",
	"new_save" : true,
	"version" : 1,
	"power_on_count" : 0,
	"seed" : 0,
	"seed_state" : 0,
	"current_game" : false,
	"tutorial_complete" : false,
	"hard_mode_unlocked" : false,
	"endless_mode_unlocked" : false,
	"highest_reputation" : 0,
	"run_data" : new_run_data.duplicate()
}

var save_data = new_save_data.duplicate()

func _ready():
	save_data.seed = rng.seed
	save_data.seed_state = rng.state

func reset_run():
	save_data["run_data"] = new_run_data.duplicate()
	
	for unlockable in unlockables:
		save_data["run_data"][unlockable] = false
	
	save_data.run_data.zone_seeds = []
	save_data.run_data.zones = []
	
	var seed_rng = RandomNumberGenerator.new()
	seed_rng.seed = save_data.seed
	
	for y in save_data.run_data.star_map_size.y:
		var seed_row := []
		save_data.run_data.zone_seeds.append(seed_row)
		
		var zone_row := []
		save_data.run_data.zones.append(zone_row)
		
		for x in save_data.run_data.star_map_size.x:
			var zone_seed = seed_rng.randi()
			seed_row.append(zone_seed)
			
			zone_row.append({"name": "ABCDEFGHIJKLMNOP"[y] + str(x + 1)})
			
			generate_planets(x, y, zone_seed)
	
	generate_factions()
	
	var government_faction_names = save_data.run_data.government_factions.keys()
	#assign factions to map
	
	var map_size = save_data.run_data.star_map_size
	for y in map_size.y:
		for x in map_size.x:
			
			if x / map_size.x < 0.25 and y / map_size.y < 0.25:
				assign_entire_zone_to_faction(Vector2(x, y), government_faction_names[0])
			elif x / map_size.x >= 0.75 and y / map_size.y < 0.25:
				assign_entire_zone_to_faction(Vector2(x, y), government_faction_names[1])
			elif x / map_size.x < 0.25 and y / map_size.y >= 0.75:
				assign_entire_zone_to_faction(Vector2(x, y), government_faction_names[2])
			elif x / map_size.x >= 0.75 and y / map_size.y >= 0.75:
				assign_entire_zone_to_faction(Vector2(x, y), government_faction_names[3])
#

func assign_entire_zone_to_faction(coords, faction) -> void:
	for planet in save_data["run_data"]["zones"][coords.y][coords.x]["planets"]:
		planet["owner"] = faction

func delete_save():
	save_data = new_save_data.duplicate()

func generate_zone_seeds() -> void:
	save_data.run_data.zone_seeds = []
	var rng = RandomNumberGenerator.new()
	rng.seed = save_data.seed
	
	for y in save_data.run_data.star_map_size.y:
		var row := []
		for x in save_data.run_data.star_map_size.x:
			row.append(rng.randi())
		save_data.run_data.zone_seeds.append(row)

func generate_planets(zone_x, zone_y, seed) -> void:
	var zone = save_data["run_data"]["zones"][zone_y][zone_x]
	zone["planets"] = []
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	var planet_count = rng.randi() % 15
	if zone_x == 0 && zone_y == 0 && planet_count == 0:
		planet_count = 1
	for i in range(planet_count):
		var planet := {
			"owner": "citizens",
			"units": {},
			"wealth": 0,
			"materials": 0,
			"food": 0,
			"citizens": 0,
			"score": 0,
			"planet_seed" : rng.randi(),
			"planet_index":Vector3(zone_x,zone_y,i),
			"persistant_data":{
				"destroyed_tiles":[],
				"destroyed_interactables":[],
			},
			"planet_type":"",
		}
		
		
		planet["planet_type"] = "basic"
		
		if zone_x == 0 && zone_y == 0 && i ==0:
			planet["planet_type"] = "first_planet"
		
		zone["planets"].append(planet)
		
		var name_part_count = rng.randf_range(2, 4)
		var generated_name = ""
		var has_space = false
		for name_part_index in name_part_count:
			if name_part_index != 0 and name_part_index < name_part_count - 2 and not has_space:
				if rng.randi() % 3 == 0:
					generated_name += " "
					has_space = true
					continue
			
			generated_name += Planet.PLANET_NAME_PARTS[rng.randi() % Planet.PLANET_NAME_PARTS.size()]
		
		generated_name = generated_name.capitalize()
		
		planet["name"] = generated_name
		var planet_name = generated_name
		
		var is_big = rng.randi() % 2
		planet["size"] = is_big
		
		if zone_x == 0 && zone_y == 0 && i ==0:
			planet["size"] = 0
		
		#generate moons
		var moon_probability = rng.randf()
		var moon_count = 0
		
		if moon_probability <= 0.4:
			moon_count = 0
		elif moon_probability < 0.8:
			moon_count = 1
		elif is_big:
			if moon_probability < 0.9:
				moon_count = 2
			elif moon_count < 0.96:
				moon_count = 3
			elif moon_count < 0.99:
				moon_count = 4
			else:
				moon_count = 5
		else:
			moon_count = 1
		
		planet["moon_count"] = moon_count
		
		var possible_angles :Array = range(0, 8)
		
		var biomes = Planet.BIOMES.keys()
		var atmospheres = Planet.ATMOSPHERES.keys()
		var terrains = Planet.TERRAIN_TYPES.keys()
		
		#generate biome
		var biome = biomes[rng.randi() % biomes.size()]
		planet["biome"] = Planet.BIOMES[biome]
		
		match biome:
			Planet.BIOMES.FOREST:
				atmospheres.erase(Planet.ATMOSPHERES.NO_AIR)
				terrains.erase(Planet.TERRAIN_TYPES.RIDGE_TERRAIN)
				terrains.erase(Planet.TERRAIN_TYPES.MARBLE_TERRAIN)
			Planet.BIOMES.ICE:
				terrains.erase(Planet.TERRAIN_TYPES.ROUGH_TERRAIN)
			Planet.BIOMES.WATER_WORLD:
				terrains.erase(Planet.TERRAIN_TYPES.ROUGH_TERRAIN)
			Planet.BIOMES.DESERT:
				terrains.erase(Planet.TERRAIN_TYPES.WATER_TERRAIN)
		
		var atmosphere = atmospheres[rng.randi() % atmospheres.size()]
		planet["atmosphere"] = Planet.ATMOSPHERES[atmosphere]
		
		var terrain = terrains[rng.randi() % terrains.size()]
		planet["terrain"] = Planet.TERRAIN_TYPES[terrain]
		
		planet["citizens"] = max(0, Planet.get_food_gain(planet) * (is_big + 1) + Planet.ATMOSPHERE_SCORE[planet["atmosphere"]])
	
	var station_count = rng.randi() % 15

func generate_factions() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = save_data.seed
	
	var government_faction_count = 4
	
	var colors = FACTION_NAME_PARTS["colors"].keys()
	var adjectives = colors + FACTION_NAME_PARTS["adjectives"]
	var nouns = FACTION_NAME_PARTS["nouns"].duplicate()
	
	var used_adjectives := []
	for i in government_faction_count:
		var adjective_index = rng.randi() % adjectives.size()
		var adjective = adjectives[adjective_index]
		adjectives.remove_at(adjective_index)
		
		var noun_index = rng.randi() % nouns.size()
		var noun = nouns[noun_index]
		nouns.remove_at(noun_index)
		
		var faction_name = (adjective + " " + noun).capitalize()
		
		var color :Color
		if adjective in colors:
			color = FACTION_NAME_PARTS["colors"][adjective]
			colors.erase(adjective)
		else:
			var color_index = rng.randi() % colors.size()
			color = FACTION_NAME_PARTS["colors"][colors[color_index]]
			colors.remove_at(color_index)
		
		#print("faction name ", faction_name)
		
		save_data["run_data"]["government_factions"][faction_name] = {
			"color": color
		}

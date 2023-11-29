extends Area2D

class_name Planet

const PLANET_NAME_PARTS := [
	"al",
	"num",
	"dum",
	"un",
	"um",
	"mor",
	"or",
	"fice",
	"gan",
	"i",
	"u",
	"ska",
	"ite",
	"blu",
	"red",
	"ed",
	"black",
	"low",
	"high",
	"hi",
	"ars",
	"plu",
	"to",
	"ven",
	"us",
	"jup",
	"er",
	"on",
	"nom",
	"e",
	"yor",
	"kor",
	"sil",
	"ki",
	"mai",
	"mae",
	"kit",
	"cil",
	"cit",
	"phor",
	"ski",
	"oi",
	"aq",
	"mir",
	"aka",
	"ao",
	"iro",
	"kuro",
	"mura",
	"saki",
	"gin",
	"kin",
	"hol",
	"hor",
	"az",
	"x",
	"eth",
	"ish",
	"in"
]

enum BIOMES {
	FOREST = 1,
	ICE = 2,
	DESERT = 4,
	WATER_WORLD = 8
}

const BIOME_NAMES := {
	BIOMES.FOREST: "Forest",
	BIOMES.ICE: "Ice",
	BIOMES.DESERT: "Desert",
	BIOMES.WATER_WORLD: "Water World"
}

const BIOME_FOOD_SCORE := {
	BIOMES.FOREST: 3,
	BIOMES.ICE: 1,
	BIOMES.DESERT: 1,
	BIOMES.WATER_WORLD: 2
}

const BIOME_MAT_SCORE := {
	BIOMES.FOREST: 3,
	BIOMES.ICE: 2,
	BIOMES.DESERT: 5,
	BIOMES.WATER_WORLD: 1
}

enum ATMOSPHERES {
	NO_AIR = 1,
	GOOD_AIR = 2,
	SLIGHTLY_TOXIC = 4,
	DANGEROUSLY_TOXIC = 8
}

const ATMOSPHERE_SCORE := {
	ATMOSPHERES.NO_AIR: 0,
	ATMOSPHERES.GOOD_AIR: 1,
	ATMOSPHERES.SLIGHTLY_TOXIC: -1,
	ATMOSPHERES.DANGEROUSLY_TOXIC: -2
}

const ATMOSPHERE_NAMES := {
	ATMOSPHERES.NO_AIR: "No Air",
	ATMOSPHERES.GOOD_AIR: "Good Air",
	ATMOSPHERES.SLIGHTLY_TOXIC: "Slightly Toxic",
	ATMOSPHERES.DANGEROUSLY_TOXIC: "Dangerously Toxic"
}

enum TERRAIN_TYPES {
	WATER_TERRAIN = 1,
	RIDGE_TERRAIN = 2,
	ROUGH_TERRAIN = 4,
	MARBLE_TERRAIN = 8
}

@export var surface_color := Color(1, 1, 1)
@export var terrain_color := Color(1, 1, 1)
@export var cloud_color := Color(1, 1, 1)

@onready var surface = $Surface
@onready var terrain = $Surface/Terrain
@onready var clouds = $Surface/Clouds

@onready var orbit = $Orbit

var radius = 256
var orbit_radius = 512

var data := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	surface.self_modulate = surface_color
	terrain.modulate = terrain_color
	clouds.modulate = cloud_color
	
	terrain.region_rect.position = Vector2(randf() * 512, randf() * 512)
	terrain.rotate(randf() * TAU)
	clouds.region_rect.position = Vector2(randf() * 512, randf() * 512)
	clouds.rotate(randf() * TAU)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	clouds.region_rect.position += Vector2(4, 1) * delta

func set_radius_to_512() -> void:
	surface.texture = load("res://assets/art/planets/planet_512.png")
	$CollisionShape256.disabled = true
	$CollisionShape512.disabled = false
	$Orbit/CollisionShape2D.shape.radius = 512
	radius = 256
	orbit_radius = radius * 3
	
	set_region_rect_size(512)

func set_radius_to_256() -> void:
	surface.texture = load("res://assets/art/planets/planet_256.png")
	$CollisionShape256.disabled = false
	$CollisionShape512.disabled = true
	$Orbit/CollisionShape2D.shape.radius = 400
	radius = 128
	orbit_radius = radius * 3
	
	set_region_rect_size(256)

func set_region_rect_size(size) -> void:
	terrain.region_rect.size = Vector2(size, size)
	clouds.region_rect.size = Vector2(size, size)

static func update_planet_resources(planet_data) -> void:
	var biome_food_score = BIOME_FOOD_SCORE[planet_data.biome]
	var biome_mat_score = BIOME_MAT_SCORE[planet_data.biome]
	var atmosphere_score = ATMOSPHERE_SCORE[planet_data.atmosphere]
	
	var food_gain = get_food_gain(planet_data)
	var mat_gain = max(0, biome_mat_score * (planet_data.size + 1)) * planet_data["citizens"]
	
	if planet_data.citizens <= 0:
		food_gain = 0
		mat_gain = 0
	planet_data.food += food_gain
	
	if planet_data.food <= 0:
		planet_data.food = 0
		if planet_data.citizens > 0 and randf() < 0.2:
			planet_data.citizens -= (randi() % planet_data.citizens) + 1
	elif planet_data.food < planet_data.citizens / 2:
		if planet_data.citizens > 0 and randf() < 0.1:
			planet_data.citizens -= (randi() % planet_data.citizens / 2) + 1
	elif planet_data.food > planet_data.citizens * 2:
		if planet_data.citizens > 0 and randf() < 0.1:
			planet_data.citizens += clamp((randi() % planet_data.citizens + 1) / 2, 0, planet_data.food / 10)
	
	planet_data.materials += mat_gain
	planet_data.wealth += (food_gain + mat_gain) / 10 * planet_data["citizens"]
	
	planet_data.score = planet_data.food + planet_data.materials + planet_data.wealth + planet_data["citizens"] + (biome_mat_score + atmosphere_score + biome_food_score) * 5
	
	Stats.save_data.run_data.government_factions[planet_data.owner].military_unit_baseline += get_digits(planet_data.score)
	
	print("score ", planet_data.name, ": ", planet_data.score)

static func get_food_gain(planet_data) -> int:
	var biome_food_score = BIOME_FOOD_SCORE[planet_data.biome]
	var atmosphere_score = ATMOSPHERE_SCORE[planet_data.atmosphere]
	
	var base_food_gain = max(0, (biome_food_score + atmosphere_score) * (planet_data.size + 1))
	
	var max_food_gain = base_food_gain * 10
	
	return clamp(base_food_gain + planet_data["citizens"] * 2, 0, max_food_gain)

static func get_digits(num: int) -> int:
	var digits := 0
	while num > 0:
		num /= 10
		digits += 1
	return digits

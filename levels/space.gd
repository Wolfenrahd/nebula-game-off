extends Node2D

var stats = Stats
var run_data = Stats.save_data["run_data"]

@onready var player = $Characters/player_ship
@onready var main_cam = $main_cam
@onready var star_map = $CanvasLayer/StarMap
@onready var star_map_grid = $CanvasLayer/StarMap/GridContainer
@onready var border_line = $Border/Line2D

var visible_static_object_count := 0

@export var world_radius := 4000
@export var loop_margin := Vector2(100, 100)

@export var star_map_size = Vector2(8, 8)

var highest_border_speed := 0.0
var border_exit_speed := 0.0

const FOREST = 1
const ICE = 2
const DESERT = 4
const WATER_WORLD = 8

const NO_AIR = 1
const GOOD_AIR = 2
const SLIGHTLY_TOXIC = 4
const DANGEROUSLY_TOXIC = 8

const WATER_TERRAIN = 1
const RIDGE_TERRAIN = 2
const ROUGH_TERRAIN = 4
const MARBLE_TERRAIN = 8

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
	"on"
]

var selected_zone_coords = null
var selected_zone_button = null

var current_zone_button = null

var planet_infos := []

func _ready():
	player.global_position = run_data["space_location"]
#	player.connect("player_dead",player_dead)
	main_cam.change_target(player.camera_follow)
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	#generate zone seeds
	if run_data["zone_seeds"].is_empty():
		var rng = RandomNumberGenerator.new()
		rng.seed = stats.save_data.seed
		
		for y in star_map_size.y:
			var row := []
			for x in star_map_size.x:
				row.append(rng.randi())
			run_data["zone_seeds"].append(row)
	
	var current_zone_coords = run_data["current_zone_coords"]
	
	#create zone buttons
	for y in star_map_size.y:
		for x in star_map_size.x:
			var zone_button = preload("res://ui/zone_button.tscn").instantiate()
			star_map_grid.add_child(zone_button)
			zone_button.connect("zone_pressed", _on_zone_button_pressed)
			
			zone_button.coords = Vector2(x, y)
			zone_button.text = "ABCDEFGHIJKLMNOP"[y] + str(x + 1)
			
			if zone_button.coords == current_zone_coords:
				set_current_zone_button(zone_button)
	
	var current_zone = run_data.zones[current_zone_coords.y][current_zone_coords.x]
	generate(current_zone)
#	generate(2)
#	generate(save_data["space_seed"])
	
#	$ShipAI.orbit_target = $Objects.get_children().pick_random()
#	$ShipAI2.orbit_target = $Objects.get_children().pick_random()
#	$ShipAI3.orbit_target = $Objects.get_children().pick_random()
#	$ShipAI4.orbit_target = $Objects.get_children().pick_random()
#	$ShipAI.follow_target = $Characters/player_ship
#	$ShipAI2.follow_target = $Characters/player_ship
#	$ShipAI3.follow_target = $Characters/player_ship
#	$ShipAI4.follow_target = $Characters/player_ship

#	$ShipAI.attack_target = $Characters/player_ship
#	$ShipAI2.attack_target = $Characters/player_ship
#	$ShipAI3.attack_target = $Characters/player_ship
#	$ShipAI4.attack_target = $Characters/player_ship
	
	star_map.hide()
	
	$ShipAI.land_target = $Objects.get_children().pick_random()
	$ShipAI2.land_target = $Objects.get_children().pick_random()
	$ShipAI3.land_target = $Objects.get_children().pick_random()
	$ShipAI4.land_target = $Objects.get_children().pick_random()
#
#	$ShipAI.follow_target = $Characters/player_ship
#	$ShipAI2.follow_target = $Characters/player_ship
#	$ShipAI3.attack_target = $Characters/player_ship
#	$ShipAI4.attack_target = $Characters/player_ship

#func generate_faction_name() -> String:
	

func set_current_zone_button(button) -> void:
	if current_zone_button != null:
		current_zone_button.set_current(false)
	current_zone_button = button
	button.set_current(true)

func generate(zone) -> void:
	$TickTimer.stop()
	
	var seed = run_data["zone_seeds"][run_data["current_zone_coords"].y][run_data["current_zone_coords"].x]
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	border_line.clear_points()
	var point_count = world_radius * 0.03
	var unit_angle = TAU / point_count
	for i in point_count + 1:
		border_line.add_point(Vector2(world_radius, 0).rotated(unit_angle * i))
	
	$Border/CollisionShape2D.shape.radius = world_radius
	
	$CanvasLayer/GenerationMessage.show()
	
	for child in $Objects.get_children():
		child.queue_free()
	
	var planet_count = zone["planets"].size()
	for i in range(planet_count):
		var planet_data = zone["planets"][i]
		
		var angle = rng.randf() * TAU
#		var distance_from_sun = rng.randf_range(600, world_radius - 300)
		var distance_from_sun = rng.randf_range(800, world_radius - 500)
		var is_big = planet_data["size"]
		
		var planet = preload("res://locations/planet.tscn").instantiate()
		$Objects.add_child(planet)
		
		planet.mouse_entered.connect(_on_planet_mouse_entered.bind(planet))
		planet.mouse_exited.connect(_on_planet_mouse_exited.bind(planet))
		
		planet.data = planet_data
		
		planet.position = $Sun.position + Vector2(distance_from_sun, 0).rotated(angle)
		
		planet.name = planet_data["name"]
		
		if is_big == 1:
			planet.set_radius_to_512()
		else:
			planet.set_radius_to_256()
		
		#make sure planet isn't overlapping anything else
		await get_tree().physics_frame
		
		#i'm checking if the # of overlapping areas is greater than 1 because it will always at least detect the planet itself
		while planet.orbit.get_overlapping_areas().size() > 1:
			planet.position += (planet.position - $Sun.position).normalized() * 512
			await get_tree().physics_frame
		
		
		#generate moons
		var moon_probability = rng.randf()
		var moon_count = planet_data["moon_count"]
		
		var possible_angles :Array = range(0, 8)
		
		for j in moon_count:
			var angle_index = rng.randi() % possible_angles.size()
			var moon_angle = (TAU / 8) * possible_angles[angle_index]
			possible_angles.remove_at(angle_index)
			
			var moon_distance = rng.randf_range(planet.radius + 100, planet.orbit_radius - 80)
			var moon = preload("res://locations/moon.tscn").instantiate()
			planet.add_child(moon)
			moon.position = Vector2(moon_distance, 0).rotated(moon_angle)
		
		#generate biome
		var biome = planet_data["biome"]
		if biome == FOREST:
			planet.surface.self_modulate = get_random_rgbv(rng, 0, 0.3, 0, 1, 0.5, 1, 0.5, 1)
			planet.terrain.modulate = get_random_rgbv(rng, 0, 0.4, .7, 1, 0, 0.4, 0.4, 1)
		elif biome == ICE:
			planet.surface.self_modulate = get_random_rgbv(rng, 0, 1, 0.5, 0.8, 0.8, 1, 0.9, 1)
			planet.terrain.modulate = get_random_rgbv(rng, 0.5, 1, 0.7, 1, 0.9, 1, 0.8, 1)
		elif biome == WATER_WORLD:
			planet.surface.self_modulate = get_random_rgbv(rng, 0, 0, 0, 0.5, 0.5, 1, 0.5, 1)
			planet.terrain.modulate = get_random_rgbv(rng, 0, 0.0, 0, 0.5, 0.5, 1, 0.4, 1)
		elif biome == DESERT:
			planet.surface.self_modulate = get_random_rgbv(rng, 0.5, 1, 0, 0.5, 0, 0.25, 0.3, 1)
			planet.terrain.modulate = get_random_rgbv(rng, 0.5, 1, 0, 0.5, 0, 0.5, 0.3, 1)
		
		var atmosphere = planet_data["atmosphere"]
		if atmosphere == NO_AIR:
			planet.clouds.hide()
		elif atmosphere == SLIGHTLY_TOXIC:
			planet.clouds.modulate = get_random_rgbv(rng, 0.5, 0.2, 0.5, 0.2, 0.5, 0.2, 0.6, 1)
		elif atmosphere == DANGEROUSLY_TOXIC:
			planet.clouds.modulate = get_random_rgbv(rng, 0, 0.2, 0, 0.2, 0, 0.2, 0.2, 1)
		
		var terrain = planet_data["terrain"]
		if terrain == WATER_TERRAIN:
			planet.terrain.texture = load("res://assets/art/planets/water_terrain.png")
		elif terrain == RIDGE_TERRAIN:
			planet.terrain.texture = load("res://assets/art/planets/ridge_terrain.png")
		elif terrain == ROUGH_TERRAIN:
			planet.terrain.texture = load("res://assets/art/planets/rough_terrain.png")
		elif terrain == MARBLE_TERRAIN:
			planet.terrain.texture = load("res://assets/art/planets/marble_terrain.png")
	
	var station_count = rng.randi() % 15
	for i in range(station_count):
		var angle = rng.randf() * TAU
#		var distance_from_sun = rng.randf_range(600, world_radius - 300)
		var distance_from_sun = rng.randf_range(800, world_radius - 300)
		
		var station = preload("res://locations/station.tscn").instantiate()
		$Objects.add_child(station)
		station.position = $Sun.position + Vector2(distance_from_sun, 0).rotated(angle)
		
		await get_tree().physics_frame
		
		while station.get_overlapping_areas().size() > 0:
			station.position += (station.position - $Sun.position).normalized() * 150
			await get_tree().physics_frame
	
	$CanvasLayer/GenerationMessage.hide()
	
	await get_tree().create_timer(1.0).timeout
	
	$TickTimer.start()

func get_random_rgbv(rng, min_r, max_r, min_g, max_g, min_b, max_b, min_v, max_v) -> Color:
	var color :Color
	color.r = rng.randf_range(min_r, max_r)
	color.g = rng.randf_range(min_g, max_g)
	color.b = rng.randf_range(min_b, max_b)
	color.v = rng.randf_range(min_v, max_v)
	return color

func _physics_process(delta: float) -> void:
	if $Border.get_overlapping_bodies().size() == 0:
		if player.velocity.length() > highest_border_speed:
			highest_border_speed = player.velocity.length()
		
		var speed = 1
		if highest_border_speed > 1:
			speed = highest_border_speed * highest_border_speed
		
		player.velocity += -player.global_position.normalized() * delta * (highest_border_speed + 10)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		star_map.visible = !star_map.visible
		if star_map.visible:
			update_star_map_colors()

func _on_zone_button_pressed(zone_button) -> void:
	var zone = run_data.zones[zone_button.coords.y][zone_button.coords.x]
	selected_zone_button = zone_button
	selected_zone_coords = zone_button.coords
	
	$CanvasLayer/StarMap/PanelContainer/VBoxContainer/Name.text = zone.name
	$CanvasLayer/StarMap/PanelContainer/VBoxContainer/PlanetCount.text = "Planets: " + str(zone.planets.size())
	
	for child in $CanvasLayer/StarMap/PanelContainer/VBoxContainer/ScrollContainer/Planets.get_children():
		child.queue_free()
	
	for i in zone.planets.size():
		var info = preload("res://ui/planet_map_info.tscn").instantiate()
		info.set_planet_name(zone.planets[i].name)
		info.set_biome_name(Planet.BIOME_NAMES[zone.planets[i].biome])
		info.set_atmosphere_name(Planet.ATMOSPHERE_NAMES[zone.planets[i].atmosphere])
		$CanvasLayer/StarMap/PanelContainer/VBoxContainer/ScrollContainer/Planets.add_child(info)
		
		var separator = HSeparator.new()
		$CanvasLayer/StarMap/PanelContainer/VBoxContainer/ScrollContainer/Planets.add_child(separator)

func _on_travel_pressed() -> void:
	star_map.hide()
	
	set_current_zone_button(selected_zone_button)
	
	run_data["current_zone_coords"] = selected_zone_coords
	var zone = run_data.zones[selected_zone_coords.y][selected_zone_coords.x]
	var zone_seed = run_data["zone_seeds"][selected_zone_coords.y][selected_zone_coords.x]
	generate(zone)

func change_camera_target(new_target):
	main_cam.change_target(new_target)

func player_dead():
	change_camera_target(null)


func _on_border_body_entered(body: Node2D) -> void:
	player.velocity = player.velocity.normalized() * border_exit_speed


func _on_border_body_exited(body: Node2D) -> void:
	border_exit_speed = player.velocity.length()

func get_zone_faction_ownership(coords) -> Dictionary:
	var zone = run_data.zones[coords.y][coords.x]
	var owners := []
	for planet in zone.planets:
		owners.append(planet["owner"])
	
	var ownership := {}
	
	for faction in run_data.factions:
		ownership[faction] = float(owners.count(faction)) / owners.size()
	
	for faction in run_data.government_factions.keys():
		ownership[faction] = float(owners.count(faction)) / owners.size()
	
	return ownership

func update_star_map_colors() -> void:
	for zone_button in star_map_grid.get_children():
		if zone_button.text == "H7":
			pass
		var zone_ownership = get_zone_faction_ownership(zone_button.coords)
		for faction_name in zone_ownership.keys():
			if faction_name in run_data.government_factions.keys():
				zone_button.faction_color_panels[faction_name].modulate.a = zone_ownership[faction_name]
		print("ownership ", zone_button.coords, zone_ownership)

func _on_planet_mouse_entered(planet) -> void:
	$CanvasLayer/PlanetInfo.show()
	$CanvasLayer/PlanetInfo.show_planet(planet)
	

func _on_planet_mouse_exited(planet) -> void:
	$CanvasLayer/PlanetInfo.hide()


func _on_tick_timer_timeout() -> void:
	print("tick")
	
	var gov_factions = run_data.government_factions
	for faction in run_data.government_factions.values():
		faction.military_unit_baseline = 0
	
	#update resources
	var planets = get_tree().get_nodes_in_group("planets")
	for planet in planets:
		Planet.update_planet_resources(planet.data)
	
	#spawn ships to cover baseline
	#first, find and sort planets into different factions
	
	var faction_planets := {}
	
	for planet in planets:
		if not faction_planets.has(planet.data.owner):
			faction_planets[planet.data.owner] = []
		faction_planets[planet.data.owner].append(planet)
	
	for faction_name in run_data.government_factions.keys():
		var faction = run_data.government_factions[faction_name]
		
		print(faction_name, ": ", faction.military_unit_baseline)
	
	$CanvasLayer/PlanetInfo.update_info()

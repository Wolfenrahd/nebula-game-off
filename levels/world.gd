extends Node2D


var stats = Stats

const landed_ship_scene = preload("res://items/ship_crashed.tscn")

@onready var rooms = $rooms
@onready var tile_map = $TileMap
@onready var player = $player
@onready var ship_crashed = $ship_crashed
@onready var main_cam = $main_cam
@onready var enemies = $enemies
@onready var interactables = $interactables
@onready var death_menu = $CanvasLayer/CenterContainer/DeathMenu
@onready var pause_menu = $CanvasLayer/CenterContainer/PauseMenu
@onready var help_text = $CanvasLayer/help_text

var tile_map_textures = [
	load("res://assets/art/tilesets/forest_tiles.png"),
	load("res://assets/art/tilesets/planet_1_final.png"),
	load("res://assets/art/tilesets/desert_tiles.png"),
	load("res://assets/art/tilesets/water_tiles.png")
	]


var all_rooms = All_Rooms.new()
var all_enemies = All_Enemies.new()
var all_upgrades = All_Upgrades.new()

var offset = 16
var tile_size = 16
var generator = Planet_Generator.new()
var planet_detailed = []

func _ready():
	tile_map.tile_set.get_source(0).texture = tile_map_textures[stats.save_data.run_data.current_planet.biome]
	player.connect("player_dead",player_dead)
	main_cam.change_target(player.camera_follow)
	#RenderingServer.set_default_clear_color(Color("45b176"))
	set_background()
	set_vector_pos()
	test_set_vector_pos()
	generator.generate_planet(stats.save_data.run_data.current_planet.size,stats.save_data.run_data.current_planet.planet_type)
	planet_detailed = generator.planet_detailed
	generate_planet()
	
	Sounds.play_music("misadventures_of_planet")

func set_background():
	match stats.save_data.run_data.current_planet.biome:
		0:
			RenderingServer.set_default_clear_color(Color.OLIVE_DRAB)
		1:
			RenderingServer.set_default_clear_color(Color.DARK_SLATE_BLUE)
		2:
			RenderingServer.set_default_clear_color(Color.CHOCOLATE)
		3:
			RenderingServer.set_default_clear_color(Color.DODGER_BLUE)
	

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause_menu.pause()
	if event.is_action_pressed("teleport") && stats.save_data.run_data.teleport_unlocked:
		player.position = ship_crashed.position

func change_camera_target(new_target):
	main_cam.change_target(new_target)

func player_dead():
	change_camera_target(null)

var vector_pos= []
func set_vector_pos():
	for i in range(tile_size):
		for j in range(tile_size):
			vector_pos.append(Vector2(i,j))

var test_num = 38
var test_vector_pos= []
func test_set_vector_pos():
	for i in range(test_num):
		for j in range(test_num):
			test_vector_pos.append(Vector2(i-11,j-11))

var tiles = []
var spaces = []
func generate_planet():
	for planet_room in planet_detailed:
		var room = all_rooms.instance_room(planet_room["room_type"],planet_room["planet_type"],planet_room["room_number"]).instantiate()
		room.position = planet_room["location"]*(offset*tile_size)
		rooms.add_child(room)
		if planet_room["room_type"] == "starting_room":
			player.position = room.player_starting_position
			ship_crashed.position = room.ship_starting_position
#		for i in vector_pos:
#			if room.tile_map.get_cell_tile_data(0,i):
#				tiles.append(i+(planet_room["location"]*offset))
#			else:
#				spaces.append(i+(planet_room["location"]*offset))
		for i in vector_pos:
			if room.tile_map.get_cell_tile_data(0,i):
				pass
			else:
				spaces.append(i+(planet_room["location"]*offset))
		for i in test_vector_pos:
			tiles.append(i+(planet_room["location"]*offset))
		for enemy in planet_room["enemies"]:
			generate_enemy(enemy["position"]+(planet_room["location"]*(offset*tile_size)),enemy["type_index"])
		if planet_room["upgrade"]:
			generate_upgrade(planet_room["upgrade"]["position"]+(planet_room["location"]*(offset*tile_size)),planet_room["upgrade"]["upgrade_type"])
	rooms.queue_free()
	var current_planet_index = stats.save_data.run_data.current_planet["planet_index"]
	var destroyed_tiles = stats.save_data["run_data"]["zones"][current_planet_index.y][current_planet_index.x]["planets"][current_planet_index.z]["persistant_data"]["destroyed_tiles"]
	for tile in destroyed_tiles:
		spaces.append(tile/16)
	tile_map.set_cells_terrain_connect(0,tiles,0,0)
	tile_map.set_cells_terrain_connect(0,spaces,0,-1)
	var destroyed_interactables = stats.save_data["run_data"]["zones"][current_planet_index.y][current_planet_index.x]["planets"][current_planet_index.z]["persistant_data"]["destroyed_interactables"]
	for interactable in interactables.get_children():
		if interactable.position in destroyed_interactables:
			interactable.queue_free()

func generate_enemy(_position,enemy_type):
	var new_enemy = all_enemies.instance_enemy(stats.save_data.run_data.current_planet.biome,enemy_type).instantiate()
	enemies.add_child(new_enemy)
	new_enemy.position = _position

func generate_upgrade(_position,upgrade_type):
	var upgrade = all_upgrades.instance_upgrade(upgrade_type).instantiate()
	interactables.add_child(upgrade)
	upgrade.position = _position

var leaving = false
func _on_ship_crashed_ship_take_off():
	stats.save_data.run_data.current_location = "res://levels/space.tscn"
	SaveAndLoad.update_save_data()
	if !leaving:
		leaving = true
		main_cam.change_target(null)
		player.queue_free()
		main_cam.fade_out()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file(stats.save_data.run_data.current_location)

#func _on_ship_crashed_ship_take_off():
	#SaveAndLoad.update_save_data()
	#get_tree().change_scene_to_file("res://levels/space.tscn")


func _on_player_player_dead():
	death_menu.start_timer()


func _on_upgrade_picked_up(text):
	help_text.text = text
	help_text.visible = true

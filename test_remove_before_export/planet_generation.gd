extends Node
class_name Planet_Generator

var stats = Stats
var rng = RandomNumberGenerator.new()

var all_rooms = All_Rooms.new()
var all_enemies = All_Enemies.new()
var all_upgrades = All_Upgrades.new()

#var rooms
var planet = []
var planet_detailed = []
var planet_room = {
	"location":Vector2.ZERO,
	"north_door":false,
	"south_door":false,
	"east_door":false,
	"west_door":false,
	"room_type":"n/a",
	"planet_type":"n/a",
	"room_number":0,
	"enemies":[],
	"items":[],
	"upgrade":null,
}
var door_names = ["north_door","south_door","east_door","west_door"]
var starting_room = Vector2.ZERO
var final_room = Vector2.ZERO

#planet types: 
#0 - null
#1 - landing (top, left, right)
#2 - corridor (left, right)
#3 - drop (top, left, right, bottom)
#4 - other (n/a)

var directions = [Vector2(0,-1),Vector2(0,1),Vector2(-1,0),Vector2(1,0)]
var directions_sans_up = [Vector2(0,1),Vector2(-1,0),Vector2(1,0)]
func generate_planet(size,planet_type):
	rng.seed = stats.save_data.run_data.current_planet.planet_seed
	var rooms
	if size == 0:
		rooms = rng.randi_range(5,9)
	else:
		rooms = rng.randi_range(10,20)
	if planet_type == "first_planet":
		rooms = 4
	starting_room = Vector2.ZERO
	planet.push_front(starting_room)
	var current_room = starting_room+Vector2(0,1)
	planet.push_front(current_room)
	var counter = 0
	while planet.size() < rooms:
		var possible_directions
		if current_room.y<=1:
			possible_directions = directions_sans_up.duplicate()
		else:
			possible_directions = directions.duplicate()
		var next_room = Vector2.ZERO
		var good_room = false
		while !good_room:
			if possible_directions.size() == 0:
				counter+=1
				current_room = planet[counter]
				if current_room.y<=1:
					possible_directions = directions_sans_up.duplicate()
				else:
					possible_directions = directions.duplicate()
			next_room = current_room+possible_directions.pop_at(rng.randi_range(0,possible_directions.size()-1))
			if next_room not in planet:
				planet.push_front(next_room)
				good_room = true
				current_room = next_room
				counter = 0
	final_room = planet[0]
	for room in planet:
		if starting_room.distance_to(room)>starting_room.distance_to(final_room):
			final_room = room
	for room in planet:
		var new_room = planet_room.duplicate()
		new_room["location"] = room
		new_room["planet_type"] = planet_type
		if room == starting_room:
			new_room["room_type"] = "starting_room"
		elif room == final_room:
			new_room["room_type"] = "final_room"
			
		for i in directions.size():
			if room+directions[i] in planet:
				new_room[door_names[i]] = true
		planet_detailed.push_front(new_room)
	for room in planet_detailed:
		if room["room_type"] == "n/a":
			if room["south_door"]:
				room["room_type"] = "drop"
			elif room["east_door"] && room["west_door"]:
				room["room_type"] = "corridor"
			else:
				room["room_type"] = "landing"
		room["room_number"] = choose_room(room["room_type"],room["planet_type"])
		room["enemies"] = generate_enemy_data(room["room_type"],room["planet_type"],room["room_number"])
		room["upgrade"] = generate_upgrade_data(room["room_type"],room["planet_type"],room["room_number"])
		
	#print(planet)
	#print(JSON.stringify(planet_detailed,"\t",false))

func choose_room(room_type,planet_type):
	return rng.randi_range(0,all_rooms.rooms[planet_type][room_type].size()-1)

func generate_enemy_data(room_type,planet_type,room_number):
	var data = []
	if room_type == "starting_room" or room_type == "final_room":
		return data
	var room = all_rooms.rooms[planet_type][room_type][room_number].instantiate()
	var enemy_positions = room.get_node("enemies").get_children()
	var enemy_numbers = rng.randi_range(0,enemy_positions.size()-1)
	for i in enemy_numbers:
		var new_enemy = {
			"position":Vector2.ZERO,
			"type_index":0
		}
		var enemy_position_index = rng.randi_range(0,enemy_positions.size()-1)
		var enemy_type_index = rng.randi_range(0,all_enemies.enemies[stats.save_data.run_data.current_planet.biome].size()-1)
		new_enemy["position"] = enemy_positions[enemy_position_index].position
		new_enemy["type_index"] = enemy_type_index
		data.append(new_enemy)
		enemy_positions.pop_at(enemy_position_index)
	return data

func generate_upgrade_data(room_type,planet_type,room_number):
	var data = {
		"position":Vector2.ZERO,
		"upgrade_type":"",
	}
	if room_type != "final_room":
		return null
	var room = all_rooms.rooms[planet_type][room_type][room_number].instantiate()
	data["position"] = room.get_node("upgrade").position
	if planet_type == "first_planet":
		data["upgrade_type"] = "wall_climbing_unlocked"
		return data
	else:
		var chance = rng.randi_range(1,10)
		if chance == 10:
			var upgrade_list = all_upgrades.list_available_unlockables()
			if upgrade_list.size() == 0:
				return null
			else:
				data["upgrade_type"] = upgrade_list[rng.randi_range(0,upgrade_list.size()-1)]
				print(data)
				return data
		else:
			return null







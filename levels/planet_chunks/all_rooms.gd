extends Node
class_name  All_Rooms

var rng = Stats.rng

var rooms = {
	"first_planet" : {
		"starting_room":[preload("res://levels/planet_chunks/starting_rooms/starting_0_1.tscn")],
		"final_room":[preload("res://levels/planet_chunks/final_rooms/final_room_0_1.tscn")],
		"landing":[preload("res://levels/planet_chunks/landing_rooms/landing_0_1.tscn")],
		"corridor":[preload("res://levels/planet_chunks/corridor_rooms/corridor_0_1.tscn")],
		"drop":[preload("res://levels/planet_chunks/drop_rooms/drop_0_1.tscn")]
	},
	"basic" : {
		"starting_room":[
			preload("res://levels/planet_chunks/starting_rooms/starting_0_1.tscn"),
			preload("res://levels/planet_chunks/starting_rooms/starting_1_1.tscn"),
			],
		"final_room":[
			preload("res://levels/planet_chunks/final_rooms/final_room_0_1.tscn"),
			preload("res://levels/planet_chunks/final_rooms/final_room_1_1.tscn"),
			],
		"landing":[
			preload("res://levels/planet_chunks/landing_rooms/landing_0_1.tscn"),
			preload("res://levels/planet_chunks/landing_rooms/landing_1_1.tscn"),
			preload("res://levels/planet_chunks/landing_rooms/landing_1_2.tscn"),
			preload("res://levels/planet_chunks/landing_rooms/landing_1_3.tscn"),
	#		preload("res://levels/planet_chunks/landing_rooms/landing_1_4.tscn"),
	#		preload("res://levels/planet_chunks/landing_rooms/landing_1_5.tscn"),
			],
		"corridor":[
			preload("res://levels/planet_chunks/corridor_rooms/corridor_0_1.tscn"),
			preload("res://levels/planet_chunks/corridor_rooms/corridor_1_1.tscn"),
			preload("res://levels/planet_chunks/corridor_rooms/corridor_1_2.tscn"),
			preload("res://levels/planet_chunks/corridor_rooms/corridor_1_3.tscn"),
			preload("res://levels/planet_chunks/corridor_rooms/corridor_1_4.tscn"),
			preload("res://levels/planet_chunks/corridor_rooms/corridor_1_5.tscn"),
			],
		"drop":[
			preload("res://levels/planet_chunks/drop_rooms/drop_0_1.tscn"),
			preload("res://levels/planet_chunks/drop_rooms/drop_1_1.tscn"),
			preload("res://levels/planet_chunks/drop_rooms/drop_1_2.tscn"),
			preload("res://levels/planet_chunks/drop_rooms/drop_1_3.tscn"),
			preload("res://levels/planet_chunks/drop_rooms/drop_1_4.tscn"),
			preload("res://levels/planet_chunks/drop_rooms/drop_1_5.tscn"),
			],
		"other":[]
	},
	"double_jump" : {
		"landing":[
			
		],
		"corridor":[
			
		],
		"drop":[
			
		],
		"other":[
			
		]
	},
}

func instance_room(room_type,planet_type,room_number):
	return rooms[planet_type][room_type][room_number]

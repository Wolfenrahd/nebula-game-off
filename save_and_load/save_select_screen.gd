extends Control

var stats = Stats
var utils = Utils
var sounds = Sounds
var save_and_load = SaveAndLoad

var next_board = "res://menus/main_menu.tscn"

var save_names = ["save_1","save_2","save_3"]
@onready var save_1 = $CenterContainer/HBoxContainer/save_1
@onready var save_2 = $CenterContainer/HBoxContainer/save_2
@onready var save_3 = $CenterContainer/HBoxContainer/save_3
@onready var save_buttons = [save_1,save_2,save_3]

@onready var name_save = $name_save
@onready var save_name_edit = $name_save/CenterContainer/VBoxContainer/save_name_edit

func _ready():
	update_buttons()


func update_buttons():
	for i in save_names.size():
		save_and_load.change_save_location(save_names[i])
		save_and_load.load_data()
		save_and_load.save_all()
		save_buttons[i].text = stats.save_data["save_name"]

func load_game(save_name):
	save_and_load.change_save_location(save_name)
	save_and_load.load_data()
	if stats.save_data.new_save:
		name_save.visible = true
	else:
		stats.rng.seed = stats.save_data.seed
		stats.rng.state = stats.save_data.seed_state
		stats.save_data.power_on_count += 1
		save_and_load.update_save_data()
		get_tree().change_scene_to_file(next_board)

func new_save():
	stats.save_data.save_name = save_name_edit.text
	stats.save_data.new_save = false
	stats.save_data.power_on_count += 1
	save_and_load.update_save_data()
	get_tree().change_scene_to_file(next_board)

func _on_save_1_pressed():
	load_game(save_names[0])

func _on_save_2_pressed():
	load_game(save_names[1])

func _on_save_3_pressed():
	load_game(save_names[2])

func _on_enter_save_name_button_pressed():
	new_save()

func _on_save_name_edit_text_submitted(_new_text):
	new_save()

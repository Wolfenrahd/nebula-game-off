extends Control

var stats = Stats
var save_and_load = SaveAndLoad

@onready var dev_mode_message = $dev_mode_message

@onready var continue_button = $CenterContainer/VBoxContainer/continue_button
@onready var volume_menu = $volume_menu
@onready var space_test_button = $CenterContainer/VBoxContainer/space_test_button

@onready var seed_edit = $set_seed/seed_edit
@onready var seed_edit_regex = RegEx.new()
var old_text = ""

var save_select_board = "res://save_and_load/save_select_screen.tscn"
var game_board = "res://levels/world.tscn"
#var game_board = "res://levels/space.tscn"
var settings_board = "res://menus/settings_menu.tscn"

func _ready():
	if stats.dev_mode:
		dev_mode_message.visible = true
	seed_edit_regex.compile("^[0-9]*$")
	if stats.save_data.current_game:
		continue_button.visible = true
		space_test_button.visible = true
	else:
		continue_button.visible = false
		space_test_button.visible = false
	#print(stats.save_data)

func _on_continue_buton_pressed():
	get_tree().change_scene_to_file(stats.save_data.run_data.current_location)

func _on_new_game_button_pressed():
	if seed_edit.text:
		stats.save_data.seed = int(seed_edit.text)
	else:
		stats.rng.randomize()
		if stats.rng.seed < 0:
			stats.rng.seed *= -1
		stats.save_data.seed = stats.rng.seed
	stats.rng.seed = stats.save_data.seed
	stats.reset_run()
	stats.save_data.current_game = true
	stats.save_data.run_data.current_planet = stats.save_data.run_data.zones[0][0]["planets"][0]
	save_and_load.update_save_data()
	get_tree().change_scene_to_file(stats.save_data.run_data.current_location)

func _on_sounds_button_pressed():
	volume_menu.visible = true

func _on_settings_button_pressed():
	get_tree().change_scene_to_file(settings_board)

func _on_seed_edit_text_changed(new_text):
	if seed_edit_regex.search(new_text):
		old_text = str(new_text)
	else:
		seed_edit.text = old_text
		seed_edit.caret_column = seed_edit.text.length()

func _on_seed_button_pressed():
	seed_edit.visible = true
	seed_edit.grab_focus()

func _on_back_button_pressed():
	get_tree().change_scene_to_file(save_select_board)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_space_test_button_pressed():
	get_tree().change_scene_to_file("res://test_remove_before_export/space_test.tscn")

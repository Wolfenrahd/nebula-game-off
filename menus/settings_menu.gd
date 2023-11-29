extends Control

var stats = Stats
var save_and_load = SaveAndLoad

var main_menu_board = "res://menus/main_menu.tscn"
var save_select_board = "res://save_and_load/save_select_screen.tscn"

@onready var confirm_delete_menu = $confirm_delete_menu



func _on_delete_save_button_pressed():
	confirm_delete_menu.visible = true

func _on_cancel_button_pressed():
	confirm_delete_menu.visible = false

func _on_confirm_button_pressed():
	stats.reset_run()
	stats.delete_save()
	save_and_load.update_save_data()
	get_tree().change_scene_to_file(save_select_board)

func _on_back_button_pressed():
	get_tree().change_scene_to_file(main_menu_board)

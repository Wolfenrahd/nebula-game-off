extends Control

@onready var exit_button = $CenterContainer/VBoxContainer/exit_button

func _ready():
	exit_button.grab_focus()

func _on_exit_button_pressed():
	get_tree().quit()

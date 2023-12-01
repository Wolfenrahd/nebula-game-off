extends Node2D

var stats = Stats
var save_data = Stats.save_data["run_data"]

@onready var player = $player_ship
@onready var main_cam = $main_cam

func _ready():
	player.global_position = save_data["space_location"]
#	player.connect("player_dead",player_dead)
	main_cam.change_target(player.camera_follow)
	RenderingServer.set_default_clear_color(Color.BLACK)
	#$Area2D.connect("mouse_entered",_on_enter)

func _on_enter():
	print("hey")

func change_camera_target(new_target):
	main_cam.change_target(new_target)

func player_dead():
	change_camera_target(null)


func _on_strafe_toggled(button_pressed):
	player.strafe = button_pressed

func _on_follow_mouse_toggled(button_pressed):
	player.follow_mouse = button_pressed


func _on_area_2d_mouse_entered():
	print("hey")

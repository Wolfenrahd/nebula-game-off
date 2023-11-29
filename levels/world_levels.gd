extends Node2D

@onready var player = $player
@onready var main_cam = $main_cam

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("player_dead",player_dead)
	main_cam.change_target(player.camera_follow)
	RenderingServer.set_default_clear_color(Color("45b176"))

func change_camera_target(new_target):
	main_cam.change_target(new_target)

func player_dead():
	change_camera_target(null)

var leaving = false
func _on_ship_landed_ship_take_off():
	if !leaving:
		leaving = true
		main_cam.change_target(null)
		player.queue_free()
		main_cam.fade_out()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://levels/space.tscn")

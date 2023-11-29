extends Node2D

var utils = Utils

const BULLET_SCENE = preload("res://items/bullet.tscn")

@onready var blaster_sprite = $blaster_sprite
@onready var muzzle = $blaster_sprite/muzzle
@onready var fire_rate_timer = $fire_rate_timer

func _process(delta):
	blaster_sprite.rotation = get_local_mouse_position().angle()
#	print(rad_to_deg(blaster_sprite.rotation))

#func _input(event):
#	if event is InputEventJoypadMotion:
#		blaster_sprite.rotation = event.axis_value
#		print(
#				"Device: %s. Joypad Axis Index: %s. Strength: %s."
#				% [event.device, event.axis, event.axis_value]
#		)

func fire_bullet():
	if !fire_rate_timer.time_left > 0.0:
		fire_rate_timer.start()
		var bullet = utils.instantiate_scene_on_world(BULLET_SCENE,muzzle.global_position)
		bullet.rotation = blaster_sprite.rotation


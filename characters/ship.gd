extends CharacterBody2D

class_name Ship

var utils = Utils

const BULLET_SCENE = preload("res://items/bullet.tscn")

@export var bullet_speed = 3125
@export var bullet_scale = Vector2(4,4)

@onready var guns = $guns
@onready var fire_rate_timer = $fire_rate_timer

#func _physics_process(delta: float) -> void:
#
#	move_and_slide()

func fire_bullet():
	if !fire_rate_timer.time_left > 0.0:
		fire_rate_timer.start()
		for child in guns.get_children():
			var bullet = utils.instantiate_scene_on_world(BULLET_SCENE,child.global_position)
			bullet.speed = bullet_speed
			bullet.scale = bullet_scale
			bullet.rotation = rotation
		Sounds.play_sfx("laser")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "land":
		queue_free()

func land() -> void:
	$AnimationPlayer.play("land")

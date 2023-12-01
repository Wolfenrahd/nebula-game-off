extends Node2D

const plant_bullet_scene = preload("res://items/plant_bullet.tscn")

@onready var character_stats = $character_stats
@onready var bullet_spawn_point = $bullet_spawn_point
@onready var fire_direction = $fire_direction

@export var bullet_speed =40
@export var bullet_spread = 45

var target 

func _ready():
	target = get_tree().current_scene.player

func _process(delta):
	if target != null:
		if global_position.x - target.global_position.x < 0:
			scale.x = 1
		else:
			scale.x = -1

func fire_bullet():
	var bullet = Utils.instantiate_scene_on_world(plant_bullet_scene,bullet_spawn_point.global_position) as Projectile
	var direction = bullet_spawn_point.position.direction_to(fire_direction.position)*scale.x
	var velocity = direction.normalized() * bullet_speed
	velocity = velocity.rotated(randf_range(-deg_to_rad(bullet_spread/2),deg_to_rad(bullet_spread/2)))
	bullet.velocity = velocity
	bullet.auto_velocity = false

func _on_character_stats_no_health():
	queue_free()

func _on_hurtbox_hurt(hitbox, damage):
	character_stats.health -= damage

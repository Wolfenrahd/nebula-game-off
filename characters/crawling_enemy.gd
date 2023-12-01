extends Node2D

var stats = Stats

@onready var floor_cast = $floor_cast
@onready var wall_cast = $wall_cast
@onready var character_stats = $character_stats
@onready var lost_floor_timer = $lost_floor_timer

enum direction {LEFT = -1, RIGHT = 1}
var updated_direction = false

var crawling_direction = direction.RIGHT
var max_speed = 150

func _process(delta):
	if !updated_direction:
		var rng = RandomNumberGenerator.new()
		rng.seed = global_position.x+stats.save_data.run_data.current_planet.planet_seed
		if rng.randi_range(0,1) == 0:
			crawling_direction = direction.LEFT
		wall_cast.target_position.x *= crawling_direction
		updated_direction = true

func _physics_process(delta):
	if wall_cast.is_colliding():
		global_position = wall_cast.get_collision_point()
		var wall_normal = wall_cast.get_collision_normal()
		rotation = wall_normal.rotated(deg_to_rad(90)).angle()
	else:
		floor_cast.rotation_degrees = -max_speed * crawling_direction * delta
		if floor_cast.is_colliding():
			global_position = floor_cast.get_collision_point()
			var floor_normal = floor_cast.get_collision_normal()
			rotation = floor_normal.rotated(deg_to_rad(90)).angle()
		else:
			rotation_degrees += crawling_direction * 2
	if !floor_cast.is_colliding():
		if lost_floor_timer.is_stopped():
			lost_floor_timer.start(.5)
	else:
		lost_floor_timer.stop()

func _on_character_stats_no_health():
	queue_free()

func _on_hurtbox_hurt(hitbox, damage):
	character_stats.health -= damage

func _on_lost_floor_timer_timeout():
	print("dead")
	queue_free()

extends CharacterBody2D

var stats = Stats
var current_planet_index = stats.save_data.run_data.current_planet["planet_index"]

@export var max_fall_velocity = 50
@export var gravity = 100
@export_enum("missile","bullet","health") var pickup_type : String

func _physics_process(delta):
	apply_gravity(delta)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func _on_interactable_area_interact():
	Sounds.play_sfx("upgrade")
	stats.save_data["run_data"]["zones"][current_planet_index.y][current_planet_index.x]["planets"][current_planet_index.z]["persistant_data"]["destroyed_interactables"].append(position)
	stats.save_data.run_data[pickup_type] = true
	queue_free()


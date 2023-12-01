extends CharacterBody2D

var stats = Stats
var current_planet_index = stats.save_data.run_data.current_planet["planet_index"]

@onready var upgrade_particles = $upgrade_particles

@export var max_fall_velocity = 50
@export var gravity = 100
@export_enum("wall_jump_unlocked","air_jump_unlocked","wall_climbing_unlocked","missiles_unlocked","teleport_unlocked") var unlockable : String
@export_enum("unlockable","upgrade") var type : String

func _physics_process(delta):
	apply_gravity(delta)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func _on_interactable_area_interact():
	Sounds.play_sfx("upgrade")
	if type == "unlockable":
		stats.save_data["run_data"]["zones"][current_planet_index.y][current_planet_index.x]["planets"][current_planet_index.z]["persistant_data"]["destroyed_interactables"].append(position)
		stats.save_data.run_data[unlockable] = true
	if type == "upgrade":
		pass
	queue_free()

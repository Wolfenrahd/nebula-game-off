extends CharacterBody2D

signal ship_take_off

@export var max_fall_velocity = 160
@export var gravity = 200

func _on_interactable_area_interact():
	ship_take_off.emit()

func _physics_process(delta):
	apply_gravity(delta)
	move_and_slide()


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

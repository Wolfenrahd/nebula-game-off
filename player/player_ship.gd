extends Ship

var stats = Stats

@export var strafe = true
@export var follow_mouse = true


@onready var camera_follow = $camera_follow
#@onready var sprite_2d = $Sprite2D


@export var forward_acceleration = 10
@export var max_forward_velocity = 1000
@export var rotation_speed = 150
@export var friction = 1

var state = move_state

signal player_dead()

func _ready():
	pass
#	Stats.no_health.connect(die)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action") and $InteractArea.get_overlapping_areas().size() > 0:
		var location = $InteractArea.get_overlapping_areas()[0]
		if location is Planet:
			stats.save_data.run_data.current_planet = location.data
			stats.save_data.run_data.space_location = position
			stats.save_data.run_data.current_location = "res://levels/world.tscn"
			SaveAndLoad.update_save_data()
			#print($InteractArea.get_overlapping_areas()[0].data)
			#print("***********")
			#var current_planet_index = stats.current_planet.planet_index
			#print(stats.save_data["run_data"]["zones"][current_planet_index.y][current_planet_index.x]["planets"][current_planet_index.z])
			get_tree().change_scene_to_file(stats.save_data.run_data.current_location)

func _physics_process(delta):
	state.call(delta)
	if Input.is_action_pressed("left_click"):
		fire_bullet()

func move_state(delta):
	var input_vector = Vector2(Input.get_axis("down", "up"),0)
	if strafe and follow_mouse:
		input_vector = Vector2(Input.get_axis("down", "up"),Input.get_axis("left","right"))

	var input_axis = Input.get_axis("left","right")
	if is_moving(input_vector):
		apply_acceleration(delta,input_vector)
	if follow_mouse:
		look_at(get_global_mouse_position())
	else:
		if is_rotating(input_axis):
			apply_rotation(delta,input_axis)
	
	apply_friction(delta,input_vector)
	move_and_slide()
	return

func is_moving(input_vector):
	return input_vector != Vector2.ZERO

func is_rotating(input_axis):
	return input_axis != 0

func apply_acceleration(delta, input_vector):
	#print(input_vector)
	velocity += input_vector.rotated(rotation) * forward_acceleration
	velocity = velocity.limit_length(max_forward_velocity)

func apply_rotation(delta, input_axis):
	rotate(deg_to_rad(rotation_speed*input_axis*delta))

func apply_friction(delta,input_vector):
	if input_vector == Vector2.ZERO:
		velocity.y = move_toward(velocity.y, 0, friction * delta)
		velocity.x = move_toward(velocity.x, 0, friction * delta)






func _on_interact_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

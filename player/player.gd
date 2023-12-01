extends CharacterBody2D

var utils = Utils
var save_data = Stats.save_data["run_data"]
var stats = Stats

const DUST_EFFECT_SCENE = preload("res://effects/dust_effect.tscn")
const JUMP_EFFECT_SCENE = preload("res://effects/jump_effect.tscn")
const AIR_JUMP_EFFECT_SCENE = preload("res://effects/air_jump_effect.tscn")
const WALL_JUMP_EFFECT_SCENE = preload("res://effects/wall_jump_effect.tscn")

@onready var camera_follow = $camera_follow
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var blinking_animation_player = $blinking_animation_player
@onready var coyote_jump_timer = $coyote_jump_timer
@onready var player_arm = $player_arm
@onready var hurtbox = $hurtbox
@onready var interact_icon = $interact_icon

@export var acceleration = 512
@export var max_velocity = 80
@export var friction = 256
@export var air_friction = 64
@export var max_fall_velocity = 128
@export var gravity = 200
@export var jump_force = 128
@export var max_wall_slide_speed = 128
@export var wall_slide_speed = 42
@export var wall_climb_speed = 21

var air_jump = false
var state = move_state

signal player_dead()


func _ready():
	Stats.no_health.connect(die)

func _physics_process(delta):
	state.call(delta)
	if Input.is_action_pressed("left_click"):
		player_arm.fire_bullet()

func move_state(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("left", "right")
	if is_moving(input_axis):
		apply_acceleration(delta,input_axis)
	else:
		apply_friction(delta)
	jump_check()
	if Input.is_action_pressed("down"):
		set_collision_mask_value(2,false)
	else:
		set_collision_mask_value(2,true)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()
	wall_check()

func wall_slide_state(delta):
	var wall_normal = sign(get_wall_normal().x)
	if Input.is_action_pressed("up") && stats.save_data.run_data["wall_climbing_unlocked"]:
		animation_player.play("wall_climb")
	else:
		animation_player.play("wall_slide")
	sprite_2d.scale.x = wall_normal
	velocity.y = clampf(velocity.y, -max_wall_slide_speed, max_wall_slide_speed)
	wall_jump_check(wall_normal)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detach(delta)

func wall_check():
	if not is_on_floor() and is_on_wall() or Input.is_action_pressed("up") and is_on_wall() and stats.save_data.run_data["wall_climbing_unlocked"]:
		state = wall_slide_state
		air_jump = true
#		create_dust_effect()

func wall_detach(delta):
	if Input.is_action_just_pressed("right"):
		velocity.x = acceleration * delta
		state = move_state
	if Input.is_action_just_pressed("left"):
		velocity.x = -acceleration * delta
		state = move_state
	if not is_on_wall() and not is_on_ceiling() or is_on_floor():
		state = move_state

func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed("jump") and stats.save_data.run_data["wall_jump_unlocked"]:
		velocity.x = wall_axis * max_velocity
		state = move_state
		jump(jump_force*0.75,false)
		var wall_jump_effect_position = global_position+Vector2(wall_axis*3.5,-2)
		var wall_jump_effect = utils.instantiate_scene_on_world(WALL_JUMP_EFFECT_SCENE,wall_jump_effect_position)
		wall_jump_effect.scale.x = wall_axis

func apply_wall_slide_gravity(delta):
	var slide_speed = wall_slide_speed
	if Input.is_action_pressed("up") && stats.save_data.run_data["wall_climbing_unlocked"]:
		slide_speed = -wall_climb_speed
	elif Input.is_action_pressed("down"):
		slide_speed = max_wall_slide_speed
	else:
		slide_speed = wall_slide_speed
	velocity.y = move_toward(velocity.y, slide_speed, gravity * delta)

func create_dust_effect():
	utils.instantiate_scene_on_world(DUST_EFFECT_SCENE,global_position)

func is_moving(input_axis):
	return input_axis != 0

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func apply_acceleration(delta, input_axis):
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)

func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)

func jump_check():
	if is_on_floor():
		air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			jump(jump_force)
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < -jump_force / 2:
			velocity.y = -jump_force / 2
		if Input.is_action_just_pressed("jump") and air_jump and stats.save_data.run_data["air_jump_unlocked"]:
			jump(jump_force * 0.75,false,true)
			air_jump = false

func jump(force, create_effect = true, air_jump = false):
	velocity.y = -force
	if create_effect:
		utils.instantiate_scene_on_world(JUMP_EFFECT_SCENE,global_position)
	if air_jump:
		utils.instantiate_scene_on_world(AIR_JUMP_EFFECT_SCENE,global_position+Vector2(0,10))


func update_animations(input_axis):
	sprite_2d.scale.x = sign(get_local_mouse_position().x)
	if abs(sprite_2d.scale.x) != 1: sprite_2d.scale.x = 1
	if is_moving(input_axis):
		animation_player.play("run")
		animation_player.speed_scale = input_axis * sprite_2d.scale.x
	else:
		animation_player.play("idle")
	
	if not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		else:
			animation_player.play("fall")

func _on_hurtbox_hurt(hitbox, damage):
#	camera_2d.reparent(get_tree().current_scene)
	Events.add_screen_shake.emit(3,.2)
	Stats.health -= 1
	blinking_animation_player.play("blink")

func die():
	player_dead.emit()
	queue_free()

func _on_interact_area_area_entered(area):
	interact_icon.visible = true
	area.interactable = true

func _on_interact_area_area_exited(area):
	interact_icon.visible = false
	area.interactable = false

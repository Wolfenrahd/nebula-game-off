extends CharacterBody2D

@onready var sprite = $sprite
@onready var floor_cast = $floor_cast
@onready var character_stats = $character_stats

@export var speed = 30.0
@export var turns_at_ledges = true
@export var face_left = false

var gravity = 200
var direction = 1.0

func _ready():
	if face_left:
		turn_around()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_wall():
		turn_around()
	
	if is_at_ledge() and turns_at_ledges:
		turn_around()
	
	velocity.x = direction * speed
	sprite.scale.x = direction
	
	move_and_slide()

func is_at_ledge():
	return is_on_floor() and not floor_cast.is_colliding()

func turn_around():
	direction *= -1


func _on_hurtbox_hurt(hitbox, damage):
	character_stats.health -= damage


func _on_character_stats_no_health():
	queue_free()

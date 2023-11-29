extends Camera2D

var target
var shake = 0
var transition_time = 2

@onready var timer = $Timer
@onready var fade_screen = $fade_screen

signal done_with_fade

func _ready():
	fade_in()
	Events.add_screen_shake.connect(start_screen_shake)

func start_screen_shake(amount, duration):
	shake = amount
	timer.start(duration)

func _process(delta):
	offset.x = randf_range(-shake, shake)
	offset.y = randf_range(-shake, shake)

func _physics_process(delta):
	if target:
		position = get_parent().to_local(target.global_position)

func change_target(new_target):
	target = new_target

func _on_timer_timeout():
	shake = 0

func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property(fade_screen,"self_modulate",Color("ffffff00"),transition_time)

func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(fade_screen,"self_modulate",Color("ffffff"),transition_time)

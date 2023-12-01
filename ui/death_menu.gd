extends HBoxContainer

@onready var timer = $PanelContainer/Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_timer() -> void:
	timer.start()


func _on_timer_timeout():
	show()
	get_tree().paused = true

func resume() -> void:
	hide()
	get_tree().paused = false

func _on_reload_save_pressed():
	resume()
	SaveAndLoad.load_data()
	get_tree().reload_current_scene()


func _on_main_menu_pressed():
	resume()
	SaveAndLoad.load_data()
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


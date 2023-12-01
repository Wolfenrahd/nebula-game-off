extends HBoxContainer

var stats = Stats
@onready var seed_label = $PanelContainer/VBoxContainer/seed_label

# Called when the node enters the scene tree for the first time.
func _ready():
	seed_label.text = "Seed: %s" % [str(stats.rng.seed)]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pause() -> void:
	get_tree().paused = true
	show()

func resume() -> void:
	get_tree().paused = false
	hide()


func _on_resume_pressed():
	resume()
	print("resume")


func _on_reload_save_pressed():
	resume()
	SaveAndLoad.load_data()
	get_tree().reload_current_scene()


func _on_main_menu_pressed():
	resume()
	SaveAndLoad.load_data()
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

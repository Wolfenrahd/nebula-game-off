extends TextureRect

var stats = Stats
var utils = Utils
var sounds = Sounds

var next_board = "res://save_and_load/save_select_screen.tscn"

@onready var timer = $Timer
@onready var easter_egg_button = $easter_egg_button

var easter_egg_audio = "angel_1_1"

func _ready():
	stats.rng.randomize()
	if stats.rng.seed < 0:
		stats.rng.seed = stats.rng.seed*-1
	easter_egg_button.grab_focus()
	SaveAndLoad.load_settings()
	utils.set_volume()
	sounds.play_sfx("smell_this_bread")

func _on_timer_timeout():
	get_tree().change_scene_to_file(next_board)

func _on_easter_egg_button_pressed():
	easter_egg_button.disabled = true
	timer.stop()
	sounds.play_sfx(easter_egg_audio)
	timer.start(sounds.sfx[easter_egg_audio].get_length())

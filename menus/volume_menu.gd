extends Control

var utils = Utils

const master_bus_name = "Master"
const music_bus_name = "Music"
const sfx_bus_name = "SFX"
const voice_bus_name = "Voice"

signal hide_menu

@onready var master_bus = AudioServer.get_bus_index(master_bus_name)
@onready var music_bus = AudioServer.get_bus_index(music_bus_name)
@onready var sfx_bus = AudioServer.get_bus_index(sfx_bus_name)
@onready var voice_bus = AudioServer.get_bus_index(voice_bus_name)

@onready var master_slider = $CenterContainer/VBoxContainer/master/master_slider
@onready var music_slider = $CenterContainer/VBoxContainer/music/music_slider
@onready var sfx_slider = $CenterContainer/VBoxContainer/sfx/sfx_slider
@onready var voice_slider = $CenterContainer/VBoxContainer/voice/voice_slider

func _ready():
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	voice_slider.value = db_to_linear(AudioServer.get_bus_volume_db(voice_bus))
	master_slider.grab_focus()

func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	utils.volume_settings["master_volume"] = value

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	utils.volume_settings["music_volume"] = value

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	utils.volume_settings["sfx_volume"] = value

func _on_voice_slider_value_changed(value):
	AudioServer.set_bus_volume_db(voice_bus, linear_to_db(value))
	utils.volume_settings["voice_volume"] = value

func _on_back_button_pressed():
	SaveAndLoad.update_settings()
	visible = false

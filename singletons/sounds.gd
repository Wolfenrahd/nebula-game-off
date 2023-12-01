extends Node

@onready var sfx_players = $sfx.get_children()
@onready var music_player =$music
@onready var voice_player = $voice

var sfx_path = "res://assets/sfx/"
var music_path = "res://assets/music/"
var voice_path = "res://assets/voice/"

var sfx = {
	"smell_this_bread" : load(sfx_path+"smell_this_bread.wav"),
	"angel_1_1" : load(sfx_path+"angel_1_1.wav"),
	"laser": load(sfx_path+"laser.wav"),
	"wall_hit": load(sfx_path+"wall_hit.wav"),
	"enemy_hit": load(sfx_path+"enemy_hit.wav"),
	"upgrade": load(sfx_path+"upgrade.wav")
	}

var music = {
	"dread_of_space": load("res://assets/music/dread_of_space.ogg"),
	"wonders_of_space": load("res://assets/music/wonders_of_space.ogg"),
	"misadventures_of_space": load("res://assets/music/misadventures_of_space.ogg"),
	"misadventures_of_planet": load("res://assets/music/misadventures_of_planet.ogg")
}

var space_music = [
	"dread_of_space",
	"wonders_of_space",
]

var voice = {}

var music_playing = null

func play_sfx(sfx_string, pitch_scale = 1, volume_db = 0):
	for sfx_player in sfx_players:
		if !sfx_player.playing:
			sfx_player.pitch_scale = pitch_scale
			sfx_player.volume_db = volume_db
			sfx_player.stream = sfx[sfx_string]
			sfx_player.play()
			return
	print("Too many sounds playing")

func play_music(music_string, pitch_scale = 1, volume_db = 0):
	if music_playing != music_string:
		music_player.pitch_scale = pitch_scale
		music_player.volume_db = volume_db
		music_player.stream = music[music_string]
		music_player.play()
		music_playing = music_string

func play_voice(voice_string, pitch_scale = 1, volume_db = 0):
	if voice_player.playing:
		voice_player.stop()
	voice_player.pitch_scale = pitch_scale
	voice_player.volume_db = volume_db
	voice_player.stream = voice[voice_string]
	voice_player.play()


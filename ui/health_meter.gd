extends Control

var stats = Stats

@onready var empty = $empty
@onready var full = $full

func _ready():
	update_health_ui()
	update_max_health_ui()
	stats.health_changed.connect(update_health_ui)
	stats.max_health_changed.connect(update_max_health_ui)

func update_health_ui():
	full.size.x = stats.health*5+1

func update_max_health_ui():
	empty.size.x = stats.max_health*5+1

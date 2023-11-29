extends Button

signal zone_pressed

var coords = Vector2.ZERO
var current := false

var faction_color_panels := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for faction_name in Stats.save_data.run_data.government_factions.keys():
		var panel = preload("res://ui/faction_color_panel.tscn").instantiate()
		add_child(panel)
		
		faction_color_panels[faction_name] = panel
		panel.modulate = Stats.save_data.run_data.government_factions[faction_name]["color"]
		panel.modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	emit_signal("zone_pressed", self)

func set_current(value) -> void:
	current = value
	$CurrentIndicator.visible = current
	

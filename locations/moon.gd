extends Area2D

var orbit_radius = 256

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Surface/Terrain.region_rect.position = Vector2(randf() * 512, randf() * 512)
	$Surface/Terrain.rotate(randf() * TAU)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

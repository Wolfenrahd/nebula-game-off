extends Node2D

@onready var player = $player

var rng = RandomNumberGenerator.new()
var arr = [1,2,3,4,5,6,7,8,9]
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in arr:
		print(i)
	for i in arr.size():
		print(i)
#	rng.seed = -1757757328032503101
#	print(rng.seed)
#	print(rng.state)
#	var x = rng.randi()
#	print(x)
#	print(rng.seed)
#	print(rng.state)
#	print("-------")
#	rng.seed = -1757757328032503101
#	print(rng.seed)
#	print(rng.state)
#	x = rng.randi()
#	print(x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_mouse_entered():
	print(true)

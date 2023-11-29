extends Area2D

signal interact

var interactable = false

func _process(delta):
	if Input.is_action_just_pressed("action") and interactable:
		interact.emit()

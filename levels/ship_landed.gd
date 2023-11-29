extends Node2D

signal ship_take_off


func _on_interactable_area_interact():
	ship_take_off.emit()

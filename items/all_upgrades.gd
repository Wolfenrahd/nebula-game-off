extends Node
class_name All_Upgrades

var stats = Stats

var upgrades = {
	"wall_climbing_unlocked":preload("res://items/climbing_boots.tscn"),
	"air_jump_unlocked":preload("res://items/double_jump.tscn"),
	"missiles_unlocked":preload("res://items/missiles_unlock.tscn"),
	"teleport_unlocked":preload("res://items/teleport_unlock.tscn"),
	#"wall_jump":preload("res://items/double_jump.tscn"),
	
}

func instance_upgrade(upgrade_type):
	return upgrades[upgrade_type]

func list_available_unlockables():
	var list = []
	for unlockable in stats.unlockables:
		if !stats.save_data.run_data[unlockable]:
			list.append(unlockable)
	return list

extends Node
class_name All_Enemies

var enemies = {
	0 : [
		preload("res://characters/walking_enemy.tscn"),
		preload("res://characters/standing_plant_enemy.tscn"),
		preload("res://characters/crawling_enemy.tscn"),
	],
	1 : [
		preload("res://characters/walking_enemy.tscn"),
		preload("res://characters/standing_plant_enemy.tscn"),
		preload("res://characters/crawling_enemy.tscn"),
	] ,
	2 : [
		preload("res://characters/walking_enemy.tscn"),
		preload("res://characters/standing_plant_enemy.tscn"),
		preload("res://characters/crawling_enemy.tscn"),
	],
	3 : [
		preload("res://characters/walking_enemy.tscn"),
		preload("res://characters/standing_plant_enemy.tscn"),
		preload("res://characters/crawling_enemy.tscn"),
	]
}

func instance_enemy(planet_type,enemy_number):
	return enemies[planet_type][enemy_number]

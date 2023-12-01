extends Area2D
class_name Hitbox

@export var damage = 1

func _on_area_entered(hurtbox):
	if not hurtbox is Hurtbox:
		Sounds.play_sfx("wall_hit")
		return
	hurtbox.take_hit(self, damage)
	Sounds.play_sfx("enemy_hit")

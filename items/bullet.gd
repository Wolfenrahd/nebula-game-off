extends Projectile

func _ready():
	projectile_type = "bullet"
	#projectile_type = "missile"
	set_physics_process(false)

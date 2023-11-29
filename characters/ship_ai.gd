extends Ship

enum States {
	FOLLOW,
	IDLE,
	ATTACK,
	PATROL,
	TRAVEL,
	ORBIT
}

var attack_target = null
var patrol_target = null
var land_target = null
var orbit_target = null
var follow_target = null

var top_speed = 1000

var factions := []

func _physics_process(delta: float) -> void:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if attack_target != null:
		travel_to(attack_target.global_position, 128, delta)
		if abs(get_angle_to(attack_target.global_position)) < TAU / 8 and \
		attack_target.global_position.distance_to(global_position) < 1024:
			fire_bullet()
	elif land_target != null:
		travel_to(land_target.global_position, 0, delta)
		if land_target.global_position.distance_to(global_position) < land_target.radius:
			land()
			attack_target = null
			patrol_target = null
			land_target = null
			orbit_target = null
			follow_target = null
	elif follow_target != null:
		travel_to(follow_target.global_position, 128, delta)
	elif orbit_target != null:
		travel_to(orbit_target.global_position, orbit_target.radius + 64, delta)
	
	move_and_slide()

func travel_to(target_pos, stop_distance, delta) -> void:
	stop_distance = 0
	var angle_to_target = get_angle_to(target_pos)
	rotation += angle_to_target * delta * randf_range(0, 14)
	
	var vector_to_target = target_pos - position
	
	var velocity_angle_to_target = velocity.normalized().angle_to(vector_to_target.normalized())
	velocity_angle_to_target = wrapf(velocity_angle_to_target, -TAU/2, TAU/2)
	
	var distance_to_target = vector_to_target.length()
	var speed = max((distance_to_target / 5) - stop_distance, 0) + 100
	
	for ship in get_tree().get_nodes_in_group("ships"):
		if ship == self:
			continue
		
		if global_position.distance_to(ship.global_position) < 128:
			velocity += (global_position - ship.global_position) * delta / 2
	
	if distance_to_target <= stop_distance:
		speed = 0
		velocity = lerp(velocity, Vector2.ZERO, delta * 2)
	elif distance_to_target < stop_distance + 192:
		speed = 20
		velocity = lerp(velocity, Vector2.ZERO, delta * 2)
	elif distance_to_target < stop_distance + 448:
		velocity = lerp(velocity, Vector2.ZERO, delta)
	elif abs(velocity_angle_to_target) > TAU / 5 and velocity.length() > 200:
		speed = 0
		rotation += get_angle_to(target_pos) * delta * 4
		velocity = lerp(velocity, Vector2.ZERO, delta * 2)
	
	velocity += Vector2(speed, 0).rotated(rotation) * delta
	
	if velocity.length() > top_speed:
		velocity = velocity.normalized() * top_speed

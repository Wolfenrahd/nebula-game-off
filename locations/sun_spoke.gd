extends Line2D

var sun = null
var anchor = null

var point_distance = 100.0
var point_count := 5

func _ready() -> void:
	clear_points()
	for i in point_count:
		add_point(Vector2.ZERO)

func _process(delta: float) -> void:
	if sun == null or anchor == null:
		return
	
	var anchor_pos = sun.to_local(anchor.global_position)
	
	var target_direction = anchor_pos.normalized()
	
	for i in points.size():
		if i == 0:
			points[0] = anchor_pos
			continue
		
		var direction_from_last_point = (points[i] - points[i - 1]).normalized()
		points[i] = lerp(points[i], anchor_pos + target_direction * point_distance * i, delta * (point_count - i))
		
		var outstreched_point = points[i - 1] + direction_from_last_point * point_distance
#		points[i] = lerp(outstreched_point, points[i], 0.5)

func set_anchor(_sun, _anchor) -> void:
	sun = _sun
	anchor = _anchor
	
	var anchor_pos = sun.to_local(anchor.global_position)
	
	var target_direction = anchor_pos.normalized()
	
	for i in points.size():
		if i == 0:
			points[0] = anchor_pos
			continue
		
		points[i] = anchor_pos + target_direction * point_distance * i

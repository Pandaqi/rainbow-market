extends Camera2D
class_name PuzzleCamera

var target : Rect2
var smooth_speed := 5.0

func set_target(new_target:Rect2) -> void:
	var update_instantly := !target
	target = new_target
	if update_instantly: set_position(target.get_center())

func _physics_process(dt: float) -> void:
	if not target: return
	
	var vp := get_viewport_rect().size
	var desired_zoom := vp / target.size
	var uniform_zoom := Vector2.ONE * minf(desired_zoom.x, desired_zoom.y)
	set_zoom(zoom.lerp(uniform_zoom, smooth_speed*dt))
	
	var desired_position := target.get_center()
	set_position(get_position().lerp(desired_position, smooth_speed*dt))

extends Node2D
class_name Tutorial

@export var indicator : Node2D

func _ready() -> void:
	indicator.hide()

func highlight_move(vis:PuzzleVisualizer) -> void:
	var current_color := vis.get_current_color()
	var possible_clients := vis.clients.filter(func(c:VisualClient): return c.has_color_in_order(current_color))
	var rand_client : VisualClient = possible_clients.pick_random()
	var rand_client_visual_color := rand_client.get_matching_color(current_color)
	
	var tw1 := play_highlight_tween(current_color)
	await tw1.finished
	var tw2 := play_highlight_tween(rand_client_visual_color)
	await tw2.finished
	
	indicator.show()
	var tw3 := play_indicator_tween(rand_client.global_position)
	await tw3.finished
	indicator.hide()

func play_highlight_tween(obj:Node2D) -> Tween:
	var tw_wiggle := get_tree().create_tween()
	var dur := randf_range(0.05, 0.15)
	var amplitude = randf_range(0.05, 0.1) * PI
	tw_wiggle.tween_property(obj, "rotation", -amplitude, dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", -amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", -amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", -amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", amplitude, 2*dur)
	tw_wiggle.tween_property(obj, "rotation", 0, dur)
	
	var tw := get_tree().create_tween()
	var dur_flash := 0.25
	tw.tween_property(obj, "modulate", Color(3, 3, 3), dur_flash)
	tw.tween_property(obj, "modulate", Color.WHITE, dur_flash)
	tw.tween_property(obj, "modulate", Color(2,2,2), dur_flash)
	tw.tween_property(obj, "modulate", Color.WHITE, dur_flash)
	tw.tween_property(obj, "modulate", Color(1.35, 1.35, 1.35), dur_flash)
	tw.tween_property(obj, "modulate", Color.WHITE, dur_flash)
	return tw

func play_indicator_tween(pos:Vector2) -> Tween:
	indicator.set_position(pos)
	
	var tw := get_tree().create_tween()
	tw.tween_property(indicator, "position", pos + Vector2.RIGHT*8.0, 0.5)
	tw.tween_property(indicator, "position", pos, 0.5)
	tw.tween_property(indicator, "position", pos + Vector2.RIGHT*8.0, 0.5)
	tw.tween_property(indicator, "position", pos, 0.5)
	tw.tween_property(indicator, "position", pos + Vector2.RIGHT*8.0, 0.5)
	tw.tween_property(indicator, "position", pos, 0.5)
	return tw

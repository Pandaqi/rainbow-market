extends Node2D
class_name Background

var bg_col := Color.GREEN

func set_color(c:VisualColor) -> void:
	bg_col = c.data.get_color()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1080,720)), bg_col, true)

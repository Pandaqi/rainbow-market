extends Node2D
class_name Background

var bg_col := Color.GREEN
var destroyed := false

@export var terrain : Terrain
@export var pattern : Sprite2D
@export var show_pattern := true

func _ready() -> void:
	pattern.set_visible(show_pattern)
	set_color_raw(PuzzleColor.get_color_as_object(PuzzleColor.ColorName.CYAN))

func set_color_raw(c:Color) -> void:
	bg_col = c
	terrain.set_color(bg_col)
	queue_redraw()

func set_color(c:VisualColor) -> void:
	set_color_raw(c.data.get_color())

func destroy() -> void:
	destroyed = true
	terrain.destroy()
	queue_redraw()

func _draw() -> void:
	var vp_size := get_viewport_rect().size
	draw_rect(Rect2(-2*vp_size, 4*vp_size), bg_col, true)
	if destroyed: return
	
	for i in range(4):
		var rand_size := randf_range(0.3, 1.0) * 500.0
		var rand_pos := PuzzleVisualizer.get_random_position_on_screen(0.5*Vector2(rand_size, rand_size))
		
		var tint_factor := 0.025
		var rand_tint := bg_col.darkened(tint_factor)
		draw_circle(rand_pos, 0.5*rand_size, rand_tint, true)

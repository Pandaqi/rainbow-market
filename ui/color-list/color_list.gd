extends Node2D
class_name ColorList

var colors : Array[VisualColor]

@export var color_visual : PackedScene
@export var size := 32.0
@export var margin := 4.0
@export var sort := false
@export var lock := false

func get_elements() -> Array[VisualColor]:
	return colors

func has_color(c:VisualColor) -> bool:
	for color in colors:
		if color.matches(c): return true
	return false

func add_color_raw(c:PuzzleColor) -> void:
	var cv : VisualColor = color_visual.instantiate()
	cv.set_from_data(c)
	add_color(cv)

func add_color(c:VisualColor) -> void:
	add_child(c)
	if lock: c.lock()
	colors.append(c)
	refresh()

func remove_color(c:VisualColor) -> VisualColor:
	colors.erase(c)
	refresh()
	return c

func remove_color_matching(c:VisualColor) -> VisualColor:
	for color in colors:
		if color.matches(c):
			return remove_color(color)
	return null

func remove_first() -> VisualColor:
	return remove_color(colors.front())

func count() -> int:
	return colors.size()

func is_empty() -> bool:
	return count() <= 0

func refresh() -> void:
	var num_colors := count()
	var size_final := size + margin
	var offset := -0.5 * (num_colors - 1) * size_final * Vector2.RIGHT
	
	if sort:
		colors.sort_custom(func(a:VisualColor, b:VisualColor): return a.data.name < b.data.name)
	
	for i in range(num_colors):
		var pos := offset + i * size_final * Vector2.RIGHT
		colors[i].set_position(pos)
		colors[i].set_size(size)

func get_first() -> VisualColor:
	return colors.front()
	

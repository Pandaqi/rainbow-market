class_name PuzzleColor

enum ColorName
{
	RED,
	BLUE,
	GREEN,
	YELLOW,
	ORANGE,
	PURPLE,
	PINK,
	CYAN,
	WHITE,
	BLACK
}

static var names_to_colors : Dictionary[ColorName, Color] = {
	ColorName.RED: Color.RED,
	ColorName.BLUE: Color.BLUE,
	ColorName.GREEN: Color.GREEN,
	ColorName.YELLOW: Color.YELLOW,
	ColorName.ORANGE: Color.ORANGE,
	ColorName.PURPLE: Color.PURPLE,
	ColorName.PINK: Color.PINK,
	ColorName.CYAN: Color.CYAN,
	ColorName.WHITE: Color.WHITE,
	ColorName.BLACK: Color(0.25, 0.25, 0.25),
}

var name : ColorName

func _init(cn:ColorName) -> void:
	name = cn

func get_color() -> Color:
	return names_to_colors[name]

func get_name() -> ColorName:
	return name

static func get_all_colors() -> Array[ColorName]:
	var arr : Array[ColorName] = []
	arr.assign(ColorName.values())
	return arr

static func get_random() -> ColorName:
	return get_all_colors().pick_random()

static func get_color_as_object(c:ColorName) -> Color:
	return names_to_colors[c]

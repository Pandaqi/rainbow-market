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
	WHITE,
	BLACK
}

var names_to_colors : Dictionary[ColorName, Color] = {
	ColorName.RED: Color.RED,
	ColorName.BLUE: Color.BLUE,
	ColorName.GREEN: Color.GREEN,
	ColorName.YELLOW: Color.YELLOW,
	ColorName.ORANGE: Color.ORANGE,
	ColorName.PURPLE: Color.PURPLE,
	ColorName.PINK: Color.PINK,
	ColorName.WHITE: Color.WHITE,
	ColorName.BLACK: Color.BLACK,
}

var name : ColorName

func _init(cn:ColorName) -> void:
	name = cn

func get_color() -> Color:
	return names_to_colors[name]

func get_name() -> ColorName:
	return name

static func get_random() -> ColorName:
	var all_options := ColorName.values()
	return all_options.pick_random()

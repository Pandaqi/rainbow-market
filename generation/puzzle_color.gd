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
	ColorName.BLACK: Color(0.25, 0.25, 0.25), # pure black is too dark to be practical
}

static var names_to_audio : Dictionary[ColorName, String] = {
	ColorName.RED: "red",
	ColorName.BLUE: "blue",
	ColorName.GREEN: "green",
	ColorName.YELLOW: "yellow",
	ColorName.ORANGE: "orange",
	ColorName.PURPLE: "purple",
	ColorName.PINK: "pink",
	ColorName.CYAN: "cyan",
	ColorName.WHITE: "white",
	ColorName.BLACK: "black",
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

static func convert_color_to_audio(c:ColorName) -> String:
	return "res://map/colors/sounds/" + names_to_audio[c] + ".ogg"

extends Node2D
class_name VisualColor

var data : PuzzleColor
var base_size := 128.0

@export var color_sprite : Sprite2D
@export var lock_sprite : Sprite2D

func set_from_data(c:PuzzleColor) -> void:
	data = c
	lock_sprite.hide()
	color_sprite.modulate = c.get_color()

func set_size(size:float) -> void:
	set_scale(Vector2.ONE * (size / base_size))

func matches(c:VisualColor) -> bool:
	return data.name == c.data.name

func lock() -> void:
	lock_sprite.show()

func bring_to_front() -> void:
	z_index = 10

func play_popup_tween() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tw.tween_property(self, "scale", scale * 2.0, 0.33)
	bring_to_front()
	await tw.finished

func play_unlock_tween() -> void:
	var dur := 0.4
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(lock_sprite, "scale", lock_sprite.scale * 1.5, dur)
	tw.parallel().tween_property(lock_sprite, "modulate:a", 0.0, dur)
	bring_to_front()
	await tw.finished

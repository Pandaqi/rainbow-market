extends Node2D
class_name VisualClient

var data : PuzzleClient

@export var reward : ColorList
@export var client_sprite : Sprite2D
@export var order : ColorList

@export var click_area : Area2D
@export var anim_player : AnimationPlayer
@export var audio_error : AudioStreamPlayer2D
@export var audio_positive : AudioStreamPlayer2D
@export var audio_unlock : AudioStreamPlayer2D
@export var audio_color : AudioStreamPlayer2D

signal clicked(c:VisualClient)

func _ready() -> void:
	click_area.input_event.connect(_on_input_event)
	anim_player.speed_scale = randf_range(0.8, 1.2)
	play_appear_tween()

func play_appear_tween() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.1, 0.6)
	set_scale(Vector2.ZERO)
	tw.tween_property(self, "scale", Vector2.ONE, dur)

func play_disappear_tween() -> Tween:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	var dur := randf_range(0.1, 0.3)
	tw.tween_property(self, "scale", Vector2.ZERO, dur)
	return tw

func on_order_mismatch() -> void:
	PuzzleFramework.play_audio_nice(audio_error)
	play_wiggle_tween()

func play_wiggle_tween() -> void:
	var tw := get_tree().create_tween()
	var dur := randf_range(0.1, 0.25)
	var amplitude = randf_range(0.05, 0.1) * PI
	tw.tween_property(client_sprite, "rotation", -amplitude, 0.25*dur)
	tw.tween_property(client_sprite, "rotation", amplitude, 0.5*dur)
	tw.tween_property(client_sprite, "rotation", 0, 0.25*dur)

func _on_input_event(_vp:Node, ev:InputEvent, _shape_idx:int) -> void:
	if not (ev is InputEventMouseButton or ev is InputEventScreenTouch): return
	if ev.is_pressed(): return
	clicked.emit(self)

func set_from_data(c:PuzzleClient) -> void:
	data = c
	
	for element in c.reward:
		reward.add_color_raw(PuzzleColor.new(element))
	
	for element in c.order:
		order.add_color_raw(PuzzleColor.new(element))

func set_animal_texture(type:String) -> void:
	client_sprite.texture = load("res://map/clients/animals/" + type + ".png")

func get_matching_color(c:VisualColor) -> VisualColor:
	for element in order.get_elements():
		if element.matches(c): return element
	return null

func has_color_in_order(c:VisualColor) -> bool:
	return get_matching_color(c) != null

func remove_color_from_order(c:VisualColor) -> void:
	PuzzleFramework.play_audio_nice(audio_positive)
	var sprite_removed := order.remove_color_matching(c)
	await sprite_removed.play_popup_tween()
	sprite_removed.queue_free()
	

func is_done() -> bool:
	return order.is_empty()

func on_removed(color_list:ColorList) -> void:
	for elem in reward.get_elements():
		PuzzleFramework.play_audio_nice(audio_unlock)
		await elem.play_unlock_tween()
		color_list.add_color_raw(elem.data)
	
	var tw := play_disappear_tween()
	await tw.finished	
	queue_free()

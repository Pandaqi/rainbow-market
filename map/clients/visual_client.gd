extends Node2D
class_name VisualClient

var data : PuzzleClient

@export var reward : ColorList
@export var client_sprite : Sprite2D
@export var order : ColorList

@export var click_area : Area2D
@export var anim_player : AnimationPlayer

signal clicked(c:VisualClient)

func _ready() -> void:
	click_area.input_event.connect(_on_input_event)
	anim_player.speed_scale = randf_range(0.8, 1.2)

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

func has_color_in_order(c:VisualColor) -> bool:
	for element in order.get_elements():
		if element.matches(c): return true
	return false

func remove_color_from_order(c:VisualColor) -> void:
	var sprite_removed := order.remove_color_matching(c)
	await sprite_removed.play_popup_tween()
	sprite_removed.queue_free()

func is_done() -> bool:
	return order.is_empty()

func on_removed(color_list:ColorList) -> void:
	for elem in reward.get_elements():
		await elem.play_unlock_tween()
		color_list.add_color_raw(elem.data)
	
	queue_free()

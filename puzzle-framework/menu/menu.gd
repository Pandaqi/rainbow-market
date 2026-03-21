extends Node2D
class_name PuzzleMenu

@export var button_container : VBoxContainer
@export var button_scene : PackedScene
@export var background : Control
@export var pattern : ColorRect
@export var label : Label

func _ready() -> void:
	create_buttons()
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()
	
	label.set_text("{game_name} v{game_version} | {game_tagline} | {creator_credit}".format({
		"game_name": PuzzleFramework.game_name,
		"game_version": PuzzleFramework.game_version,
		"game_tagline": PuzzleFramework.game_tagline,
		"creator_credit": PuzzleFramework.creator_credit
	}))
	
	background.set_visible(PuzzleFramework.menu_pattern_enabled)
	
	if PuzzleFramework.menu_scene_custom:
		add_child(PuzzleFramework.menu_scene_custom.instantiate())

func _on_size_changed():
	pattern.material.set_shader_parameter("viewport_size", get_viewport_rect().size)

func create_buttons() -> void:
	var diffs := PuzzleFramework.difficulties
	var tween_interval := 0.0
	for diff in diffs:
		var btn : PuzzleMenuButton = button_scene.instantiate()
		btn.sync_difficulty(diffs[diff])
		button_container.add_child(btn)
		btn.pressed.connect(func():
			PuzzleFramework.load_new_puzzle(diffs[diff])
		)
		
		var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		var dur := randf_range(0.4, 0.6)
		tw.tween_interval(tween_interval)
		tween_interval += 0.5*dur
		btn.modulate.a = 0.0
		tw.tween_property(btn, "modulate:a", 1.0, dur)

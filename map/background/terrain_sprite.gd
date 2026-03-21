extends Node2D
class_name TerrainSprite

@export var terrain_sprites : Array[Texture2D] = []
@export var scalings_allowed := [Vector2(0.25, 0.25), Vector2(0.5, 0.5), Vector2(0.75, 0.75)]

@export var sprite : Sprite2D

func _ready() -> void:
	sprite.texture = terrain_sprites.pick_random()
	
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	var dur := randf_range(0.1, 0.6)
	var target_scale : Vector2 = scalings_allowed.pick_random()
	set_scale(Vector2.ZERO)
	tw.tween_property(self, "scale", target_scale, dur)

func destroy() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	var dur := randf_range(0.1, 1.0)
	tw.tween_property(self, "scale", Vector2.ZERO, dur)
	await tw.finished
	queue_free()

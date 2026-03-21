extends Node2D
class_name Terrain

@export var terrain_container : Node2D
@export var terrain_scene : PackedScene
var terrain_sprites : Array[TerrainSprite] = []

func _ready() -> void:
	create()

func create() -> void:
	var num_terrain_sprites := randi_range(30, 40)
	
	for i in range(num_terrain_sprites):
		var s := terrain_scene.instantiate()
		s.set_position(PuzzleVisualizer.get_random_position_on_screen())
		terrain_sprites.append(s)
		terrain_container.add_child(s)

func set_color(c:Color) -> void:
	terrain_container.modulate = c

func destroy() -> void:
	for sprite in terrain_sprites:
		sprite.destroy()

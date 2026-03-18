extends Node2D

@export var vis : PuzzleVisualizer

func _ready() -> void:
	vis.all_clients_removed.connect(_on_all_clients_removed)
	vis.puzzle_failed.connect(_on_puzzle_failed)
	
	# @TODO: read the seed from some Global that persists between reloads
	# seed(0)
	
	var gen := PuzzleGenerator.new()
	gen.generate()
	vis.visualize(gen)

func _on_all_clients_removed() -> void:
	print("GAME OVER | YOU'VE WON!")

func _on_puzzle_failed() -> void:
	print("GAME OVER | YOU'VE LOST!")

extends Node2D

@export var vis : PuzzleVisualizer
@export var gameover : GameOverDialog
@export var game_menu : PuzzleGameMenu

func _ready() -> void:
	PuzzleFramework.puzzle_done.connect(_on_puzzle_done)

	var gen := PuzzleGenerator.new()
	gen.generate()
	vis.visualize(gen)
	
	PuzzleFramework.start_puzzle()

func _on_puzzle_done(player_won:bool) -> void:
	print("GAME OVER | YOU'VE WON!" if player_won else "GAME OVER | YOU'VE LOST!")
	vis.on_game_over()
	game_menu.on_game_over()
	gameover.activate(player_won)

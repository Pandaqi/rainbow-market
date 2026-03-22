extends Node
class_name PuzzleFrameworkAutoload

@export_group("Game Core")
@export var game_name := "GameName"
@export var game_version := "1.0"
@export var game_tagline := "Educational Puzzle Game"
@export var creator_credit := "The Wayward Melody"

@export_group("Menu")
@export var menu_pattern_enabled := false
@export var menu_scene_custom : PackedScene

var puzzle_seed := 0
var button_audio : AudioStreamPlayer
var state_audio : AudioStreamPlayer
var state := State.MENU

@export_group("Difficulties & Campaign")
var puzzle_difficulty : PuzzleDifficulty
@export var difficulties : Dictionary[PuzzleDifficulty.Difficulty, PuzzleDifficulty] = {}

@export_group("Settings & Configuration")
@export var settings : Array[PuzzleSetting] = []
var settings_by_id : Dictionary[String, PuzzleSetting] = {}

enum State
{
	MENU,
	LOAD,
	PUZZLE,
	DONE
}

signal puzzle_started()
signal puzzle_done(player_won:bool)

# Done in enter_tree to ensure it grabs all buttons added later
func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)
	
	for setting in settings:
		settings_by_id[setting.key] = setting

func _ready() -> void:
	button_audio = AudioStreamPlayer.new()
	add_child(button_audio)
	button_audio.stream = load("res://puzzle-framework/ui/ui_button_press.ogg")
	
	state_audio = AudioStreamPlayer.new()
	add_child(state_audio)
	state_audio.stream = load("res://puzzle-framework/game/sfx/game_new.ogg")

func _on_node_added(node):
	if (node is Button) or (node is TextureButton):
		node.pressed.connect(play_ui_button_sound)
		node.mouse_entered.connect(play_ui_button_sound)
		
func play_ui_button_sound():
	PuzzleFramework.play_audio_nice(button_audio)

func go_back_to_menu() -> void:
	change_state(State.MENU)
	get_tree().change_scene_to_file("res://puzzle-framework/menu/menu.tscn")

func reload_current_puzzle() -> void:
	seed(puzzle_seed)
	change_state(State.LOAD)
	get_tree().reload_current_scene()

func load_new_puzzle(diff := get_puzzle_difficulty()) -> void:
	puzzle_difficulty = diff
	puzzle_seed = randi()
	seed(puzzle_seed)
	change_state(State.LOAD)
	get_tree().change_scene_to_file("res://main/main.tscn")

func start_puzzle() -> void:
	change_state(State.PUZZLE)
	state_audio.play()
	puzzle_started.emit()

func finish_puzzle(player_won := false) -> void:
	change_state(State.DONE)
	puzzle_done.emit(player_won)

func change_state(s:State) -> void:
	state = s

func get_puzzle_difficulty() -> PuzzleDifficulty:
	if not puzzle_difficulty: return difficulties[difficulties.keys()[0]]
	return puzzle_difficulty

func get_puzzle_difficulty_level() -> PuzzleDifficulty.Difficulty:
	if not puzzle_difficulty: return PuzzleDifficulty.Difficulty.EASIEST
	return puzzle_difficulty.difficulty

func apply_difficulty_settings(obj) -> void:
	var diff := get_puzzle_difficulty()
	for key in diff.properties:
		obj[key] = diff.properties[key]

func play_audio_nice(ap:Node) -> void:
	apply_pitch_shift(ap)
	ap.play()

func apply_pitch_shift(ap:Node) -> void:
	var base := 1.05946309436
	var rand_num := randi_range(-2, 2)
	ap.pitch_scale = pow(base, rand_num)

func has_settings() -> bool:
	return settings.size() > 0

func get_setting_value(key:String) -> Variant:
	if not (key in settings_by_id): return false
	return settings_by_id[key].get_value_safe()

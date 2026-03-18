extends Node2D
class_name PuzzleVisualizer

@export var color_visual : PackedScene
@export var client_visual : PackedScene

@export var background : Background
@export var color_list : ColorList
@export var clients_container : Node2D

var clients : Array[VisualClient]
var clients_all : Array[VisualClient]
var generator : PuzzleGenerator
var busy := false

signal puzzle_failed()
signal all_clients_removed()

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	
	# create row of colors
	for c in gen.colors_start:
		var cv : VisualColor = color_visual.instantiate()
		cv.set_from_data(c)
		color_list.add_color(cv)
	
	
	# we prepare a quick grid so we can pigeonhole clients into unique slots
	# ensuring they don't overlap
	var client_size := 128.0
	var viewport_size := Vector2i(1080, 720)
	var grid_size := Vector2i((viewport_size / client_size).floor())
	var all_indices := []
	for x in range(grid_size.x):
		for y in range(1, grid_size.y):
			all_indices.append(grid_size.x * y + x)
	all_indices.shuffle()
	
	var animal_types : Array[String] = ["bear", "chick", "chicken", "cow", "crocodile", "dog", "duck", "elephant", "giraffe", "gorilla", "horse", "owl", "panda", "parrot", "penguin", "pig", "rabbit", "rhino", "sloth", "snake", "walrus", "zebra"]
	animal_types.shuffle()
	
	# place clients on screen
	clients_all = []
	for c in gen.clients:
		var cv : VisualClient = client_visual.instantiate()
		cv.set_from_data(c)
		cv.set_animal_texture(animal_types.pop_back())
		
		var rand_index : int = all_indices.pop_back()
		var rand_pos_grid := Vector2i(rand_index % grid_size.x, floori(rand_index / grid_size.x))
		var rand_pos := (Vector2(rand_pos_grid) + Vector2(0.5, 0.5)) * client_size
		cv.set_position(rand_pos)
		cv.clicked.connect(_on_client_clicked)
		
		clients_all.append(cv)
		clients_container.add_child(cv)
	
	clients = clients_all.duplicate(false)
	
	switch_to_next_color(false)

func _input(ev:InputEvent) -> void:
	if not OS.is_debug_build(): return
	if not ev.is_action_released("ui_accept"): return
	play_solution()

func play_solution() -> void:
	var solution := generator.solution
	for client_idx in solution:
		await _on_client_clicked(clients_all[client_idx])

func _on_client_clicked(c:VisualClient) -> void:
	if busy:
		print("NOPE | Still busy handling previous click")
		return
		
	var current_color := color_list.get_first()
	if not current_color:
		print("NOPE | No current color. | Game should've gone to game over before this point.")
		return
	
	if not c.has_color_in_order(current_color):
		print("NOPE | Client doesn't want this color | ", current_color.data.get_name())
		return
	
	busy = true
	await c.remove_color_from_order(current_color)
	
	if c.is_done():
		print("YEP | Client is done, remove it")
		await remove_client(c)
	
	switch_to_next_color()
	busy = false
	
	if clients.size() <= 0:
		all_clients_removed.emit()
		return
	
	if color_list.is_empty():
		puzzle_failed.emit()
		return
	
	# @TODO: a check if ANY animal accepts our current color => if not, emit puzzle_failed
	

func switch_to_next_color(remove_old := true) -> void:
	if remove_old: 
		var node := color_list.remove_first()
		node.queue_free()
	
	var new_first := color_list.get_first()
	if not new_first: return
	background.set_color(new_first)
	new_first.play_popup_tween()

func remove_client(c:VisualClient) -> void:
	clients.erase(c)
	await c.on_removed(color_list)

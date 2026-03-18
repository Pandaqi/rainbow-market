class_name PuzzleGenerator

var starting_colors_bounds := Vector2i(2,4)
var starting_clients_bounds := Vector2i(2,4)
var client_done_probability := 0.25
var num_client_bounds := Vector2i(4, 7)
var max_order_size := 3
var num_colors_solution_bounds := Vector2i(6, 10)
var reward_bounds := Vector2i(0,3)

var colors : Array[PuzzleColor]
var colors_start : Array[PuzzleColor]
var current_color_index := -1
var clients : Array[PuzzleClient]

func generate() -> void:
	var max_tries := 100
	for i in range(max_tries):
		create_random_setup()
		take_turns()
		var is_valid := clean_up_solution()
		if is_valid: break

func create_random_setup() -> void:
	var num_colors := randi_range(starting_colors_bounds.x, starting_colors_bounds.y)
	var num_clients := randi_range(starting_clients_bounds.x, starting_clients_bounds.y)
	
	colors_start = []
	for i in range(num_colors):
		var c := PuzzleColor.new(PuzzleColor.get_random())
		colors_start.append(c)
	
	clients = []
	for i in range(num_clients):
		create_new_client()

func create_new_client() -> PuzzleClient:
	var c := PuzzleClient.new()
	var rewards : Array[PuzzleColor.ColorName] = []
	var num_rewards := randi_range(reward_bounds.x, reward_bounds.y)
	for i in range(num_rewards):
		rewards.append(PuzzleColor.get_random())
	c.set_rewards(rewards)
	clients.append(c)
	return c

func get_open_clients() -> Array[PuzzleClient]:
	return clients.filter(func(c:PuzzleClient): return not c.is_done())

func take_turns() -> void:
	var is_done := false
	
	current_color_index = 0
	colors = colors_start.duplicate()
	
	while not is_done:
		var current_color := colors[current_color_index]
		
		# pick a random client (that isn't done yet)
		# if none exists, add a new one and work with that
		var open_clients := get_open_clients()
		var no_open_clients := open_clients.size() <= 0
		
		# @NOTE: minimum number of colors takes precedence over max clients; we continue anyway if not met
		var reached_maximum := (clients.size() >= num_client_bounds.y and current_color_index > num_colors_solution_bounds.x)
		if no_open_clients and reached_maximum:
			is_done = true
			break
		
		var client : PuzzleClient
		if no_open_clients:
			client = create_new_client()
		else:
			client = open_clients.pick_random()
		
		# give our current color to that client (pretending it wanted that all along!)
		client.add_to_order(current_color.get_name())
		current_color_index += 1
		
		# randomly decide if this client is now done;
		# if so, lock it down and add its reward color to our list
		var client_done_because_full := client.count_order() >= max_order_size
		var client_done_because_colors_exhausted := current_color_index >= colors.size()
		var client_done_because_random := randf() <= client_done_probability
		var client_is_done := client_done_because_full or client_done_because_colors_exhausted or client_done_because_random
		if client_is_done:
			client.finish()
			if client.count_reward() <= 0: client.add_to_reward(PuzzleColor.get_random())
			for reward in client.reward:
				colors.append(PuzzleColor.new(reward))
		
		# check if entire generation is done
		var gen_done_no_more_colors := current_color_index >= colors.size() or current_color_index >= num_colors_solution_bounds.y
		var gen_not_done_colors_unused := current_color_index < (colors.size() - 1)
		var gen_done_no_more_clients := get_open_clients().size() <= 0 and clients.size() >= num_client_bounds.x
		is_done = (gen_done_no_more_colors or gen_done_no_more_clients) and (not gen_not_done_colors_unused)
		
		if is_done: 
			client.remove_reward()
			for i in range(client.count_reward()): colors.pop_back()

func clean_up_solution() -> bool:
	# remove clients that did absolutely nothing
	for i in range(clients.size() - 1, -1, -1):
		if clients[i].has_empty_order():
			clients.remove_at(i)
	
	var too_few_clients := clients.size() < num_client_bounds.x
	if too_few_clients: return false
	
	var colors_left_over := current_color_index < colors.size()
	if colors_left_over: return false
	
	return true

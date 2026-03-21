class_name PuzzleGenerator

# these properties are modified by the difficulty level you chose
var num_colors_bounds := Vector2i(4,7)
var num_client_bounds := Vector2i(10, 20)
var num_colors_solution_bounds := Vector2i(6, 50)
var reward_bounds := Vector2i(0,2)
var max_order_size_bounds := Vector2i(3,3)

# these properties are always the same
var client_done_probability := 0.45
var new_client_probability := 0.1
var starting_colors_bounds := Vector2i(4,8)
var starting_clients_bounds := Vector2i(2,4)

var colors : Array[PuzzleColor]
var colors_start : Array[PuzzleColor]
var colors_possible : Array[PuzzleColor.ColorName]
var current_color_index := -1
var clients : Array[PuzzleClient]

## contains the indices of CLIENTS pressed on every turn
var solution : Array[int]

func generate() -> void:
	var max_tries := 500
	PuzzleFramework.apply_difficulty_settings(self)
	var counter := 0
	while true:
		print("Generator | Attempt " + str(counter))
		counter += 1
		create_random_setup()
		take_turns()
		var is_valid := clean_up_solution(counter >= max_tries)
		if is_valid: break

func create_random_setup() -> void:
	var num_colors_start := randi_range(starting_colors_bounds.x, starting_colors_bounds.y)
	num_colors_start = mini(num_colors_start, num_colors_solution_bounds.y)
	
	var num_clients := randi_range(starting_clients_bounds.x, starting_clients_bounds.y)
	
	var num_colors_total := randi_range(num_colors_bounds.x, num_colors_bounds.y)
	colors_possible = PuzzleColor.get_all_colors()
	colors_possible.shuffle()
	colors_possible = colors_possible.slice(0, num_colors_total)
	
	colors_start = []
	for i in range(num_colors_start):
		# by alternating colors like this we ensure no puzzle solution is ever just 100% same color
		var c := PuzzleColor.new(colors_possible[i % colors_possible.size()])
		colors_start.append(c)
	
	clients = []
	for i in range(num_clients):
		create_new_client()

func create_new_client() -> PuzzleClient:
	var c := PuzzleClient.new()
	var rewards : Array[PuzzleColor.ColorName] = []
	var num_rewards := randi_range(reward_bounds.x, reward_bounds.y)
	for i in range(num_rewards):
		rewards.append(colors_possible.pick_random())
	c.set_rewards(rewards)
	clients.append(c)
	return c

func get_open_clients() -> Array[PuzzleClient]:
	return clients.filter(func(c:PuzzleClient): return not c.is_done())

func take_turns() -> void:
	var is_done := false
	
	current_color_index = 0
	colors = colors_start.duplicate()
	solution = []
	
	var max_order_size := randi_range(max_order_size_bounds.x, max_order_size_bounds.y)
	var rewards_are_allowed := reward_bounds.y > 0
	var last_client : PuzzleClient
	
	while not is_done:
		var current_color := colors[current_color_index]
		if not current_color: break
		
		# pick a random client (that isn't done yet)
		var open_clients := get_open_clients()
		var no_open_clients := open_clients.size() <= 0
		
		# if none exists, add a new one (if not at max) and work with that
		var reached_maximum_clients := clients.size() >= num_client_bounds.y 
		if no_open_clients and reached_maximum_clients:
			break
		
		var client : PuzzleClient
		var should_create_new_client := (no_open_clients or randf() <= new_client_probability) and not reached_maximum_clients
		
		if should_create_new_client:
			client = create_new_client()
		else:
			client = open_clients.pick_random()
		
		# give our current color to that client (pretending it wanted that all along!)
		client.add_to_order(current_color.get_name())
		solution.append(clients.find(client))
		last_client = client
		current_color_index += 1
		
		# randomly decide if this client is now done;
		# if so, lock it down and add its reward color to our list
		var sim_needs_to_continue := clients.size() < num_client_bounds.x or open_clients.size() > 1 or current_color_index < colors.size()
		var more_colors_needed := current_color_index >= colors.size()
		
		var client_done_because_full := client.count_order() >= max_order_size
		var client_done_because_final := not sim_needs_to_continue
		var client_done_because_need_new_colors := more_colors_needed
		var client_done_because_random := randf() <= client_done_probability
		var client_is_done := client_done_because_full or client_done_because_need_new_colors or client_done_because_random or client_done_because_final
		
		if client_is_done:
			client.finish()
			
			# @NOTE: by guaranteeing at least 1 reward, we will NEVER be out of colors
			if more_colors_needed and client.count_reward() <= 0 and rewards_are_allowed: 
				client.add_to_reward(PuzzleColor.get_random())
			
			if sim_needs_to_continue:
				for reward in client.reward:
					colors.append(PuzzleColor.new(reward))
			else:
				client.remove_reward()
		
		# check if entire generation is done
		# (all clients done, and we've passed our minimum threshold)
		is_done = get_open_clients().size() <= 0 and clients.size() >= num_client_bounds.x
		
		# ERROR: something went wrong, abort
		if current_color_index >= colors.size():
			break
		
	# the final client should not add a reward if we want to end perfectly, so remove/undo that
	# (but only if simulation finished SUCCESFULLY)
	if is_done:
		for i in range(last_client.count_reward()): colors.pop_back()
		last_client.remove_reward()

func clean_up_solution(force_solution := false) -> bool:
	# remove clients that did absolutely nothing
	for i in range(clients.size() - 1, -1, -1):
		if clients[i].has_empty_order():
			clients.remove_at(i)
	
	var open_clients_remain := get_open_clients().size() > 0
	var colors_left_over := current_color_index < colors.size()
	if open_clients_remain or colors_left_over: return false
	
	# this mode is enabled if we've been trying for a while without success; it just skips all "non-critical checks"
	if force_solution: return true
	
	# check if client bounds are met
	var too_few_clients := clients.size() < num_client_bounds.x
	if too_few_clients: return false
	
	# check if color bounds are met
	var too_few_turns := current_color_index < num_colors_solution_bounds.x
	var too_many_turns := current_color_index > num_colors_solution_bounds.y
	if colors_left_over or too_few_turns or too_many_turns: return false
	
	return true

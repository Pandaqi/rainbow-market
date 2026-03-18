class_name PuzzleClient

var order : Array[PuzzleColor.ColorName]
var reward : Array[PuzzleColor.ColorName]
var done : bool

func _init() -> void:
	order = []
	reward = []
	done = false

func unfinish() -> void:
	done = false

func finish() -> void:
	done = true

func is_done() -> bool:
	return done

func has_empty_order() -> bool:
	return count_order() <= 0

func count_order() -> int:
	return order.size()

func add_to_order(c:PuzzleColor.ColorName) -> void:
	order.append(c)

func matches_order(c:PuzzleColor.ColorName) -> void:
	return order.has(c)

func count_reward() -> int:
	return reward.size()

func set_rewards(r:Array[PuzzleColor.ColorName]) -> void:
	reward = r

func add_to_reward(r:PuzzleColor.ColorName) -> void:
	reward.append(r)

func remove_reward() -> void:
	reward = []

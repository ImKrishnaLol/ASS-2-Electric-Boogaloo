extends Node

const MAX_LEVEL = 5

var level : int = 1

func set_level(new_level: int) -> void:
	level = clamp(new_level, 1, 5)

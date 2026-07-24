extends Node


const MIN_LEVEL: int = 1
const MAX_LEVEL: int = 5


var level: int = MIN_LEVEL


func set_level(new_level: int) -> void:
	level = clampi(
		new_level,
		MIN_LEVEL,
		MAX_LEVEL
	)

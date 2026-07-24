extends Node2D

func _ready() -> void:
	# On load emit a trigger level dialogue signal after a 1 second delay to make sure signal connections established
	await get_tree().create_timer(1).timeout
	EventBus.dialogue_level_triggered.emit(LevelManager.level)

extends Node2D

func _ready() -> void:
	# On loading level 1 emit a trigger level dialogue signal after a 1 second delay to make sure signal connections established
	await get_tree().create_timer(0.1).timeout
	if LevelManager.level == 1:
		EventBus.dialogue_level_triggered.emit(LevelManager.level)

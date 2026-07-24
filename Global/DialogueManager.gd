extends Node

var dialogue_box_displayed : bool = false

func _input(event: InputEvent) -> void:
	# For whenever player press primary key, it emits a single signal to skip to the next dialogue
	if event.is_action_pressed("action_primary"):
		if dialogue_box_displayed:
			EventBus.dialogue_next.emit()

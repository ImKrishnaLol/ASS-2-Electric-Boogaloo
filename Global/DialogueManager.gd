extends Node

signal dialogue_closed

var _dialogue_box_displayed : bool = false

func _input(event: InputEvent) -> void:
	# For whenever player press primary key, it emits a single signal to skip to the next dialogue
	if event.is_action_pressed("action_primary"):
		if _dialogue_box_displayed:
			EventBus.dialogue_next.emit()

func open_dialogue() -> void:
	_dialogue_box_displayed = true

func close_dialogue() -> void:
	_dialogue_box_displayed = false
	dialogue_closed.emit()

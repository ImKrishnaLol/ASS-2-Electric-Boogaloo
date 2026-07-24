extends Node


signal dialogue_closed
signal level_dialogue_closed


var _dialogue_box_displayed: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_primary"):
		if _dialogue_box_displayed:
			EventBus.dialogue_next.emit()


func open_dialogue() -> void:
	_dialogue_box_displayed = true


func close_dialogue() -> void:
	_dialogue_box_displayed = false
	dialogue_closed.emit()


func open_level_dialogue() -> void:
	_dialogue_box_displayed = true


func close_level_dialogue() -> void:
	_dialogue_box_displayed = false
	dialogue_closed.emit()
	level_dialogue_closed.emit()

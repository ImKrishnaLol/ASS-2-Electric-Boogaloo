extends TextureButton

@export var dialogue: Array[String]

func _on_pressed() -> void:
	EventBus.dialogue_triggered.emit(dialogue)

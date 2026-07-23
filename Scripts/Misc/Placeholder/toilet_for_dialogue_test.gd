extends TextureButton

# Inputs for the dialogue
@export var mood: String

func _on_pressed() -> void:
	EventBus.dialogue_triggered.emit(mood)

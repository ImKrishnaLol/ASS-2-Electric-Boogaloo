extends TextureButton

# Inputs for the dialogue
@export_enum("happy", "sad", "angry", "neutral") var mood: String

func _on_pressed() -> void:
	EventBus.dialogue_triggered.emit(mood)

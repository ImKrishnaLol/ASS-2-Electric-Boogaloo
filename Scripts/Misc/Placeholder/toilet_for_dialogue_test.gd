extends TextureButton

# Inputs for the dialogue
@export_enum("HAPPY", "SAD", "ANGRY", "NEUTRAL") var mood: String

func _on_pressed() -> void:
	EventBus.dialogue_triggered.emit(mood)

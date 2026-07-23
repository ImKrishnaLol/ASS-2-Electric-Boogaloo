extends VBoxContainer

func _on_happy_button_pressed() -> void:
	EventBus.dialogue_triggered.emit("HAPPY")

func _on_flirty_button_pressed() -> void:
	EventBus.dialogue_triggered.emit("FLIRTY")

func _on_angry_button_pressed() -> void:
	EventBus.dialogue_triggered.emit("ANGRY")

func _on_dejected_button_pressed() -> void:
	EventBus.dialogue_triggered.emit("DEJECTED")

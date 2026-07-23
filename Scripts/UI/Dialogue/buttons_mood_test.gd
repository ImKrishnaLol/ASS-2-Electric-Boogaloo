extends VBoxContainer

func _on_happy_button_pressed() -> void:
	EventBus.dialogue_mood_triggered.emit("HAPPY", 1)

func _on_flirty_button_pressed() -> void:
	EventBus.dialogue_mood_triggered.emit("FLIRTY", 1)

func _on_angry_button_pressed() -> void:
	EventBus.dialogue_mood_triggered.emit("ANGRY", 1)

func _on_dejected_button_pressed() -> void:
	EventBus.dialogue_mood_triggered.emit("DEJECTED", 1)

func _on_level_button_0_pressed() -> void:
	EventBus.dialogue_level_triggered.emit(0)

func _on_level_button_1_pressed() -> void:
	EventBus.dialogue_level_triggered.emit(1)

func _on_level_button_2_pressed() -> void:
	EventBus.dialogue_level_triggered.emit(2)

func _on_level_button_3_pressed() -> void:
	EventBus.dialogue_level_triggered.emit(3)

func _on_level_button_4_pressed() -> void:
	EventBus.dialogue_level_triggered.emit(4)

func _on_level_button_5_pressed() -> void:
	EventBus.dialogue_level_triggered.emit(5)

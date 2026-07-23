class_name DialogueBox extends Control

@export var dialogue_label: Label
@export var mood_label: Label
@export var animation_player: AnimationPlayer

func display_dialogue(dialogue: String) -> void:
	visible = true
	animation_player.play("typing_anim")
	dialogue_label.text = dialogue

func hide_dialogue() -> void:
	dialogue_label.text = "placeholder text: if you see this something went wrong!"
	visible = false

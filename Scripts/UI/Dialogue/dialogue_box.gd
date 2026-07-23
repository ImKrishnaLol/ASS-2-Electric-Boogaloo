extends Control

signal nextDialogue

@onready var dialogue_label: Label = $Panel/DialogueLabel
@onready var mood_label: Label = $Panel/MoodLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var dialogue_messages: Array[String]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_primary"):
		nextDialogue.emit()

func _ready() -> void:
	for message in dialogue_messages:
		dialogue_label.text = message
		animation_player.play("typing_anim")
		await nextDialogue

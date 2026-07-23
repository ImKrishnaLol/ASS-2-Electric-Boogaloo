extends Control

signal nextDialogue

@onready var dialogue_label: Label = $Panel/DialogueLabel
@onready var mood_label: Label = $Panel/MoodLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	EventBus.dialogue_triggered.connect(_on_dialogue_triggered)

func _input(event: InputEvent) -> void:
	# For whenever player press primary key, it skips to the next dialogue
	if event.is_action_pressed("action_primary"):
		nextDialogue.emit()

func _on_dialogue_triggered(input_dialogue) -> void:
	# Basic dialogue system
	for message in input_dialogue:
		dialogue_label.text = message
		animation_player.play("typing_anim")
		await nextDialogue

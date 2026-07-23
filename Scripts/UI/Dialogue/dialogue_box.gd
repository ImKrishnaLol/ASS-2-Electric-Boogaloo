extends Control

signal nextDialogue

@onready var dialogue_label: Label = $Panel/DialogueLabel
@onready var mood_label: Label = $Panel/MoodLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialogue_moods: Dictionary = {
	"angry": [
		"BARK BARK VARK BARK",
		"AAAAAAAAAAAAAAAAAAA",
		"I ate chezburger too",
		"MATH IS FUN",
	],
	"happy": [
		"YIPPY YIPPY YIPPY",
		"HORAY",
		":D",
		"I LIKE UMBRELLAS",
	],
	"sad": [
		"Im sad :(",
		"D:",
		"*sleep*",
	],
	"neutral": [
		"Uh",
		"Um",
	]
}

func _ready() -> void:
	EventBus.dialogue_triggered.connect(_on_dialogue_triggered)

func _input(event: InputEvent) -> void:
	# For whenever player press primary key, it skips to the next dialogue
	if event.is_action_pressed("action_primary"):
		nextDialogue.emit()

func _on_dialogue_triggered(mood) -> void:
	# Basic dialogue system
	visible = true
	
	mood_label.text = mood
	
	for message in dialogue_moods[mood]:
		animation_player.play("typing_anim")
		dialogue_label.text = message
		await nextDialogue
	
	visible = false

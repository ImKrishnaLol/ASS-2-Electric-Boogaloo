extends Control

@onready var dialogue_box: DialogueBox = $DialogueBox

var dialogue_moods: Dictionary = {
	"HAPPY": [
		"Im happy",
		"*happy noise*",
		"Yippyyyyy",
		"MATH IS FUN",
	],
	"FLIRTY": [
		"I lik u lowkey",
		"Are you Wi‑Fi? Because I’m feeling strong signals and zero common sense. (AI)",
		"How do i rizz someone",
		"touch grass? no. touch me (WHY IS MY AI FREAKY GAHDAMN)",
	],
	"ANGRY": [
		"BARK BARK BARK BARK GRRRRR",
		"D:<",
		"GRRRR BARK",
	],
	"DEJECTED": [
		"MC, I know we don't get along.. but I think I'm cooked.",
		"Um.. my rizz is on airplane mode. (AI GENERATED)",
	],
}

func _ready() -> void:
	EventBus.dialogue_mood_triggered.connect(_on_dialogue_mood_triggered)
	# hide dialogue box on ready
	dialogue_box.hide_dialogue()

func _on_dialogue_mood_triggered(mood: String, level: int) -> void:
	DialogueManager.dialogue_box_displayed = true
	# Dialogue system for mood mode
	var dialogue : String = dialogue_moods[mood].pick_random()
	dialogue_box.display_dialogue(dialogue)
	await EventBus.dialogue_next
	dialogue_box.hide_dialogue()
	DialogueManager.dialogue_box_displayed = false

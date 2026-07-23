extends Control

signal nextDialogue

@onready var dialogue_label: Label = $Panel/DialogueLabel
@onready var mood_label: Label = $Panel/MoodLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialogue_levels: Dictionary = {
	1: [
		"SO: Lets make a deal then… This old machine is still here. You beat me five times. We delay the end one more day.",
		"MC: And if you win?",
		"SO: We play again. Each ball you lose, is another star I pluck from the sky.",
		"MC: Until there are no more stars?",
		"SO: You would still be here. For a few seconds."
	],
	2: [
		"MC: Dude I'm bored",
		"SO: LEVEL TWOOOOO",
		"MC: WHAT",
		"SO: LEVEL TWOOOOO GRRRR",
		"MC: WHAT"
	],
	3: [
		"MC: Hi, did you know that I ate a sandwich today?",
		"SO: So?",
		"MC: ...",
		"MC: So what?",
		"SO: Didn't ask"
	],
	4: [
		"MC: Quack quack",
		"SO: U're cringe >:(",
		"MC: So?",
		"SO: So what?",
		"MC: So so so"
	],
	5: [
		"SO: IMMA KILL YOU",
		"MC: You already killed me to be honnest.",
		"SO: With what?",
		"MC: With your heart",
		"SO: Idk if that's a rizz or not but ok"
	]
}

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
	]
}

func _ready() -> void:
	EventBus.dialogue_triggered.connect(_on_dialogue_triggered)

func _input(event: InputEvent) -> void:
	# For whenever player press primary key, it skips to the next dialogue
	if event.is_action_pressed("action_primary"):
		nextDialogue.emit()

func _on_dialogue_triggered(mood) -> void:
	# Dialogue system
	visible = true
	
	mood_label.text = mood
	animation_player.play("typing_anim")
	dialogue_label.text = dialogue_moods[mood].pick_random()
	await nextDialogue
	
	visible = false

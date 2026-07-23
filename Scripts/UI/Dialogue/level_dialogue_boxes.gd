extends Control

@export var on_display_audio : AudioStream
@export var on_text_audio : AudioStream

@export_subgroup("Child Nodes")
@export var dialogue_boxes: Array[DialogueBox]

var in_level_dialogue : bool = false

var dialogue_levels: Dictionary = {
	0: [
		"SO: Lets make a deal then… This old machine is still here. You beat me five times. We delay the end one more day.",
		"MC: And if you win?",
		"SO: We play again. Each ball you lose, is another star I pluck from the sky.",
		"MC: Until there are no more stars?",
		"SO: You would still be here. For a few seconds.",
	],
	1: [
		"MC: Dude I'm bored",
		"SO: LEVEL TWOOOOO",
		"MC: WHAT",
		"SO: LEVEL TWOOOOO GRRRR",
		"MC: WHAT",
	],
	2: [
		"MC: Hi, did you know that I ate a sandwich today?",
		"SO: So?",
		"MC: ...",
		"MC: So what?",
		"SO: Didn't ask",
	],
	3: [
		"MC: Why did the chicken cross the road?",
		"SO: ... Really?",
		"MC: To... get... to...",
		"MC: No, your not going to finish that joke",
		"SO: O...K...",
	],
	4: [
		"MC: Quack quack",
		"SO: U're cringe >:(",
		"MC: So?",
		"SO: So what?",
		"MC: So so so",
	],
	5: [
		"SO: IMMA KILL YOU",
		"MC: You already killed me to be honnest.",
		"SO: With what?",
		"MC: With your heart",
		"SO: Idk if that's a rizz or not but ok",
	],
}

func _ready() -> void:
	EventBus.dialogue_level_triggered.connect(_on_dialogue_level_triggered)
	# hide dialogue boxes on ready
	for dialogue_box: DialogueBox in dialogue_boxes:
		dialogue_box.instant_hide_dialogue()
		if on_display_audio:
			dialogue_box.on_display_audio = on_display_audio
		if on_text_audio:
			dialogue_box.on_text_audio = on_text_audio

func _on_dialogue_level_triggered(level: int):
	if not in_level_dialogue:
		in_level_dialogue = true
		# Dialogue system for level mode
		DialogueManager.dialogue_box_displayed = true
		for index: int in range(len(dialogue_levels[level])):
			var message : String = dialogue_levels[level][index]
			if len(dialogue_boxes) >= index:
				dialogue_boxes[index].display_dialogue(message)
			else:
				printerr("Error in level_dialogue_boxes: length of dialogue_levels for this level is too long")
			await EventBus.dialogue_next
		for box: DialogueBox in dialogue_boxes:
			box.hide_dialogue()
		DialogueManager.dialogue_box_displayed = false
		in_level_dialogue = false

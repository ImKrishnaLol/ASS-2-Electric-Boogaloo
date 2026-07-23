class_name DialogueBox extends Control

signal DISPLAY_DIALOGUE(dialogue: String)
signal NEXT_DIALOGUE

@export var dialogue_label: Label
@export var mood_label: Label
@export var animation_player: AnimationPlayer 

#@onready var dialogue_label: Label = $Panel/DialogueLabel
#@onready var mood_label: Label = $Panel/MoodLabel
#@onready var animation_player: AnimationPlayer = $AnimationPlayer

#@export_enum("1", "2", "3", "4", "5") var level_dialogue
#
#
#var dialogue_levels: Dictionary = {
	#1: [
		#"SO: Lets make a deal then… This old machine is still here. You beat me five times. We delay the end one more day.",
		#"MC: And if you win?",
		#"SO: We play again. Each ball you lose, is another star I pluck from the sky.",
		#"MC: Until there are no more stars?",
		#"SO: You would still be here. For a few seconds.",
	#],
	#2: [
		#"MC: Dude I'm bored",
		#"SO: LEVEL TWOOOOO",
		#"MC: WHAT",
		#"SO: LEVEL TWOOOOO GRRRR",
		#"MC: WHAT",
	#],
	#3: [
		#"MC: Hi, did you know that I ate a sandwich today?",
		#"SO: So?",
		#"MC: ...",
		#"MC: So what?",
		#"SO: Didn't ask",
	#],
	#4: [
		#"MC: Quack quack",
		#"SO: U're cringe >:(",
		#"MC: So?",
		#"SO: So what?",
		#"MC: So so so",
	#],
	#5: [
		#"SO: IMMA KILL YOU",
		#"MC: You already killed me to be honnest.",
		#"SO: With what?",
		#"MC: With your heart",
		#"SO: Idk if that's a rizz or not but ok",
	#],
#}
#
#var dialogue_moods: Dictionary = {
	#"HAPPY": [
		#"Im happy",
		#"*happy noise*",
		#"Yippyyyyy",
		#"MATH IS FUN",
	#],
	#"FLIRTY": [
		#"I lik u lowkey",
		#"Are you Wi‑Fi? Because I’m feeling strong signals and zero common sense. (AI)",
		#"How do i rizz someone",
		#"touch grass? no. touch me (WHY IS MY AI FREAKY GAHDAMN)",
	#],
	#"ANGRY": [
		#"BARK BARK BARK BARK GRRRRR",
		#"D:<",
		#"GRRRR BARK",
	#],
	#"DEJECTED": [
		#"MC, I know we don't get along.. but I think I'm cooked.",
		#"Um.. my rizz is on airplane mode. (AI GENERATED)",
	#],
#}


func _ready() -> void:
	DISPLAY_DIALOGUE.connect(_display_dialogue)
	#EventBus.dialogue_mood_triggered.connect(_on_dialogue_mood_triggered)
	#EventBus.dialogue_level_triggered.connect(_on_dialogue_level_triggered)


func _input(event: InputEvent) -> void:
	# For whenever player press primary key, it skips to the next dialogue
	if event.is_action_pressed("action_primary"):
		NEXT_DIALOGUE.emit()


#func _on_dialogue_level_triggered(level: int):
	## Dialogue system for level mode
	#if level == level_dialogue+1: # Enum returns int starts at 0
		#visible = true
		#
		#for message in dialogue_levels[level]:
			#animation_player.play("typing_anim")
			#dialogue_label.text = message
			#await NEXT_DIALOGUE
		#
		#visible = false

func _display_dialogue(dialogue: String) -> void:
	visible = true
		
	animation_player.play("typing_anim")
	dialogue_label.text = dialogue
	await NEXT_DIALOGUE
	
	visible = false
#
#func _on_dialogue_mood_triggered(mood: String, level: int) -> void:
	## Dialogue system for mood mode
	#if level == level_dialogue+1: # Enum returns int starts from 0, that's why add 1
		#visible = true
		#
		#mood_label.text = mood
		#animation_player.play("typing_anim")
		#dialogue_label.text = dialogue_moods[mood].pick_random()
		#await NEXT_DIALOGUE
		#
		#visible = false

class_name DialogueBox extends Control

@export var fade_in_time : float
@export var fade_out_time : float

@export var on_display_audio : AudioStreamRandomizer
@export var on_text_audio : AudioStreamRandomizer

@export_subgroup("Child Nodes")
@export var dialogue_label: Label
@export var mood_label: Label
@export var animation_player: AnimationPlayer


var placeholder_text = "placeholder text: if you see this something went wrong!"

func display_dialogue(dialogue: String) -> void:
	dialogue_label.text = dialogue
	animation_player.play("RESET")
	await _fade_in(fade_in_time)
	SfxPlayer.play(on_text_audio)
	animation_player.play("typing_anim")

func hide_dialogue() -> void:
	await _fade_out(fade_out_time)
	dialogue_label.text = placeholder_text

func instant_hide_dialogue() -> void:
	dialogue_label.text = placeholder_text
	visible = false

func _fade_in(duration := 0.3):
	SfxPlayer.play(on_display_audio)
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)
	var promise = tween.finished
	return promise

func _fade_out(duration := 0.3):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	var promise = await tween.finished
	visible = false
	return promise

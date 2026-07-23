extends Control

# Main menu script.
# Handles scene buttons, button sounds, and button juice.
# This scene assumes the required UI nodes exist.

@onready var new_game_button: Button = %NewGameButton
@onready var credits_button: Button = %CreditsButton
@onready var settings_button: Button = %SettingsButton


@export_group("Scenes")
@export var new_game_scene: String = "main"
@export var settings_scene: String = "settings"
@export var credits_scene: String = "credits"

@export_group("Scene Transitions")
@export var new_game_transition_duration: float = 1.0
@export var settings_transition_duration: float = 0.0
@export var credits_transition_duration: float = 1.0

@export_group("UI Sounds")
@export var click_sound: AudioStream
@export var hover_sound: AudioStream
@export var new_game_sound: AudioStream

@export_group("Button Juice")
@export var button_hover_scale: Vector2 = Vector2(1.06, 1.06)
@export var button_down_scale: Vector2 = Vector2(0.94, 0.94)
@export var button_up_scale: Vector2 = Vector2(1.08, 1.08)
@export var button_hover_duration: float = 0.10
@export var button_down_duration: float = 0.06
@export var button_up_duration: float = 0.08

# Stores active button tweens so new animations can cancel old ones.
var button_tweens: Dictionary[Button, Tween] = {}


func _ready() -> void:
	get_tree().paused = false

	# Wait one frame so buttons have their final size before setting pivot offsets.
	await get_tree().process_frame

	_setup_buttons()


func _on_new_game_button_pressed() -> void:
	play_sfx(new_game_sound)
	SceneManager.go(new_game_scene, new_game_transition_duration)


func _on_settings_button_pressed() -> void:
	play_sfx(click_sound)
	SceneManager.go(settings_scene, settings_transition_duration)


# This is still named "load" so existing editor signal connections do not break.
# In this template, the old Load button is used as Credits.
func _on_load_pressed() -> void:
	play_sfx(click_sound)
	SceneManager.go(credits_scene, credits_transition_duration)


# Sets button text, pivots, and hover/click signals.
func _setup_buttons() -> void:
	new_game_button.text = "New game"
	credits_button.text = "Credits"
	settings_button.text = "Settings"

	for node: Node in find_children("*", "Button", true, false):
		var button: Button = node as Button

		if button == null:
			continue

		button.pivot_offset = button.size / 2.0

		var mouse_entered_callable: Callable = _on_button_mouse_entered.bind(button)
		var mouse_exited_callable: Callable = _on_button_mouse_exited.bind(button)
		var button_down_callable: Callable = _on_button_down.bind(button)
		var button_up_callable: Callable = _on_button_up.bind(button)

		if not button.mouse_entered.is_connected(mouse_entered_callable):
			button.mouse_entered.connect(mouse_entered_callable)

		if not button.mouse_exited.is_connected(mouse_exited_callable):
			button.mouse_exited.connect(mouse_exited_callable)

		if not button.button_down.is_connected(button_down_callable):
			button.button_down.connect(button_down_callable)

		if not button.button_up.is_connected(button_up_callable):
			button.button_up.connect(button_up_callable)


func _on_button_mouse_entered(button: Button) -> void:
	play_sfx(hover_sound)
	_animate_button(button, button_hover_scale, button_hover_duration)


func _on_button_mouse_exited(button: Button) -> void:
	_animate_button(button, Vector2.ONE, button_hover_duration)


func _on_button_down(button: Button) -> void:
	play_sfx(click_sound)
	_animate_button(button, button_down_scale, button_down_duration)


func _on_button_up(button: Button) -> void:
	if button.get_global_rect().has_point(get_global_mouse_position()):
		_animate_button(button, button_up_scale, button_up_duration)
	else:
		_animate_button(button, Vector2.ONE, button_up_duration)


# Tweens a button to a target scale.
func _animate_button(
	button: Button,
	target_scale: Vector2,
	duration: float
) -> void:
	if button == null:
		return

	if button_tweens.has(button):
		var old_tween: Tween = button_tweens[button] as Tween

		if old_tween != null:
			old_tween.kill()

	var tween: Tween = create_tween()
	button_tweens[button] = tween

	tween.tween_property(button, "scale", target_scale, duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


# Plays a UI sound if one is assigned.
func play_sfx(sound: AudioStream) -> void:
	if sound != null:
		SfxPlayer.play(sound)

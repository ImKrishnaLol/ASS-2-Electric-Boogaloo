extends Control

# Main menu script.
# Handles scene buttons, button sounds, button juice,
# and the neon logo animation.


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


@export_group("Logo Neon")

@export_range(0.1, 5.0, 0.1) var logo_flicker_speed: float = 1.0
@export var neon_light_energy: float = 0.2
@export var neon_light_2_energy: float = 0.2
@export var neon_flicker_sound: AudioStream
@export var neon_flicker_volume_db: float = 0.0
@export var neon_sound_tail_duration: float = 0.5

@onready var new_game_button: Button = %NewGameButton
@onready var credits_button: Button = %CreditsButton
@onready var settings_button: Button = %SettingsButton

@onready var logo: Sprite2D = $Logo
@onready var neon_light: PointLight2D = %NeonLight
@onready var neon_light_2: PointLight2D = %NeonLight2


# Stores active button tweens so new animations can cancel old ones.
var button_tweens: Dictionary[Button, Tween] = {}

var logo_tween: Tween


func _ready() -> void:
	get_tree().paused = false

	# Wait one frame so buttons have their final size.
	await get_tree().process_frame

	_setup_buttons()
	_blink_logo_in()


func _exit_tree() -> void:
	_stop_neon_flicker_sound()


func _on_new_game_button_pressed() -> void:
	play_sfx(new_game_sound)

	GameData.start_new_game(20)
	LevelManager.set_level(0)

	SceneManager.go(
		new_game_scene,
		new_game_transition_duration
	)


func _on_settings_button_pressed() -> void:
	play_sfx(click_sound)

	SceneManager.go(
		settings_scene,
		settings_transition_duration
	)


# This is still named "load" so existing editor signal connections do not break.
# In this template, the old Load button is used as Credits.
func _on_load_pressed() -> void:
	play_sfx(click_sound)

	SceneManager.go(
		credits_scene,
		credits_transition_duration
	)


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

		var mouse_entered_callable: Callable = (
			_on_button_mouse_entered.bind(button)
		)
		var mouse_exited_callable: Callable = (
			_on_button_mouse_exited.bind(button)
		)
		var button_down_callable: Callable = (
			_on_button_down.bind(button)
		)
		var button_up_callable: Callable = (
			_on_button_up.bind(button)
		)

		if not button.mouse_entered.is_connected(
			mouse_entered_callable
		):
			button.mouse_entered.connect(
				mouse_entered_callable
			)

		if not button.mouse_exited.is_connected(
			mouse_exited_callable
		):
			button.mouse_exited.connect(
				mouse_exited_callable
			)

		if not button.button_down.is_connected(
			button_down_callable
		):
			button.button_down.connect(
				button_down_callable
			)

		if not button.button_up.is_connected(
			button_up_callable
		):
			button.button_up.connect(
				button_up_callable
			)


func _on_button_mouse_entered(
	button: Button
) -> void:
	play_sfx(hover_sound)

	_animate_button(
		button,
		button_hover_scale,
		button_hover_duration
	)


func _on_button_mouse_exited(
	button: Button
) -> void:
	_animate_button(
		button,
		Vector2.ONE,
		button_hover_duration
	)


func _on_button_down(
	button: Button
) -> void:
	play_sfx(click_sound)

	_animate_button(
		button,
		button_down_scale,
		button_down_duration
	)


func _on_button_up(
	button: Button
) -> void:
	if button.get_global_rect().has_point(
		get_global_mouse_position()
	):
		_animate_button(
			button,
			button_up_scale,
			button_up_duration
		)
	else:
		_animate_button(
			button,
			Vector2.ONE,
			button_up_duration
		)


# Tweens a button to a target scale.
func _animate_button(
	button: Button,
	target_scale: Vector2,
	duration: float
) -> void:
	if button == null:
		return

	if button_tweens.has(button):
		var old_tween: Tween = (
			button_tweens[button] as Tween
		)

		if old_tween != null:
			old_tween.kill()

	var tween: Tween = create_tween()
	button_tweens[button] = tween

	tween.tween_property(
		button,
		"scale",
		target_scale,
		duration
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)


# Flickers the logo and both neon lights before leaving them illuminated.
# Flickers the logo and both neon lights before leaving them illuminated.
func _blink_logo_in() -> void:
	if logo_tween != null:
		logo_tween.kill()

	_stop_neon_flicker_sound()

	logo.modulate.a = 0.0
	neon_light.energy = 0.0
	neon_light_2.energy = 0.0

	logo_tween = create_tween()

	_play_neon_flicker_sound()

	var flicker_sequence: Array[Vector2] = [
		Vector2(0.90, 0.06),
		Vector2(0.05, 0.04),
		Vector2(0.65, 0.08),
		Vector2(0.10, 0.05),
		Vector2(1.00, 0.07),
		Vector2(0.25, 0.06),
		Vector2(0.85, 0.05),
		Vector2(0.10, 0.04),
		Vector2(1.00, 0.15)
	]

	for flicker: Vector2 in flicker_sequence:
		var brightness: float = flicker.x
		var duration: float = (
			flicker.y / logo_flicker_speed
		)

		logo_tween.tween_property(
			logo,
			"modulate:a",
			brightness,
			duration
		)

		logo_tween.parallel().tween_property(
			neon_light,
			"energy",
			brightness * neon_light_energy,
			duration
		)

		logo_tween.parallel().tween_property(
			neon_light_2,
			"energy",
			brightness * neon_light_2_energy,
			duration
		)

	# Ensure the logo and lights finish fully illuminated.
	var final_duration: float = (
		0.08 / logo_flicker_speed
	)

	logo_tween.tween_property(
		logo,
		"modulate:a",
		1.0,
		final_duration
	)

	logo_tween.parallel().tween_property(
		neon_light,
		"energy",
		neon_light_energy,
		final_duration
	)

	logo_tween.parallel().tween_property(
		neon_light_2,
		"energy",
		neon_light_2_energy,
		final_duration
	)

	# Keep the sound playing after the visual animation finishes.
	logo_tween.tween_interval(
		neon_sound_tail_duration
	)

	logo_tween.finished.connect(
		_on_logo_flicker_finished
	)


func _play_neon_flicker_sound() -> void:
	if neon_flicker_sound == null:
		return

	SfxPlayer.play(
		neon_flicker_sound,
		false,
		false,
		0.5,
		false,
		neon_flicker_volume_db,
		0.5,
		false,
		true
	)


func _stop_neon_flicker_sound() -> void:
	if neon_flicker_sound == null:
		return

	SfxPlayer.stop_audio(
		neon_flicker_sound
	)


func _on_logo_flicker_finished() -> void:
	_stop_neon_flicker_sound()


# Plays a UI sound if one is assigned.
func play_sfx(
	sound: AudioStream
) -> void:
	if sound != null:
		SfxPlayer.play(sound)

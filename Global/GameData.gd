extends Node


# GameData stores settings and game progress.

signal audio_settings_changed
signal display_settings_changed
signal current_level_changed(current_level_scene: String)
signal input_bindings_changed(input_bindings: Dictionary)
signal settings_saved
signal settings_loaded
signal emotion_changed

signal ball_count_changed(
	balls_remaining: int,
	maximum_ball_count: int
)


const SAVE_PATH: String = "user://game_data.cfg"

# Default audio and display settings.
const DEFAULT_MASTER_VOLUME: float = 0.70
const DEFAULT_MUSIC_VOLUME: float = 0.10
const DEFAULT_SFX_VOLUME: float = 0.50
const DEFAULT_FULLSCREEN: bool = false
const DEFAULT_CURRENT_LEVEL_SCENE: String = "main"

# Master volume settings.
const MASTER_NO_CHANGE_VALUE: float = 0.70
const MASTER_MAX_BOOST_DB: float = 10.0

# Audio bus names.
const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"


# Current settings.
var master_volume: float = DEFAULT_MASTER_VOLUME
var music_volume: float = DEFAULT_MUSIC_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME
var fullscreen: bool = DEFAULT_FULLSCREEN
var current_level_scene: String = DEFAULT_CURRENT_LEVEL_SCENE

# Custom input bindings.
var input_bindings: Dictionary = {}


# Persistent ball counter.
var balls_remaining: int = 0
var maximum_ball_count: int = 0
var ball_counter_initialized: bool = false


# Emotion types.
enum emotions {
	Angry,
	Sad
}


# Current character emotion.
var current_emotion: int:
	set(value):
		current_emotion = value
		emotion_changed.emit(value)


func _ready() -> void:
	# Load settings and progress.
	load_game()

	# Apply loaded settings.
	apply_audio_settings()
	apply_display_settings()

	current_emotion = 0


# Saves settings and progress.
func save_game() -> void:
	var config_file: ConfigFile = ConfigFile.new()

	# Save audio.
	config_file.set_value(
		"audio",
		"master_volume",
		master_volume
	)
	config_file.set_value(
		"audio",
		"music_volume",
		music_volume
	)
	config_file.set_value(
		"audio",
		"sfx_volume",
		sfx_volume
	)

	# Save display settings.
	config_file.set_value(
		"display",
		"fullscreen",
		fullscreen
	)

	# Save level progress.
	config_file.set_value(
		"progress",
		"current_level_scene",
		current_level_scene
	)

	# Save the ball counter.
	config_file.set_value(
		"progress",
		"balls_remaining",
		balls_remaining
	)
	config_file.set_value(
		"progress",
		"maximum_ball_count",
		maximum_ball_count
	)
	config_file.set_value(
		"progress",
		"ball_counter_initialized",
		ball_counter_initialized
	)

	# Save input bindings.
	config_file.set_value(
		"input",
		"bindings",
		input_bindings
	)

	var save_error: Error = config_file.save(
		SAVE_PATH
	)

	if save_error != OK:
		push_warning(
			"Could not save GameData to %s"
			% SAVE_PATH
		)
		return

	settings_saved.emit()


# Loads settings and progress.
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		settings_loaded.emit()
		return

	var config_file: ConfigFile = ConfigFile.new()

	var load_error: Error = config_file.load(
		SAVE_PATH
	)

	if load_error != OK:
		push_warning(
			"Could not load GameData from %s"
			% SAVE_PATH
		)
		settings_loaded.emit()
		return

	# Load audio settings.
	master_volume = _get_clamped_float(
		config_file,
		"audio",
		"master_volume",
		DEFAULT_MASTER_VOLUME
	)

	music_volume = _get_clamped_float(
		config_file,
		"audio",
		"music_volume",
		DEFAULT_MUSIC_VOLUME
	)

	sfx_volume = _get_clamped_float(
		config_file,
		"audio",
		"sfx_volume",
		DEFAULT_SFX_VOLUME
	)

	# Load display settings.
	fullscreen = bool(
		config_file.get_value(
			"display",
			"fullscreen",
			DEFAULT_FULLSCREEN
		)
	)

	# Load the current level.
	current_level_scene = String(
		config_file.get_value(
			"progress",
			"current_level_scene",
			DEFAULT_CURRENT_LEVEL_SCENE
		)
	).strip_edges()

	if current_level_scene.is_empty():
		current_level_scene = (
			DEFAULT_CURRENT_LEVEL_SCENE
		)

	# Load the ball counter.
	ball_counter_initialized = bool(
		config_file.get_value(
			"progress",
			"ball_counter_initialized",
			false
		)
	)

	maximum_ball_count = maxi(
		int(
			config_file.get_value(
				"progress",
				"maximum_ball_count",
				0
			)
		),
		0
	)

	balls_remaining = clampi(
		int(
			config_file.get_value(
				"progress",
				"balls_remaining",
				0
			)
		),
		0,
		maximum_ball_count
	)

	# Invalid saved ball data should be initialized
	# when the board loads.
	if maximum_ball_count <= 0:
		ball_counter_initialized = false
		balls_remaining = 0

	# Load input bindings.
	var loaded_input_bindings: Variant = (
		config_file.get_value(
			"input",
			"bindings",
			{}
		)
	)

	if loaded_input_bindings is Dictionary:
		input_bindings = (
			loaded_input_bindings as Dictionary
		).duplicate(true)
	else:
		input_bindings = {}

	settings_loaded.emit()

	ball_count_changed.emit(
		balls_remaining,
		maximum_ball_count
	)


# Starts a new game and resets the balls.
func start_new_game(
	starting_ball_count: int,
	should_save: bool = true
) -> void:
	maximum_ball_count = maxi(
		starting_ball_count,
		0
	)

	balls_remaining = maximum_ball_count
	ball_counter_initialized = true

	ball_count_changed.emit(
		balls_remaining,
		maximum_ball_count
	)

	if should_save:
		save_game()


# Creates the ball counter only if there is no game.
func ensure_ball_counter(
	starting_ball_count: int
) -> void:
	if ball_counter_initialized:
		return

	start_new_game(starting_ball_count)


# Uses one ball.
func use_ball(
	should_save: bool = true
) -> void:
	if not ball_counter_initialized:
		return

	balls_remaining = maxi(
		balls_remaining - 1,
		0
	)

	ball_count_changed.emit(
		balls_remaining,
		maximum_ball_count
	)

	if should_save:
		save_game()


# Refunds one ball.
func refund_ball(
	should_save: bool = true
) -> void:
	if not ball_counter_initialized:
		return

	balls_remaining = mini(
		balls_remaining + 1,
		maximum_ball_count
	)

	ball_count_changed.emit(
		balls_remaining,
		maximum_ball_count
	)

	if should_save:
		save_game()


# Gets a saved number between zero and one.
func _get_clamped_float(
	config_file: ConfigFile,
	section: String,
	key: String,
	default_value: float
) -> float:
	return clampf(
		float(
			config_file.get_value(
				section,
				key,
				default_value
			)
		),
		0.0,
		1.0
	)


# Sets master volume.
func set_master_volume(
	value: float,
	should_save: bool = true
) -> void:
	master_volume = clampf(
		value,
		0.0,
		1.0
	)

	_apply_audio_change(should_save)


# Sets music volume.
func set_music_volume(
	value: float,
	should_save: bool = true
) -> void:
	music_volume = clampf(
		value,
		0.0,
		1.0
	)

	_apply_audio_change(should_save)


# Sets sound-effect volume.
func set_sfx_volume(
	value: float,
	should_save: bool = true
) -> void:
	sfx_volume = clampf(
		value,
		0.0,
		1.0
	)

	_apply_audio_change(should_save)


# Applies and saves audio changes.
func _apply_audio_change(
	should_save: bool
) -> void:
	apply_audio_settings()
	audio_settings_changed.emit()

	if should_save:
		save_game()


# Applies all audio settings.
func apply_audio_settings() -> void:
	_apply_bus_volume(
		MASTER_BUS_NAME,
		_master_volume_to_db(master_volume),
		master_volume
	)

	_apply_bus_volume(
		MUSIC_BUS_NAME,
		linear_to_db(
			max(music_volume, 0.0001)
		),
		music_volume
	)

	_apply_bus_volume(
		SFX_BUS_NAME,
		linear_to_db(
			max(sfx_volume, 0.0001)
		),
		sfx_volume
	)


# Applies one audio bus.
func _apply_bus_volume(
	bus_name: String,
	volume_db: float,
	volume_value: float
) -> void:
	var bus_index: int = (
		AudioServer.get_bus_index(bus_name)
	)

	if bus_index == -1:
		push_warning(
			"Missing audio bus: %s"
			% bus_name
		)
		return

	if volume_value <= 0.0:
		AudioServer.set_bus_mute(
			bus_index,
			true
		)
		AudioServer.set_bus_volume_db(
			bus_index,
			-80.0
		)
		return

	AudioServer.set_bus_mute(
		bus_index,
		false
	)
	AudioServer.set_bus_volume_db(
		bus_index,
		volume_db
	)


# Converts master volume to decibels.
func _master_volume_to_db(
	value: float
) -> float:
	var clamped_value: float = clampf(
		value,
		0.0,
		1.0
	)

	if clamped_value <= 0.0:
		return -80.0

	if clamped_value <= MASTER_NO_CHANGE_VALUE:
		return lerpf(
			-40.0,
			0.0,
			clamped_value
				/ MASTER_NO_CHANGE_VALUE
		)

	return lerpf(
		0.0,
		MASTER_MAX_BOOST_DB,
		(
			clamped_value
				- MASTER_NO_CHANGE_VALUE
		) / (
			1.0
				- MASTER_NO_CHANGE_VALUE
		)
	)


# Resets only audio settings.
func reset_audio_settings(
	should_save: bool = true
) -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	music_volume = DEFAULT_MUSIC_VOLUME
	sfx_volume = DEFAULT_SFX_VOLUME

	_apply_audio_change(should_save)


# Sets fullscreen on or off.
func set_fullscreen(
	value: bool,
	should_save: bool = true
) -> void:
	fullscreen = value

	apply_display_settings()
	display_settings_changed.emit()

	if should_save:
		save_game()


# Applies the display setting.
func apply_display_settings() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)


# Stores the current level.
func set_current_level(
	level_scene: String,
	should_save: bool = true
) -> void:
	var cleaned_level_scene: String = (
		level_scene.strip_edges()
	)

	if cleaned_level_scene.is_empty():
		current_level_scene = (
			DEFAULT_CURRENT_LEVEL_SCENE
		)
	else:
		current_level_scene = cleaned_level_scene

	current_level_changed.emit(
		current_level_scene
	)

	if should_save:
		save_game()


# Gets the current level.
func get_current_level() -> String:
	if current_level_scene.strip_edges().is_empty():
		return DEFAULT_CURRENT_LEVEL_SCENE

	return current_level_scene


# Gets the most recent level.
func get_most_recent_level() -> String:
	return get_current_level()


# Saves custom input bindings.
func set_input_bindings(
	new_input_bindings: Dictionary,
	should_save: bool = true
) -> void:
	input_bindings = (
		new_input_bindings.duplicate(true)
	)

	input_bindings_changed.emit(
		input_bindings.duplicate(true)
	)

	if should_save:
		save_game()


# Clears custom input bindings.
func clear_input_bindings(
	should_save: bool = true
) -> void:
	input_bindings.clear()
	input_bindings_changed.emit({})

	if should_save:
		save_game()


# Resets settings but does not reset the balls.
func reset_all_settings(
	should_save: bool = true
) -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	music_volume = DEFAULT_MUSIC_VOLUME
	sfx_volume = DEFAULT_SFX_VOLUME
	fullscreen = DEFAULT_FULLSCREEN
	current_level_scene = DEFAULT_CURRENT_LEVEL_SCENE
	input_bindings.clear()

	apply_audio_settings()
	apply_display_settings()

	audio_settings_changed.emit()
	display_settings_changed.emit()

	current_level_changed.emit(
		current_level_scene
	)

	input_bindings_changed.emit({})

	if should_save:
		save_game()

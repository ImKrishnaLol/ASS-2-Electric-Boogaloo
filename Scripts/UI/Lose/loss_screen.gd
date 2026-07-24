extends Control


@export_group("Scenes")

# SceneManager key for level 1.
@export var first_level_scene: String = "main"

# SceneManager key for the main menu.
@export var main_menu_scene: String = "main_menu"


@export_group("Game")

# Used if GameData does not have a valid maximum.
@export var default_max_ball_count: int = 20


@export_group("Scene Transitions")

@export var retry_loading_duration: float = 1.0
@export var menu_loading_duration: float = 1.0


func _on_retry_button_pressed() -> void:
	# Return to level 1.
	LevelManager.set_level(1)

	# Use the existing maximum ball count.
	var maximum_balls: int = (
		GameData.maximum_ball_count
	)

	# Use the fallback if no maximum exists.
	if maximum_balls <= 0:
		maximum_balls = default_max_ball_count

	# Begin a new run with full balls.
	GameData.start_new_game(
		maximum_balls
	)

	# Store level 1 as the current level.
	GameData.set_current_level(
		first_level_scene
	)

	# Force level 1 to load from a fresh instance.
	SceneManager.go(
		first_level_scene,
		retry_loading_duration,
		true
	)


func _on_main_menu_button_pressed() -> void:
	# Prepare the level number for a new game.
	LevelManager.set_level(1)

	SceneManager.go(
		main_menu_scene,
		menu_loading_duration
	)

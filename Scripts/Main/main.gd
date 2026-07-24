extends Node


@export_group("Scenes")

@export var current_level_scene: String = "main"


@export_group("Game")

@export var starting_ball_count: int = 20


@export_group("Peggle Board Transition")

@export var board_fade_duration: float = 0.5


@onready var peggle_board: Node2D = (
	%PeggleBoard
)


var board_fade_tween: Tween


func _enter_tree() -> void:
	# Create the ball counter only if no game exists.
	GameData.ensure_ball_counter(
		starting_ball_count
	)


func _ready() -> void:
	# Save the current scene.
	GameData.set_current_level(
		current_level_scene
	)

	# Reveal the board after level dialogue.
	DialogueManager.level_dialogue_closed.connect(
		fade_in_peggle_board
	)

	# Begin with the board hidden.
	peggle_board.modulate.a = 0.0
	peggle_board.hide()

	# Wait for the dialogue controller to connect.
	_trigger_level_dialogue.call_deferred()


func _trigger_level_dialogue() -> void:
	# LevelManager and dialogue both start at one.
	EventBus.dialogue_level_triggered.emit(
		LevelManager.level
	)


func fade_in_peggle_board() -> void:
	# Stop the previous fade.
	if board_fade_tween != null:
		board_fade_tween.kill()

	peggle_board.show()
	peggle_board.modulate.a = 0.0

	# Fade the board in.
	board_fade_tween = create_tween()

	board_fade_tween.tween_property(
		peggle_board,
		"modulate:a",
		1.0,
		board_fade_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)


func fade_out_peggle_board() -> void:
	# Stop the previous fade.
	if board_fade_tween != null:
		board_fade_tween.kill()

	peggle_board.show()

	# Fade the board out.
	board_fade_tween = create_tween()

	board_fade_tween.tween_property(
		peggle_board,
		"modulate:a",
		0.0,
		board_fade_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	await board_fade_tween.finished

	peggle_board.hide()

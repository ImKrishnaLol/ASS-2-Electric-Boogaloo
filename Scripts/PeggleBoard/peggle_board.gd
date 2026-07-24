extends Node2D


enum Turn {
	PLAYER,
	AI
}


const FULL_BAR_FRACTION: float = 0.75

@export var STARTING_BALL_COUNT: int = 20

const WIN_SCENE_KEY: String = "win_screen"
const LOSS_SCENE_KEY: String = "loss_screen"
const END_SCREEN_TRANSITION_DURATION: float = 1.0

# COLLISION INFORMATION
# Layer 1: Walls
# Layer 2: Pegs
# Layer 3: Ball
# Layer 4: Bin

# BALL
@export var ball: PackedScene

# PEG LEVELS
# Assign PegsLevel1 through PegsLevel5 in order.
@export var peg_levels: Array[Node2D] = []

# AUDIO
@export var cannon_fire_sfx: AudioStream

# CANNON NODES
@onready var peggle_ball_shooter: Node2D = (
	$PeggleBallShooter
)
@onready var peggle_ball_barrel: Sprite2D = (
	$PeggleBallShooter/PeggleBallBarrel
)
@onready var peggle_ball_firing_point: Node2D = (
	$PeggleBallShooter/PeggleBallBarrel/PeggleBallFiringPoint
)
@onready var flash_cooldown: Timer = (
	$PeggleBallShooter/FlashCooldown
)
@onready var peggle_ball_animation_player: AnimationPlayer = (
	$PeggleBallShooter/PeggleBallAnimationPlayer
)

# BALL REMOVAL NODES
@onready var endzone: Area2D = $Endzone
@onready var ball_bin: PeggleBallBin = %Bin
@onready var bins: Node2D = $Bins

# INTERFACE NODES
@onready var player_progress_bar: ProgressBar = (
	$ProgressBar
)
@onready var ai_progress_bar: ProgressBar = (
	$ProgressBar2
)
@onready var ball_bar: ProgressBar = $BallBar
@onready var counting_label: Label = $CountingLabel

# SHOOTING
@export var shoot_offset: Vector2 = Vector2.ZERO
@export var shoot_strength: float = 100.0
@export_range(0, 180, 1) var left_turn_limit: int = 165
@export_range(0, 180, 1) var right_turn_limit: int = 15

var shoot_direction: Vector2

# AI
@export var ai_aim_time: float = 0.75

# PROGRESS BARS
@export var progress_bar_duration: float = 0.75

# ROUND STATE
var current_turn: int = Turn.PLAYER
var ball_in_play: bool = false
var resolving_ball: bool = false
var game_ended: bool = false

# PEG DATA
var active_peg_level: Node2D
var all_pegs: Array[Node] = []
var total_peg_count: int = 0

var progress_tween: Tween

# POWER-UPS
var is_ghost_ball: bool = false
var is_split_ball: bool = false

# SPAWNED BALLS
var new_ball: RigidBody2D
var split_ball: RigidBody2D


func _ready() -> void:
	endzone.body_entered.connect(
		destroy_ball
	)

	for child: Node in bins.get_children():
		if child.has_signal("ball_caught"):
			child.ball_caught.connect(
				catch_ball
			)

	peggle_ball_shooter.rotation = (
		deg_to_rad(90)
	)

	setup_ball_counter()

	# Show the peg layout for the current level.
	show_peg_level(
		LevelManager.level
	)

	reset_current_round()


func _process(_delta: float) -> void:
	if game_ended:
		return

	if resolving_ball:
		return

	if (
		current_turn == Turn.PLAYER
		and not ball_in_play
	):
		aim_shooter_at(
			get_global_mouse_position()
		)


func _input(event: InputEvent) -> void:
	if game_ended:
		return

	if resolving_ball:
		return

	if current_turn != Turn.PLAYER:
		return

	if ball_in_play:
		return

	if event.is_action_pressed(
		"action_primary"
	):
		if not DialogueManager._dialogue_box_displayed:
			fire_ball(
				get_global_mouse_position()
			)


func setup_ball_counter() -> void:
	GameData.ensure_ball_counter(
		STARTING_BALL_COUNT
	)

	update_ball_counter()


func use_ball() -> void:
	GameData.use_ball()
	update_ball_counter()


func refund_ball() -> void:
	GameData.refund_ball()
	update_ball_counter()


func update_ball_counter() -> void:
	ball_bar.min_value = 0.0

	ball_bar.max_value = float(
		GameData.maximum_ball_count
	)

	ball_bar.value = float(
		GameData.balls_remaining
	)

	counting_label.text = str(
		GameData.balls_remaining
	)


func show_peg_level(level_number: int) -> void:
	if peg_levels.is_empty():
		push_error(
			"No peg level nodes were assigned."
		)
		return

	var level_index: int = clampi(
		level_number - 1,
		0,
		peg_levels.size() - 1
	)

	# Hide and disable every peg layout.
	for index: int in range(
		peg_levels.size()
	):
		var peg_level: Node2D = peg_levels[index]

		if peg_level == null:
			continue

		var is_active: bool = (
			index == level_index
		)

		peg_level.visible = is_active

		if is_active:
			peg_level.process_mode = (
				Node.PROCESS_MODE_INHERIT
			)
		else:
			peg_level.process_mode = (
				Node.PROCESS_MODE_DISABLED
			)

		_set_level_collisions_enabled(
			peg_level,
			is_active
		)

	active_peg_level = peg_levels[level_index]

	refresh_pegs()


func _set_level_collisions_enabled(
	node: Node,
	enabled: bool
) -> void:
	# Hiding a Node2D does not disable physics,
	# so its collision shapes must also be disabled.
	for child: Node in node.get_children():
		if child is CollisionShape2D:
			child.set_deferred(
				"disabled",
				not enabled
			)

		elif child is CollisionPolygon2D:
			child.set_deferred(
				"disabled",
				not enabled
			)

		_set_level_collisions_enabled(
			child,
			enabled
		)


func refresh_pegs() -> void:
	all_pegs.clear()
	total_peg_count = 0

	if active_peg_level == null:
		return

	_collect_pegs(
		active_peg_level
	)

	total_peg_count = all_pegs.size()

	if all_pegs.is_empty():
		push_warning(
			"The active peg level contains no pegs."
		)


func _collect_pegs(node: Node) -> void:
	for child: Node in node.get_children():
		if child.is_in_group("pegs"):
			all_pegs.append(child)

		_collect_pegs(child)


func reset_current_round() -> void:
	# Stop an old progress animation.
	if progress_tween != null:
		progress_tween.kill()
		progress_tween = null

	refresh_pegs()

	# Reset every active peg.
	for peg: Node in all_pegs:
		if peg.has_method("reset_peg"):
			peg.call("reset_peg")

	# Reset the progress bars.
	player_progress_bar.min_value = 0.0
	player_progress_bar.max_value = 100.0
	player_progress_bar.value = 0.0

	ai_progress_bar.min_value = 0.0
	ai_progress_bar.max_value = 100.0
	ai_progress_bar.value = 0.0

	# Reset the turn.
	current_turn = Turn.PLAYER
	ball_in_play = false
	resolving_ball = false


func get_progress_values() -> Vector2:
	refresh_pegs()

	var player_peg_count: int = 0
	var ai_peg_count: int = 0

	for peg: Node in all_pegs:
		if not is_instance_valid(peg):
			continue

		if not peg.has_method(
			"get_claimed_turn"
		):
			continue

		var claimed_turn: int = int(
			peg.call("get_claimed_turn")
		)

		if claimed_turn == Turn.PLAYER:
			player_peg_count += 1
		elif claimed_turn == Turn.AI:
			ai_peg_count += 1

	return Vector2(
		get_progress_percentage(
			player_peg_count
		),
		get_progress_percentage(
			ai_peg_count
		)
	)


func animate_progress_bars() -> void:
	if game_ended:
		return

	var progress_values: Vector2 = (
		get_progress_values()
	)

	if progress_tween != null:
		progress_tween.kill()

	progress_tween = create_tween()
	progress_tween.set_parallel(true)

	progress_tween.tween_property(
		player_progress_bar,
		"value",
		progress_values.x,
		progress_bar_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	progress_tween.tween_property(
		ai_progress_bar,
		"value",
		progress_values.y,
		progress_bar_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	await progress_tween.finished

	check_for_winner()


func get_progress_percentage(
	claimed_peg_count: int
) -> float:
	if total_peg_count <= 0:
		return 0.0

	var pegs_required_for_full_bar: int = maxi(
		int(
			ceil(
				float(total_peg_count)
					* FULL_BAR_FRACTION
			)
		),
		1
	)

	return clampf(
		float(claimed_peg_count)
			/ float(pegs_required_for_full_bar)
			* 100.0,
		0.0,
		100.0
	)


func check_for_winner() -> void:
	# Player wins the current peg level.
	if (
		player_progress_bar.value
		>= player_progress_bar.max_value
	):
		if (
			LevelManager.level
			< LevelManager.MAX_LEVEL
		):
			advance_to_next_peg_level()
		else:
			end_game(
				WIN_SCENE_KEY
			)

	# AI wins the current peg level.
	elif (
		ai_progress_bar.value
		>= ai_progress_bar.max_value
	):
		# Zero balls always opens the loss screen.
		if GameData.balls_remaining <= 0:
			end_game(
				LOSS_SCENE_KEY
			)
		else:
			restart_current_peg_level()


func advance_to_next_peg_level() -> void:
	if game_ended:
		return

	game_ended = true

	# Fade out the board before changing pegs.
	await fade_out_board()

	# Advance the level number.
	LevelManager.set_level(
		LevelManager.level + 1
	)

	# Switch to the next group of pegs.
	show_peg_level(
		LevelManager.level
	)

	reset_current_round()

	# Allow gameplay after dialogue opens.
	game_ended = false

	# Start the next level dialogue.
	EventBus.dialogue_level_triggered.emit(
		LevelManager.level
	)


func restart_current_peg_level() -> void:
	if game_ended:
		return

	game_ended = true

	# Fade the board out.
	await fade_out_board()

	# Keep the same level and reset its pegs.
	show_peg_level(
		LevelManager.level
	)

	reset_current_round()

	game_ended = false

	# Replay the current level dialogue.
	EventBus.dialogue_level_triggered.emit(
		LevelManager.level
	)


func fade_out_board() -> void:
	var current_level_scene: Node = (
		get_tree().current_scene
	)

	if current_level_scene.has_method(
		"fade_out_peggle_board"
	):
		await current_level_scene.call(
			"fade_out_peggle_board"
		)


func end_game(scene_key: String) -> void:
	if game_ended:
		return

	game_ended = true

	await fade_out_board()

	# Only the final win and zero balls
	# cause a full scene transition.
	if scene_key == WIN_SCENE_KEY:
		SceneManager.go(
			WIN_SCENE_KEY,
			END_SCREEN_TRANSITION_DURATION,
			true
		)
	else:
		SceneManager.go(
			LOSS_SCENE_KEY,
			END_SCREEN_TRANSITION_DURATION
		)


func aim_shooter_at(
	target_position: Vector2
) -> void:
	peggle_ball_shooter.look_at(
		target_position
	)

	peggle_ball_shooter.rotation = clampf(
		peggle_ball_shooter.rotation,
		deg_to_rad(right_turn_limit),
		deg_to_rad(left_turn_limit)
	)


func fire_ball(
	target_position: Vector2
) -> void:
	if game_ended:
		return

	if resolving_ball:
		return

	# Zero balls opens the loss screen.
	if GameData.balls_remaining <= 0:
		end_game(
			LOSS_SCENE_KEY
		)
		return

	new_ball = (
		ball.instantiate() as RigidBody2D
	)

	if new_ball == null:
		push_error(
			"The assigned ball scene must use a RigidBody2D root."
		)
		return

	get_tree().current_scene.add_child(
		new_ball
	)

	new_ball.body_entered.connect(
		func(body: Node) -> void:
			_on_ball_body_entered(
				new_ball,
				body
			)
	)

	if is_ghost_ball:
		is_ghost_ball = false
		new_ball.ghost_ball()

	new_ball.global_position = (
		peggle_ball_firing_point.global_position
			+ shoot_offset
	)

	new_ball.set_meta(
		"is_peggle_ball",
		true
	)

	new_ball.set_meta(
		"ball_resolved",
		false
	)

	new_ball.set_meta(
		"ball_owner",
		get_current_ball_owner()
	)

	new_ball.set_meta(
		"turn_owner",
		current_turn
	)

	shoot_direction = (
		peggle_ball_firing_point.global_position
		.direction_to(target_position)
	)

	new_ball.apply_central_impulse(
		shoot_strength * shoot_direction
	)

	ball_in_play = true

	use_ball()
	game_feel()


func get_current_ball_owner() -> String:
	if current_turn == Turn.PLAYER:
		return "player"

	return "ai"


func game_feel() -> void:
	peggle_ball_barrel.modulate = Color(
		2,
		2,
		2
	)

	if peggle_ball_animation_player.is_playing():
		peggle_ball_animation_player.play(
			"RESET"
		)

	peggle_ball_animation_player.play(
		"CANNON_FIRE"
	)

	flash_cooldown.start()

	if cannon_fire_sfx != null:
		SfxPlayer.play(
			cannon_fire_sfx
		)


func catch_ball(
	body: Node2D,
	_bin_emotion: int
) -> void:
	resolve_ball(
		body,
		true
	)


func destroy_ball(
	body: Node2D
) -> void:
	resolve_ball(
		body,
		false
	)


func resolve_ball(
	body: Node2D,
	should_refund: bool
) -> void:
	if (
		body.get_meta(
			"is_peggle_ball",
			false
		) != true
	):
		return

	if (
		body.get_meta(
			"ball_resolved",
			false
		) == true
	):
		return

	body.set_meta(
		"ball_resolved",
		true
	)

	var finished_turn: int = int(
		body.get_meta(
			"turn_owner",
			current_turn
		)
	)

	body.queue_free()

	ball_in_play = false
	resolving_ball = true

	if should_refund:
		refund_ball()
	else:
		var percentage_left: float = 0.0

		if GameData.maximum_ball_count > 0:
			percentage_left = (
				float(
					GameData.balls_remaining
				)
				/ float(
					GameData.maximum_ball_count
				)
				* 100.0
			)

		EventBus.balls_left_percentage_changed.emit(
			percentage_left
		)

	finish_ball_resolution(
		finished_turn
	)


func finish_ball_resolution(
	finished_turn: int
) -> void:
	await get_tree().process_frame

	await animate_progress_bars()

	if game_ended:
		resolving_ball = false
		return

	# Zero balls is the only loss condition.
	if GameData.balls_remaining <= 0:
		resolving_ball = false
		end_game(
			LOSS_SCENE_KEY
		)
		return

	if finished_turn == Turn.PLAYER:
		current_turn = Turn.AI
		resolving_ball = false
		start_ai_turn()
	else:
		current_turn = Turn.PLAYER
		resolving_ball = false


func start_ai_turn() -> void:
	if game_ended:
		return

	if resolving_ball:
		return

	refresh_pegs()

	if all_pegs.is_empty():
		current_turn = Turn.PLAYER
		return

	var target_peg := (
		all_pegs.pick_random() as Node2D
	)

	if target_peg == null:
		current_turn = Turn.PLAYER
		return

	aim_shooter_at(
		target_peg.global_position
	)

	await get_tree().create_timer(
		ai_aim_time
	).timeout

	if game_ended:
		return

	if (
		current_turn != Turn.AI
		or ball_in_play
	):
		return

	if not is_instance_valid(target_peg):
		start_ai_turn()
		return

	fire_ball(
		target_peg.global_position
	)


func _on_flash_cooldown_timeout() -> void:
	peggle_ball_barrel.modulate = Color.WHITE

	peggle_ball_animation_player.play(
		"RESET"
	)


func _on_ball_body_entered(
	current_ball: RigidBody2D,
	_body: Node
) -> void:
	if is_split_ball:
		is_split_ball = false

		split_ball = (
			ball.instantiate() as RigidBody2D
		)

		if split_ball == null:
			return

		get_tree().current_scene.add_child(
			split_ball
		)

		split_ball.global_position = (
			current_ball.global_position
				+ shoot_offset
		)

		split_ball.apply_central_impulse(
			shoot_strength * shoot_direction
		)

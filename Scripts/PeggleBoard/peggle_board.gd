extends Node2D

enum Turn {
	PLAYER,
	AI
}

# COLLISION INFORMATION
# Layer 1: Walls
# Layer 2: Pegs
# Layer 3: Ball

# SCENES
@export var ball: PackedScene

# NODES
@onready var peggle_ball_shooter: Node2D = $PeggleBallShooter
@onready var peggle_ball_barrel: Sprite2D = $PeggleBallShooter/PeggleBallBarrel
@onready var peggle_ball_firing_point: Node2D = $PeggleBallShooter/PeggleBallBarrel/PeggleBallFiringPoint
@onready var flash_cooldown: Timer = $PeggleBallShooter/FlashCooldown
@onready var peggle_ball_animation_player: AnimationPlayer = $PeggleBallShooter/PeggleBallAnimationPlayer
@onready var endzone: Area2D = $Endzone

# SHOOTING
@export var shoot_offset: Vector2
@export var shoot_strength: float
@export var left_turn_limit: int
@export var right_turn_limit: int

# TURN SYSTEM
@export var player_hit_colour: Color = Color("#54cea7")
@export var ai_hit_colour: Color = Color("#ff82bd")
@export var ai_aim_time: float = 0.75

var current_turn: int = Turn.PLAYER
var ball_in_play: bool = false


func _ready() -> void:
	endzone.body_entered.connect(destroy_ball)
	peggle_ball_shooter.rotation = deg_to_rad(90)


func _process(_delta: float) -> void:
	if current_turn == Turn.PLAYER and not ball_in_play:
		aim_shooter_at(get_global_mouse_position())


func _input(event: InputEvent) -> void:
	if current_turn != Turn.PLAYER:
		return

	if ball_in_play:
		return

	if event.is_action_pressed("action_primary"):
		fire_ball(get_global_mouse_position())


func aim_shooter_at(target_position: Vector2) -> void:
	peggle_ball_shooter.look_at(target_position)

	peggle_ball_shooter.rotation = clampf(
		peggle_ball_shooter.rotation,
		deg_to_rad(right_turn_limit),
		deg_to_rad(left_turn_limit)
	)


func fire_ball(target_position: Vector2) -> void:
	var new_ball := ball.instantiate() as RigidBody2D

	if new_ball == null:
		push_error("The assigned ball scene must use a RigidBody2D root.")
		return

	get_tree().current_scene.add_child(new_ball)

	new_ball.global_position = (
		peggle_ball_firing_point.global_position
		+ shoot_offset
	)

	new_ball.set_meta("is_peggle_ball", true)
	new_ball.set_meta("hit_colour", get_current_hit_colour())

	var shoot_direction := (
		peggle_ball_firing_point.global_position
		.direction_to(target_position)
	)

	new_ball.apply_central_impulse(
		shoot_strength * shoot_direction
	)

	ball_in_play = true
	game_feel()


func get_current_hit_colour() -> Color:
	if current_turn == Turn.PLAYER:
		return player_hit_colour

	return ai_hit_colour


func game_feel() -> void:
	peggle_ball_barrel.modulate = Color(2, 2, 2)

	if peggle_ball_animation_player.is_playing():
		peggle_ball_animation_player.play("RESET")

	peggle_ball_animation_player.play("CANNON_FIRE")
	flash_cooldown.start()


func destroy_ball(body: Node2D) -> void:
	if body.get_meta("is_peggle_ball", false) != true:
		return

	body.queue_free()
	ball_in_play = false

	if current_turn == Turn.PLAYER:
		current_turn = Turn.AI
		start_ai_turn()
	else:
		current_turn = Turn.PLAYER


func start_ai_turn() -> void:
	var pegs := get_tree().get_nodes_in_group("pegs")

	if pegs.is_empty():
		current_turn = Turn.PLAYER
		return

	var target_peg := pegs.pick_random() as Node2D

	if target_peg == null:
		current_turn = Turn.PLAYER
		return

	aim_shooter_at(target_peg.global_position)

	await get_tree().create_timer(ai_aim_time).timeout

	if current_turn != Turn.AI or ball_in_play:
		return

	if not is_instance_valid(target_peg):
		start_ai_turn()
		return

	fire_ball(target_peg.global_position)


func _on_flash_cooldown_timeout() -> void:
	peggle_ball_barrel.modulate = Color.WHITE
	peggle_ball_animation_player.play("RESET")

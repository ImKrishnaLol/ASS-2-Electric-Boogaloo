extends Node2D

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

# VARIABLES (exports)
@export var shoot_offset: Vector2; # how far from shooter balls should spawn
@export var shoot_strength: float; # shooting momentum
@export var left_turn_limit: int; # the ammount the cannon can rotate left
@export var right_turn_limit: int; # the ammount the cannon can rotate right # inncrease me with negative numberes
@onready var endzone: Area2D = $Endzone

func _ready() -> void:
	endzone.body_entered.connect(destroy_ball)
	peggle_ball_shooter.rotation = 90

func _process(_delta: float) -> void:
	peggle_ball_shooter.look_at(get_global_mouse_position())
	peggle_ball_shooter.rotation = clampf(
		peggle_ball_shooter.rotation,
		deg_to_rad(right_turn_limit),
		deg_to_rad(left_turn_limit))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_primary"): # space/left click
		shoot_ball()
		game_feel()

func game_feel():
	peggle_ball_barrel.modulate = Color(2, 2, 2)
	if peggle_ball_animation_player.is_playing():
		peggle_ball_animation_player.play("RESET")
	peggle_ball_animation_player.play("CANNON_FIRE")
	flash_cooldown.start()

func shoot_ball() -> void:
	var new_ball = ball.instantiate()
	get_tree().current_scene.add_child(new_ball)
	new_ball.global_position = peggle_ball_firing_point.global_position + shoot_offset
	# make it move in a direction
	new_ball.apply_central_impulse(shoot_strength * get_direction_to_mouse())

func get_direction_to_mouse() -> Vector2:
	var mouse_position = get_global_mouse_position()
	var direction = peggle_ball_shooter.global_position.direction_to(mouse_position)
	print(direction)
	return direction

func destroy_ball(body: Node2D) -> void:
	if body is not RigidBody2D: return # not a ball
	print("ball destroyed")
	body.queue_free()


func _on_flash_cooldown_timeout() -> void:
	peggle_ball_barrel.modulate = Color(1.0, 1.0, 1.0)
	peggle_ball_animation_player.play("RESET")

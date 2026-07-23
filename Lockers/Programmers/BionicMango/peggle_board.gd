extends Node2D

# COLLISION INFORMATION
# Layer 1: Walls
# Layer 2: Pegs
# Layer 3: Ball

# SCENES
@export var ball: PackedScene
@onready var peggle_ball_shooter: Sprite2D = $PeggleBallShooter

# VARIABLES (exports)
@export var shoot_offset: Vector2; # how far from shooter balls should spawn
@export var shoot_strength: float; # shooting momentum
@onready var endzone: Area2D = $Endzone

func _ready() -> void:
	endzone.body_entered.connect(destroy_ball)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_primary"): # space/left click
		shoot_ball()

func shoot_ball() -> void:
	var new_ball = ball.instantiate()
	get_tree().current_scene.add_child(new_ball)
	new_ball.global_position = peggle_ball_shooter.global_position + shoot_offset
	# make it move in a direction
	new_ball.apply_central_impulse(shoot_strength * get_direction_to_mouse())

func get_direction_to_mouse() -> Vector2:
	var mouse_position = get_global_mouse_position()
	var direction = peggle_ball_shooter.global_position.direction_to(mouse_position)
	return direction

func destroy_ball(body: Node2D) -> void:
	if body is not RigidBody2D: return # not a ball
	print("ball destroyed")
	body.queue_free()

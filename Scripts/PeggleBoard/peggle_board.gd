extends Node2D

# COLLISION INFORMATION
# Layer 1: Walls
# Layer 2: Pegs
# Layer 3: Ball

# SCENES
var win_screen: String = "res://Scenes/UI/Win/win_screen.tscn"
@export var ball: PackedScene
@onready var peggle_ball_shooter: Node2D = $PeggleBallShooter
@onready var peggle_ball_firing_point: Node2D = $PeggleBallShooter/PeggleBallBarrel/PeggleBallFiringPoint
@onready var pegs: Node2D = $Pegs

# VARIABLES (exports)
@export var shoot_offset: Vector2; # how far from shooter balls should spawn
@export var shoot_strength: float; # shooting momentum
@onready var endzone: Area2D = $Endzone

func _ready() -> void:
	endzone.body_entered.connect(destroy_ball)
	peggle_ball_shooter.rotation = 90

func _process(_delta: float) -> void:
	win_condition()
	peggle_ball_shooter.look_at(get_global_mouse_position())
	peggle_ball_shooter.rotation = clampf(
		peggle_ball_shooter.rotation,
		deg_to_rad(0),
		deg_to_rad(180))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_primary"): # space/left click
		shoot_ball()

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

func win_condition() -> void:
	var blue_count = 0
	var pink_count = 0
	for child in pegs.get_children():
		if child.value == "blue":
			blue_count += 1.0
		elif child.value == "pink":
			pink_count += 1.0
	var win_percentage = (pink_count / pegs.get_child_count()) * 100
	var loss_percentage = (blue_count / pegs.get_child_count()) * 100
	if win_percentage > 75 :
		print("win")
		SceneManager.go(win_screen)

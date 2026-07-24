extends RigidBody2D

#SCENES
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var ball_textures: Array[Texture2D]

@onready var sprite_2d: Sprite2D = $Sprite2D

#Variables for different powerups
var is_ghost_ball = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if ball_textures.is_empty():
		push_warning("No ballz textures have been assigned.")
		return

	sprite_2d.texture = ball_textures.pick_random()
	
func ghost_ball():
	collision_shape_2d.disabled=true
	await get_tree().create_timer(3).timeout
	collision_shape_2d.disabled=false
	

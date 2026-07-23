extends RigidBody2D

@export var ball_textures: Array[Texture2D]

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	if ball_textures.is_empty():
		push_warning("No ballz textures have been assigned.")
		return

	sprite_2d.texture = ball_textures.pick_random()

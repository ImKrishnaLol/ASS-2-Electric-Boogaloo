extends RigidBody2D

#SCENES
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

#Variables for different powerups
var is_ghost_ball = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func ghost_ball():
	collision_shape_2d.disabled=true
	await get_tree().create_timer(3).timeout
	collision_shape_2d.disabled=false
	

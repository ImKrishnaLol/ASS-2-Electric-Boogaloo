extends RigidBody2D

#SCENES
@export var ball_dot: PackedScene

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var ball_textures: Array[Texture2D]
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if ball_textures.is_empty():
		push_warning("No ballz textures have been assigned.")
		return

	sprite_2d.texture = ball_textures.pick_random()
	
func ghost_ball():
	collision_mask=1+3
	await get_tree().create_timer(1).timeout
	collision_mask=1+2+3


func _on_timer_timeout() -> void:
	var dot_ins = ball_dot.instantiate()
	get_tree().current_scene.add_child(dot_ins)  
	dot_ins.global_position = (global_position)


func _on_body_entered(_body: Node) -> void:
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("BALL_BOUNCE")

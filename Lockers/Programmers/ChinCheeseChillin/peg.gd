extends StaticBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var bouncing_ball = $"../Ball"
var hit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hit == true:
		animated_sprite.play("hit")


func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	hit = true

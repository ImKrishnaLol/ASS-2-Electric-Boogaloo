extends StaticBody2D

# child nodes
@onready var area_2d: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
var ball_texture: Texture2D = load("res://Assets/Art/Game/PeggleBoard/Ball (2).png")
var value: String  = "defauult"

func _ready() -> void:
	area_2d.body_entered.connect(destroy_peg)

func destroy_peg(_body: Node2D) -> void:
	sprite.texture = ball_texture
	value = "pink"
	#queue_free()

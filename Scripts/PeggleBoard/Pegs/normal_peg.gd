extends StaticBody2D

# child nodes
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.body_entered.connect(destroy_peg)

func destroy_peg(_body: Node2D) -> void:
	queue_free()

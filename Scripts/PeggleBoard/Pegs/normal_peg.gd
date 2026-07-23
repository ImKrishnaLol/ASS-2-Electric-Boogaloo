extends StaticBody2D

@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	add_to_group("pegs")
	area_2d.body_entered.connect(change_peg_colour)


func change_peg_colour(body: Node2D) -> void:
	if body.get_meta("is_peggle_ball", false) != true:
		return

	var hit_colour: Color = body.get_meta(
		"hit_colour",
		Color.WHITE
	)

	modulate = hit_colour

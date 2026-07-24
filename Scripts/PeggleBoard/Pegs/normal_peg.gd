extends StaticBody2D

signal claim_changed

@onready var hit_area: Area2D = $Area2D
@onready var peg_sprite: AnimatedSprite2D = $Sprite2D

const PEG_TEXTURE_A = preload("uid://dvw1g6cx3q43s")
const PEG_TEXTURE_B = preload("uid://dfr50ew5ksk84")

# -1 means the peg has not been claimed yet.
var claimed_turn: int = -1


func _ready() -> void:
	hit_area.body_entered.connect(change_peg_colour)

	peg_sprite.play("default")


func change_peg_colour(body: Node2D) -> void:
	if body.get_meta("is_peggle_ball", false) != true:
		return

	var new_claimed_turn: int = int(
		body.get_meta("turn_owner", -1)
	)
	


	if new_claimed_turn == -1:
		return

	peg_sprite.play( body.get_meta( "ball_owner", "default" ))
	#var hit_colour: Color = body.get_meta(
		#"ball_owner",
		#Color.WHITE
	#)

	#modulate = hit_colour

	if claimed_turn == new_claimed_turn:
		return

	claimed_turn = new_claimed_turn
	
	claim_changed.emit()


func get_claimed_turn() -> int:
	return claimed_turn

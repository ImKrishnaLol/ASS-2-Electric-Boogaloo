extends StaticBody2D

signal claim_changed

@onready var hit_area: Area2D = $Area2D
@onready var peg_sprite: AnimatedSprite2D = $Sprite2D

const PEG_TEXTURE_A = preload("uid://dvw1g6cx3q43s")
const PEG_TEXTURE_B = preload("uid://dfr50ew5ksk84")

# -1 means the peg has not been claimed yet.
var claimed_turn: int = -1
var tween = create_tween()

func _ready() -> void:
	hit_area.body_entered.connect(change_peg_colour)

	peg_sprite.play("default")


func change_peg_colour(body: Node2D) -> void:
	scale = Vector2(0.6, 0.6)
	if body.get_meta("is_peggle_ball", false) != true:
		return

	var new_claimed_turn: int = int(
		body.get_meta("turn_owner", -1)
	)
	


	if new_claimed_turn == -1:
		return
	
	peg_sprite.stop()
	peg_sprite.play( body.get_meta( "ball_owner", "default" ))
	
	#other effects
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", scale * 1.5, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.6, 0.6), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if claimed_turn == new_claimed_turn:
		return

	claimed_turn = new_claimed_turn
	
	claim_changed.emit()


func get_claimed_turn() -> int:
	return claimed_turn

class_name PeggleBallBin
extends Area2D

signal ball_caught(ball: Node2D)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.get_meta("is_peggle_ball", false) != true:
		return
	
	if body.get_meta("ball_resolved", false) == true:
		return
	
	ball_caught.emit(body)

class_name PeggleBallBin
extends Area2D

signal ball_caught(ball: Node2D, bin_emotion: int)

@export_enum("Angry", "Sad") var what_emotion_to_resoond_to: int = 0



func _ready() -> void:
	$Sprite2D.texture = load("res://Assets/Art/Game/BinSprites/" + GameData.emotions.keys()[what_emotion_to_resoond_to] + "Bin.png")
	body_entered.connect(_on_body_entered)
	if get_child_count() == 3:
		GameData.connect("emotion_changed", get_child(2).emotion_effect())


func _on_body_entered(body: Node2D) -> void:
	if body.get_meta("is_peggle_ball", false) != true:
		return
	
	if body.get_meta("ball_resolved", false) == true:
		return
	
	ball_caught.emit(body, what_emotion_to_resoond_to)

	

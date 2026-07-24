extends Node2D

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "global_position:y", 5, 3).as_relative().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position:y", -5, 3).as_relative().set_trans(Tween.TRANS_QUAD)
	

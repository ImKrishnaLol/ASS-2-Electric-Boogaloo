extends Node

#These exist strictly to show how an eventbus works. 
signal score_changed(new_score: int)
signal chinchilla_pooped(poop_count: int, poop_position: Vector2)
signal dialogue_triggered(input_dialogue: Array[String])

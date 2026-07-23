extends Node

#These exist strictly to show how an eventbus works. 
signal score_changed(new_score: int)
signal chinchilla_pooped(poop_count: int, poop_position: Vector2)

signal dialogue_mood_triggered(mood: String, dialogue_level: int)
signal dialogue_level_triggered(level: int)

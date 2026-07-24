extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var textures: Dictionary[String, Texture2D]

func _ready() -> void:
	EventBus.dialogue_mood_triggered.connect(change_sprite)

func change_sprite(mood: String):
	if textures[mood]:
		sprite_2d.texture = textures[mood]

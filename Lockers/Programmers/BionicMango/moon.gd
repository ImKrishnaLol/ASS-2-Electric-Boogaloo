extends Node2D

# TEXTURES
@export var moon_textures: Array[Texture2D]
@export var moon_type: int = 0 # choose which texture to use

# NODES
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	sprite_2d.texture = moon_textures[moon_type]
	cpu_particles_2d.global_position = sprite_2d.global_position
	cpu_particles_2d.finished.connect(func(): print("yay"); queue_free) # destroy

func explode() -> void:
	animation_player.play("explode")

func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("action_primary"): explode() # temporary signal

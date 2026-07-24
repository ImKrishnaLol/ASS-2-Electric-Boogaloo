class_name CelestialBody
extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var body_id: StringName
@export var sprite_texture: Texture2D

@export var explosion_speed: float = 1.0
@export var particle_speed: float = 1.0

@export var explosion_lifetime: float = 0.7
@export var particle_count: int = 100
@export var particle_scale_min: float = 1.0
@export var particle_scale_max: float = 2.0

var has_exploded: bool = false


func _ready() -> void:
	EventBus.celestial_body_explosion_triggered.connect(
		_on_explosion_triggered
	)

	cpu_particles_2d.finished.connect(queue_free)

	setup_sprite()
	setup_explosion()


func setup_sprite() -> void:
	if sprite_texture != null:
		sprite_2d.texture = sprite_texture


func setup_explosion() -> void:
	animation_player.speed_scale = explosion_speed

	cpu_particles_2d.position = sprite_2d.position
	cpu_particles_2d.speed_scale = particle_speed
	cpu_particles_2d.lifetime = explosion_lifetime
	cpu_particles_2d.amount = particle_count
	cpu_particles_2d.scale_amount_min = particle_scale_min
	cpu_particles_2d.scale_amount_max = particle_scale_max

	cpu_particles_2d.one_shot = true
	cpu_particles_2d.emitting = false


func _on_explosion_triggered(
	triggered_body_id: StringName
) -> void:
	if triggered_body_id != body_id:
		return

	explode()


func explode() -> void:
	if has_exploded:
		return

	has_exploded = true

	animation_player.play("explode")

	cpu_particles_2d.restart()
	cpu_particles_2d.emitting = true

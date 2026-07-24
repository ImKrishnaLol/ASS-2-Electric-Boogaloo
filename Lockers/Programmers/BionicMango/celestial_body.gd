class_name CelestialBody extends Node2D

# NODES
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# EXPORT PARAMETERS
@export var explosion_speed: float = 1 # animation_player (ratio)
@export var particle_speed: float = 1 # gpu particles (ratio)

@export var explosion_lifetime: float = 0.7 # seconds
@export var particle_count: int = 100
@export var particle_scale_size: Array[float] = [1.0, 2.0] # [min, max]
@export var time_countdown: float = 2.0 # when to call time - REMOVE???

func _ready() -> void:
	# SIGNALS
	cpu_particles_2d.finished.connect(queue_free) # destroy when animation finished
	
	# SYNCING VALUES
	# animation
	animation_player.speed_scale = explosion_speed
	# particles
	cpu_particles_2d.global_position = sprite_2d.global_position
	cpu_particles_2d.speed_scale = particle_speed
	cpu_particles_2d.lifetime = explosion_lifetime
	cpu_particles_2d.amount = particle_count
	cpu_particles_2d.scale_amount_min = particle_scale_size[0]
	cpu_particles_2d.scale_amount_max = particle_scale_size[1]
	
	# KABOOM !!!
	explode(time_countdown)

func explode(time: float) -> void:
	await get_tree().create_timer(time).timeout
	animation_player.play("explode")

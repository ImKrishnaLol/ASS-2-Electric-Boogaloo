extends Node2D

@export var segments: Array[Sprite2D] = []

# SNAKE IS NOT WORKING YET. DIEM AND I ARE STILL COOKING.

@export_group("Wriggling")
@export var wriggle_angle: float = 3.0
@export var wriggle_height: float = 3.0
@export var wriggle_scale: float = 0.05
@export var wave_difference: float = 0.45
@export var wriggle_duration: float = 3.0

var starting_rotations: Array[float] = []
var starting_positions: Array[Vector2] = []
var starting_scales: Array[Vector2] = []

var wriggle_tween: Tween


func _ready() -> void:
	if segments.is_empty():
		push_error("Assign the snake segments from the fixed end to the tail.")
		return
	
	for segment: Sprite2D in segments:
		starting_rotations.append(segment.rotation)
		starting_positions.append(segment.position)
		starting_scales.append(segment.scale)
	
	start_wriggling()


func start_wriggling() -> void:
	if wriggle_tween != null:
		wriggle_tween.kill()
	
	wriggle_tween = create_tween()
	wriggle_tween.set_loops()
	wriggle_tween.tween_method(
		update_wriggle,
		0.0,
		TAU,
		wriggle_duration
	)


func update_wriggle(phase: float) -> void:
	for index: int in segments.size():
		var segment: Sprite2D = segments[index]
		var wave: float = sin(phase + index * wave_difference)
		var wriggle_strength: float = absf(wave)
		
		segment.rotation = (
			starting_rotations[index]
			+ wave * deg_to_rad(wriggle_angle)
		)
		
		segment.position = (
			starting_positions[index]
			+ Vector2.UP * wave * wriggle_height
		)
		
		segment.scale = starting_scales[index] * (
			1.0 + wriggle_strength * wriggle_scale
		)

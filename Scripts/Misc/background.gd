extends Node2D

@export var wall_sections: Array[Sprite2D]

@onready var table: Sprite2D = $TableObjects/Table
@onready var tv: Sprite2D = $TableObjects/TV
@onready var object: Sprite2D = $TableObjects/Object
@onready var disco_light: AnimatedSprite2D = $DiscoLight

@onready var arcadia_sign: AnimatedSprite2D = $ArcadiaSign
@onready var arcadia_sign_2: AnimatedSprite2D = $ArcadiaSign2
@onready var arcadia_sign_3: AnimatedSprite2D = $ArcadiaSign3

@onready var small_stars_0: Sprite2D = $Space/SmallStars0
@onready var small_stars_1: Sprite2D = $Space/SmallStars1
@onready var small_stars_2: Sprite2D = $Space/SmallStars2

@onready var med_stars_0: Sprite2D = $Space/MedStars0
@onready var med_stars_1: Sprite2D = $Space/MedStars1

@onready var big_stars_0: Sprite2D = $Space/BigStars0
@onready var big_stars_1: Sprite2D = $Space/BigStars1
@onready var big_stars_2: Sprite2D = $Space/BigStars2

@export var trigger_percentages: Array[float] = [
	85.0,
	70.0,
	55.0,
	40.0,
	25.0,
	10.0
]

@export var shatter_durations: Array[float] = [
	2.5,
	3.0,
	3.5,
	4.0,
	4.5,
	5.0
]

@export var star_trigger_percentages: Array[float] = [
	95.0,
	90.0,
	70.0,
	60.0,
	50.0,
	45.0,
	35.0,
	20.0
]

@export var celestial_body_ids: Array[StringName] = [
	&"grey_moon",
	&"purple_moon",
	&"blue_planet",
	&"ring_planet",
	&"sun"
]

@export var celestial_trigger_percentages: Array[float] = [
	80.0,
	65.0,
	30.0,
	15.0,
	5.0
]

# DISCO LIGHT
@export var disco_peak_fps: float = 20.0
@export var disco_final_fps: float = 6.0

# ARCADIA SIGN LOOP
@export var arcadia_start_x: float = 380.0
@export var arcadia_right_x: float = 380.0
@export var arcadia_sign_spacing: float = 148.0
@export var arcadia_movement_speed: float = 40.0

@export var arcadia_fade_in_start_x: float = -64.0
@export var arcadia_fade_in_end_x: float = 84.0
@export var arcadia_fade_out_start_x: float = 350.0
@export var arcadia_fade_out_end_x: float = 380.0

@export var arcadia_sign_fade_duration: float = 3.0
@export var object_fade_duration: float = 1.5
@export var star_fade_duration: float = 20.0

var star_layers: Array[Sprite2D] = []
var arcadia_signs: Array[AnimatedSprite2D] = []

var triggered_sections: Array[bool] = []
var triggered_star_layers: Array[bool] = []
var triggered_celestial_bodies: Array[bool] = []

var next_section_to_process: int = 0
var processing_transitions: bool = false

var arcadia_loop_active: bool = true
var arcadia_visibility: float = 1.0


func _ready() -> void:
	setup_wall_sections()
	setup_star_layers()
	setup_celestial_bodies()
	setup_arcadia_signs()

	EventBus.balls_left_percentage_changed.connect(
		_on_balls_left_percentage_changed
	)


func _process(delta: float) -> void:
	update_arcadia_signs(delta)


func setup_wall_sections() -> void:
	triggered_sections.resize(wall_sections.size())
	triggered_sections.fill(false)

	for section: Sprite2D in wall_sections:
		if section == null:
			continue

		if not section.material is ShaderMaterial:
			push_warning(
				section.name
				+ " does not have a ShaderMaterial."
			)
			continue

		section.material = section.material.duplicate()

		var shader_material := (
			section.material as ShaderMaterial
		)

		shader_material.set_shader_parameter(
			"shatter_progress",
			0.0
		)

		section.show()


func setup_star_layers() -> void:
	star_layers = [
		small_stars_0,
		small_stars_1,
		small_stars_2,
		med_stars_0,
		med_stars_1,
		big_stars_0,
		big_stars_1,
		big_stars_2
	]

	triggered_star_layers.resize(star_layers.size())
	triggered_star_layers.fill(false)


func setup_celestial_bodies() -> void:
	triggered_celestial_bodies.resize(
		celestial_body_ids.size()
	)

	triggered_celestial_bodies.fill(false)


func setup_arcadia_signs() -> void:
	arcadia_signs = [
		arcadia_sign,
		arcadia_sign_2,
		arcadia_sign_3
	]

	for sign_index: int in arcadia_signs.size():
		var sign := arcadia_signs[sign_index]

		sign.position.x = (
			arcadia_start_x
			- arcadia_sign_spacing * sign_index
		)

		sign.show()

	update_arcadia_signs(0.0)


func update_arcadia_signs(delta: float) -> void:
	if not arcadia_loop_active:
		return

	var loop_width := (
		arcadia_sign_spacing
		* float(arcadia_signs.size())
	)

	for sign: AnimatedSprite2D in arcadia_signs:
		sign.position.x += (
			arcadia_movement_speed
			* delta
		)

		if sign.position.x > arcadia_right_x:
			sign.position.x -= loop_width

		var fade_in_visibility := clampf(
			(
				sign.position.x
				- arcadia_fade_in_start_x
			)
			/ (
				arcadia_fade_in_end_x
				- arcadia_fade_in_start_x
			),
			0.0,
			1.0
		)

		var fade_out_visibility := 1.0 - clampf(
			(
				sign.position.x
				- arcadia_fade_out_start_x
			)
			/ (
				arcadia_fade_out_end_x
				- arcadia_fade_out_start_x
			),
			0.0,
			1.0
		)

		var edge_visibility := minf(
			fade_in_visibility,
			fade_out_visibility
		)

		var sign_colour := sign.modulate

		sign_colour.a = (
			edge_visibility
			* arcadia_visibility
		)

		sign.modulate = sign_colour


func _on_balls_left_percentage_changed(
	percentage: float
) -> void:
	check_wall_sections(percentage)
	check_star_layers(percentage)
	check_celestial_bodies(percentage)

	process_transition_queue()


func check_wall_sections(percentage: float) -> void:
	for section_index: int in wall_sections.size():
		if triggered_sections[section_index]:
			continue

		if section_index >= trigger_percentages.size():
			continue

		if section_index >= shatter_durations.size():
			continue

		if percentage <= trigger_percentages[section_index]:
			triggered_sections[section_index] = true


func check_star_layers(percentage: float) -> void:
	for star_index: int in star_layers.size():
		if triggered_star_layers[star_index]:
			continue

		if star_index >= star_trigger_percentages.size():
			continue

		if percentage <= star_trigger_percentages[star_index]:
			triggered_star_layers[star_index] = true
			fade_star_layer(star_index)


func check_celestial_bodies(
	percentage: float
) -> void:
	for body_index: int in celestial_body_ids.size():
		if triggered_celestial_bodies[body_index]:
			continue

		if body_index >= celestial_trigger_percentages.size():
			continue

		if percentage <= celestial_trigger_percentages[body_index]:
			triggered_celestial_bodies[body_index] = true

			EventBus.celestial_body_explosion_triggered.emit(
				celestial_body_ids[body_index]
			)


func process_transition_queue() -> void:
	if processing_transitions:
		return

	processing_transitions = true

	while next_section_to_process < wall_sections.size():
		if not triggered_sections[next_section_to_process]:
			break

		await process_wall_section(
			next_section_to_process
		)

		next_section_to_process += 1

	processing_transitions = false


func process_wall_section(section_index: int) -> void:
	if section_index == 0:
		animate_disco_light()

		await shatter_wall_section(0)
		await fade_sprite(tv)
		return

	if section_index == 1:
		fade_arcadia_signs()

		await shatter_wall_section(1)
		await fade_sprite(object)
		await fade_sprite(table)
		return

	await shatter_wall_section(section_index)


func animate_disco_light() -> void:
	if disco_light == null:
		return

	if disco_light.sprite_frames == null:
		return

	var animation_name := disco_light.animation

	var base_fps := disco_light.sprite_frames.get_animation_speed(
		animation_name
	)

	if base_fps <= 0.0:
		return

	var duration := shatter_durations[0]
	var half_duration := duration * 0.5

	var peak_speed_scale := disco_peak_fps / base_fps
	var final_speed_scale := disco_final_fps / base_fps

	var speed_tween := create_tween()

	speed_tween.tween_property(
		disco_light,
		"speed_scale",
		peak_speed_scale,
		half_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	speed_tween.tween_property(
		disco_light,
		"speed_scale",
		final_speed_scale,
		half_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	var fade_tween := create_tween()

	fade_tween.tween_property(
		disco_light,
		"modulate:a",
		0.0,
		duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN_OUT
	)

	fade_tween.tween_callback(disco_light.hide)


func shatter_wall_section(section_index: int) -> void:
	if section_index >= wall_sections.size():
		return

	var section: Sprite2D = wall_sections[section_index]

	if section == null:
		return

	if not section.material is ShaderMaterial:
		push_error(
			section.name
				+ " needs a ShaderMaterial."
		)
		return

	var shader_material := (
		section.material as ShaderMaterial
	)

	var shatter_duration: float = (
		shatter_durations[section_index]
	)

	var tween := create_tween()

	tween.tween_property(
		shader_material,
		"shader_parameter/shatter_progress",
		1.0,
		shatter_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	await tween.finished

	section.hide()


func fade_sprite(sprite: Sprite2D) -> void:
	if sprite == null:
		return

	var tween := create_tween()

	tween.tween_property(
		sprite,
		"modulate:a",
		0.0,
		object_fade_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN_OUT
	)

	await tween.finished

	sprite.hide()


func fade_arcadia_signs() -> void:
	if not arcadia_loop_active:
		return

	var tween := create_tween()

	tween.tween_property(
		self,
		"arcadia_visibility",
		0.0,
		arcadia_sign_fade_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN_OUT
	)

	tween.tween_callback(
		finish_arcadia_sign_fade
	)


func finish_arcadia_sign_fade() -> void:
	arcadia_loop_active = false

	for sign: AnimatedSprite2D in arcadia_signs:
		sign.hide()


func fade_star_layer(star_index: int) -> void:
	if star_index >= star_layers.size():
		return

	var star: Sprite2D = star_layers[star_index]

	if star == null:
		return

	var tween := create_tween()

	tween.tween_property(
		star,
		"modulate:a",
		0.0,
		star_fade_duration
	).set_trans(
		Tween.TRANS_LINEAR
	)

	tween.tween_callback(star.hide)

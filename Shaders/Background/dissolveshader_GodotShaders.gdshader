shader_type canvas_item;

uniform float shatter_progress : hint_range(0.0, 1.0) = 0.0;

uniform vec2 shard_grid = vec2(20.0, 16.0);
uniform float movement_distance : hint_range(0.0, 0.5) = 0.12;
uniform float crack_width : hint_range(0.0, 0.2) = 0.035;

uniform vec4 crack_colour : source_color = vec4(
	0.05,
	0.03,
	0.08,
	1.0
);


float random_value(vec2 value) {
	return fract(
		sin(dot(value, vec2(12.9898, 78.233)))
		* 43758.5453
	);
}


void fragment() {
	vec2 grid_uv = UV * shard_grid;
	vec2 shard_cell = floor(grid_uv);
	vec2 shard_uv = fract(grid_uv);

	float diagonal_direction = random_value(shard_cell);

	float triangle;

	if (diagonal_direction < 0.5) {
		triangle = step(1.0, shard_uv.x + shard_uv.y);
	} else {
		triangle = step(shard_uv.x, shard_uv.y);
	}

	vec2 shard_id = shard_cell + vec2(
		triangle * 17.0,
		triangle * 31.0
	);

	float random_x = random_value(
		shard_id + vec2(4.2, 8.7)
	);

	float random_y = random_value(
		shard_id + vec2(9.3, 2.4)
	);

	vec2 movement_direction = normalize(
		vec2(
			random_x * 2.0 - 1.0,
			0.5 + random_y
		)
	);

	float movement_progress = smoothstep(
		0.05,
		1.0,
		shatter_progress
	);

	vec2 sample_uv = UV - (
		movement_direction
		* movement_distance
		* movement_progress
	);

	vec4 texture_colour = texture(
		TEXTURE,
		sample_uv
	);

	float grid_edge = min(
		min(shard_uv.x, 1.0 - shard_uv.x),
		min(shard_uv.y, 1.0 - shard_uv.y)
	);

	float diagonal_edge;

	if (diagonal_direction < 0.5) {
		diagonal_edge = abs(
			shard_uv.x + shard_uv.y - 1.0
		);
	} else {
		diagonal_edge = abs(
			shard_uv.x - shard_uv.y
		);
	}

	float shard_edge = min(
		grid_edge,
		diagonal_edge
	);

	float crack = 1.0 - smoothstep(
		0.0,
		crack_width,
		shard_edge
	);

	float crack_progress = smoothstep(
		0.0,
		0.15,
		shatter_progress
	);

	texture_colour.rgb = mix(
		texture_colour.rgb,
		crack_colour.rgb,
		crack * crack_progress
	);

	float fade_order = random_value(
		shard_id + vec2(15.7, 22.1)
	);

	float fade_start = mix(
		0.15,
		0.65,
		fade_order
	);

	float shard_alpha = 1.0 - smoothstep(
		fade_start,
		fade_start + 0.3,
		shatter_progress
	);

	texture_colour.a *= shard_alpha;

	if (
		sample_uv.x < 0.0
		|| sample_uv.x > 1.0
		|| sample_uv.y < 0.0
		|| sample_uv.y > 1.0
	) {
		texture_colour.a = 0.0;
	}

	COLOR = texture_colour;
}
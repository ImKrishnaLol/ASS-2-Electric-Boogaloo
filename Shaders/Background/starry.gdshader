shader_type canvas_item;

uniform float scroll_speed : hint_range(0.0, 0.05) = 0.003;
uniform float star_amount : hint_range(0.0, 1.0) = 0.32;
uniform float star_brightness : hint_range(0.0, 3.0) = 1.25;
uniform float cloud_strength : hint_range(0.0, 1.0) = 0.12;

// #0d2147, darkened towards the top
uniform vec4 background_colour : source_color = vec4(
	0.05098, 0.12941, 0.27843, 1.0
);

// #ce79d2
uniform vec4 star_colour_1 : source_color = vec4(
	0.80784, 0.47451, 0.82353, 1.0
);

// #f4dfbe
uniform vec4 star_colour_2 : source_color = vec4(
	0.95686, 0.87451, 0.74510, 1.0
);

// #ff82bd
uniform vec4 star_colour_3 : source_color = vec4(
	1.0, 0.50980, 0.74118, 1.0
);

// #becbeb
uniform vec4 star_colour_4 : source_color = vec4(
	0.74510, 0.79608, 0.92157, 1.0
);


float hash(vec2 position) {
	position = fract(position * vec2(123.34, 456.21));
	position += dot(position, position + 45.32);
	return fract(position.x * position.y);
}


vec2 hash2(vec2 position) {
	return vec2(
		hash(position),
		hash(position + vec2(37.0, 91.0))
	);
}


float noise(vec2 position) {
	vec2 cell = floor(position);
	vec2 local = fract(position);
	
	local = local * local * (3.0 - 2.0 * local);
	
	float bottom_left = hash(cell);
	float bottom_right = hash(cell + vec2(1.0, 0.0));
	float top_left = hash(cell + vec2(0.0, 1.0));
	float top_right = hash(cell + vec2(1.0, 1.0));
	
	return mix(
		mix(bottom_left, bottom_right, local.x),
		mix(top_left, top_right, local.x),
		local.y
	);
}


float cloud_noise(vec2 position) {
	float result = 0.0;
	float strength = 0.5;
	
	for (int i = 0; i < 4; i++) {
		result += noise(position) * strength;
		position *= 2.03;
		strength *= 0.5;
	}
	
	return result;
}


vec3 star_layer(vec2 uv, float scale, float seed) {
	vec2 grid = uv * scale;
	vec2 cell = floor(grid);
	vec2 local = fract(grid);
	
	float random_value = hash(cell + seed);
	float exists = step(1.0 - star_amount, random_value);
	
	vec2 star_position = 0.15 + hash2(cell + seed) * 0.7;
	float distance_to_star = distance(local, star_position);
	
	float size_random = hash(cell + seed + 17.0);
	float radius = mix(0.018, 0.075, size_random * size_random);
	
	float core = 1.0 - smoothstep(
		radius * 0.25,
		radius,
		distance_to_star
	);
	
	float glow = 1.0 - smoothstep(
		radius,
		radius * 3.5,
		distance_to_star
	);
	
	float colour_random = hash(cell + seed + 53.0);
	vec3 star_colour;
	
	if (colour_random < 0.25) {
		star_colour = star_colour_1.rgb;
	} else if (colour_random < 0.5) {
		star_colour = star_colour_2.rgb;
	} else if (colour_random < 0.75) {
		star_colour = star_colour_3.rgb;
	} else {
		star_colour = star_colour_4.rgb;
	}
	
	float brightness = mix(0.4, 1.0, size_random);
	float star = core + glow * 0.12;
	
	return star_colour * star * brightness * exists;
}


void fragment() {
	float aspect_ratio = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	
	vec2 uv = vec2(
		(UV.x - 0.5) * aspect_ratio,
		UV.y
	);
	
	uv += vec2(
		TIME * scroll_speed,
		TIME * scroll_speed * 0.25
	);
	
	// #0d2147 at the bottom, slightly darker at the top
	float gradient = mix(0.55, 1.0, UV.y);
	vec3 sky = background_colour.rgb * gradient;
	
	// Subtle cloudy depth using the background colour
	float clouds = cloud_noise(uv * 3.0 + vec2(12.0, 4.0));
	clouds = smoothstep(0.48, 0.82, clouds);
	sky += background_colour.rgb * clouds * cloud_strength;
	
	vec3 stars = vec3(0.0);
	stars += star_layer(uv, 24.0, 3.0);
	stars += star_layer(uv, 47.0, 19.0) * 0.65;
	stars += star_layer(uv, 83.0, 47.0) * 0.35;
	
	vec3 final_colour = sky + stars * star_brightness;
	
	COLOR = vec4(final_colour, 1.0);
}
shader_type canvas_item;

uniform float animation_speed : hint_range(0.0, 0.1) = 0.008;
uniform float swirl_strength : hint_range(0.0, 15.0) = 7.0;
uniform float swirl_scale : hint_range(0.5, 10.0) = 3.5;
uniform float nebula_strength : hint_range(0.0, 2.0) = 0.75;

uniform float star_amount : hint_range(0.0, 1.0) = 0.22;
uniform float star_brightness : hint_range(0.0, 3.0) = 1.15;

uniform vec2 swirl_centre = vec2(0.5, 0.5);

// #0d2147
uniform vec4 background_colour : source_color = vec4(
	0.05098, 0.12941, 0.27843, 1.0
);

// #ce79d2
uniform vec4 colour_1 : source_color = vec4(
	0.80784, 0.47451, 0.82353, 1.0
);

// #f4dfbe
uniform vec4 colour_2 : source_color = vec4(
	0.95686, 0.87451, 0.74510, 1.0
);

// #ff82bd
uniform vec4 colour_3 : source_color = vec4(
	1.0, 0.50980, 0.74118, 1.0
);

// #becbeb
uniform vec4 colour_4 : source_color = vec4(
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


float fbm(vec2 position) {
	float result = 0.0;
	float strength = 0.5;
	
	for (int i = 0; i < 5; i++) {
		result += noise(position) * strength;
		position = position * 2.03 + vec2(17.1, 9.2);
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
	float radius = mix(0.015, 0.065, size_random * size_random);
	
	float core = 1.0 - smoothstep(
		radius * 0.2,
		radius,
		distance_to_star
	);
	
	float glow = 1.0 - smoothstep(
		radius,
		radius * 3.0,
		distance_to_star
	);
	
	float colour_random = hash(cell + seed + 53.0);
	vec3 star_colour;
	
	if (colour_random < 0.25) {
		star_colour = colour_1.rgb;
	} else if (colour_random < 0.5) {
		star_colour = colour_2.rgb;
	} else if (colour_random < 0.75) {
		star_colour = colour_3.rgb;
	} else {
		star_colour = colour_4.rgb;
	}
	
	float brightness = mix(0.4, 1.0, size_random);
	float star = core + glow * 0.1;
	
	return star_colour * star * brightness * exists;
}


void fragment() {
	float aspect_ratio = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	
	vec2 position = UV - swirl_centre;
	position.x *= aspect_ratio;
	
	float radius = length(position);
	float angle = atan(position.y, position.x);
	
	// Twist space more strongly toward the centre
	float twisted_angle =
		angle
		+ radius * swirl_strength
		- TIME * animation_speed;
	
	vec2 swirl_uv = vec2(
		cos(twisted_angle),
		sin(twisted_angle)
	) * radius;
	
	// Warp the swirls to stop them looking geometrically perfect
	float warp_x = fbm(
		swirl_uv * swirl_scale + vec2(4.7, 1.3)
	);
	
	float warp_y = fbm(
		swirl_uv * swirl_scale + vec2(9.2, 7.6)
	);
	
	vec2 warped_uv = swirl_uv + vec2(
		warp_x - 0.5,
		warp_y - 0.5
	) * 0.35;
	
	float cloud_1 = fbm(
		warped_uv * swirl_scale + vec2(TIME * animation_speed, 2.0)
	);
	
	float cloud_2 = fbm(
		warped_uv * swirl_scale * 2.2 - vec2(7.0, TIME * animation_speed)
	);
	
	// Three broad spiral arms
	float arms = 0.5 + 0.5 * sin(
		twisted_angle * 3.0
		- radius * 10.0
		+ cloud_1 * 5.0
	);
	
	float filaments = smoothstep(
		0.38,
		0.78,
		cloud_1 * 0.65 + cloud_2 * 0.25 + arms * 0.3
	);
	
	float radial_fade = 1.0 - smoothstep(0.2, 1.1, radius);
	float nebula = filaments * radial_fade;
	
	// Original background, slightly darker toward the top
	float background_gradient = mix(0.55, 1.0, UV.y);
	vec3 sky = background_colour.rgb * background_gradient;
	
	// Blend the four palette colours through the nebula
	vec3 nebula_colour = mix(
		colour_1.rgb,
		colour_3.rgb,
		cloud_1
	);
	
	nebula_colour = mix(
		nebula_colour,
		colour_4.rgb,
		cloud_2 * 0.65
	);
	
	// Warm cream highlights in the densest parts
	nebula_colour = mix(
		nebula_colour,
		colour_2.rgb,
		pow(filaments, 4.0) * 0.55
	);
	
	sky += nebula_colour * nebula * nebula_strength;
	
	// Soft coloured haze behind the main filaments
	sky += colour_1.rgb
		* cloud_1
		* radial_fade
		* nebula_strength
		* 0.08;
	
	// Static stars above the nebula
	vec2 star_uv = vec2(
		(UV.x - 0.5) * aspect_ratio,
		UV.y
	);
	
	vec3 stars = vec3(0.0);
	stars += star_layer(star_uv, 30.0, 3.0);
	stars += star_layer(star_uv, 58.0, 19.0) * 0.6;
	stars += star_layer(star_uv, 95.0, 47.0) * 0.3;
	
	sky += stars * star_brightness;
	
	COLOR = vec4(sky, 1.0);
}
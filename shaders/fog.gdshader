shader_type spatial;

render_mode cull_disabled, unshaded;
uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform sampler2D screen_texture : source_color, hint_screen_texture, repeat_disable, filter_nearest;

uniform vec3 fog_color : source_color;

uniform float fog_distance_min : hint_range(0, 1) = 0.5;
uniform float fog_distance_max : hint_range(0, 1) = 0.5;

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	vec2 screen_coords = SCREEN_UV * 2.0 - 1.0;
	float depth = texture(depth_texture, SCREEN_UV).x;
	
	if (depth < fog_distance_min) {
		ALBEDO = fog_color;
	}
	else if (depth < fog_distance_max) {
		ALBEDO = mix(fog_color, screen_color, (depth - fog_distance_min) / (fog_distance_max - fog_distance_min));
	}
	else {
		ALBEDO = screen_color;
	}
}

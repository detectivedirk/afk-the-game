shader_type canvas_item;

uniform sampler2D bayer;
uniform float DitherStrength = 0.1;
uniform float ColorDepth = 3.0;
uniform float world_scale = 10;

varying vec2 world_position;

uniform sampler2D screen_texture: hint_screen_texture;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	vec2 ts = vec2(textureSize(bayer, 0));
	vec2 uv = mod(floor(world_position.xy * world_scale), ts) / ts;
	color += (texture(bayer, uv).r - 0.5) * DitherStrength;
	color = round(color * ColorDepth) / ColorDepth;
	COLOR = color;
}
shader_type spatial;
render_mode unshaded, blend_mul, cull_disabled, depth_test_disabled;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_nearest, repeat_disable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest, repeat_disable;


uniform bool is_inverted = false;
uniform float depth_multiplier = 1.5;
uniform float depth_addend = 0.0;
uniform float transparency = 0.75;
uniform vec4 outline_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float depth_pow = 5.;
uniform float line_width = 1.;


float get_linear_depth(vec2 screen_uv, mat4 inv_proj_matrix, float depth) {
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
	vec4 view = inv_proj_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	
	vec2 pixel_width = vec2(line_width/VIEWPORT_SIZE.x, 0.);
	vec2 pixel_height = vec2(0., line_width/VIEWPORT_SIZE.y);
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float depth_neighbor1 = texture(DEPTH_TEXTURE, SCREEN_UV + pixel_width).r;
	float depth_neighbor2 = texture(DEPTH_TEXTURE, SCREEN_UV - pixel_width).r;
	float depth_neighbor3 = texture(DEPTH_TEXTURE, SCREEN_UV + pixel_height).r;
	float depth_neighbor4 = texture(DEPTH_TEXTURE, SCREEN_UV - pixel_height).r;
	
	float linear_depth = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, depth);
	float linear_depth_neighbor1 = get_linear_depth(SCREEN_UV + pixel_width, INV_PROJECTION_MATRIX, depth_neighbor1);
	float linear_depth_neighbor2 = get_linear_depth(SCREEN_UV - pixel_width, INV_PROJECTION_MATRIX, depth_neighbor2);
	float linear_depth_neighbor3 = get_linear_depth(SCREEN_UV + pixel_height, INV_PROJECTION_MATRIX, depth_neighbor3);
	float linear_depth_neighbor4 = get_linear_depth(SCREEN_UV - pixel_height, INV_PROJECTION_MATRIX, depth_neighbor4);
	
	
	float xdiff = linear_depth * 2. - linear_depth_neighbor1 - linear_depth_neighbor2;
	float ydiff = linear_depth * 2. - linear_depth_neighbor3 - linear_depth_neighbor4;
	
	float diff = 0.0;
	if (is_inverted) {
		diff = -min(xdiff, ydiff);
	} else {
		diff = max(xdiff, ydiff);
	}
	
	float cascades = 2.;
	float line_strength = round(clamp(diff * depth_multiplier + depth_addend, 0., 1.) * cascades) / cascades * transparency;
	
	// Alternate method
	diff = max(max(linear_depth_neighbor1, linear_depth_neighbor2), max(linear_depth_neighbor3, linear_depth_neighbor4));
	linear_depth -= diff;
	line_strength = -linear_depth * pow(2., depth_pow);
	line_strength = -linear_depth * depth_multiplier;
	if (line_strength < 0.1) line_strength = 0.;
	//line_strength = clamp(line_strength, 0., 1.);
	line_strength = round(clamp(line_strength, 0., 1.) * cascades) / cascades;
	
	ALBEDO = mix(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, outline_color.rgb, line_strength * outline_color.a);
	
	//Use code this if blend mode is mul
	ALBEDO = mix(vec3(1.), vec3(0.), line_strength * outline_color.a);
	
	//ALBEDO = outline_color.rgb;
	//ALPHA = line_strength * outline_color.a;

}
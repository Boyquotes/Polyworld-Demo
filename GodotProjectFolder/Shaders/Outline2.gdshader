shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_test_disabled;

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
	vec4 view = inv_proj_matrix * vec4(screen_uv * 2. - 1., depth, 1.0);
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
	
	float linear_depth = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, depth); //center
	float linear_depth_neighbor1 = get_linear_depth(SCREEN_UV + pixel_width, INV_PROJECTION_MATRIX, depth_neighbor1); //right
	float linear_depth_neighbor2 = get_linear_depth(SCREEN_UV - pixel_width, INV_PROJECTION_MATRIX, depth_neighbor2); //left
	float linear_depth_neighbor3 = get_linear_depth(SCREEN_UV + pixel_height, INV_PROJECTION_MATRIX, depth_neighbor3); //below
	float linear_depth_neighbor4 = get_linear_depth(SCREEN_UV - pixel_height, INV_PROJECTION_MATRIX, depth_neighbor4); //above
	
	
	float xdiff = linear_depth * 2. - linear_depth_neighbor1 - linear_depth_neighbor2;
	float ydiff = linear_depth * 2. - linear_depth_neighbor3 - linear_depth_neighbor4;
	
	
	float abs_xdiff = abs(linear_depth-linear_depth_neighbor1) - abs(linear_depth-linear_depth_neighbor2);
	float abs_ydiff = abs(linear_depth-linear_depth_neighbor3) - abs(linear_depth-linear_depth_neighbor4);
	
	float diff = 0.0;
	if (is_inverted) {
		diff = -min(xdiff, ydiff);
	} else {
		diff = max(xdiff, ydiff);
	}

//	if (is_inverted) {
//		diff = -min(abs_xdiff, abs_xdiff);
//	} else {
//		diff = max(abs_xdiff, abs_xdiff);
//	}
	
	//diff = max(linear_depth-linear_depth_neighbor1, linear_depth-linear_depth_neighbor2);
	
	float cascades = 2.;
	float line_strength = round(clamp(diff * depth_multiplier + depth_addend, 0., 1.) * cascades) / cascades * transparency;
	
	// Alternate method
	//diff = max(max(linear_depth_neighbor1, linear_depth_neighbor2), max(linear_depth_neighbor3, linear_depth_neighbor4));
	//linear_depth -= diff;
	//line_strength = -linear_depth * pow(2., depth_pow);
	//line_strength = -linear_depth * depth_multiplier;
	//if (line_strength < 0.1) line_strength = 0.;
	//line_strength = clamp(line_strength, 0., 1.);
	line_strength = round(clamp(line_strength, 0., 1.) * cascades) / cascades;
	
	vec3 base_albedo = round(texture(SCREEN_TEXTURE, SCREEN_UV).rgb * 500.) / 500.;
	
	
	ALBEDO = mix(base_albedo, outline_color.rgb, line_strength * outline_color.a);
	
	//Use code this if blend mode is mul
	//ALBEDO = mix(vec3(1.), vec3(0.), line_strength * outline_color.a);
	
	//ALBEDO = outline_color.rgb;
	//ALPHA = line_strength * outline_color.a;

}
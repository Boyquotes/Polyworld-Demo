shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_test_disabled;

global uniform float outline_depth_multiplier;
global uniform float outline_transparency;
global uniform vec4 outline_color;

//palette shader
uniform sampler2D palette : hint_default_black; // Insert a palette from lospec for instance
uniform int palette_size = 16;


void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}


float get_linear_depth(vec2 screen_uv, mat4 inv_proj_matrix, float depth) {
	vec4 view = inv_proj_matrix * vec4(screen_uv * 2. - 1., depth, 1.0);
	view.xyz /= view.w;
	return -view.z;
}


void fragment() {
	
	// outline
	vec2 vp = VIEWPORT_SIZE;
	float depth = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV).r);
	float depth_neighbor1 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(1.0/vp.x,0)).r);
	float depth_neighbor2 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(1.0/vp.x,0)).r);
	float depth_neighbor3 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(0,1.0/vp.y)).r);
	float depth_neighbor4 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(0,1.0/vp.y)).r);
	
	float levels = 2.0;
	float diff = max(sqrt(depth)-sqrt(depth_neighbor1) + sqrt(depth)-sqrt(depth_neighbor2), sqrt(depth)-sqrt(depth_neighbor3) + sqrt(depth)-sqrt(depth_neighbor4));
	//float diff = max(depth-depth_neighbor1 + depth-depth_neighbor2, depth-depth_neighbor3 + depth-depth_neighbor4);
	float line_strength = round(clamp(diff * outline_depth_multiplier, 0.0, 1.0) * levels) / levels * outline_transparency;
	
	ALBEDO = mix(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, outline_color.rgb, clamp(line_strength, 0.,1.));
	
	
	//palette shader
//	vec4 new_color = vec4(.0);
//	for (int i = 0; i < palette_size; i++) {
//		vec4 palette_color = texture(palette, vec2(1.0 / float(palette_size) * float(i), .0));
//		if (distance(palette_color, vec4(ALBEDO,1.)) < distance(new_color, vec4(ALBEDO,1.))) {
//			new_color = palette_color;
//		}
//	}
//	ALBEDO = new_color.rgb;

}

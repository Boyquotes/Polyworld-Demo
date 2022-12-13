shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_test_disabled;

uniform bool is_inverted = false;
uniform float depth_multiplier = 0.3;
uniform float depth_addend = 0.0;
uniform float transparency = 0.9;
uniform vec4 outline_color : source_color;


//palette shader
uniform sampler2D palette : hint_default_black; // Insert a palette from lospec for instance
uniform int palette_size = 16;


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
	
	//textureLod()
	
	vec2 vp = VIEWPORT_SIZE;
	//vp = vec2(360.0, 270.0);
	float depth = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV).r);
	float depth_neighbor1 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(1.0/vp.x,0)).r);
	float depth_neighbor2 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(1.0/vp.x,0)).r);
	float depth_neighbor3 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(0,1.0/vp.y)).r);
	float depth_neighbor4 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(0,1.0/vp.y)).r);

	float diff = 0.0;
	if (is_inverted) {
		diff = -min(depth-depth_neighbor1 + depth-depth_neighbor2, depth-depth_neighbor3 + depth-depth_neighbor4);
	} else {
		diff = max(depth-depth_neighbor1 + depth-depth_neighbor2, depth-depth_neighbor3 + depth-depth_neighbor4);
	}

	float line_strength = round(clamp(diff * depth_multiplier + depth_addend, 0.0, 1.0) * 2.0) / 2.0 * transparency;
	
	ALBEDO = mix(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, outline_color.rgb, line_strength);
	//ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	//ALBEDO = texelFetch(SCREEN_TEXTURE, ivec2(round(SCREEN_UV * vp))-1, 0).rgb;
	
	//palette shader
	vec4 new_color = vec4(.0);
	
	for (int i = 0; i < palette_size; i++) {
		vec4 palette_color = texture(palette, vec2(1.0 / float(palette_size) * float(i), .0));
		if (distance(		palette_color, vec4(ALBEDO,1.)) < distance(new_color, vec4(ALBEDO,1.))) {
			new_color = palette_color;
		}
	}
	
	//ALBEDO = new_color.rgb;

}

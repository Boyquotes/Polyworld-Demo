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
	
	float diff_neighbor1 = linear_depth - linear_depth_neighbor1; // if negative, right pixel is more distant than center
	float diff_neighbor2 = linear_depth - linear_depth_neighbor2; // if negative, left pixel is more distant than center
	float diff_neighbor3 = linear_depth - linear_depth_neighbor3; // if negative, below pixel is more distant than center
	float diff_neighbor4 = linear_depth - linear_depth_neighbor4; // if negative, above pixel is more distant than center
	
	float xdiff = clamp(diff_neighbor1 + diff_neighbor2, 0., 1.);
	float ydiff = clamp(diff_neighbor3 + diff_neighbor4, 0., 1.);
	
//	if (xdiff > 0.) {
//		float depth_neighbor_extra = texture(DEPTH_TEXTURE, SCREEN_UV + pixel_width * 2.).r;
//		float linear_depth_neighbor_extra = get_linear_depth(SCREEN_UV + pixel_width * 2., INV_PROJECTION_MATRIX, depth_neighbor_extra);
//		float diff_neighbor_extra = linear_depth_neighbor1 - linear_depth_neighbor_extra;
//		float xdiff_extra = linear_depth_neighbor1 - linear_depth + diff_neighbor_extra;
//		if (xdiff_extra > 0. && diff_neighbor_extra >= 0.) {
//			xdiff = 0.;
//		}
//	} 
//	if (ydiff > 0.) {
//		float depth_neighbor_extra = texture(DEPTH_TEXTURE, SCREEN_UV + pixel_height * 2.).r;
//		float linear_depth_neighbor_extra = get_linear_depth(SCREEN_UV + pixel_height * 2., INV_PROJECTION_MATRIX, depth_neighbor_extra);
//		float diff_neighbor_extra = linear_depth_neighbor3 - linear_depth_neighbor_extra;
//		float ydiff_extra = linear_depth_neighbor3 - linear_depth + diff_neighbor_extra;
//		if (ydiff_extra > 0. && diff_neighbor_extra >= 0.) {
//			ydiff = 0.;
//		}
//	}
	
	float diff = max(xdiff, ydiff);
	
	float cascades = 3.;
	float line_strength = floor(clamp(diff * depth_multiplier, 0., 1.) * cascades) / cascades * transparency;
	
	vec3 base_albedo = round(texture(SCREEN_TEXTURE, SCREEN_UV).rgb * 50.) / 50.;
	
	//Use if blend mode is mix
	//ALBEDO = mix(base_albedo, outline_color.rgb, line_strength * outline_color.a);
	
	//Use if blend mode is mul
	ALBEDO = mix(vec3(1.), vec3(0.), line_strength * outline_color.a);
	
//	if (xdiff > 0.0) {
//		ALBEDO = vec3(0.,0.,1.);
//	}
	
//	if (diff_neighbor3 > 0.0 && diff_neighbor4 > 0.0) {
//		ALBEDO = vec3(1.,0.,1.);
//	}
	
//		if (((diff_neighbor1 > 0.0 && diff_neighbor2 < 0.0) ||
//			(diff_neighbor1 < 0.0 && diff_neighbor2 > 0.0)) &&
//			(!(diff_neighbor3 > 0.0 && diff_neighbor4 < 0.0) ||
//			!(diff_neighbor3 < 0.0 && diff_neighbor4 > 0.0))){
//			ALBEDO = vec3(1.,1.,1.);
//		}
//
//		if (!((diff_neighbor1 > 0.0 && diff_neighbor2 < 0.0) ||
//			!(diff_neighbor1 < 0.0 && diff_neighbor2 > 0.0)) &&
//			((diff_neighbor3 > 0.0 && diff_neighbor4 < 0.0) ||
//			(diff_neighbor3 < 0.0 && diff_neighbor4 > 0.0))){
//			ALBEDO = vec3(1.,1.,1.);
//		}


}
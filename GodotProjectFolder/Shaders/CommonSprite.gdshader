shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, unshaded, specular_disabled, vertex_lighting;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_disable;
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

global uniform float outline_depth_multiplier;
global uniform float outline_transparency;
global uniform vec4 outline_color;

varying vec4 depth_pos;


void vertex() {
	
	// Store depth before billboard transformation
	mat4 upright = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], MODEL_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	depth_pos = PROJECTION_MATRIX * (upright * vec4(VERTEX, 1.0));
	
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	//MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	
	// Perspective scale clamping (to reduce distortion from upscaling)
	float s = -(MODELVIEW_MATRIX)[3].z / PROJECTION_MATRIX[0][0];
	float w = (VIEWPORT_SIZE.x / 2.) * 0.05;//half the viewport width * max size (sprite pixel size)
	float max_size_thresh = 0.;
	float min_size_thresh = 0.;
	if (s < w - min_size_thresh) {
		float scale = s / (w - min_size_thresh);
		MODELVIEW_MATRIX[0] *= scale;
		MODELVIEW_MATRIX[1] *= scale;
		MODELVIEW_MATRIX[2] *= scale;
	} if (s > w + max_size_thresh) {
		float scale = s / (w + max_size_thresh);
		MODELVIEW_MATRIX[0] *= scale;
		MODELVIEW_MATRIX[1] *= scale;
		MODELVIEW_MATRIX[2] *= scale;
	}

}


float get_linear_depth(vec2 screen_uv, mat4 inv_proj_matrix, float depth) {
	vec4 view = inv_proj_matrix * vec4(screen_uv * 2. - 1., depth, 1.0);
	view.xyz /= view.w;
	return -view.z;
}


void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	NORMAL = -CAMERA_DIRECTION_WORLD;
	ALPHA = albedo.a * albedo_tex.a;
	if (ALPHA != 1.) {
		discard;
	}
	
	//outline
//	vec2 vp = VIEWPORT_SIZE;
//	float depth = -VERTEX.z;
//
//	float depth_neighbor1 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(1.0/vp.x,0)).r);
//	float depth_neighbor2 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(1.0/vp.x,0)).r);
//	float depth_neighbor3 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(0,1.0/vp.y)).r);
//	float depth_neighbor4 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(0,1.0/vp.y)).r);
//
//	// Depth neighbors can't be further away than the sprite itself
//	depth_neighbor1 = min(depth, depth_neighbor1);
//	depth_neighbor2 = min(depth, depth_neighbor2);
//	depth_neighbor3 = min(depth, depth_neighbor3);
//	depth_neighbor4 = min(depth, depth_neighbor4);
//
//	float levels = 2.0;
//	float diff = max(sqrt(depth)-sqrt(depth_neighbor1) + sqrt(depth)-sqrt(depth_neighbor2), sqrt(depth)-sqrt(depth_neighbor3) + sqrt(depth)-sqrt(depth_neighbor4));
//	//float diff = max(depth-depth_neighbor1 + depth-depth_neighbor2, depth-depth_neighbor3 + depth-depth_neighbor4);
//	float line_strength = round(clamp(diff * outline_depth_multiplier, 0.0, 1.0) * levels) / levels * outline_transparency;
//
//	ALBEDO = mix(ALBEDO, outline_color.rgb, clamp(line_strength, 0.,1.));
	
	// THIS DOESNT WORK ?!
//	float A = PROJECTION_MATRIX[2].z;
//    float B = PROJECTION_MATRIX[3].z;
//	float depth_thresh = 0.0;
//	float depth = depth_pos.z - depth_thresh;
//	DEPTH = (-A * depth + B) / depth;
	
}



// NOTE: Shader automatically converted from Godot Engine 4.0.beta7's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,unshaded;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_disable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_nearest,repeat_disable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest,repeat_disable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


varying float z_dist;

void vertex() {
	POINT_SIZE=point_size;
	
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	
	// Perspective scale clamping (to reduce distortion from upscaling)
	float s = -(MODELVIEW_MATRIX)[3].z / PROJECTION_MATRIX[0][0];
	float w = (VIEWPORT_SIZE.x / 2.) * 0.05;//half the viewport width * max size (sprite pixel size)
	float max_size_thresh = 8.;
	float min_size_thresh = 3.;
	if (s < w - min_size_thresh) {
		float scale = s / (w - min_size_thresh);
		POINT_SIZE = point_size / scale;
	} if (s > w + max_size_thresh) {
		float scale = s / (w + max_size_thresh);
		POINT_SIZE = point_size / scale;
	}
	
	z_dist = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).z * -1.0;

}


float get_linear_depth(vec2 screen_uv, mat4 inv_proj_matrix, float depth) {
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
	vec4 view = inv_proj_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}



void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,POINT_COORD);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	ALPHA *= albedo.a * albedo_tex.a;
	if (ALPHA != 1.) {
		discard;
	}
	
	//outline
	vec2 vp = VIEWPORT_SIZE;
	
	float depth_thresh = 1.5;
	float depth = z_dist/2. + depth_thresh;
	
	//depth = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV).r);
	float depth_neighbor1 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(1.0/vp.x,0)).r);
	float depth_neighbor2 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(1.0/vp.x,0)).r);
	float depth_neighbor3 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(0,1.0/vp.y)).r);
	float depth_neighbor4 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(0,1.0/vp.y)).r);
	
	if (depth_neighbor1 > depth) {
		depth_neighbor1 = depth;
	}if (depth_neighbor2 > depth) {
		depth_neighbor2 = depth;
	}if (depth_neighbor3 > depth) {
		depth_neighbor3 = depth;
	}if (depth_neighbor4 > depth) {
		depth_neighbor4 = depth;
	}
	
	float diff = max(sqrt(depth)-sqrt(depth_neighbor1) + sqrt(depth)-sqrt(depth_neighbor2), sqrt(depth)-sqrt(depth_neighbor3) + sqrt(depth)-sqrt(depth_neighbor4));
	
	float line_strength = round(clamp(diff * 16., 0.0, 1.0) * 2.0);
	ALBEDO = mix(ALBEDO, vec3(0.), clamp(line_strength, 0.,1.));
	
}



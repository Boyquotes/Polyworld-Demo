shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, vertex_lighting;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_disable;
uniform float point_size : hint_range(0,128);
uniform float specular;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	POINT_SIZE=point_size;
	
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//VERTEX.y += sin(TIME * 2. + world_position.x * 2.) * 0.02;
	VERTEX.z += sin(TIME * 2. + world_position.x * 2.) * 0.02;
	
	// Perspective scale clamping (to reduce distortion from upscaling)
	float s = -(MODELVIEW_MATRIX)[3].z / PROJECTION_MATRIX[0][0];
	float w = (VIEWPORT_SIZE.x / 2.) * 0.05;//half the viewport width * max size (sprite pixel size)
	float max_size_thresh = 5.;
	float min_size_thresh = 2.;
	if (s < w - min_size_thresh) {
		float scale = s / (w - min_size_thresh);
		POINT_SIZE = point_size / scale;
	} if (s > w + max_size_thresh) {
		float scale = s / (w + max_size_thresh);
		POINT_SIZE = point_size / scale;
	}
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,POINT_COORD);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	SPECULAR = specular;
	ALPHA *= albedo.a * albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
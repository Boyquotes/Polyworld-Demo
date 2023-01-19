shader_type spatial;
render_mode cull_back, shadows_disabled, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform sampler2D texture_albedo2 : source_color, filter_nearest;

global uniform float outline_depth_multiplier;
global uniform float outline_transparency;
global uniform vec4 outline_color;

varying float z_dist;


void vertex() {
	z_dist = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).z * -1.0;
}


float get_linear_depth(vec2 screen_uv, mat4 inv_proj_matrix, float depth) {
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
	vec4 view = inv_proj_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}


void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = round(texture(texture_albedo, UV + vec2(TIME * 0.01) + texture(texture_albedo2, UV - vec2(TIME * 0.005)).r).r * 10.) / 10.;
	
	ALPHA *= (1. - distance(UV, vec2(0.5)) * 2.) * 2.;
	ALPHA = clamp(ALPHA, 0., 1.);
	
	//outline
	vec2 vp = VIEWPORT_SIZE;
	float depth = -VERTEX.z;
	
	float depth_neighbor1 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(1.0/vp.x,0)).r);
	float depth_neighbor2 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(1.0/vp.x,0)).r);
	float depth_neighbor3 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV + vec2(0,1.0/vp.y)).r);
	float depth_neighbor4 = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX, texture(DEPTH_TEXTURE, SCREEN_UV - vec2(0,1.0/vp.y)).r);
	
	// Depth neighbors can't be further away than the sprite itself
	depth_neighbor1 = min(depth, depth_neighbor1);
	depth_neighbor2 = min(depth, depth_neighbor2);
	depth_neighbor3 = min(depth, depth_neighbor3);
	depth_neighbor4 = min(depth, depth_neighbor4);
	
	float levels = 2.0;
	float diff = max(sqrt(depth)-sqrt(depth_neighbor1) + sqrt(depth)-sqrt(depth_neighbor2), sqrt(depth)-sqrt(depth_neighbor3) + sqrt(depth)-sqrt(depth_neighbor4));
	//float diff = max(depth-depth_neighbor1 + depth-depth_neighbor2, depth-depth_neighbor3 + depth-depth_neighbor4);
	float line_strength = round(clamp(diff * outline_depth_multiplier, 0.0, 1.0) * levels) / levels * outline_transparency;
	
	ALBEDO = mix(ALBEDO, outline_color.rgb, clamp(line_strength, 0.,1.));
	//ALBEDO = vec3(depth / 200.);
	
}

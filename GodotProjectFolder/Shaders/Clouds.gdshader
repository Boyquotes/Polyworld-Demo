shader_type spatial;
render_mode cull_back, shadows_disabled, unshaded;


uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform sampler2D texture_albedo2 : source_color, filter_nearest;


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
	//ALPHA = texture(texture_albedo, UV + vec2(TIME * 0.025)).r * texture(texture_albedo2, UV + vec2(TIME * 0.01)).r;
	ALPHA = round(texture(texture_albedo, UV + vec2(TIME * 0.01) + texture(texture_albedo2, UV - vec2(TIME * 0.005)).r).r * 10.) / 10.;
	
	//ALPHA *= 1./(distance(UV, vec2(0.5)) * 3.);
	ALPHA *= (1. - distance(UV, vec2(0.5)) * 2.) * 2.;
	ALPHA = clamp(ALPHA, 0., 1.);
	
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

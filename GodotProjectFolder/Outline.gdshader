shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_test_disabled;

uniform bool is_inverted = false;
uniform float depth_multiplier = 0.3;
uniform float depth_addend = 0.0;
uniform float transparency = 0.9;
uniform vec4 outline_color : source_color;


//palette shader
uniform float size_x = 0.006;
uniform float size_y = 0.006;

const float valuesPerComponent = 32.0;
const float maxComponentValue = valuesPerComponent - 1.0;
const float invMaxComponentValue = 1.0 / maxComponentValue;

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
	vec2 uv = SCREEN_UV;
    uv -= mod(uv, vec2(size_x, size_y));
    ALBEDO.rgb = invMaxComponentValue * round(maxComponentValue * ALBEDO.rgb);

}


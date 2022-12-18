shader_type spatial;
render_mode cull_disabled, shadows_disabled, unshaded;


uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform sampler2D texture_albedo2 : source_color, filter_nearest;


void fragment() {
	ALBEDO = albedo.rgb;
	//ALPHA = texture(texture_albedo, UV + vec2(TIME * 0.025)).r * texture(texture_albedo2, UV + vec2(TIME * 0.01)).r;
	ALPHA = round(texture(texture_albedo, UV + vec2(TIME * 0.01) + texture(texture_albedo2, UV - vec2(TIME * 0.005)).r).r * 10.) / 10.;
	
	//ALPHA *= 1./(distance(UV, vec2(0.5)) * 3.);
	ALPHA *= (1. - distance(UV, vec2(0.5)) * 2.) * 2.;
	ALPHA = clamp(ALPHA, 0., 1.);
	
}

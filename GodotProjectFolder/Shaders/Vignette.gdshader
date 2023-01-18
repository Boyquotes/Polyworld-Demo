shader_type canvas_item;

uniform vec4 color : source_color;
uniform float scale = 0.0;
uniform bool border = false;

void fragment() {
	float value = distance(UV, vec2(0.5));
	COLOR = vec4(color.rgb, smoothstep(scale, scale+0.000001, value));
	if (border) {
		if (UV.x > 0.75 || UV.x < 0.25) {
			COLOR = vec4(0.,0.,0.,1.);
		} if (UV.y > 0.666 || UV.y < 0.333) {
			COLOR = vec4(0.,0.,0.,1.);
		}
	}
}

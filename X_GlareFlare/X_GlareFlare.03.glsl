#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Matte;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 matte = texture2D(Matte, st).rgb;

	gl_FragColor = vec4(matte, matte.r);
}

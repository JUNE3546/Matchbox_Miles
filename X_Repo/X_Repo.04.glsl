#version 120

#define INPUT Front2
#define MATTE Matte2
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT, MATTE;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(INPUT, st).rgb;
	float matte = texture2D(MATTE, st).r;

	gl_FragColor = vec4(front, matte);
}

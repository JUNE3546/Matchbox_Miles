//Idea from here: http://www.catalinzima.com/2008/01/converting-displacement-maps-into-normal-maps/

#version 120

#define INPUT Front
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform	float normalStrength;
uniform	float width;
uniform float sobel_width;
uniform int times;
uniform bool keep_between_0_and_1;

vec3 calcNormal(in vec3 p)
{
    vec2 e = vec2(0.0001, 0.0);
    return normalize(vec3(
                        vec3(p+e.xyy) - vec3(p-e.xyy),
                        vec3(p+e.yxy) - vec3(p-e.yxy),
                        vec3(p+e.yyx) - vec3(p-e.yyx)
                    ));
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec4 col = texture2D(INPUT, st);

	vec2 texelSize = 1.0 / res * .1;

	vec4 N = vec4(0.0);
	vec2 Q = vec2(0.0);

	float edge;

	for (int i = 1; i <= times; i++) {
 
    	float tl = abs(tex (INPUT, st + texelSize * vec2(-i, -i)).x);
    	float  l = abs(tex (INPUT, st + texelSize * vec2(-i,  0)).x);
    	float bl = abs(tex (INPUT, st + texelSize * vec2(-i,  i)).x);
    	float  t = abs(tex (INPUT, st + texelSize * vec2( 0, -i)).x);
    	float  b = abs(tex (INPUT, st + texelSize * vec2( 0,  i)).x);
    	float tr = abs(tex (INPUT, st + texelSize * vec2( i, -i)).x);
    	float  r = abs(tex (INPUT, st + texelSize * vec2( i,  0)).x);
    	float br = abs(tex (INPUT, st + texelSize * vec2( i,  i)).x);
 
    	float dX = tr + sobel_width*r + br -tl - sobel_width*l - bl;
    	float dY = bl + sobel_width*b + br -tl - sobel_width*t - tr;

		//edge = .5 * sqrt(dX * dX + dY * dY);

 
    	// Build the normalized normal
    	//N += vec4(normalize(vec3(dX, 1.0f / normalStrength, dY)), 1.0f);
		N = calcNormal(vec3(dX, 0.0, dY));
	}

	N /= times;

    //convert (-1.0 , 1.0) to (0.0 , 1.0)
    //N =  N * 0.5 + 0.5;

	/*
	float g = N.g;
	N.g = N.b;
	N.b = g;

	N.g = 1.0 - N.g;
	N.r = 1.0 - N.r;

	if (! keep_between_0_and_1) {
    	N =  (N - 0.5) * 2.0;
	}
	*/

	gl_FragColor = N;
	//gl_FragColor = vec4(edge);
}

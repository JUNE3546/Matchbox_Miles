#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);


uniform vec3 translation_amount;

uniform float persp_amnt;
uniform vec3 rotation_amount;
float x_rotation = rotation_amount.x;
float y_rotation = rotation_amount.y;
float z_rotation = rotation_amount.z;

uniform vec2 perspective_position;
float x_persp_pos = perspective_position.x;
float y_persp_pos = perspective_position.y;

uniform vec3 scale_amount;

uniform vec3 shear_amount;

uniform vec3 angle3D;

uniform float near;

uniform sampler2D Front;
vec2 center = vec2(.5);

bool isInTex( const vec2 coords )
{
	return coords.x >= 0.0 && coords.x <= 1.0 &&
			coords.y >= 0.0 && coords.y <= 1.0;
}


mat3 rotate3D(float angle, vec3 axis3D)
{
	// Need to figure out how to make this rotate around center of texture not camera
	// Once figured out get rid of the rotate_* functions below

	vec3 nv1 = axis3D;
	float x = normalize(nv1.x);
	float y = normalize(nv1.y);
	float z = normalize(nv1.z);

	float c = cos(angle);
	float nc = 1.0 - c;
	float s = sin(angle);
	float ns = 1.0 - s;

	mat3 rotation_matrix = mat3(
								x * x * nc + c, 		y * x * nc - z * s, 	z * x * nc + y * s,
								x * y * nc + z * s, 	y * y * nc + c, 		z * y * nc - x * s,
								x * z * nc - y * s, 	y * z * nc + x * s, 	z * z * nc + c
								);

	return rotation_matrix;
}

mat3 shear(vec3 shear_amount)
{
	mat3 shear_matrix = mat3(
                        	1.0, 				-shear_amount.x, 	0.0,
                        	-shear_amount.y, 	1.0, 				0.0,
							0.0,				-shear_amount.z,	1.0
                    	);

	return shear_matrix;
}

mat3 scale(vec3 scale_amount)
{
	mat3 scale_matrix = mat3(
							abs(1.0 - scale_amount.x), 	0.0, 						0.0,
							0.0,						abs(1.0 - scale_amount.y), 	0.0,
							0.0,						0.0,						1.0 + scale_amount.z
							);

	return scale_matrix;
}

mat3 rotate_z(float rotation_amount)
{
	mat3 rotation_matrix = mat3(
								cos(-rotation_amount), -sin(-rotation_amount), 	0.0,
								sin(-rotation_amount), cos(-rotation_amount), 	0.0,
								0.0,			0.0,		  					1.0
								);

	return rotation_matrix;
}

mat3 rotate_y(float rotation_amount)
{
	mat3 rotation_matrix = mat3(
               		1.0 + abs(rotation_amount * persp_amnt) * 2.0, 	0.0, x_persp_pos,
               		0.0,											1.0, 0.0,
               		rotation_amount,    							0.0, 1.0
                	);

	return rotation_matrix;
}

mat3 rotate_x(float rotation_amount)
{
	mat3 rotation_matrix = mat3(
                	1.0, 0.0, 											0.0,
                	0.0, 1.0 + abs(rotation_amount * persp_amnt) * 2.0, 	y_persp_pos,
                	0.0, rotation_amount,       							1.0 
                	);

	return rotation_matrix;
}

mat3 translate(vec3 translation_amount)
{
	mat3 translation_matrix = mat3(
									1.0, 0.0, -translation_amount.x,
									0.0, 1.0, -translation_amount.y,
									0.0, 0.0, 1.0 + translation_amount.z
								);

	return translation_matrix;
}

vec2 apply_transformations(vec2 coords, vec2 center, mat3 transformation_matrix)
{
	coords -= center;
   	coords.x *= adsk_result_frameratio;

	vec3 tmp_vec = vec3(coords, 1.0);
   	tmp_vec *= transformation_matrix;

    coords.x = tmp_vec.x / tmp_vec.z;
    coords.y = tmp_vec.y / tmp_vec.z;

   	coords.x /= adsk_result_frameratio;
   	coords += center;

	return coords;
}

void main(void)
{
    vec2 st = gl_FragCoord.xy / res;
	vec3 front = vec3(0.0);

	// Default postion
	mat3 t_matrix = mat3(
						1.0, 0.0, 0.0,
						0.0, 1.0, 0.0,
						0.0, 0.0, 1.0
						);


	t_matrix *= translate(translation_amount);

	t_matrix *= rotate3D(angle3D.x, vec3(1.0, 0.0, 0.0));
	t_matrix *= rotate3D(angle3D.y, vec3(0.0, 1.0, 0.0));
	t_matrix *= rotate3D(angle3D.z, vec3(0.0, 0.0, 1.0));

	t_matrix *= scale(scale_amount);
	t_matrix *= rotate_x(x_rotation);
	t_matrix *= rotate_y(y_rotation);
	t_matrix *= rotate_z(z_rotation);
	t_matrix *= shear(shear_amount);

	st = apply_transformations(st, center, t_matrix);

	if (isInTex(st)) {
    	front = texture2D(Front, st).rgb;
	}

    gl_FragColor = vec4(front, 0.0);
}

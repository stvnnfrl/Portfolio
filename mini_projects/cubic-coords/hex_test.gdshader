shader_type canvas_item;

const vec3 down_cubic = vec3(1.0, 1.0, -2.0)/3.0;
const vec3 right_cubic = vec3(1.0, -1.0, 0.0)/sqrt(3.0);

const vec3 RIGHT = vec3(1.0, -1.0, 0.0);
const vec3 DOWNRIGHT = vec3(1.0, 0.0 ,-1.0);
const vec3 DOWNLEFT = vec3(0.0, 1.0, -1.0);

const mat3 foo = mat3(RIGHT, -DOWNLEFT, -DOWNRIGHT);

uniform float size;
instance uniform vec2 mouse_pos;

vec3 cube_round(vec3 cube) {
	vec3 naive = round(cube);
	vec3 diff = abs(naive - cube);
	if (diff.x > diff.y && diff.x > diff.z) {
		return vec3(-naive.y-naive.z, naive.y, naive.z);
	} else if (diff.y > diff.z) {
		return vec3(naive.x, -naive.x-naive.z, naive.z);
	} else {
		return vec3(naive.x, naive.y, -naive.x-naive.y);
	}
}
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 pos = UV/TEXTURE_PIXEL_SIZE - mouse_pos;
	vec3 cubic_pos = (pos.x * right_cubic + pos.y * down_cubic)/size;
	COLOR = vec4(mod(cubic_pos - mod(cubic_pos, 1.0), 10.0)/10.0, 1.0);
	mat3 bar = transpose(foo);
	vec3 abs_cubic = abs(bar*cubic_pos);
	//COLOR = vec4(mod(round((bar*cubic_pos)/2.0 - vec3(TIME, TIME, TIME)), 6.0)/1.0, 1.0);
	COLOR = vec4(mod(cube_round((cubic_pos)/* - vec3(TIME, TIME, TIME)*/), 6.0)/6.0, 1.0);
	//if ((dot(vec3(1.0,1.0,1.0), abs_cubic)/2.0) <= 1.0) {
		//COLOR = vec4(0.0,0.0,0.0,1.0);
	//}
	
	//if (max(max(abs_cubic.x, abs_cubic.y), abs_cubic.z) <= 1.0) {
		//COLOR = vec4(0.0,0.0,0.0,1.0);
	//}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

instance uniform float size;
instance uniform float border_frac;
instance uniform vec2 rect_size;

const vec3 down_cubic = vec3(1.0, 1.0, -2.0)/3.0;
const vec3 right_cubic = vec3(1.0, -1.0, 0.0)/sqrt(3.0);

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

void fragment() {
	vec2 pos = UV*rect_size;
	vec3 cubic_pos = (pos.x * right_cubic + pos.y * down_cubic)/size;
	vec3 diff = (cubic_pos - cube_round(cubic_pos));
	diff = abs(diff - diff.yzx);
	if (!(max(diff.x, max(diff.y, diff.z)) > border_frac)) {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

instance uniform float size;
instance uniform float border_frac;
instance uniform vec2 rect_size;
instance uniform vec4 limit_rect;

const vec3 down_cubic = vec3(1.0, 1.0, -2.0)/3.0;
const vec3 right_cubic = vec3(1.0, -1.0, 0.0)/sqrt(3.0);

const vec3 RIGHT = vec3(1.0, -1.0, 0.0);
const vec3 DOWNRIGHT = vec3(1.0, 0.0 ,-1.0);
const vec3 DOWNLEFT = vec3(0.0, 1.0, -1.0);



bool in_rect(vec4 rect, vec2 pos) {
	return pos.x >= rect.x && pos.y >= rect.y && pos.x <= rect.x + rect.z && pos.y <= rect.y + rect.w;
}

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

vec2 cubic_to_2d(vec3 cubic) {
	return vec2((cubic.x-cubic.y)*sqrt(3.0)/2.0, cubic.z*-1.5)*size;
}

void fragment() {
	vec2 pos = UV*rect_size;
	vec3 cubic_pos = (pos.x * right_cubic + pos.y * down_cubic)/size;
	vec3 cubic_cell = cube_round(cubic_pos);
	vec3 diff = (cubic_pos - cubic_cell);
	diff = abs(diff - diff.yzx);
	if (!(max(diff.x, max(diff.y, diff.z)) > border_frac)
	&& in_rect(limit_rect, cubic_to_2d(cubic_cell))) {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

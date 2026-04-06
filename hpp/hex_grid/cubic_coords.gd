class_name CubicCoords extends Resource

@export var size: float = 10.0

const down_cubic = Vector3(1, 1, -2)/3
const right_cubic = RIGHT/sqrt(3)

const RIGHT = Vector3(1, -1, 0)
const DOWNRIGHT = Vector3(1, 0 ,-1)
const DOWNLEFT = Vector3(0, 1, -1)
const LEFT = -RIGHT
const UPLEFT = -DOWNRIGHT
const UPRIGHT = -DOWNLEFT
const CUBIC_DIRECTIONS = [RIGHT, DOWNRIGHT, DOWNLEFT, LEFT, UPLEFT, UPRIGHT]

const x_2d = Vector2(sqrt(3)/2, 0.5)
const y_2d = Vector2(-sqrt(3)/2, 0.5)
const z_2d = Vector2(0, -1)

func pos2D_to_cubic(pos: Vector2) -> Vector3:
	return (pos.x * right_cubic + pos.y * down_cubic)/size
func cubic_to_pos2D(pos: Vector3) -> Vector2:
	return size * (x_2d * pos.x + y_2d * pos.y + z_2d * pos.z)
func cubic_round(pos: Vector3) -> Vector3:
	# credit to redblobgames.com/grids/hexagons
	var rounded = round(pos)
	var diff = abs(rounded - pos)
	if (diff.x > diff.y && diff.x > diff.z):
		rounded.x = -rounded.y-rounded.z
	elif (diff.y > diff.z):
		rounded.y = -rounded.x-rounded.z
	else:
		rounded.z = -rounded.x-rounded.y
	return rounded

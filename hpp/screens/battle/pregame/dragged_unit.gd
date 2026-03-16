extends Sprite2D

var units: Array[Variant]

@export var unset_unit_texture: Texture2D
@export var size: Vector2 = Vector2(100, 100)

# resize the sprite to get a consistent size
# if a unit ever requires a bigger preview,
# we can add scale multipliers to the unit
var base_scale: Vector2 = Vector2.ONE

func init(units_: Array[Dictionary]) -> void:
	units = units_
	unset_unit()

func _on_unit_selector_selected_unit_changed(index: int) -> void:
	set_unit_to(index)

func unset_unit() -> void:
	set_unit_to(-1)

func set_unit_to(index: int) -> void:
	if index < 0:
		texture = unset_unit_texture
	else:
		var unit = units[index]
		texture = unit.texture
	
	base_scale = size / texture.get_size()


# drag animation

@export var massInverse: float = 150.
@export var springConstant: float = 0.7

# target length at rest
@export var targetDistance: float = 100.

# percentage of velocity left after a dampingInterval
@export var dampingFactor: float = 0.997

# how often in seconds velocity is multiplied by dampingFactor
@export var dampingInterval: float = 1.0

var bottom_position = position  # like a mass at the end of the spring that is the the texture
var velocity = Vector2.ZERO
const PI_OVER_TWO = PI/2
func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var difference = mouse_position - bottom_position
	
	# set gravity so that texture hits target distance at rest
	# so we need an equilibrium at a difference of targetDistance
	#   gravityStrength - springConstant*targetDistance = 0
	#   gravityStrength = springConstant*targetDistance
	var gravityForce = Vector2(0, springConstant * targetDistance)
	var springForce = springConstant * difference
	var force = springForce + gravityForce
	
	var acceleration = force * massInverse
	
	velocity *= pow(dampingFactor, dampingInterval / delta)
	velocity += acceleration * delta
	
	bottom_position += velocity * delta
	
	# position
	position = (mouse_position + bottom_position) / 2
	
	# scale
	var distance = difference.length()
	var scaleFactor = distance / targetDistance
	
	# clamp to prevent too much stretching
	scale = base_scale * Vector2(
		clampf(1 / scaleFactor, .5, 1.5),
		clampf(scaleFactor, .5, 1.5))

	# rotate and skew
	var angle = mouse_position.angle_to_point(bottom_position) - PI_OVER_TWO
	rotation = angle / 2
	skew = angle / 2

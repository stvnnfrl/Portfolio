extends Sprite2D

@export var massInverse: float
@export var springConstant: float

# target length at rest
@export var targetDistance: float

# percentage of velocity left after a dampingInterval
@export var dampingFactor: float

# how often in seconds velocity is multiplied by dampingFactor
@export var dampingInterval: float

const PI_OVER_TWO = PI/2

@onready var curr = global_position
@onready var velocity = Vector2.ZERO

func _process(delta: float) -> void:
	position = get_viewport().get_mouse_position()

	var difference = position - curr

	# set so that texture hits target distance at rest
	# so we need an equilibrium at a difference of targetDistance
	#   gravityStrength - springConstant*targetDistance = 0
	#   gravityStrength = springConstant*targetDistance
	var gravityForce = Vector2(0, springConstant * targetDistance)
	var springForce = springConstant * difference
	var force = springForce + gravityForce

	var acceleration = force * massInverse

	velocity *= pow(dampingFactor, dampingInterval/delta)
	velocity += acceleration * delta

	curr += velocity * delta
	curr.y = min(curr.y, 648)

	# position
	$"Target".global_position = curr
	$"Dragged".global_position = (position + curr)/2

	# scale
	var distance = (position - curr).length()
	var scaleFactor = distance/targetDistance
	$"Dragged".scale = Vector2(
		clampf(1/scaleFactor, .5, 1.5),
		clampf(scaleFactor, .5, 1.5))

	# rotate and skew
	var angle = get_angle_to(curr) - PI_OVER_TWO
	$"Dragged".rotation = angle/2
	$"Dragged".skew = angle/2

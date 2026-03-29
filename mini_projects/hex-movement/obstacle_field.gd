extends Node2D
@export var obstacle_scene: PackedScene
@export var cubic: CubicCoords

var obstacles: Dictionary[Vector3i, Node2D] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("m2"):
		var pos = get_viewport().get_mouse_position()
		var cubic_pos = cubic.pos2D_to_cubic(pos)
		cubic_pos = Vector3i(cubic.cubic_round(cubic_pos))
		if obstacles.has(cubic_pos):
			var obstacle = obstacles[cubic_pos]
			obstacles.erase(cubic_pos)
			obstacle.queue_free()
		else:
			var obstacle = obstacle_scene.instantiate()
			obstacles[cubic_pos] = obstacle
			obstacle.position = cubic.cubic_to_pos2D(cubic_pos)
			add_child(obstacle)
	
	pass

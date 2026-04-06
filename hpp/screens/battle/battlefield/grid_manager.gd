extends Node2D
class_name GridManager

@export var cubic : CubicCoords
@export var border_frac : float = 0.93

@onready var grid_visuals : ColorRect = $GridVisuals
@onready var paper_background : TextureRect = $PaperBackground

# This will hold the units, obstacles, etc...
var board_state : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cubic.size = 84.0
	grid_visuals.set_instance_shader_parameter("size", cubic.size)
	#grid_visuals.set_instance_shader_parameter("size", 100.0)
	grid_visuals.set_instance_shader_parameter("border_frac", border_frac)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# update sizes since UI nodes sit under Node2D
	var screen_size = get_viewport_rect().size
	grid_visuals.size = screen_size 
	paper_background.size = screen_size
	grid_visuals.set_instance_shader_parameter("rect_size", screen_size)
	

# helper functions

func get_cubic_distance(a: Vector3i, b: Vector3i) -> int:
	return maxi(maxi(abs(a.x - b.x), abs(a.y - b.y)), abs(a.z - b.z))


func get_entity_at_hex(target_hex: Vector3i) -> Node:
	if board_state.has(target_hex):
		return board_state[target_hex]
	return null


func calculate_reachable_hexes(start: Vector3i, max_move: int) -> Dictionary:
	var queue: Array[Vector3i] = [start]
	var reachable_hex: Dictionary = {start: start}
	var cost_so_far: Dictionary = {start: 0}
	
	while not queue.is_empty():
		var current : Vector3i = queue.pop_front()
		
		for dir in cubic.CUBIC_DIRECTIONS:
			var neighbor = current + Vector3i(dir)
			var new_cost = cost_so_far[current] + 1
			
			# Stop search if distance is too far for the unit
			if new_cost > max_move:
				continue
				
			# Stop search if there is a unit already standing there
			if get_entity_at_hex(neighbor) != null:
				continue
				
			if not cost_so_far.has(neighbor) or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				reachable_hex[neighbor] = current
				queue.append(neighbor)
				
	return reachable_hex

extends Node2D
class_name GridManager

@export var cubic : CubicCoords
@export var border_frac : float = 0.93

@onready var grid_visuals : ColorRect = $GridVisuals
@onready var paper_background : TextureRect = $PaperBackground
@onready var border_ref_rect : ReferenceRect = $BorderReferenceRect

# This will hold the units, obstacles, etc...
var board_state : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cubic.size = 84.0
	grid_visuals.set_instance_shader_parameter("size", cubic.size)
	grid_visuals.set_instance_shader_parameter("border_frac", border_frac)
	grid_visuals.set_instance_shader_parameter("limit_rect", border_ref_rect.get_rect())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# update sizes since UI nodes sit under Node2D
	var screen_size = get_viewport_rect().size
	grid_visuals.size = screen_size 
	paper_background.size = screen_size
	grid_visuals.set_instance_shader_parameter("rect_size", screen_size)
	

# helper functions

# Regular distance
func get_cubic_distance(a: Vector3i, b: Vector3i) -> int:
	return maxi(maxi(abs(a.x - b.x), abs(a.y - b.y)), abs(a.z - b.z))

# Is hex within border?
func in_border(pos: Vector3i) -> bool:
	return border_ref_rect.get_rect().has_point(cubic.cubic_to_pos2D(pos))

# Range (without taking into account obstacles)
func get_hexes_in_range(center: Vector3i, radius: int) -> Array[Vector3i]:
	var results: Array[Vector3i] = []
	for dx in range(-radius, radius + 1):
		for dy in range(max(-radius, -dx - radius), min(radius, -dx + radius) + 1):
			var dz = -dx - dy
			var pos := center + Vector3i(dx, dy, dz)
			if (in_border(pos)):
				results.append(pos)
	return results
	

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
			
			# Stop search if hex outside border
			if !in_border(neighbor):
				continue
			
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

extends Node2D

@export var cubic: CubicCoords
@export var path_segment: Texture2D

@onready var label = $Label
@onready var label2 = $Label2
@onready var field = $".."
var path_segments: Array[Stretch] = []
var last_dest: Vector3i = Vector3i.MIN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos = position
	var cubic_pos = cubic.pos2D_to_cubic(pos)
	if Input.is_action_just_pressed("m1"):
		pos = get_viewport().get_mouse_position()
		cubic_pos = cubic.pos2D_to_cubic(pos)
		cubic_pos = cubic.cubic_round(cubic_pos)
		if last_dest != Vector3i.MIN and last_dest == Vector3i(cubic_pos):
			position = cubic.cubic_to_pos2D(cubic_pos)
		if !field.obstacles.has(cubic_pos):
			pathfind(cubic.cubic_round(cubic.pos2D_to_cubic(position)), cubic_pos)
	
	label2.text = str(cubic.cubic_round(cubic.pos2D_to_cubic(position)))

func pathfind(start: Vector3i, dest: Vector3i):
	for segment in path_segments:
		segment.queue_free()
	path_segments.clear()
	if field.obstacles.has(dest) or start == dest:
		return
	var cell_distance: Dictionary[Vector3i, int] = {start:0}
	var cell_from: Dictionary[Vector3i, Vector3i] = {start:start}
	var queue: Array[Vector3i] = [start]
	
	while !queue.is_empty():
		var cubic_pos = queue.pop_front()
		var dist = cell_distance[cubic_pos]
		for dir in cubic.CUBIC_DIRECTIONS:
			dir = Vector3i(dir)
			var search_pos = cubic_pos + dir
			if on_screen(cubic.cubic_to_pos2D(search_pos))\
			and (!cell_distance.has(search_pos) or dist + 1 < cell_distance.get(search_pos, -1))\
			and !field.obstacles.has(search_pos):
				cell_distance[search_pos] = dist + 1
				cell_from[search_pos] = cubic_pos
				if search_pos == dest:
					queue.clear()
					break
				else:
					queue.append(search_pos)
	
	if cell_from.has(dest):
		last_dest = dest
		var cell = dest
		while cell != start:
			var prev = cell_from[cell]
			var cell_2D = cubic.cubic_to_pos2D(cell)
			var prev_2D = cubic.cubic_to_pos2D(prev)
			
			var segment = Stretch.new()
			segment.texture = path_segment
			add_sibling(segment)
			segment.stretch(prev_2D, cell_2D)
			path_segments.append(segment)
			
			cell = prev
	else:
		last_dest = Vector3i.MIN

func on_screen(pos: Vector2) -> bool:
	var screen = get_viewport_rect()
	screen.position = Vector2.ZERO
	return screen.has_point(pos)

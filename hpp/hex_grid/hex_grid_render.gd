extends CanvasItem

@export var cubic: CubicCoords
@export var color: Color = Color.BLACK
@export var border_frac: float = 0.9
@export var unit_scene : PackedScene

enum SubTurnPhase {MOVING, ATTACKING}

var turn_queue : Array = []
var curr_subturn_index : int = -1
var curr_subturn_phase : SubTurnPhase = SubTurnPhase.MOVING
var active_unit : Dictionary

var army_1 : Array = []
var army_2 : Array = []

# Units (this is temporary, will be replaced by the data passed from the pre-game)
var unit_1 = {
	"stats" = {
		"speed" = 2,
		"movement" = 3,
		"health" = 10,
		"damage" = 2
	},
	"coords" = Vector3i(4,-1,-3)
}

var unit_2 = {
	"stats" = {
		"speed" = 4,
		"movement" = 2,
		"health" = 5,
		"damage" = 3
	},
	"coords" = Vector3i(7,-4,-3)
}

var unit_3 = {
	"stats" = {
		"speed" = 5,
		"movement" = 3,
		"health" = 20,
		"damage" = 1
	},
	"coords" = Vector3i(5, 0, -5)
}

var unit_4 = {
	"stats" = {
		"speed" = 1,
		"movement" = 1,
		"health" = 7,
		"damage" = 10
	},
	"coords" = Vector3i(8, -3, -5)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.material = load("res://hex_grid/hex_grid_render.tres")
	set_instance_shader_parameter("size", cubic.size)
	set_instance_shader_parameter("border_frac", border_frac)
	
	# init armies
	_setup_army()
	
	# init turn
	_init_turn()
	
	# start turn
	_start_next_sub_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_instance_shader_parameter("rect_size", get_viewport_rect().size)
	pass
	
func _draw() -> void:
	self.draw_rect(get_viewport_rect(), color)
	
# This will have to be improved to be more modular depending on the unit and data we get from pre-grame
func _setup_army():
	
	_instantiate_unit_scene(unit_1, Color.DARK_RED)
	army_1.append(unit_1)
	
	_instantiate_unit_scene(unit_3, Color.DARK_RED)
	army_1.append(unit_3)
	
	_instantiate_unit_scene(unit_2, Color.DARK_BLUE)
	army_2.append(unit_2)
	
	_instantiate_unit_scene(unit_4, Color.DARK_BLUE)
	army_2.append(unit_4)
	

func _instantiate_unit_scene(unit : Dictionary, unit_color: Color):
	var u_scene = unit_scene.instantiate()
	add_child(u_scene)
	u_scene.position = cubic.cubic_to_pos2D(unit["coords"])
	
	var sprite = u_scene.get_node("Sprite2D")
	sprite.self_modulate = unit_color
	
	unit["hex"] = u_scene
	unit["base_color"] = unit_color
	update_health_label(unit)


func _init_turn():
	#turn_queue.clear()
	
	var pointer_1 = 0
	var pointer_2 = 0
	
	while pointer_1 < army_1.size() or pointer_2 < army_2.size():
		
		if pointer_2 == army_2.size() or (pointer_1 < army_1.size() and army_1[pointer_1]["stats"]["speed"] > army_2[pointer_2]["stats"]["speed"]):
			turn_queue.append(army_1[pointer_1])
			pointer_1 += 1
		else:
			turn_queue.append(army_2[pointer_2])
			pointer_2 += 1


func _start_next_sub_turn():
	curr_subturn_index += 1
	
	if curr_subturn_index >= turn_queue.size():
		curr_subturn_index = 0
		print("round done")
		
	active_unit = turn_queue[curr_subturn_index]
	curr_subturn_phase = SubTurnPhase.MOVING
	_update_unit_color(active_unit)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_viewport().get_mouse_position()
		var cubic_pos = cubic.pos2D_to_cubic(pos)
		var target_pos = Vector3i(cubic.cubic_round(cubic_pos))
		print(cubic_pos)
		
		var move_limit = active_unit["stats"]["movement"]
		var dist = get_cubic_distance(active_unit["coords"], target_pos)
		var target_unit = get_unit_at_hex(target_pos)
		
		# Subturn phase 1: Moving
		if curr_subturn_phase == SubTurnPhase.MOVING:
			if dist <= move_limit and target_unit.is_empty():
				#active_unit["hex"].modulate = active_unit["base_color"]
				active_unit["coords"] = target_pos
				active_unit["hex"].position = cubic.cubic_to_pos2D(target_pos)
				
				curr_subturn_phase = SubTurnPhase.ATTACKING
				print("Moved")
			elif target_pos == active_unit["coords"]:
				curr_subturn_phase = SubTurnPhase.ATTACKING
				print("Moving subphase skipped")
			else:
				print("Invalid move")
			
		# Subturn phase 2: Attacking
		elif curr_subturn_phase == SubTurnPhase.ATTACKING:
			# skip attack subturn phase by clicking on current unit
			if target_pos == active_unit["coords"]:
				print("Attack skipped.")
				_end_turn_cleanup()
				return
				
			# Check if target is 1 hex away and has a unit
			if dist == 1 and not target_unit.is_empty():
				# Check if enemy unit
				var is_enemy = (active_unit in army_1 and target_unit in army_2) or (active_unit in army_2 and target_unit in army_1)
				
				if is_enemy:
					target_unit["stats"]["health"] -= active_unit["stats"]["damage"]
					update_health_label(target_unit)
					
					if target_unit["stats"]["health"] <= 0:
						kill_unit(target_unit)
						
					_end_turn_cleanup()
			else:
				print("Invalid attack target")
		

func _update_unit_color(unit):
	var sprite = unit["hex"].get_node("Sprite2D")
	
	if active_unit in army_1:
		sprite.self_modulate = Color.RED
	else:
		sprite.self_modulate = Color.BLUE
		
func _end_turn_cleanup():
	var sprite = active_unit["hex"].get_node("Sprite2D")
	sprite.self_modulate = active_unit["base_color"]
	
	_start_next_sub_turn()
	
# Helper functions

# This will have to be replaced by proper pathfinding (see Daniil code for inspo)
func get_cubic_distance(a: Vector3i, b: Vector3i) -> int:
	return maxi(maxi(abs(a.x - b.x), abs(a.y - b.y)), abs(a.z - b.z))

# Check if there is already a unit in the target hex
#func is_hex_occupied(target_hex: Vector3i) -> bool:
	#for unit in turn_queue:
		## the first condition allows the user to skip the move step by clicking on the units current pos
		#if unit != active_unit and unit["coords"] == target_hex:
			#return true
	#return false
	
func get_unit_at_hex(target_hex: Vector3i) -> Dictionary:
	for unit in turn_queue:
		if unit["coords"] == target_hex:
			return unit
	return {}

func update_health_label(unit: Dictionary):
	var label = unit["hex"].get_node("Sprite2D/HealthLabel")
	if label:
		label.text = str(unit["stats"]["health"])

func kill_unit(unit: Dictionary):
	# remove the visal node
	unit["hex"].queue_free()
	
	# adjust turn index if the killed unit was behind in the queue
	var queue_index = turn_queue.find(unit)
	if queue_index != -1 and queue_index < curr_subturn_index:
		curr_subturn_index -= 1 
	
	# remove from arrays
	turn_queue.erase(unit)
	army_1.erase(unit)
	army_2.erase(unit)
	
	print("Unit killed")

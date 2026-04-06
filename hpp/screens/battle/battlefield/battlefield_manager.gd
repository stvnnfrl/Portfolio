extends Node
class_name BattlefieldManager

# this will have to be changed in the future. Only for demo purposes. 
# Have to think of a better way because 20 variables for all different unit types is propably not the best
@export var minelayer_scene : PackedScene
@export var pawn_scene : PackedScene

@export var highlight_scene : PackedScene

@onready var grid : GridManager = $"../GridManager"
@onready var units_layer : Node2D = $"../UnitsLayer"
@onready var highlight_layer : Node2D = $"../HighlightLayer"

var active_highlights : Array = []
var active_reachable_hexes : Dictionary = {}

var turn_queue : Array[Unit] = []
var army_1 : Array[Unit] = []
var army_2 : Array[Unit] = []

# Army colors
var army_1_color_normal = Color(0.933, 0.102, 0.102, 0.4)
var army_1_color_active = Color(0.917, 0.0, 0.188, 0.9)
var army_2_color_normal = Color(0.106, 0.106, 0.89, 0.4)
var army_2_color_active = Color(0.301, 0.036, 1.0, 0.9)

enum SubTurnPhase {MOVING, ATTACKING}
var current_phase : SubTurnPhase = SubTurnPhase.MOVING
var curr_subturn_index : int = -1
var active_unit : Unit

func _ready() -> void:
	# call_deferred to ensure the GridManager finishes its own _ready setup first
	call_deferred("_setup_army")

func _setup_army() -> void:
	# this will have to be changed when we receive data through the scene manager
	# army 1
	_instantiate_unit_scene(minelayer_scene, Vector3i(4, -1, -3), 1)
	_instantiate_unit_scene(pawn_scene, Vector3i(5, 0, -5), 1)
	
	# army 2
	_instantiate_unit_scene(pawn_scene, Vector3i(7, -4, -3), 2)
	_instantiate_unit_scene(minelayer_scene, Vector3i(8, -3, -5), 2)
	
	# start game loop
	_init_turn_queue()
	_start_next_sub_turn()
	

func _instantiate_unit_scene(scene_to_spawn : PackedScene, hex_coords : Vector3i, army : int) -> void:
	
	var unit_instance = scene_to_spawn.instantiate() as Unit
	units_layer.add_child(unit_instance)
	
	# set attributes
	unit_instance.cubic_pos = hex_coords
	unit_instance.army_id = army
	unit_instance.position = grid.cubic.cubic_to_pos2D(hex_coords)
	
	_set_normal_color(unit_instance)
	
	# update the grid manager
	grid.board_state[hex_coords] = unit_instance
	
	if army == 1:
		army_1.append(unit_instance)
	else:
		army_2.append(unit_instance)

func _set_normal_color(unit : Unit):
	if unit.army_id == 1:
		unit.hex_halo.modulate = army_1_color_normal
	else:
		unit.hex_halo.modulate = army_2_color_normal

func _init_turn_queue():
	turn_queue.clear()
	turn_queue.append_array(army_1)
	turn_queue.append_array(army_2)
	turn_queue.sort_custom(sort_by_movement_speed)
	print(turn_queue)

func _start_next_sub_turn():
	if active_unit != null:
		_set_normal_color(active_unit)
	
	curr_subturn_index += 1
	
	if curr_subturn_index >= turn_queue.size():
		curr_subturn_index = 0
		print("round done")
		
	active_unit = turn_queue[curr_subturn_index]
	current_phase = SubTurnPhase.MOVING
	_activate_unit_color()
	_draw_reachable_hexes()

func _activate_unit_color():
	if active_unit.army_id == 1:
		active_unit.hex_halo.modulate = army_1_color_active
	else:
		active_unit.hex_halo.modulate = army_2_color_active


func _clear_highlights() -> void:
	for hex in active_highlights:
		if is_instance_valid(hex):
			hex.queue_free()
	active_highlights.clear()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_viewport().get_mouse_position()
		var cubic_pos = grid.cubic.pos2D_to_cubic(pos)
		var target_hex = Vector3i(grid.cubic.cubic_round(cubic_pos))
		
		print("Clicked Hex: ", target_hex)
		
		if current_phase == SubTurnPhase.MOVING:
			_attempt_move(target_hex)
		elif current_phase == SubTurnPhase.ATTACKING:
			_attempt_attack(target_hex)


func _attempt_move(target_hex: Vector3i) -> void:
	# check if hex clicked is reachable
	if active_reachable_hexes.has(target_hex):
		
		grid.board_state.erase(active_unit.cubic_pos)
		grid.board_state[target_hex] = active_unit
		active_unit.cubic_pos = target_hex
		active_unit.position = grid.cubic.cubic_to_pos2D(target_hex)
		
		print("Unit moved")
		
		_clear_highlights()
		current_phase = SubTurnPhase.ATTACKING
		
	# Skip movement if they click the tile they are already standing on
	elif target_hex == active_unit.cubic_pos:
		print("movement skipped")
		_clear_highlights()
		current_phase = SubTurnPhase.ATTACKING 


func _attempt_attack(target_hex: Vector3i) -> void:
	# Skip attack if they click on the current unit hex
	if target_hex == active_unit.cubic_pos:
		print("Attack skipped")
		_start_next_sub_turn()
		return
		
	# TODO using simple cubic distance for now
	# Depending on type of unit, could consider different algorithm (e.g. follow path, range, etc.)
	var dist = grid.get_cubic_distance(active_unit.cubic_pos, target_hex)
	if dist <= active_unit.reach:
		
		var target_entity = grid.get_entity_at_hex(target_hex)
		
		# attack only is another unit and enemy unit
		if target_entity is Unit and target_entity.army_id != active_unit.army_id:
			var damage = active_unit.get_attack_damage()
			target_entity.take_damage(damage)
			
			# check if enemy died
			if target_entity.health <= 0:
				_kill_unit(target_entity)
				
			_start_next_sub_turn()
		else:
			print("Invalid target")
	else:
		print("Target out of range")


func _kill_unit(unit: Unit) -> void:
	#remove unit from arrays
	grid.board_state.erase(unit.cubic_pos)
	turn_queue.erase(unit)
	army_1.erase(unit)
	army_2.erase(unit)
	
	# adjust turn index
	var queue_index = turn_queue.find(unit)
	if queue_index != -1 and queue_index < curr_subturn_index:
		curr_subturn_index -= 1 
		
	# Delete the node
	unit.queue_free()
	

func _draw_reachable_hexes() -> void:
	# clean up just in case
	_clear_highlights() 
	
	# get reachable hexes with BFS
	active_reachable_hexes = grid.calculate_reachable_hexes(active_unit.cubic_pos, active_unit.movement)
	
	for hex_coord in active_reachable_hexes.keys():
		# skip active unit coordinates (i.e. don't want to "overwrite" unit)
		if hex_coord == active_unit.cubic_pos:
			continue
			
		var h_instance = highlight_scene.instantiate()
		highlight_layer.add_child(h_instance)
		h_instance.position = grid.cubic.cubic_to_pos2D(hex_coord)
		h_instance.modulate = Color(0.37, 0.37, 0.37, 1.0)
		
		active_highlights.append(h_instance)


# Helper functions

func sort_by_movement_speed(unit_1 : Unit, unit_2 : Unit) -> bool:
	return unit_1.speed > unit_2.speed

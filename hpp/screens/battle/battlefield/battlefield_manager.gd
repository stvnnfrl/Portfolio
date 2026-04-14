extends Node
class_name BattlefieldManager

@export var highlight_scene : PackedScene

@onready var grid : GridManager = $"../GridManager"
@onready var units_layer : Node2D = $"../UnitsLayer"
@onready var highlight_layer : Node2D = $"../HighlightLayer"

var active_highlights : Array = []
var active_reachable_hexes : Dictionary = {}

var turn_queue : Array[Unit] = []
var hero_1 : Hero
var army_1 : Array[Unit] = []
var hero_2 : Hero
var army_2 : Array[Unit] = []

# Army colors
var army_1_color_normal = Color(0.933, 0.102, 0.102, 0.4)
var army_1_color_active = Color(0.917, 0.0, 0.188, 0.9)
var army_2_color_normal = Color(0.106, 0.106, 0.89, 0.4)
var army_2_color_active = Color(0.301, 0.036, 1.0, 0.9)

enum SubTurnPhase {MOVING, ATTACKING, ANIMATING}
var current_phase : SubTurnPhase = SubTurnPhase.MOVING
var curr_subturn_index : int = -1
var active_unit : Unit
var active_hero : Hero

func setup_battlefield(
	hero1: Hero,
	army1: Array[Unit],
	hero2: Hero,
	army2: Array[Unit],
	saved_turn_queue: Array[int] = [],
	saved_subturn_index: int = -1,
	saved_phase: int = SubTurnPhase.MOVING
) -> void:
	
	hero_1 = hero1
	hero_2 = hero2

	_setup_army(army1, army2)
	
	# start game loop
	_init_turn_queue()
	if saved_turn_queue.is_empty() or saved_subturn_index < 0:
		_start_next_sub_turn()
		return

	_load_saved_turn_state(saved_turn_queue, saved_subturn_index, saved_phase)

func _setup_army(army1: Array[Unit], army2: Array[Unit]) -> void:
	for unit in army1:
		_setup_pregame_unit(unit, 1)
			
	for unit in army2:
		_setup_pregame_unit(unit, 2)

func _load_saved_turn_state(saved_turn_queue: Array[int], saved_subturn_index: int, saved_phase: int) -> void:
	if active_unit != null:
		_set_normal_color(active_unit)

	_clear_highlights()
	turn_queue.clear()

	var all_units: Array[Unit] = []
	all_units.append_array(army_1)
	all_units.append_array(army_2)

	for unit_index in saved_turn_queue:
		if unit_index >= 0 and unit_index < all_units.size():
			turn_queue.append(all_units[unit_index])

	for unit in all_units:
		if not turn_queue.has(unit):
			turn_queue.append(unit)

	if turn_queue.is_empty():
		_start_next_sub_turn()
		return

	curr_subturn_index = clamp(saved_subturn_index, 0, turn_queue.size() - 1)
	current_phase = saved_phase as SubTurnPhase
	active_unit = turn_queue[curr_subturn_index]
	_activate_unit_color()
	if current_phase == SubTurnPhase.MOVING:
		_draw_phase_highlights()
	
	
func _setup_pregame_unit(unit_instance: Unit, army: int) -> void:
	
	units_layer.add_child(unit_instance)
	unit_instance._ensure_node_refs()
	
	# Set attributes
	unit_instance.army_id = army
	unit_instance.position = grid.cubic.cubic_to_pos2D(unit_instance.cubic_pos)
	
	_set_normal_color(unit_instance)
	
	# update the grid manager
	grid.board_state[unit_instance.cubic_pos] = unit_instance
	
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
	if active_unit.army_id == 1:
		active_hero = hero_1
	else:
		active_hero = hero_2
	
	_activate_unit_color()
	
	if active_unit.movement <= 0:
		current_phase = SubTurnPhase.ATTACKING
	else:
		current_phase = SubTurnPhase.MOVING
	
	_draw_phase_highlights()

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
	
	# Skip movement if they click the tile they are already standing on
	if target_hex == active_unit.cubic_pos:
		print("movement skipped")
		_clear_highlights()
		current_phase = SubTurnPhase.ATTACKING 
		_draw_phase_highlights()
		
	# check if hex clicked is reachable
	elif active_reachable_hexes.has(target_hex):
		
		grid.board_state.erase(active_unit.cubic_pos)
		grid.board_state[target_hex] = active_unit
		active_unit.cubic_pos = target_hex
		active_unit.position = grid.cubic.cubic_to_pos2D(target_hex)
		
		print("Unit moved")
		
		_clear_highlights()
		current_phase = SubTurnPhase.ATTACKING
		_draw_phase_highlights()
		


func _attempt_attack(target_hex: Vector3i) -> void:
	# Skip attack if they click on the current unit hex
	if target_hex == active_unit.cubic_pos:
		print("Attack skipped")
		_clear_highlights()
		_start_next_sub_turn()
		return
		
	# TODO using simple cubic distance for now
	# Depending on type of unit, could consider different algorithm (e.g. follow path, range, etc.)
	var dist = grid.get_cubic_distance(active_unit.cubic_pos, target_hex)
	if dist <= active_unit.reach:
		
		var target_entity = grid.get_entity_at_hex(target_hex)
		
		# attack only is another unit and enemy unit
		if target_entity is Unit and target_entity.army_id != active_unit.army_id:
			# block other inputs during animation
			current_phase = SubTurnPhase.ANIMATING
			await active_unit.play_attack_animation()
			var damage = active_unit.get_attack_damage()
			target_entity.take_damage(damage)
			
			# check if enemy died
			if target_entity.health <= 0:
				_kill_unit(target_entity)
				
			_clear_highlights()
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
	
	# TODO this check placement might get changed in the future when spells are involved
	# Check if one army has won
	_check_winning_condition()

func _check_winning_condition():
	if army_1.is_empty():
		print("Army 2 wins")
		SceneManager.load_game_over("Army 2 wins", army_2_color_active)
	elif army_2.is_empty():
		print("Army 1 wins")
		SceneManager.load_game_over("Army 1 wins", army_1_color_active)


func _draw_phase_highlights() -> void:
	# clean up just in case
	_clear_highlights() 
	
	var hexes_to_highlight: Array = []
	var highlight_color: Color
	
	# Determine hexes and colors based on the current phase
	if current_phase == SubTurnPhase.MOVING:
		# get reachable hexes with BFS
		active_reachable_hexes = grid.calculate_reachable_hexes(active_unit.cubic_pos, active_unit.movement)
		hexes_to_highlight = active_reachable_hexes.keys()
		highlight_color = Color(0.37, 0.37, 0.37, 1.0)
		
	elif current_phase == SubTurnPhase.ATTACKING:
		# Calculate distance for ranged attacks
		hexes_to_highlight = grid.get_hexes_in_range(active_unit.cubic_pos, active_unit.reach)
		highlight_color = Color(0.369, 0.369, 0.369, 0.867)
	
	# draw
	for hex_coord in hexes_to_highlight:
		# skip active unit coordinates (i.e. don't want to "overwrite" unit)
		if hex_coord == active_unit.cubic_pos:
			continue
			
		var h_instance = highlight_scene.instantiate()
		highlight_layer.add_child(h_instance)
		h_instance.position = grid.cubic.cubic_to_pos2D(hex_coord)
		h_instance.modulate = highlight_color
		
		active_highlights.append(h_instance)


# Helper functions

func sort_by_movement_speed(unit_1 : Unit, unit_2 : Unit) -> bool:
	return unit_1.speed > unit_2.speed
	

func get_current_hero_spells() -> Array[Dictionary]:
	var hero_spells_data: Array[Dictionary] = []
	
	if active_hero == null:
		return hero_spells_data
		
	for spell_scene in active_hero.spells: 
		if spell_scene != null:

			var spell_instance = spell_scene.instantiate()
			
			hero_spells_data.append({
				"name": spell_instance.spell_name, 
				"description": spell_instance.description,
				"texture": spell_instance.texture 
			})
			
			spell_instance.queue_free()
			
	return hero_spells_data

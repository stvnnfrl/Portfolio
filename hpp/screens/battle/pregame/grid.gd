extends ColorRect

@export var state: Pregame
@export var cubic_coords: CubicCoords

var placed_units: Dictionary[Vector3i, Node2D]

# indices for the current player - reset when players switch
var placed_unit_indices: Dictionary[Node2D, int]

func _on_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	
	event = event as InputEventMouseButton
	
	# only trigger on release (consistent with buttons, but could be changed) 
	if event.pressed:
		return
	
	if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		# only do anything if a unit is selected
		var selected_unit = state.selected_unit
		if selected_unit == null:
			return
		
		var grid_coordinates = cubic_coords.cubic_round(cubic_coords.pos2D_to_cubic(event.position))
		
		# check whether we can afford the unit
		var purchase_callback = state.can_purchase()
		if purchase_callback.is_null():
			return
		
		# check whether we can remove what was already there
		var clear_callback = can_clear(grid_coordinates)
		if clear_callback.is_null():
			return
		
		# trigger the purchase
		purchase_callback.call()
		clear_callback.call()
		
		# place a new unit
		var screen_coordinates = cubic_coords.cubic_to_pos2D(grid_coordinates)
		var new_unit = create_unit_at(screen_coordinates, selected_unit)
		placed_units[grid_coordinates] = new_unit
		placed_unit_indices[new_unit] = state.selected_index
	
	elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		# clear the unit if possible
		var grid_coordinates = cubic_coords.cubic_round(cubic_coords.pos2D_to_cubic(event.position))
		var clear_callback = can_clear(grid_coordinates)
		if clear_callback.is_valid():
			clear_callback.call()

func can_clear(coordinates: Vector3i) -> Callable:
	var unit = placed_units.get(coordinates)
	if unit == null:  # yes, don't need to do anything
		return func(): pass
	
	var unit_index = placed_unit_indices.get(unit)
	if unit_index == null:  # no, this unit was placed by another player
		return Callable()
	
	var refund_callback = state.can_refund(unit_index)
	if refund_callback.is_null():  # no, something in the state is preventing a refund
		return Callable()
	
	# yes, here's a callback to clear the coordinate
	return func():
		refund_callback.call()
		placed_unit_indices.erase(unit)
		placed_units.erase(coordinates)
		unit.queue_free()

func create_unit_at(screen_coordinates: Vector2, unit_type: Unit) -> Node2D:
	var new_unit = unit_type.duplicate()
	new_unit.position = screen_coordinates
	add_child(new_unit)
	return new_unit

func _on_pregame_units_updated(_units: Array[Unit]) -> void:
	placed_unit_indices = {}

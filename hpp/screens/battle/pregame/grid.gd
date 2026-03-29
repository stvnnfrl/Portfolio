extends ColorRect

@export var cubic_coords: CubicCoords

var placed_units: Dictionary[Vector3i, Node2D]

var current_unit: int = -1
var units: Array[Variant]

func _on_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	
	event = event as InputEventMouseButton
	
	# only trigger on release (consistent with buttons, but could be changed) 
	if event.pressed:
		return
	
	if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		# only do anything if a unit is selected
		if current_unit < 0:
			return
		
		var grid_coordinates = cubic_coords.cubic_round(cubic_coords.pos2D_to_cubic(event.position))
		var unit_at_click = placed_units.get(grid_coordinates)
		
		# free what was previously there
		if unit_at_click != null:
			unit_at_click.queue_free()
		
		# place a new unit
		var screen_coordinates = cubic_coords.cubic_to_pos2D(grid_coordinates)
		var new_unit = create_unit_at(screen_coordinates)
		placed_units[grid_coordinates] = new_unit
	
	elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		# clear the unit
		var grid_coordinates = cubic_coords.cubic_round(cubic_coords.pos2D_to_cubic(event.position))
		var unit_at_click = placed_units.get(grid_coordinates)
		
		if unit_at_click != null:
			placed_units.erase(grid_coordinates)
			unit_at_click.queue_free()

func create_unit_at(screen_coordinates: Vector2) -> Node2D:
	var sprite = Sprite2D.new()
	
	var unit = units[current_unit]
	var texture: Texture2D = unit.texture
	sprite.texture = texture
	
	# make sizes consistent between units
	var current_size = texture.get_size()
	sprite.scale = Vector2(cubic_coords.size / current_size.x, cubic_coords.size / current_size.y)
	
	sprite.position = screen_coordinates
	
	add_child(sprite)
	
	return sprite

func _on_unit_selector_selected_unit_changed(index: int) -> void:
	current_unit = index

func init(units_: Array[Variant]) -> void:
	units = units_

extends ColorRect

@export var grid_size: float = 128

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
		
		var grid_coordinates = cubic_round(pos2D_to_cubic(event.position))
		var unit_at_click = placed_units.get(grid_coordinates)
		
		# free what was previously there
		if unit_at_click != null:
			unit_at_click.queue_free()
		
		# place a new unit
		var screen_coordinates = cubic_to_pos2D(grid_coordinates)
		var new_unit = create_unit_at(screen_coordinates)
		placed_units[grid_coordinates] = new_unit
	
	elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		# clear the unit
		var grid_coordinates = cubic_round(pos2D_to_cubic(event.position))
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
	sprite.scale = Vector2(grid_size / current_size.x, grid_size / current_size.y)
	
	sprite.position = screen_coordinates
	
	add_child(sprite)
	
	return sprite

func _on_unit_selector_selected_unit_changed(index: int) -> void:
	current_unit = index

func init(units_: Array[Variant]) -> void:
	units = units_


# coordinate conversion
# from hex movement mini-project

const RIGHT = Vector3(1, -1, 0)
const DOWNRIGHT = Vector3(1, 0 ,-1)
const DOWNLEFT = Vector3(0, 1, -1)

const down_cubic = Vector3(1, 1, -2)/3
const right_cubic = RIGHT/sqrt(3)
func pos2D_to_cubic(pos: Vector2) -> Vector3:
	return (pos.x * right_cubic + pos.y * down_cubic)/grid_size

const x_2d = Vector2(sqrt(3)/2, 0.5)
const y_2d = Vector2(-sqrt(3)/2, 0.5)
const z_2d = Vector2(0, -1)
func cubic_to_pos2D(pos: Vector3) -> Vector2:
	return grid_size * (x_2d * pos.x + y_2d * pos.y + z_2d * pos.z)

func cubic_round(pos: Vector3) -> Vector3i:
	# credit to redblobgames.com/grids/hexagons
	var rounded = round(pos)
	var diff = abs(rounded - pos)
	if (diff.x > diff.y && diff.x > diff.z):
		rounded.x = -rounded.y-rounded.z
	elif (diff.y > diff.z):
		rounded.y = -rounded.x-rounded.z
	else:
		rounded.z = -rounded.x-rounded.y
	return Vector3i(rounded)

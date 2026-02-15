extends Panel

# Signal we will send to the main game controller when the user is done drawing
signal drawing_finished(points: PackedVector2Array)

var _active_line: PackedVector2Array = []
var _is_drawing: bool = false

func _ready():
	# This ensures the panel actually blocks mouse clicks from going behind it
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	# 1. DETECT MOUSE CLICK (START/END)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drawing(event.position)
			else:
				_end_drawing()
	
	# 2. DETECT MOUSE MOVEMENT (DRAGGING)
	elif event is InputEventMouseMotion and _is_drawing:
		_add_point(event.position)

func _start_drawing(pos: Vector2):
	_is_drawing = true
	_active_line.clear()
	_add_point(pos)

func _add_point(pos: Vector2):
	# Don't add points if the mouse barely moved
	if _active_line.size() > 0 and pos.distance_to(_active_line[-1]) < 5.0:
		return
		
	_active_line.append(pos)
	queue_redraw()

func _end_drawing():
	_is_drawing = false
	
	# Only process if the line is long enough to be a real shape
	if _active_line.size() > 10:
		emit_signal("drawing_finished", _active_line)

func _draw():
	if _active_line.size() > 1:
		draw_polyline(_active_line, Color.WHITE, 5.0, true)

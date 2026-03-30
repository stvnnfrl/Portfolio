extends HBoxContainer

@export var state: Pregame

@export var buttongroup: ButtonGroup
@export var buttons: Array[Button]  # explicitly set order

var buttonMap: Dictionary[Button, int]

func _ready():
	# initialize button map
	for i in buttons.size():
		var button = buttons[i]
		buttonMap[button] = i
	
	# start emitting signals
	buttongroup.pressed.connect(_handle_selected_unit_change)

func _handle_selected_unit_change(__) -> void:
	# need to get pressed here
	# since unselecting by double click
	# gives same arg as select
	var button = buttongroup.get_pressed_button()
	var index = buttonMap.get(button, -1)
	
	state.change_selected_unit_to(index)

func _on_pregame_units_updated(units: Array[Unit]) -> void:
	# unselect whatever's selected
	var pressed = buttongroup.get_pressed_button()
	if pressed:
		pressed.button_pressed = false
	
	# update display
	for i in buttons.size():
		var button = buttons[i]
		button.text = units[i].name

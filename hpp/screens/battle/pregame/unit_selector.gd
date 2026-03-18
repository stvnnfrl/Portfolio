"""
adapts buttongroup.pressed
for a deselectable radio input
"""

class_name UnitSelector
extends HBoxContainer

signal selectedUnitChanged(index: int)

@export var buttongroup: ButtonGroup
@export var buttons: Array[Button]

@onready
var buttonMap: Dictionary[Button, int]

func init(units: Array[Dictionary]) -> void:
	# initialize buttonmap and button label
	for i in buttons.size():
		var button = buttons[i]

		button.text = units[i].name
		buttonMap[button] = i

	buttongroup.pressed.connect(_handle_selected_unit_change)

func _handle_selected_unit_change(__) -> void:
	# need to get pressed here
	# since unselecting by double click
	# gives same arg as select
	# and don't want to duplicate state in a global
	var button = buttongroup.get_pressed_button()
	var index = buttonMap.get(button, -1)

	selectedUnitChanged.emit(index)

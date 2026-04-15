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
	state.counts_updated.connect(_refresh_buttons)

func _handle_selected_unit_change(__) -> void:
	# need to get pressed here
	# since unselecting by double click
	# gives same arg as select
	var button = buttongroup.get_pressed_button()
	var index = buttonMap.get(button, -1)
	
	state.change_selected_unit_to(index)

func _on_pregame_units_updated() -> void:
	# unselect whatever's selected
	#var pressed = buttongroup.get_pressed_button()
	#if pressed:
		#pressed.button_pressed = false
	#
	## update display
	#for i in buttons.size():
		#var button = buttons[i]
		#
		#if i < units.size():
			#button.text = units[i].unit_name
			#button.show()
			#
			#if units[i].anim_sprite:
				#button.icon = units[i].anim_sprite.sprite_frames.get_frame_texture("idle", 0)
		#else:
			## hide the extra buttons
			#button.hide()
			
	# unselect whatever's selected
	var pressed = buttongroup.get_pressed_button()
	if pressed:
		pressed.button_pressed = false
	
	_refresh_buttons()
			
			
func _refresh_buttons() -> void:
	var units = state.current_units
	var counts = state.current_unit_counts
	
	for i in buttons.size():
		var button = buttons[i]
		button.show()
		
		if i < units.size():
			var amount_left = counts[i]
			button.text = units[i].unit_name + " (" + str(amount_left) + ")"
			
			# Disable button if out of units
			if amount_left <= 0:
				button.disabled = true
			else:
				button.disabled = false
		else:
			# TODO this will not be useful once we implement every unit
			# If no unit available yet
			button.text = ""
			button.disabled = true

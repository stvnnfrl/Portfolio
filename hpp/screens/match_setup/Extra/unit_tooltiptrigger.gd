
extends Button  

#I will set the slot_index for each index in the optionbutton //->{0,1,2,3}
@export var slot_index: int = 0  
@export var tooltip_delay: float = 1.0

var tooltip_scene = preload("res://screens/match_setup/Extra/unit_tooltip.tscn")
var tooltip_instance: Control = null
var hover_timer: Timer

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	hover_timer = Timer.new()
	hover_timer.one_shot = true
	hover_timer.wait_time = tooltip_delay
	hover_timer.timeout.connect(_show_tooltip)
	add_child(hover_timer)

#for delaying the tooltip popup
func _on_mouse_entered():
	hover_timer.start()
	
func _on_mouse_exited():
	hover_timer.stop()
	_hide_tooltip()


func _show_tooltip():
	# setting the set up as for selectionP1
	var match_setup = get_parent() 
	if not match_setup:
		return
		
	if slot_index >= len(match_setup.unit_data_cache):
		return
		
	var data = match_setup.unit_data_cache[slot_index]
	if data.is_empty():
		return
	
	if tooltip_instance == null:
		tooltip_instance = tooltip_scene.instantiate()
		get_viewport().add_child(tooltip_instance)
	
	# Filling in the tooltip using the data dictionary
	#it is reading data as it is in the global units
	tooltip_instance.set_unit(data["name"], data["icon"], data["description"])
	
	var mouse_pos = get_global_mouse_position()
	tooltip_instance.global_position = mouse_pos + Vector2(15, 15)
	tooltip_instance.show()

func _hide_tooltip():
	if tooltip_instance:
		tooltip_instance.hide()

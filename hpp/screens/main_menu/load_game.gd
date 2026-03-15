extends MarginContainer

@export var save_slot_scene : PackedScene

@onready var saves_container = $HBoxContainer/NavigationContainer/VBoxContainer/ScrollContainer/SavesContainer
@onready var search_bar = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/SearchBar
@onready var filter_dropdown = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/FilterHBox/Filter
@onready var sort_dropdown = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/FilterHBox/Sort

# Saves data
var saves_data = []

# Stub data
var stub_saves_data = [
		{
			"save_name": "Save 1",
			"mode": "Multiplayer",
			"date": "2026-01-17T01:05"
		},
		{
			"save_name": "Save 2",
			"mode": "Singleplayer",
			"date": "2026-01-15T11:57"
		},
		{
			"save_name": "Save 3",
			"mode": "Multiplayer",
			"date": "2026-01-16T14:23"
		},
		{
			"save_name": "Save 4",
			"mode": "Singleplayer",
			"date": "2026-01-16T14:33"
		},
		{
			"save_name": "Save 5",
			"mode": "Singleplayer",
			"date": "2026-01-16T14:34"
		},
		{
			"save_name": "test 6",
			"mode": "Multiplayer",
			"date": "2026-01-16T14:35"
		}
	]

func _ready():
	# Populate dropdown menu
	populate_drop_down()
	
	# Connect signals
	search_bar.text_changed.connect(_on_search_or_filter_changed)
	filter_dropdown.item_selected.connect(_on_search_or_filter_changed)
	sort_dropdown.item_selected.connect(_on_search_or_filter_changed)
	
	#search_bar.focus_entered.connect(_on_search_focus_entered)
	#search_bar.focus_exited.connect(_on_search_focus_exited)
	
	# Get saves from 
	# Call to load manager autoload
	
	# Populate saves list accordingly
	update_saves_list()

# This function is to remove the search bar focus when clicking outside of it
#func _input(event):
	## Listen for any left mouse button clicks
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#if search_bar.has_focus():
			## Get the global screen rectangle of the search bar
			#var bar_rect = search_bar.get_global_rect()
			#var mouse_pos = get_global_mouse_position()
			#
			## If click is outside the rectangle, drop focus
			#if not bar_rect.has_point(mouse_pos):
				#search_bar.release_focus()

func populate_drop_down():
	filter_dropdown.clear()
	sort_dropdown.clear()
	
	filter_dropdown.add_item("All Modes")
	filter_dropdown.add_item("Singleplayer")
	filter_dropdown.add_item("Multiplayer")
	
	sort_dropdown.add_item("Newest First")
	sort_dropdown.add_item("Oldest First")
	sort_dropdown.add_item("Name (A-Z)")
	sort_dropdown.add_item("Name (Z-A)")

func update_saves_list():
	var current_data = stub_saves_data.duplicate(true)
	
	current_data = apply_search(current_data)
	current_data = apply_mode_filter(current_data)
	current_data = apply_sorting(current_data)
	
	populate_saves_list(current_data)

func apply_search(data: Array) -> Array:
	var query = search_bar.text.to_lower()
	if query == "": #or "Search Saves ...":
		return data
		
	return data.filter(func(save): return query in save["save_name"].to_lower())

func apply_mode_filter(data: Array) -> Array:
	var filter_idx = filter_dropdown.selected
	
	if filter_idx == 1:
		return data.filter(func(save): return save["mode"] == "Singleplayer")
	elif filter_idx == 2:
		return data.filter(func(save): return save["mode"] == "Multiplayer")
		
	return data

func apply_sorting(data: Array) -> Array:
	var sort_idx = sort_dropdown.selected
	
	if sort_idx == 0: 
		data.sort_custom(func(a, b): return a["date"] > b["date"])
	elif sort_idx == 1: 
		data.sort_custom(func(a, b): return a["date"] < b["date"])
	elif sort_idx == 2: 
		data.sort_custom(func(a, b): return a["save_name"] < b["save_name"])
	elif sort_idx == 3: 
		data.sort_custom(func(a, b): return a["save_name"] > b["save_name"])
		
	return data

func populate_saves_list(data_to_display : Array):
	# clear to be safe
	for child in saves_container.get_children():
		child.queue_free()
	
	# Create slot for every save
	for metadata in data_to_display:
		var slot = save_slot_scene.instantiate()
		saves_container.add_child(slot)
		slot.setup(metadata)
		slot.pressed.connect(_on_save_slot_pressed.bind(metadata))


# Signals functions
func _on_search_or_filter_changed(_value_passed_by_signal):
	update_saves_list()

func _on_save_slot_pressed(metadata: Dictionary):
	print("Player clicked on: ", metadata["save_name"])

#func _on_search_focus_entered():
	#if search_bar.text == "Search Saves...":
		#search_bar.text = ""
	#
#func _on_search_focus_exited():
	#if search_bar.text == "":
		#search_bar.text = "Search Saves..."

extends MarginContainer

@export var save_slot_scene : PackedScene

@onready var saves_container = $HBoxContainer/NavigationContainer/VBoxContainer/ScrollContainer/SavesContainer
@onready var search_bar = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/SearchBar
@onready var filter_dropdown = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/FilterHBox/Filter
@onready var sort_dropdown = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/FilterHBox/Sort
@onready var delete_button = $HBoxContainer/PreviewContainer/VBoxContainer/HBoxContainer/DeleteButton

# Saves data
var saves_data : Array = []
var current_selected_save : Dictionary = {}

func _ready():
	# Populate dropdown menu
	populate_drop_down()
	
	# Connect signals
	search_bar.text_changed.connect(_on_search_or_filter_changed)
	filter_dropdown.item_selected.connect(_on_search_or_filter_changed)
	sort_dropdown.item_selected.connect(_on_search_or_filter_changed)
	
	delete_button.pressed.connect(_on_delete_button_pressed)
	delete_button.disabled = true
	
	#search_bar.focus_entered.connect(_on_search_focus_entered)
	#search_bar.focus_exited.connect(_on_search_focus_exited)
	
	# Get saves from 
	# Call to load manager autoload
	saves_data = FileManager.get_all_saves()
	
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
	var current_data = saves_data.duplicate(true)
	
	current_data = apply_search(current_data)
	current_data = apply_mode_filter(current_data)
	current_data = apply_sorting(current_data)
	
	populate_saves_list(current_data)

func apply_search(data: Array) -> Array:
	var query = search_bar.text.to_lower()
	if query == "": #or "Search Saves ...":
		return data
		

func apply_mode_filter(data: Array) -> Array:
	var filter_idx = filter_dropdown.selected
	
	if filter_idx == 1:
	elif filter_idx == 2:
		
	return data

func apply_sorting(data: Array) -> Array:
	var sort_idx = sort_dropdown.selected
	
	if sort_idx == 0: 
	elif sort_idx == 1: 
	elif sort_idx == 2: 
	elif sort_idx == 3: 
		
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

# Signals functions
func _on_search_or_filter_changed(_value_passed_by_signal):
	update_saves_list()

	print("Player clicked on: ", metadata["save_name"])
	current_selected_save = metadata
	delete_button.disabled = false
	
func _on_delete_button_pressed():
	if current_selected_save.is_empty():
		return
		
	var save_to_delete_file_path = current_selected_save["file_path"]
	
	# Delete file with FileManager
	var success : bool = FileManager.delete_save(save_to_delete_file_path)
	
	if success:
		# Remove the save from our local array
		for i in range(saves_data.size()):
			if saves_data[i]["file_path"] == save_to_delete_file_path:
				saves_data.remove_at(i)
				break
			
	# Clear selection and button
	current_selected_save = {}
	delete_button.disabled = true
	
	# Refresh UI
	update_saves_list()


func _on_resume_button_pressed():
	if current_selected_save.is_empty():
		return

	var file_path := String(current_selected_save.get("file_path", ""))
	if file_path == "":
		return

	var save_data := FileManager.load_single_save(file_path)
	if save_data.is_empty():
		push_warning("Unable to resume the selected save.")
		return

	var save_session := BattlefieldSaveLoad.resolve_save_session(save_data)
	var hero1 := save_session.get("hero1", null) as Hero
	var units1 := _to_unit_array(save_session.get("units1", []))
	var hero2 := save_session.get("hero2", null) as Hero
	var units2 := _to_unit_array(save_session.get("units2", []))
	SceneManager.load_battlefield(hero1, units1, hero2, units2)


func _select_slot(slot) -> void:
	if current_selected_slot != null and is_instance_valid(current_selected_slot):
		current_selected_slot.set_selected(false)

	current_selected_slot = slot
	if current_selected_slot != null and is_instance_valid(current_selected_slot):
		current_selected_slot.set_selected(true)


func _to_unit_array(raw_units: Variant) -> Array[Unit]:
	var units: Array[Unit] = []
	if raw_units is not Array:
		return units

	for raw_unit in raw_units:
		if raw_unit is Unit:
			units.append(raw_unit)

	return units


#func _on_search_focus_entered():
	#if search_bar.text == "Search Saves...":
		#search_bar.text = ""
	#
#func _on_search_focus_exited():
	#if search_bar.text == "":
		#search_bar.text = "Search Saves..."

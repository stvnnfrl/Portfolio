extends MarginContainer

@export var save_slot_scene : PackedScene

@onready var saves_container = $HBoxContainer/NavigationContainer/VBoxContainer/ScrollContainer/SavesContainer
@onready var search_bar = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/SearchBar
@onready var filter_dropdown = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/FilterHBox/Filter
@onready var sort_dropdown = $HBoxContainer/NavigationContainer/VBoxContainer/SearchVContainer/FilterHBox/Sort
@onready var preview_image = $HBoxContainer/PreviewContainer/VBoxContainer/PanelContainer/PreviewImage
@onready var delete_button = $HBoxContainer/PreviewContainer/VBoxContainer/HBoxContainer/DeleteButton
@onready var resume_button = $HBoxContainer/PreviewContainer/VBoxContainer/HBoxContainer/ResumeGameButton

# Saves data
var saves_data : Array = []
var current_selected_save : Dictionary = {}
var current_selected_slot = null

func _ready():
	# Populate dropdown menu
	populate_drop_down()
	
	# Connect signals
	search_bar.text_changed.connect(_on_search_or_filter_changed)
	filter_dropdown.item_selected.connect(_on_search_or_filter_changed)
	sort_dropdown.item_selected.connect(_on_search_or_filter_changed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	delete_button.disabled = true
	resume_button.disabled = true
	_clear_preview()
	
	# Get saves from
	# Call to load manager autoload
	saves_data = FileManager.get_all_saves()
	
	# Populate saves list accordingly
	update_saves_list()

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
	if query == "":
		return data
	return data.filter(func(save): return query in String(save.get("save_name", "")).to_lower())

func apply_mode_filter(data: Array) -> Array:
	var filter_idx = filter_dropdown.selected
	if filter_idx == 1:
		return data.filter(func(save): return save.get("mode", "Multiplayer") == "Singleplayer")
	elif filter_idx == 2:
		return data.filter(func(save): return save.get("mode", "Multiplayer") == "Multiplayer")
	return data

func apply_sorting(data: Array) -> Array:
	var sort_idx = sort_dropdown.selected
	if sort_idx == 0:
		data.sort_custom(func(a, b): return String(a.get("date", "")) > String(b.get("date", "")))
	elif sort_idx == 1:
		data.sort_custom(func(a, b): return String(a.get("date", "")) < String(b.get("date", "")))
	elif sort_idx == 2:
		data.sort_custom(func(a, b): return String(a.get("save_name", "")) < String(b.get("save_name", "")))
	elif sort_idx == 3:
		data.sort_custom(func(a, b): return String(a.get("save_name", "")) > String(b.get("save_name", "")))
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
		slot.pressed.connect(_on_save_slot_pressed.bind(metadata, slot))

# Signals functions
func _on_search_or_filter_changed(_value_passed_by_signal):
	update_saves_list()

func _on_save_slot_pressed(metadata: Dictionary, slot):
	print("Player clicked on: ", metadata["save_name"])
	current_selected_save = metadata
	_select_slot(slot)
	_update_preview(metadata)
	delete_button.disabled = false
	resume_button.disabled = false
	
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
	_clear_preview()
	delete_button.disabled = true
	resume_button.disabled = true
	
	# Refresh UI
	update_saves_list()

func _select_slot(slot) -> void:
	if current_selected_slot != null and is_instance_valid(current_selected_slot):
		current_selected_slot.set_selected(false)

	current_selected_slot = slot
	if current_selected_slot != null and is_instance_valid(current_selected_slot):
		current_selected_slot.set_selected(true)

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
	var turn_queue := _to_int_array(save_session.get("turn_queue", []))
	var curr_subturn_index := int(save_session.get("curr_subturn_index", -1))
	var current_phase := int(save_session.get("current_phase", 0))
	var mode := String(save_session.get("mode", "Multiplayer"))
	SceneManager.load_battlefield(hero1, units1, hero2, units2, turn_queue, curr_subturn_index, current_phase, mode, true)

func _to_unit_array(raw_units: Variant) -> Array[Unit]:
	var units: Array[Unit] = []
	if raw_units is not Array:
		return units

	for raw_unit in raw_units:
		if raw_unit is Unit:
			units.append(raw_unit)

	return units

func _to_int_array(raw_values: Variant) -> Array[int]:
	var values: Array[int] = []
	if raw_values is not Array:
		return values

	for raw_value in raw_values:
		values.append(int(raw_value))

	return values

func _update_preview(metadata: Dictionary) -> void:
	var file_path := String(metadata.get("file_path", ""))
	if file_path == "":
		_clear_preview()
		return

	preview_image.texture = FileManager.load_photo_texture(file_path)

func _clear_preview() -> void:
	preview_image.texture = null

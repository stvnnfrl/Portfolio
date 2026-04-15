extends Control

@onready var spell_name_label: Label = $HBoxContainer/VBoxContainer/SpellNameLabel
@onready var spell_icon_display: TextureRect = $HBoxContainer/VBoxContainer/SpellIconDisplay
@onready var count_label: Label = $HBoxContainer/VBoxContainer/TemplateCount
@onready var drawing_pad: Panel = $HBoxContainer/DrawingPad
@onready var recognizer: GestureRecognizer = $GestureRecognizer

var loaded_spells: Array[Dictionary] = []
var current_spell_index: int = 0
var current_spell_count: int = 0

func _ready() -> void:
	drawing_pad.drawing_finished.connect(_on_drawing_finished)
	$HBoxContainer/SaveButton.pressed.connect(_on_save_pressed)
	$HBoxContainer/VBoxContainer/PrevButton.pressed.connect(_on_prev_pressed)
	$HBoxContainer/VBoxContainer/NextButton.pressed.connect(_on_next_pressed)
	
	_load_spells_from_folder("res://spells/")
	_display_current_spell()

func _load_spells_from_folder(folder_path: String) -> void:
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore folders and only look for Godot scene files
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				var full_path = folder_path + "/" + file_name
				var scene = load(full_path) as PackedScene
				
				if scene:
					var instance = scene.instantiate()
					# Make sure it actually is a spell node with our properties
					if "spell_name" in instance and "texture" in instance:
						loaded_spells.append({
							"name": instance.spell_name,
							"texture": instance.texture
						})
					instance.queue_free()
					
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func _display_current_spell() -> void:
	if loaded_spells.is_empty():
		spell_name_label.text = "No spells found!"
		return
		
	var current_spell = loaded_spells[current_spell_index]
	spell_name_label.text = current_spell["name"]
	spell_icon_display.texture = current_spell["texture"]
	
	# Optional: Check the JSON to see how many templates already exist for this spell
	if recognizer.templates.has(current_spell["name"]):
		current_spell_count = recognizer.templates[current_spell["name"]].size()
	else:
		current_spell_count = 0
		
	_update_count_label()

func _on_prev_pressed() -> void:
	if loaded_spells.size() > 0:
		current_spell_index = (current_spell_index - 1 + loaded_spells.size()) % loaded_spells.size()
		_display_current_spell()

func _on_next_pressed() -> void:
	if loaded_spells.size() > 0:
		current_spell_index = (current_spell_index + 1) % loaded_spells.size()
		_display_current_spell()

func _on_drawing_finished(raw_points: PackedVector2Array) -> void:
	if loaded_spells.is_empty():
		return
		
	var current_spell_name = loaded_spells[current_spell_index]["name"]
	recognizer.add_template(current_spell_name, raw_points)
	
	current_spell_count += 1
	_update_count_label()
	
	var original_color = drawing_pad.self_modulate
	drawing_pad.self_modulate = Color.GREEN
	await get_tree().create_timer(0.2).timeout
	drawing_pad.self_modulate = original_color

func _on_save_pressed() -> void:
	recognizer.save_templates()
	print("SUCCESS: Templates saved to JSON!")

func _update_count_label() -> void:
	count_label.text = "Saved Templates: " + str(current_spell_count)

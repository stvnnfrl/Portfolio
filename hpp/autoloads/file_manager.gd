extends Node

# var SAVE_DIR = "user://saves/"
var SAVE_DIR = "res://common/saves_testing/"

func _ready() -> void:
	# We need to make sure the saves directory exists when we load the game
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)

# Loading

# Load all the saves in the SAVE_DIR using load_single_save()
func get_all_saves() -> Array:
	var saves_list: Array = []
	var dir = DirAccess.open(SAVE_DIR)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Check if it's a file and ends with .json
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var full_path = SAVE_DIR + file_name
				var save_data = load_single_save(full_path)
				
				# If the load was successful, inject the file path so the UI knows exactly what file this is
				if not save_data.is_empty():
					save_data["file_path"] = full_path
					saves_list.append(save_data)
					
			file_name = dir.get_next()
	else:
		print("Warning: Could not open save directory.")
		
	return saves_list

# Load single save
func load_single_save(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
		
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var text: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(text)
	
	if parse_result == OK:
		return json.data as Dictionary
	else:
		print("JSON Parse Error")
		return {}

# Saving

## Saves a dictionary to a specific filename in the save directory
#func save_game(save_data: Dictionary):
	#var file_path = SAVE_DIR + save_data["save_name"] + ".json"
	#var file = FileAccess.open(file_path, FileAccess.WRITE)
	#
	#if file:
		#file.store_string(JSON.stringify(save_data, "\t"))
		#file.close()
		#print("Successfully saved to: ", file_path)

# Delete

func delete_save(file_path: String) -> bool:
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err == OK:
			print("Successfully deleted save: ", file_path)
			return true
		else:
			print("Error deleting save file. Error code: ", err)
			return false
	return false

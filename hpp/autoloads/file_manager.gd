extends Node

const SAVE_DIR := "user://saved_games/"
const TEMP_SAVE_PATH := SAVE_DIR + "temp_save.json"

func _ready() -> void:
	_ensure_save_dir()


func _ensure_save_dir() -> void:
	if DirAccess.dir_exists_absolute(SAVE_DIR):
		return

	DirAccess.make_dir_absolute(SAVE_DIR)


func get_all_saves() -> Array:
	var saves_list: Array = []
	_ensure_save_dir()
	var dir = DirAccess.open(SAVE_DIR)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Check if it's a file and ends with .json
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var full_path = SAVE_DIR + file_name
				var save_data = load_single_save(full_path)
				
				if not save_data.is_empty():
					save_data["file_path"] = full_path
					saves_list.append(save_data)
					
			file_name = dir.get_next()
	else:
		print("Warning: Could not open save directory.")
		
	return saves_list


func load_single_save(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
		
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}

	var text: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(text)
	
	if parse_result != OK:
		print("JSON Parse Error: ", file_path)
		return {}

	var parsed_data: Variant = json.data
	if not _is_loadable_save_data(parsed_data):
		print("Invalid save data: ", file_path)
		return {}

	var save_data := parsed_data as Dictionary
	if not save_data.has("save_name"):
		save_data["save_name"] = file_path.get_file().get_basename()

	return save_data


func save_game(save_data: Dictionary, file_name: String = "") -> bool:
	_ensure_save_dir()

	if not _is_loadable_save_data(save_data):
		push_warning("Refusing to save invalid game state.")
		return false

	var target_file_name := _build_target_file_name(file_name)
	var target_path := SAVE_DIR + target_file_name
	var save_json := JSON.stringify(save_data, "\t")

	for attempt in range(2):
		var file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
		if file == null:
			continue

		file.store_string(save_json)
		file.close()

		if FileAccess.file_exists(target_path):
			DirAccess.remove_absolute(target_path)

		var rename_result := DirAccess.rename_absolute(TEMP_SAVE_PATH, target_path)
		if rename_result == OK:
			print("Successfully saved to: ", target_path)
			return true

		if FileAccess.file_exists(TEMP_SAVE_PATH):
			DirAccess.remove_absolute(TEMP_SAVE_PATH)

	return false


func save_exists(file_name: String) -> bool:
	var target_path := get_save_path(file_name)
	return FileAccess.file_exists(target_path)


func get_save_path(file_name: String) -> String:
	return SAVE_DIR + _build_target_file_name(file_name)


func _build_target_file_name(file_name: String) -> String:
	var trimmed_name := file_name.strip_edges()
	if trimmed_name == "":
		trimmed_name = "save_%s.json" % _build_file_timestamp()
	elif not trimmed_name.ends_with(".json"):
		trimmed_name += ".json"

	return _sanitize_file_name(trimmed_name)


func _build_file_timestamp() -> String:
	var timestamp := Time.get_datetime_string_from_system().replace("T", "_")
	timestamp = timestamp.replace(":", "-")
	return "%s_%s" % [timestamp, str(Time.get_ticks_msec())]


func _sanitize_file_name(file_name: String) -> String:
	return file_name.replace("/", "_").replace("\\", "_").replace(":", "-")


func _is_loadable_save_data(raw_data: Variant) -> bool:
	if raw_data is not Dictionary:
		return false

	var data: Dictionary = raw_data
	return data.get("battlefield", null) is Dictionary

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

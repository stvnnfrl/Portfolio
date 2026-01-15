extends Node

const SETTINGS_PATH := "user://settings.cfg" # macOS: ~/Library/Application Support/Godot/app_userdata/hpp/settings.cfg
const RESOLUTION_PRESETS := [
	"1280x720",
	"1600x900",
	"1920x1080",
	"2560x1440"
]

const DEFAULT_SETTINGS := {
	"display": {
		"window_mode": "windowed",
		"resolution": "1920x1080",
		"vsync": true
	},
	"audio": {
		"master_volume": 0.5,
		"music_volume": 1.0,
		"sfx_volume": 1.0
	},
	"accessibility": {
		"reduce_motion": false,
		"high_contrast_grid": false
	}
}

var settings: Dictionary = {}


func _ready() -> void:
	load_settings()
	apply_settings()


func get_settings_copy() -> Dictionary:
	return _deep_copy(settings)


func replace_settings(new_settings: Dictionary) -> void:
	settings = _merge_with_defaults(new_settings)


func load_settings() -> void:
	settings = _deep_copy(DEFAULT_SETTINGS)

	var config := ConfigFile.new()
	var load_result: int = config.load(SETTINGS_PATH)
	if load_result != OK:
		save_settings()
		return

	for section_name: String in DEFAULT_SETTINGS.keys():
		var section_defaults: Dictionary = DEFAULT_SETTINGS[section_name]
		var section_state: Dictionary = settings[section_name]
		for key_name: String in section_defaults.keys():
			if config.has_section_key(section_name, key_name):
				section_state[key_name] = config.get_value(section_name, key_name, section_defaults[key_name])
		settings[section_name] = section_state

	settings = _merge_with_defaults(settings)


func save_settings() -> bool:
	settings = _merge_with_defaults(settings)

	var config := ConfigFile.new()
	for section_name: String in settings.keys():
		var section_values: Dictionary = settings[section_name]
		for key_name: String in section_values.keys():
			config.set_value(section_name, key_name, section_values[key_name])

	return config.save(SETTINGS_PATH) == OK


func apply_settings() -> void:
	_apply_display_settings()
	_apply_audio_settings()


func _apply_display_settings() -> void:
	if OS.has_feature("editor"):
		return

	var display_settings: Dictionary = settings["display"]
	var window_mode: String = str(display_settings["window_mode"])
	var resolution: Vector2i = _parse_resolution(str(display_settings["resolution"]))
	var use_vsync: bool = bool(display_settings["vsync"])

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if use_vsync else DisplayServer.VSYNC_DISABLED
	)

	match window_mode:
		"fullscreen":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(resolution)


func _apply_audio_settings() -> void:
	var audio_settings: Dictionary = settings["audio"]
	_set_bus_volume("Master", float(audio_settings["master_volume"]))
	_set_bus_volume("Music", float(audio_settings["music_volume"]))
	_set_bus_volume("SFX", float(audio_settings["sfx_volume"]))


func _set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return

	var volume: float = clampf(linear_value, 0.0, 1.0)
	var db_value: float = -80.0 if is_zero_approx(volume) else linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db_value)


func _parse_resolution(value: String) -> Vector2i:
	var parts: PackedStringArray = value.split("x")
	if parts.size() != 2:
		return Vector2i(1600, 900)

	var width: int = int(parts[0])
	var height: int = int(parts[1])
	if width <= 0 or height <= 0:
		return Vector2i(1600, 900)
	return Vector2i(width, height)


func _merge_with_defaults(candidate: Dictionary) -> Dictionary:
	var merged: Dictionary = _deep_copy(DEFAULT_SETTINGS)

	for section_name: String in merged.keys():
		var merged_section: Dictionary = merged[section_name]
		var candidate_section: Dictionary = candidate.get(section_name, {})
		for key_name: String in merged_section.keys():
			if candidate_section.has(key_name):
				merged_section[key_name] = candidate_section[key_name]
		merged[section_name] = merged_section

	var display_settings: Dictionary = merged["display"]
	var resolution_name: String = str(display_settings["resolution"])
	if not RESOLUTION_PRESETS.has(resolution_name):
		display_settings["resolution"] = str(DEFAULT_SETTINGS["display"]["resolution"])
	if not ["windowed", "fullscreen"].has(str(display_settings["window_mode"])):
		display_settings["window_mode"] = str(DEFAULT_SETTINGS["display"]["window_mode"])
	display_settings["vsync"] = bool(DEFAULT_SETTINGS["display"]["vsync"])
	merged["display"] = display_settings

	var audio_settings: Dictionary = merged["audio"]
	audio_settings["master_volume"] = clampf(float(audio_settings["master_volume"]), 0.0, 1.0)
	audio_settings["music_volume"] = float(DEFAULT_SETTINGS["audio"]["music_volume"])
	audio_settings["sfx_volume"] = float(DEFAULT_SETTINGS["audio"]["sfx_volume"])
	merged["audio"] = audio_settings

	var accessibility_settings: Dictionary = merged["accessibility"]
	accessibility_settings["reduce_motion"] = bool(DEFAULT_SETTINGS["accessibility"]["reduce_motion"])
	accessibility_settings["high_contrast_grid"] = bool(DEFAULT_SETTINGS["accessibility"]["high_contrast_grid"])
	merged["accessibility"] = accessibility_settings

	return merged


func _deep_copy(source: Dictionary) -> Dictionary:
	var duplicate_dict: Dictionary = {}
	for key: Variant in source.keys():
		var value: Variant = source[key]
		if value is Dictionary:
			duplicate_dict[key] = _deep_copy(value)
		else:
			duplicate_dict[key] = value
	return duplicate_dict

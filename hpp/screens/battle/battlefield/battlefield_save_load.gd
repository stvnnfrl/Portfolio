extends Node2D
class_name BattlefieldSaveLoad

const UNIT_SCENE_DIR := "res://army/units/"
const DEFAULT_MODE := "Multiplayer"
const DEFAULT_MOVING_PHASE := 0
const EMPTY_HERO_DATA := {}
const LEGACY_UNIT_NAME_MAP := {
	"Pawn_V2": "pawn",
	"Knight": "knight",
	"Bishop": "bishop",
	"Queen": "queen",
	"Lich": "lich",
	"Soul Well": "soul_well",
	"Spectral Rider": "spectral_rider",
	"Minelayer": "mine_layer",
}

@onready var battlefield_manager = $BattlefieldManager
@onready var game_menu = $UILayer/GameMenu

var _mode: String = DEFAULT_MODE
var _turn_queue: Array[int] = []
var _curr_subturn_index: int = -1
var _current_phase: int = DEFAULT_MOVING_PHASE

# Vince added for init
var hero_1 : Hero
var hero_2 : Hero
var army_1 : Array[Unit] = []
var army_2 : Array[Unit] = []


func init(
	hero1: Hero,
	units1: Array[Unit],
	hero2: Hero,
	units2: Array[Unit],
	turn_queue: Array[int] = [],
	curr_subturn_index: int = -1,
	current_phase: int = DEFAULT_MOVING_PHASE,
	mode: String = DEFAULT_MODE
) -> void:
	# Vince added for init
	hero_1 = hero1
	hero_2 = hero2
	army_1 = units1
	army_2 = units2
	_turn_queue = turn_queue
	_curr_subturn_index = curr_subturn_index
	_current_phase = current_phase
	_mode = mode
	

func _ready() -> void:
	_connect_game_menu()
	battlefield_manager.setup_battlefield(hero_1, army_1, hero_2, army_2, _turn_queue, _curr_subturn_index, _current_phase)

func _connect_game_menu() -> void:
	if game_menu == null:
		return
	if not game_menu.save_requested.is_connected(_on_save_requested):
		game_menu.save_requested.connect(_on_save_requested)
	if not game_menu.quit_to_menu.is_connected(_on_quit_to_menu):
		game_menu.quit_to_menu.connect(_on_quit_to_menu)

func _on_save_requested(file_name: String) -> void:
	var save_name := file_name.strip_edges()
	var save_data := build_save_data(save_name, _mode, battlefield_manager)
	if FileManager.save_game(save_data, save_name):
		await _save_screenshot(save_name)
		print("[Battlefield] Saved game: ", save_name)
	else:
		push_warning("[Battlefield] Failed to save current game state.")

func _on_quit_to_menu() -> void:
	get_tree().paused = false
	SceneManager.load_main_menu()

func _save_screenshot(file_name: String) -> void:
	if game_menu != null:
		game_menu.visible = false

	await RenderingServer.frame_post_draw

	var image := get_viewport().get_texture().get_image()
	if image != null and not image.is_empty():
		image.resize(320, 180, Image.INTERPOLATE_LANCZOS)
		FileManager.save_photo(image, file_name)

	if game_menu != null:
		game_menu.visible = true

static func extract_battlefield_state(save_data: Dictionary) -> Dictionary:
	var battlefield: Dictionary = {}
	var raw_battlefield: Variant = save_data.get("battlefield", {})
	if raw_battlefield is Dictionary:
		battlefield = raw_battlefield

	var units1: Array = _unit_states(battlefield.get("units1", []), 1)
	var units2: Array = _unit_states(battlefield.get("units2", []), 2)
	if units1.is_empty() and units2.is_empty():
		var all_units: Array = _unit_states(battlefield.get("units", []))
		for unit_state in all_units:
			if int(unit_state.get("army_id", 1)) == 1:
				units1.append(unit_state)
			else:
				units2.append(unit_state)

	return {
		"hero1": EMPTY_HERO_DATA,
		"units1": units1,
		"hero2": EMPTY_HERO_DATA,
		"units2": units2,
		"turn_queue": _int_values(battlefield.get("turn_queue", [])),
		"curr_subturn_index": int(battlefield.get("curr_subturn_index", -1)),
		"current_phase": int(battlefield.get("current_phase", DEFAULT_MOVING_PHASE)),
		"mode": String(save_data.get("mode", DEFAULT_MODE)),
	}

static func build_save_data(save_name: String, mode: String, manager) -> Dictionary:
	return {
		"save_name": save_name,
		"date": Time.get_datetime_string_from_system(),
		"mode": mode if mode != "" else DEFAULT_MODE,
		"battlefield": capture_battlefield_state(manager),
	}

static func capture_battlefield_state(manager) -> Dictionary:
	var all_units: Array = []
	var unit_index_by_instance: Dictionary = {}
	_append_serialized_units(manager.army_1, all_units, unit_index_by_instance)
	_append_serialized_units(manager.army_2, all_units, unit_index_by_instance)

	var turn_queue: Array = []
	for unit in manager.turn_queue:
		if unit_index_by_instance.has(unit):
			turn_queue.append(unit_index_by_instance[unit])

	return {
		"hero1": EMPTY_HERO_DATA,
		"units1": _serialize_units(manager.army_1, 1),
		"hero2": EMPTY_HERO_DATA,
		"units2": _serialize_units(manager.army_2, 2),
		"turn_queue": turn_queue,
		"curr_subturn_index": manager.curr_subturn_index,
		"current_phase": int(manager.current_phase),
	}

static func resolve_save_session(save_data: Dictionary) -> Dictionary:
	var state: Dictionary = extract_battlefield_state(save_data)
	var hero1: Hero = null
	var hero2: Hero = null
	var units1: Array = _instantiate_units(state.get("units1", []))
	var units2: Array = _instantiate_units(state.get("units2", []))
	return {
		"hero1": hero1,
		"hero2": hero2,
		"units1": units1,
		"units2": units2,
		"turn_queue": state.get("turn_queue", []),
		"curr_subturn_index": state.get("curr_subturn_index", -1),
		"current_phase": state.get("current_phase", DEFAULT_MOVING_PHASE),
		"mode": state.get("mode", DEFAULT_MODE),
	}

static func _serialize_units(units: Array, army_id: int) -> Array:
	var serialized: Array = []
	for unit in units:
		if not is_instance_valid(unit):
			continue
		var unit_name: String = String(unit.unit_name)
		if unit_name == "":
			continue
		serialized.append({
			"unit_name": unit_name,
			"army_id": army_id,
			"health": unit.health if unit.health > 0 else unit.max_health,
			"cubic_pos": _cubic_to_dict(unit.cubic_pos),
		})
	return serialized

static func _append_serialized_units(units: Array, serialized: Array, unit_index_by_instance: Dictionary) -> void:
	for unit in units:
		if not is_instance_valid(unit):
			continue
		var unit_name: String = String(unit.unit_name)
		if unit_name == "":
			continue
		unit_index_by_instance[unit] = serialized.size()
		serialized.append({
			"unit_name": unit_name,
			"army_id": unit.army_id,
			"health": unit.health,
			"cubic_pos": _cubic_to_dict(unit.cubic_pos),
		})

static func _instantiate_units(raw_units: Variant) -> Array:
	var units: Array = []
	for unit_state in _unit_states(raw_units):
		var unit_instance: Unit = _instantiate_unit(unit_state)
		if unit_instance != null:
			units.append(unit_instance)
	return units

static func _instantiate_unit(unit_state: Dictionary) -> Unit:
	var unit_name := String(unit_state.get("unit_name", ""))
	var scene_path := ""
	if unit_name != "":
		if LEGACY_UNIT_NAME_MAP.has(unit_name):
			unit_name = LEGACY_UNIT_NAME_MAP[unit_name]
		scene_path = UNIT_SCENE_DIR + unit_name + ".tscn"
	if scene_path == "":
		scene_path = String(unit_state.get("scene_path", ""))
	if scene_path.begins_with("res://army/test_units/"):
		var moved_scene_path := UNIT_SCENE_DIR + scene_path.get_file()
		if ResourceLoader.exists(moved_scene_path):
			scene_path = moved_scene_path
	if scene_path == "":
		return null

	var unit_scene: PackedScene = load(scene_path) as PackedScene
	if unit_scene == null:
		push_warning("[BattlefieldSaveLoad] Could not load unit scene: " + scene_path)
		return null

	var unit_instance: Unit = unit_scene.instantiate() as Unit
	if unit_instance == null:
		return null

	unit_instance.set_meta("source_scene_path", scene_path)
	unit_instance.cubic_pos = _dict_to_cubic(unit_state.get("cubic_pos", {}))
	unit_instance.army_id = int(unit_state.get("army_id", 1))
	unit_instance.health = int(unit_state.get("health", unit_instance.max_health))
	return unit_instance

static func _unit_states(raw_units: Variant, default_army_id: int = -1) -> Array:
	var unit_states: Array = []
	if raw_units is not Array:
		return unit_states

	for raw_unit in raw_units:
		if raw_unit is not Dictionary:
			continue
		var unit_state := raw_unit as Dictionary
		var unit_name := String(unit_state.get("unit_name", ""))
		var scene_path := String(unit_state.get("scene_path", ""))
		if unit_name == "" and scene_path == "":
			continue
		unit_states.append({
			"unit_name": unit_name,
			"scene_path": scene_path,
			"army_id": int(unit_state.get("army_id", default_army_id if default_army_id != -1 else 1)),
			"health": int(unit_state.get("health", 1)),
			"cubic_pos": _cubic_to_dict(_dict_to_cubic(unit_state.get("cubic_pos", {}))),
		})

	return unit_states

static func _int_values(raw_array: Variant) -> Array:
	var values: Array = []
	if raw_array is not Array:
		return values
	for value in raw_array:
		values.append(int(value))
	return values

static func _dict_to_cubic(raw_coords: Variant) -> Vector3i:
	if raw_coords is not Dictionary:
		return Vector3i.ZERO
	return Vector3i(int(raw_coords.get("x", 0)), int(raw_coords.get("y", 0)), int(raw_coords.get("z", 0)))

static func _cubic_to_dict(coords: Vector3i) -> Dictionary:
	return {"x": coords.x, "y": coords.y, "z": coords.z}

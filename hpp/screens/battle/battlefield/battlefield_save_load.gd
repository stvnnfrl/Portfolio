extends Node2D
class_name BattlefieldSaveLoad

const UNIT_SCENE_DIR := "res://army/units/"
const DEFAULT_MODE := "Multiplayer"
const DEFAULT_MOVING_PHASE := 0
const RESTORE_META := "battlefield_restore_state"
const EMPTY_HERO_DATA := {}

@onready var battlefield_manager = $BattlefieldManager
@onready var game_menu = $UILayer/GameMenu

var _mode: String = DEFAULT_MODE
var _pending_battlefield_state: Dictionary = {}
var _restore_nodes: Array = []

func init(hero1: Hero, units1: Array[Unit], hero2: Hero, units2: Array[Unit]) -> void:
	_restore_nodes = [hero1, hero2] + units1 + units2
	_pending_battlefield_state = build_runtime_state(hero1, units1, hero2, units2)
	_apply_battlefield_metadata(_pending_battlefield_state)

func _ready() -> void:
	_connect_game_menu()
	var restore_state := extract_restore_state(_restore_nodes)
	if not restore_state.is_empty():
		_pending_battlefield_state = restore_state
		_apply_battlefield_metadata(restore_state)
	if not _pending_battlefield_state.is_empty():
		call_deferred("_apply_pending_battlefield_state")

func _connect_game_menu() -> void:
	if game_menu == null:
		return
	if not game_menu.save_requested.is_connected(_on_save_requested):
		game_menu.save_requested.connect(_on_save_requested)
	if not game_menu.quit_to_menu.is_connected(_on_quit_to_menu):
		game_menu.quit_to_menu.connect(_on_quit_to_menu)

func _apply_pending_battlefield_state() -> void:
	apply_to_manager(battlefield_manager, _pending_battlefield_state)

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

func _apply_battlefield_metadata(battlefield_state: Dictionary) -> void:
	_mode = String(battlefield_state.get("mode", DEFAULT_MODE))

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

static func build_runtime_state(hero1, units1: Array, hero2, units2: Array) -> Dictionary:
	return {
		"hero1": EMPTY_HERO_DATA,
		"units1": _serialize_units(units1, 1),
		"hero2": EMPTY_HERO_DATA,
		"units2": _serialize_units(units2, 2),
		"turn_queue": [],
		"curr_subturn_index": -1,
		"current_phase": DEFAULT_MOVING_PHASE,
		"mode": DEFAULT_MODE,
	}

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

static func apply_to_manager(manager, battlefield_state: Dictionary) -> void:
	var state: Dictionary = extract_battlefield_state({"battlefield": battlefield_state})
	_reset_manager(manager)

	var all_unit_states: Array = []
	all_unit_states.append_array(state.get("units1", []))
	all_unit_states.append_array(state.get("units2", []))
	var spawned_units: Array = []
	for unit_state in all_unit_states:
		var unit_instance: Unit = _instantiate_unit(unit_state)
		if unit_instance == null:
			continue
		_add_unit_to_manager(manager, unit_instance)
		spawned_units.append(unit_instance)

	_restore_turn_state(manager, spawned_units, state)

static func resolve_save_session(save_data: Dictionary) -> Dictionary:
	var state: Dictionary = extract_battlefield_state(save_data)
	var hero1: Hero = null
	var hero2: Hero = null
	var units1: Array = _instantiate_units(state.get("units1", []))
	var units2: Array = _instantiate_units(state.get("units2", []))
	_attach_restore_state([hero1, hero2] + units1 + units2, state)
	return {"hero1": hero1, "hero2": hero2, "units1": units1, "units2": units2}

static func extract_restore_state(nodes: Array) -> Dictionary:
	for node in nodes:
		if node != null and node.has_meta(RESTORE_META):
			return node.get_meta(RESTORE_META)
	return {}

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

static func _reset_manager(manager) -> void:
	manager._clear_highlights()
	manager.active_reachable_hexes.clear()
	manager.grid.board_state.clear()
	manager.turn_queue.clear()
	manager.army_1.clear()
	manager.army_2.clear()
	manager.active_unit = null
	manager.curr_subturn_index = -1
	manager.current_phase = manager.SubTurnPhase.MOVING
	for child in manager.units_layer.get_children():
		child.queue_free()

static func _add_unit_to_manager(manager, unit_instance: Unit) -> void:
	var saved_health := unit_instance.health
	manager.units_layer.add_child(unit_instance)
	unit_instance.health = saved_health
	if unit_instance.health_bar:
		unit_instance.health_bar.max_value = unit_instance.max_health
		unit_instance.health_bar.value = unit_instance.health
	unit_instance.position = manager.grid.cubic.cubic_to_pos2D(unit_instance.cubic_pos)
	manager._set_normal_color(unit_instance)
	manager.grid.board_state[unit_instance.cubic_pos] = unit_instance
	if unit_instance.army_id == 1:
		manager.army_1.append(unit_instance)
	else:
		manager.army_2.append(unit_instance)

static func _restore_turn_state(manager, spawned_units: Array, state: Dictionary) -> void:
	var turn_queue: Array = _int_values(state.get("turn_queue", []))
	if turn_queue.is_empty():
		manager._init_turn_queue()
		manager._start_next_sub_turn()
		return

	for unit_index in turn_queue:
		if unit_index >= 0 and unit_index < spawned_units.size():
			manager.turn_queue.append(spawned_units[unit_index])
	for unit in spawned_units:
		if not manager.turn_queue.has(unit):
			manager.turn_queue.append(unit)

	manager.curr_subturn_index = clamp(int(state.get("curr_subturn_index", 0)), 0, manager.turn_queue.size() - 1)
	manager.current_phase = int(state.get("current_phase", DEFAULT_MOVING_PHASE))
	manager.active_unit = manager.turn_queue[manager.curr_subturn_index]
	manager._activate_unit_color()
	if manager.current_phase == manager.SubTurnPhase.MOVING:
		manager._draw_reachable_hexes()

static func _attach_restore_state(nodes: Array, battlefield_state: Dictionary) -> void:
	for node in nodes:
		if node != null:
			node.set_meta(RESTORE_META, battlefield_state)
			return

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

static func _unit_scene_path(unit: Unit) -> String:
	if unit.has_meta("source_scene_path"):
		var meta_path := String(unit.get_meta("source_scene_path"))
		if meta_path != "":
			return meta_path
	if unit.scene_file_path != "":
		return unit.scene_file_path
	return ""

static func _dict_to_cubic(raw_coords: Variant) -> Vector3i:
	if raw_coords is not Dictionary:
		return Vector3i.ZERO
	return Vector3i(int(raw_coords.get("x", 0)), int(raw_coords.get("y", 0)), int(raw_coords.get("z", 0)))

static func _cubic_to_dict(coords: Vector3i) -> Dictionary:
	return {"x": coords.x, "y": coords.y, "z": coords.z}

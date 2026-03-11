extends MarginContainer

signal back_requested

const STATUS_COLOR_INFO := Color("7b5b2e")
const STATUS_COLOR_DIRTY := Color("9a6419")
const STATUS_COLOR_OK := Color("4c6b2f")
const STATUS_COLOR_ERROR := Color("a03d2f")

@onready var window_mode_option: OptionButton = $BodyCenter/Body/ContentRow/Sections/DisplayPanel/DisplayBox/WindowModeRow/WindowModeOption
@onready var resolution_option: OptionButton = $BodyCenter/Body/ContentRow/Sections/DisplayPanel/DisplayBox/ResolutionRow/ResolutionOption
@onready var master_slider: HSlider = $BodyCenter/Body/ContentRow/Sections/AudioPanel/AudioBox/MasterWrapper/MasterSlider
@onready var master_value_label: Label = $BodyCenter/Body/ContentRow/Sections/AudioPanel/AudioBox/MasterWrapper/MasterHeader/MasterValue
@onready var summary_label: Label = $BodyCenter/Body/ContentRow/SummaryPanel/SummaryBox/SummaryLabel
@onready var status_label: Label = $BodyCenter/Body/FooterPanel/FooterBox/StatusLabel

var _pending_settings: Dictionary = {}
var _is_loading: bool = false
var _dirty: bool = false


func _ready() -> void:
	refresh_from_saved_settings(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_node_ready() and visible:
		refresh_from_saved_settings()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func refresh_from_saved_settings(show_loaded_message: bool = true) -> void:
	_pending_settings = SettingsManager.get_settings_copy()
	_is_loading = true

	var display_settings: Dictionary = _pending_settings["display"]
	var audio_settings: Dictionary = _pending_settings["audio"]

	_select_option(window_mode_option, _window_mode_to_label(str(display_settings["window_mode"])))
	_select_option(resolution_option, str(display_settings["resolution"]))
	_assign_slider(master_slider, float(audio_settings["master_volume"]))

	_is_loading = false
	_dirty = false
	_refresh_summary()

	if show_loaded_message:
		_set_status("Loaded saved settings.", STATUS_COLOR_INFO)
	else:
		_set_status("Adjust values and press Apply to save them.", STATUS_COLOR_INFO)


func _on_window_mode_changed(index: int) -> void:
	if _is_loading:
		return

	_pending_settings["display"]["window_mode"] = window_mode_option.get_item_text(index).to_lower()
	_mark_dirty()


func _on_resolution_changed(index: int) -> void:
	if _is_loading:
		return

	_pending_settings["display"]["resolution"] = resolution_option.get_item_text(index)
	_mark_dirty()


func _on_master_volume_changed(value: float) -> void:
	if _is_loading:
		return

	_pending_settings["audio"]["master_volume"] = value
	_update_master_value(value)
	_mark_dirty()


func _on_apply_button_pressed() -> void:
	SettingsManager.replace_settings(_pending_settings)
	var save_ok: bool = SettingsManager.save_settings()
	SettingsManager.apply_settings()

	_pending_settings = SettingsManager.get_settings_copy()
	_dirty = false
	_refresh_summary()

	if save_ok:
		_set_status("Settings saved and applied.", STATUS_COLOR_OK)
	else:
		_set_status("Settings applied in memory, but saving to disk failed.", STATUS_COLOR_ERROR)


func _on_reset_button_pressed() -> void:
	refresh_from_saved_settings(false)
	_set_status("Reverted to the last saved setting.", STATUS_COLOR_INFO)


func _on_back_button_pressed() -> void:
	back_requested.emit()


func _select_option(option_button: OptionButton, text_value: String) -> void:
	for index: int in range(option_button.item_count):
		if option_button.get_item_text(index) == text_value:
			option_button.select(index)
			return
	option_button.select(0)


func _assign_slider(slider: HSlider, value: float) -> void:
	slider.value = value
	_update_master_value(value)


func _update_master_value(value: float) -> void:
	master_value_label.text = "%d%%" % int(round(value * 100.0))


func _window_mode_to_label(mode_name: String) -> String:
	if mode_name == "fullscreen":
		return "Fullscreen"
	return "Windowed"


func _mark_dirty() -> void:
	_dirty = true
	_refresh_summary()
	_set_status("Unsaved changes. Press Apply to save them.", STATUS_COLOR_DIRTY)


func _refresh_summary() -> void:
	var display_settings: Dictionary = _pending_settings["display"]
	var audio_settings: Dictionary = _pending_settings["audio"]

	summary_label.text = "\n".join([
		"Display",
		"Mode: %s" % _window_mode_to_label(str(display_settings["window_mode"])),
		"Resolution: %s" % str(display_settings["resolution"]),
		"",
		"Audio",
		"Master: %d%%" % int(round(float(audio_settings["master_volume"]) * 100.0)),
		"",
		"State: %s" % ("Pending/Changed" if _dirty else "Loaded/Saved")
	])


func _set_status(message: String, color_value: Color) -> void:
	status_label.text = message
	status_label.add_theme_color_override("font_color", color_value)

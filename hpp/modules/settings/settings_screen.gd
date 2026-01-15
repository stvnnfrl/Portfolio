extends MarginContainer

signal back_requested

const FONT_PATH := "res://shared_assets/fonts/Excalifont-Regular.woff2"

var _window_mode_option: OptionButton
var _resolution_option: OptionButton

var _master_slider: HSlider

var _status_label: Label
var _summary_label: Label

var _pending_settings: Dictionary = {}
var _is_loading: bool = false
var _dirty: bool = false


func _ready() -> void:
	theme = _create_theme()
	_build_layout()
	refresh_from_saved_settings()
	_set_status("Adjust values and press Apply to save them.", Color("7b5b2e"))


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func refresh_from_saved_settings() -> void:
	_pending_settings = SettingsManager.get_settings_copy()
	if _window_mode_option == null:
		return
	_load_controls_from_pending()
	_set_status("Loaded saved settings.", Color("7b5b2e"))


func _create_theme() -> Theme:
	var built_theme := Theme.new()
	var font_resource: Resource = load(FONT_PATH)
	if font_resource is Font:
		built_theme.default_font = font_resource
	built_theme.default_font_size = 22
	return built_theme


func _build_layout() -> void:
	for child: Node in get_children():
		child.queue_free()

	add_theme_constant_override("margin_left", 36)
	add_theme_constant_override("margin_top", 52)
	add_theme_constant_override("margin_right", 36)
	add_theme_constant_override("margin_bottom", 24)

	var page := VBoxContainer.new()
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 14)
	add_child(page)

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 3)
	page.add_child(header)

	var title := Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color("23180d"))
	title.add_theme_color_override("font_outline_color", Color("e7d7b7"))
	title.add_theme_constant_override("outline_size", 2)
	header.add_child(title)

	var body_scroll := ScrollContainer.new()
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.follow_focus = true
	page.add_child(body_scroll)

	var body_center := CenterContainer.new()
	body_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.add_child(body_center)

	var body := VBoxContainer.new()
	body.custom_minimum_size = Vector2(980, 0)
	body.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	body.add_theme_constant_override("separation", 14)
	body_center.add_child(body)

	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	body.add_child(content)

	var summary_panel := _create_panel(22)
	summary_panel.custom_minimum_size = Vector2(240, 0)
	content.add_child(summary_panel)

	var summary_box := VBoxContainer.new()
	summary_box.add_theme_constant_override("separation", 12)
	summary_panel.add_child(summary_box)

	var summary_title := Label.new()
	summary_title.text = "Current Summary"
	summary_title.add_theme_font_size_override("font_size", 24)
	summary_title.add_theme_color_override("font_color", Color("2b1e12"))
	summary_box.add_child(summary_title)

	_summary_label = Label.new()
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.add_theme_font_size_override("font_size", 19)
	_summary_label.add_theme_color_override("font_color", Color("49331c"))
	summary_box.add_child(_summary_label)

	var sections := VBoxContainer.new()
	sections.custom_minimum_size = Vector2(700, 0)
	sections.add_theme_constant_override("separation", 16)
	content.add_child(sections)

	var display_box := _add_section(sections, "Display", "Window mode and resolution.")
	_window_mode_option = _create_option_button(["Windowed", "Fullscreen"])
	_window_mode_option.item_selected.connect(_on_window_mode_changed)
	_add_form_row(display_box, "Window Mode", _window_mode_option)

	_resolution_option = OptionButton.new()
	_style_picker(_resolution_option)
	for resolution_name: String in SettingsManager.RESOLUTION_PRESETS:
		_resolution_option.add_item(resolution_name)
	_resolution_option.item_selected.connect(_on_resolution_changed)
	_add_form_row(display_box, "Resolution", _resolution_option)

	var audio_box := _add_section(sections, "Audio", "")
	_master_slider = _add_slider_row(audio_box, "Master Volume", "audio", "master_volume")

	var footer := _create_panel(18)
	footer.custom_minimum_size = Vector2(980, 0)
	body.add_child(footer)

	var footer_box := VBoxContainer.new()
	footer_box.add_theme_constant_override("separation", 12)
	footer.add_child(footer_box)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.add_theme_font_size_override("font_size", 20)
	footer_box.add_child(_status_label)

	var action_row := HFlowContainer.new()
	action_row.add_theme_constant_override("h_separation", 16)
	action_row.add_theme_constant_override("v_separation", 12)
	action_row.alignment = FlowContainer.ALIGNMENT_CENTER
	footer_box.add_child(action_row)

	var apply_button := _create_button("Apply", true)
	apply_button.pressed.connect(_on_apply_pressed)
	action_row.add_child(apply_button)

	var reset_button := _create_button("Reset")
	reset_button.pressed.connect(_on_reset_pressed)
	action_row.add_child(reset_button)

	var back_button := _create_button("Back")
	back_button.pressed.connect(_on_back_pressed)
	action_row.add_child(back_button)

	var bottom_spacer := Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 12)
	body.add_child(bottom_spacer)


func _add_section(parent: VBoxContainer, title_text: String, description_text: String) -> VBoxContainer:
	var section_panel := _create_panel(20)
	parent.add_child(section_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	section_panel.add_child(box)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("2b1e12"))
	box.add_child(title)

	var description := Label.new()
	description.text = description_text
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 20)
	description.add_theme_color_override("font_color", Color("5b4327"))
	box.add_child(description)

	return box


func _add_form_row(parent: VBoxContainer, label_text: String, control: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(150, 0)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color("352414"))
	row.add_child(label)

	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)


func _add_slider_row(parent: VBoxContainer, label_text: String, section_name: String, key_name: String) -> HSlider:
	var wrapper := VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", 6)
	parent.add_child(wrapper)

	var header := HBoxContainer.new()
	wrapper.add_child(header)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color("352414"))
	header.add_child(label)

	var value_label := Label.new()
	value_label.add_theme_font_size_override("font_size", 22)
	value_label.add_theme_color_override("font_color", Color("7a4f12"))
	header.add_child(value_label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_slider(slider)
	slider.value_changed.connect(func(value: float) -> void:
		if _is_loading:
			return
		_pending_settings[section_name][key_name] = value
		value_label.text = "%d%%" % int(round(value * 100.0))
		_mark_dirty()
	)
	wrapper.add_child(slider)

	slider.set_meta("value_label", value_label)
	return slider


func _create_option_button(items: Array[String]) -> OptionButton:
	var picker := OptionButton.new()
	_style_picker(picker)
	for entry: String in items:
		picker.add_item(entry)
	return picker


func _style_picker(control: Control) -> void:
	control.custom_minimum_size = Vector2(190, 42)
	control.add_theme_font_size_override("font_size", 20)
	control.add_theme_stylebox_override("normal", _box_style(10))
	control.add_theme_stylebox_override("hover", _box_style(10, Color(0.85, 0.67, 0.34, 0.20), Color("9d7740")))
	control.add_theme_stylebox_override("pressed", _box_style(10, Color(0.55, 0.41, 0.18, 0.16)))
	control.add_theme_stylebox_override("focus", _box_style(10, Color(0.85, 0.67, 0.34, 0.12), Color("e7d7b7")))
	control.add_theme_color_override("font_color", Color("2b1e12"))

func _style_slider(slider: HSlider) -> void:
	slider.add_theme_stylebox_override("grabber_area", _line_style(Color(0.88, 0.80, 0.66, 0.55)))
	slider.add_theme_stylebox_override("grabber_area_highlight", _line_style(Color(0.92, 0.83, 0.63, 0.70)))
	slider.add_theme_icon_override("grabber", _empty_icon())
	slider.add_theme_icon_override("grabber_highlight", _empty_icon())


func _load_controls_from_pending() -> void:
	_is_loading = true

	var display_settings: Dictionary = _pending_settings["display"]
	var audio_settings: Dictionary = _pending_settings["audio"]

	_select_option(_window_mode_option, _window_mode_to_label(str(display_settings["window_mode"])))
	_select_option(_resolution_option, str(display_settings["resolution"]))

	_assign_slider(_master_slider, float(audio_settings["master_volume"]))

	_is_loading = false
	_dirty = false
	_refresh_summary()


func _assign_slider(slider: HSlider, value: float) -> void:
	slider.value = value
	var value_label: Variant = slider.get_meta("value_label", null)
	if value_label is Label:
		value_label.text = "%d%%" % int(round(value * 100.0))


func _select_option(option_button: OptionButton, text_value: String) -> void:
	for index: int in range(option_button.item_count):
		if option_button.get_item_text(index) == text_value:
			option_button.selected = index
			return
	option_button.selected = 0


func _window_mode_to_label(mode_name: String) -> String:
	match mode_name:
		"fullscreen":
			return "Fullscreen"
		_:
			return "Windowed"


func _on_window_mode_changed(index: int) -> void:
	if _is_loading:
		return

	var selection: String = _window_mode_option.get_item_text(index).to_lower()
	_pending_settings["display"]["window_mode"] = selection
	_mark_dirty()


func _on_resolution_changed(index: int) -> void:
	if _is_loading:
		return
	_pending_settings["display"]["resolution"] = _resolution_option.get_item_text(index)
	_mark_dirty()


func _mark_dirty() -> void:
	_dirty = true
	_refresh_summary()
	_set_status("Unsaved changes. Press Apply to save them.", Color("9a6419"))


func _refresh_summary() -> void:
	var display_settings: Dictionary = _pending_settings["display"]
	var audio_settings: Dictionary = _pending_settings["audio"]

	_summary_label.text = "\n".join([
		"Display",
		"Mode: %s" % _window_mode_to_label(str(display_settings["window_mode"])),
		"Resolution: %s" % str(display_settings["resolution"]),
		"",
		"Audio",
		"Master: %d%%" % int(round(float(audio_settings["master_volume"]) * 100.0)),
		"",
		"State: %s" % ("Pending/Changed" if _dirty else "Loaded/Saved")
	])


func _on_apply_pressed() -> void:
	SettingsManager.replace_settings(_pending_settings)
	var save_ok: bool = SettingsManager.save_settings()
	SettingsManager.apply_settings()
	_pending_settings = SettingsManager.get_settings_copy()
	_dirty = false
	_refresh_summary()

	if save_ok:
		_set_status("Settings saved and applied.", Color("4c6b2f"))
	else:
		_set_status("Settings applied in memory, but saving to disk failed.", Color("a03d2f"))


func _on_reset_pressed() -> void:
	_pending_settings = SettingsManager.get_settings_copy()
	_load_controls_from_pending()
	_set_status("Reverted to the last saved setting.", Color("7b5b2e"))


func _on_back_pressed() -> void:
	back_requested.emit()


func _set_status(message: String, color_value: Color) -> void:
	_status_label.text = message
	_status_label.add_theme_color_override("font_color", color_value)


func _create_panel(padding: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box_style(padding))
	return panel


func _create_button(text_value: String, is_primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(170, 54)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color("2b1e12"))

	var accent_fill := Color(0.85, 0.67, 0.34, 0.18) if is_primary else Color(0.0, 0.0, 0.0, 0.0)
	button.add_theme_stylebox_override("normal", _box_style(12, accent_fill))
	button.add_theme_stylebox_override("hover", _box_style(12, Color(0.85, 0.67, 0.34, 0.20), Color("9d7740")))
	button.add_theme_stylebox_override("pressed", _box_style(12, Color(0.55, 0.41, 0.18, 0.16)))
	button.add_theme_stylebox_override("focus", _box_style(12, accent_fill, Color("e7d7b7")))
	button.add_theme_stylebox_override("disabled", _box_style(12, Color(0.0, 0.0, 0.0, 0.0), Color("6c5131")))
	return button


func _box_style(
	padding: int,
	fill_color: Color = Color(0.0, 0.0, 0.0, 0.0),
	border_color: Color = Color("8e6a3b")
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style


func _line_style(fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	return style


func _empty_icon() -> AtlasTexture:
	var image := Image.create(14, 14, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.58, 0.42, 0.20, 1.0))
	var texture := ImageTexture.create_from_image(image)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(0, 0, 14, 14)
	return atlas

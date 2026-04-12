extends Control
## In-game pause menu — toggles with ESC, pauses the game while open
##
## Usage:
##   1. Add this scene (game_menu.tscn) as a child of the battlefield scene
##   2. Connect signals for Resume / Save / Quit actions
##   3. ESC key automatically toggles the menu

signal resume_game
signal save_requested(file_name: String)
signal quit_to_menu

@onready var resume_btn: Button = $DimBg/CenterContainer/MenuPanel/ButtonBox/ResumeButton
@onready var save_btn: Button = $DimBg/CenterContainer/MenuPanel/ButtonBox/SaveButton
@onready var quit_btn: Button = $DimBg/CenterContainer/MenuPanel/ButtonBox/QuitButton
@onready var save_modal: Control = $SaveModal
@onready var save_name_input: LineEdit = $SaveModal/ModalDimBg/CenterContainer/ModalPanel/Content/SaveNameInput
@onready var warning_label: Label = $SaveModal/ModalDimBg/CenterContainer/ModalPanel/Content/WarningLabel
@onready var confirm_save_btn: Button = $SaveModal/ModalDimBg/CenterContainer/ModalPanel/Content/ButtonRow/ConfirmSaveButton
@onready var cancel_save_btn: Button = $SaveModal/ModalDimBg/CenterContainer/ModalPanel/Content/ButtonRow/CancelSaveButton

func _ready() -> void:
	resume_btn.pressed.connect(_on_resume_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	confirm_save_btn.pressed.connect(_on_confirm_save_pressed)
	cancel_save_btn.pressed.connect(_close_save_modal)
	save_name_input.text_changed.connect(_on_save_name_changed)
	
	# Must receive input even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Standalone test: show immediately. As battlefield child: start hidden.
	if get_parent() == get_tree().root:
		visible = true
	else:
		visible = false

	save_modal.visible = false
	warning_label.visible = false


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if save_modal.visible:
			_close_save_modal()
			get_viewport().set_input_as_handled()
			return
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if visible:
		_close_menu()
	else:
		_open_menu()


func _open_menu() -> void:
	visible = true
	get_tree().paused = true

func _close_menu() -> void:
	_close_save_modal()
	visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	_close_menu()
	print("[GameMenu] Resume to game requested")
	resume_game.emit()

func _on_save_pressed() -> void:
	print("[GameMenu] Save game requested")
	_open_save_modal()

func _on_quit_pressed() -> void:
	_close_menu()
	print("[GameMenu] Quit to main menu requested")
	quit_to_menu.emit()
	# TODO: Switch to main menu via SceneManager


func _open_save_modal() -> void:
	save_modal.visible = true
	save_name_input.grab_focus()
	_refresh_save_name_feedback()


func _close_save_modal() -> void:
	save_modal.visible = false
	save_name_input.text = ""
	warning_label.visible = false
	confirm_save_btn.text = "Save"


func _on_confirm_save_pressed() -> void:
	var trimmed_name := save_name_input.text.strip_edges()
	if trimmed_name == "":
		warning_label.text = "Please enter a save file name."
		warning_label.visible = true
		confirm_save_btn.text = "Save"
		return

	save_requested.emit(trimmed_name)
	_close_save_modal()


func _on_save_name_changed(_new_text: String) -> void:
	_refresh_save_name_feedback()


func _refresh_save_name_feedback() -> void:
	var trimmed_name := save_name_input.text.strip_edges()
	if trimmed_name == "":
		warning_label.visible = false
		confirm_save_btn.text = "Save"
		return

	if FileManager.save_exists(trimmed_name):
		warning_label.text = "A save with this name already exists. Saving will overwrite it."
		warning_label.visible = true
		confirm_save_btn.text = "Overwrite"
		return

	warning_label.visible = false
	confirm_save_btn.text = "Save"

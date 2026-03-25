extends Control
## In-game pause menu — toggles with ESC, pauses the game while open
##
## Usage:
##   1. Add this scene (game_menu.tscn) as a child of the battlefield scene
##   2. Connect signals for Resume / Save / Quit actions
##   3. ESC key automatically toggles the menu

signal resume_game
signal save_requested
signal quit_to_menu

@onready var resume_btn: Button = $DimBg/CenterContainer/MenuPanel/ButtonBox/ResumeButton
@onready var save_btn: Button = $DimBg/CenterContainer/MenuPanel/ButtonBox/SaveButton
@onready var quit_btn: Button = $DimBg/CenterContainer/MenuPanel/ButtonBox/QuitButton


func _ready() -> void:
	resume_btn.pressed.connect(_on_resume_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	# Must receive input even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Standalone test: show immediately. As battlefield child: start hidden.
	if get_parent() == get_tree().root:
		visible = true
	else:
		visible = false


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
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
	visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	_close_menu()
	print("[GameMenu] Resume to game requested")
	resume_game.emit()

func _on_save_pressed() -> void:
	print("[GameMenu] Save game requested")
	save_requested.emit()
	# TODO: Connect to DataManager for actual save

func _on_quit_pressed() -> void:
	_close_menu()
	print("[GameMenu] Quit to main menu requested")
	quit_to_menu.emit()
	# TODO: Switch to main menu via SceneManager

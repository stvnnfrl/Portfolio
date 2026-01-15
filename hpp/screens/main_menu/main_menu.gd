extends Control

@onready var main_screen : MarginContainer = $Screens/MainMenu
@onready var settings_screen : MarginContainer = $Screens/Settings
@onready var load_game_screen : MarginContainer = $Screens/LoadGame
@onready var settings_button : Button = $Screens/MainMenu/MainLayout/ButtonsCenterContainer/ButtonsVContainer/SettingsButton
@onready var exit_button : Button = $Screens/MainMenu/MainLayout/ButtonsCenterContainer/ButtonsVContainer/ExitButton

# Main functions
func _ready() -> void:
	settings_button.pressed.connect(_on_settings_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	settings_screen.connect("back_requested", Callable(self, "_on_settings_back_requested"))
	show_screen(main_screen)
	
func show_screen(target_screen: Control) -> void:
	# hide all first
	main_screen.hide()
	settings_screen.hide()
	load_game_screen.hide()
	
	# show target screen
	target_screen.show()
	if target_screen == settings_screen and settings_screen.has_method("refresh_from_saved_settings"):
		settings_screen.call("refresh_from_saved_settings")

# Button functions

func _on_start_button_pressed() -> void:
	SceneManager.load_match_setup()

func _on_load_button_pressed() -> void:
	show_screen(load_game_screen)
	

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	show_screen(main_screen)

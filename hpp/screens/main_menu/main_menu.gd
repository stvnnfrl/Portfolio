extends Control

@onready var main_screen: MarginContainer = $Screens/MainMenu
@onready var settings_screen: MarginContainer = $Screens/Settings
@onready var load_game_screen: MarginContainer = $Screens/LoadGame


func _ready() -> void:
	show_screen(main_screen)
	AudioController.play_music(AudioController.menu_music)


func show_screen(target_screen: Control) -> void:
	main_screen.hide()
	settings_screen.hide()
	load_game_screen.hide()

	target_screen.show()


func _on_start_button_pressed() -> void:
	SceneManager.load_match_setup()


func _on_load_button_pressed() -> void:
	show_screen(load_game_screen)


func _on_settings_button_pressed() -> void:
	show_screen(settings_screen)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	show_screen(main_screen)


func _on_settings_back_requested() -> void:
	show_screen(main_screen)

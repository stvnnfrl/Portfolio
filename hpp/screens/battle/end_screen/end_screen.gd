extends Control

@export var game_result_label : Label

func init(game_result : String, text_color : Color):
	game_result_label.text = game_result
	game_result_label.add_theme_color_override("font_color", text_color)

# Button functions
func _on_restart_button_pressed() -> void:
	SceneManager.load_match_setup()
	
func _on_quit_pressed() -> void:
	SceneManager.load_main_menu()

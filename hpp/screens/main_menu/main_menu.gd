extends Control

@onready var main_screen : MarginContainer = $Screens/MainMenu
@onready var settings_screen : MarginContainer = $Screens/Settings
@onready var load_game_screen : MarginContainer = $Screens/LoadGame

# Main functions
func _ready() -> void:
	show_screen(main_screen)
	
func show_screen(target_screen) -> void:
	# hide all first
	main_screen.hide()
	settings_screen.hide()
	load_game_screen.hide()
	
	# show target screen
	target_screen.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Button functions

func _on_start_button_pressed():
	SceneManager.load_match_setup()
	

func _on_load_button_pressed() -> void:
	show_screen(load_game_screen)
	

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	show_screen(main_screen)

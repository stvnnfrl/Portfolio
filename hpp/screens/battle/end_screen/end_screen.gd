extends Control

# Main functions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Button functions

func _on_restart_button_pressed() -> void:
	SceneManager.load_main_menu()

extends Control

@onready var selectionP1 = $ArmySetup/SelectionP1
@onready var selectionP2 = $ArmySetup/SelectionP2

func _on_back_pressed() -> void:
	SceneManager.load_main_menu()


func _on_start_match_pressed() -> void:
	call_deferred("_start_match")

func _start_match() -> void:
	SceneManager.load_pre_game(
		selectionP1.selected_hero, selectionP1.quantities,
		selectionP2.selected_hero, selectionP2.quantities
	)

extends Control

@onready var selectionP1 = $ArmySetup/SelectionP1
@onready var selectionP2 = $ArmySetup/SelectionP2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	SceneManager.load_main_menu()


func _on_start_match_pressed() -> void:
	call_deferred("_start_match")

func _start_match() -> void:
	SceneManager.load_pre_game(
		selectionP1.selected_hero, selectionP1.quantities,
		selectionP2.selected_hero, selectionP2.quantities
	)

extends Control

@onready var selectionP1 = $ArmySetup/SelectionP1
@onready var selectionP2 = $ArmySetup/SelectionP2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioController.play_music(AudioController.match_setup_music)


func _on_back_pressed() -> void:
	SceneManager.load_main_menu()


func _on_start_match_pressed() -> void:
	# Check if army1 and army2 has something
	if _total(selectionP1.quantities) == 0:
		return
		
	if _total(selectionP2.quantities) == 0:
		return
			
	call_deferred("_start_match")

func _start_match() -> void:
	SceneManager.load_pre_game(
		selectionP1.selected_hero, selectionP1.quantities,
		selectionP2.selected_hero, selectionP2.quantities
	)

func _total(arr: Array[int]) -> int:
	var s := 0
	for v in arr:
		s += v
	return s

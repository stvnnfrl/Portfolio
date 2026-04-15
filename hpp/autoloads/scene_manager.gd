extends Node

var main_menu_path : String = "res://screens/main_menu/main_menu.tscn"
var match_setup_path : String = "res://screens/match_setup/match_setup.tscn"
var pre_game : PackedScene = preload("res://screens/battle/pregame/pregame.tscn")
var battlefield : PackedScene = preload("res://screens/battle/battlefield/battlefield.tscn")
var end_screen : PackedScene = preload("res://screens/battle/end_screen/end_screen.tscn")


func load_main_menu():
	get_tree().change_scene_to_file(main_menu_path)

func load_match_setup():
	get_tree().change_scene_to_file(match_setup_path)

func load_pre_game(hero1: Hero, unit_counts1 : Array[int], hero2: Hero, unit_counts2: Array[int]):
	var pregame_scene = pre_game.instantiate()
	pregame_scene.init(hero1, unit_counts1, hero2, unit_counts2)
	_swap_to(pregame_scene)

func load_battlefield(
	hero1: Hero,
	units1: Array[Unit],
	hero2: Hero,
	units2: Array[Unit],
	turn_queue: Array[int] = [],
	curr_subturn_index: int = -1,
	current_phase: int = 0,
	mode: String = "Multiplayer"
):
	var battlefield_scene = battlefield.instantiate()
	battlefield_scene.init(hero1, units1, hero2, units2, turn_queue, curr_subturn_index, current_phase, mode)
	_swap_to(battlefield_scene)

func load_game_over(game_result : String, text_color : Color):
	#get_tree().change_scene_to_file(ending_screen_path)
	var end_screen_scene = end_screen.instantiate()
	end_screen_scene.init(game_result, text_color)
	_swap_to(end_screen_scene)


#func _swap_to(initialized_scene: Node) -> void:
	#var tree = get_tree()
	#tree.unload_current_scene()
	#tree.call_deferred("set_current_scene", initialized_scene)  # "tree.current_scene = pregame" doesn't seem to work here
	#tree.root.add_child(initialized_scene)
	
# TODO Temp change to make the connection work. Will need to investigate more
func _swap_to(initialized_scene: Node) -> void:
	var tree = get_tree()
	var current_scene = tree.current_scene
	tree.root.add_child(initialized_scene)
	tree.current_scene = initialized_scene
	current_scene.queue_free()

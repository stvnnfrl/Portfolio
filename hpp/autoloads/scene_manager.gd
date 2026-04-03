extends Node

var main_menu_path : String = "res://screens/main_menu/main_menu.tscn"
var match_setup_path : String = "res://screens/match_setup/match_setup.tscn"
var pre_game : PackedScene = preload("res://screens/battle/pregame/pregame.tscn")
var battlefield : PackedScene = preload("res://screens/battle/battlefield_og/battlefield.tscn")
var ending_screen_path : String = "res://screens/battle/end_screen/end_screen.tscn"

func load_main_menu():
	get_tree().change_scene_to_file(main_menu_path)

func load_match_setup():
	get_tree().change_scene_to_file(match_setup_path)

func load_pre_game(hero1: Hero, unit_counts1 : Array[int], hero2: Hero, unit_counts2: Array[int]):
	var pregame = pre_game.instantiate()
	pregame.init(hero1, unit_counts1, hero2, unit_counts2)
	
	var tree = get_tree()
	tree.unload_current_scene()
	tree.call_deferred("set_current_scene", pregame)  # "tree.current_scene = pregame" doesn't seem to work here
	tree.root.add_child(pregame)

func load_battlefield(hero1: Hero, units1: Array[Unit], hero2: Hero, units2: Array[Unit]):
	var battlefield_scene = battlefield.instantiate()
	battlefield_scene.init(hero1, units1, hero2, units2)
	
	var tree = get_tree()
	tree.unload_current_scene()
	tree.call_deferred("set_current_scene", battlefield_scene)
	tree.root.add_child(battlefield_scene)

func load_game_over():
	get_tree().change_scene_to_file(ending_screen_path)

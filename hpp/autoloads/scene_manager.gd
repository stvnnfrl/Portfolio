extends Node

var main_menu_path : String = "res://screens/main_menu/main_menu.tscn"
var match_setup_path : String = "res://screens/match_setup/match_setup.tscn"
var pre_game_path : String = "res://screens/battle/pregame/pregame.tscn"
var ending_screen_path : String = "res://screens/battle/end_screen/end_screen.tscn"

func load_main_menu():
	get_tree().change_scene_to_file(main_menu_path)

func load_match_setup():
	get_tree().change_scene_to_file(match_setup_path)

func load_pre_game():
	get_tree().change_scene_to_file(pre_game_path)

func load_game_over():
	get_tree().change_scene_to_file(ending_screen_path)
	

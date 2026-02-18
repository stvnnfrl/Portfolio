extends Control

@onready var main_menu_container : Control = $mainMenu
@onready var save_menu_container : Control = $saveMenu
@onready var load_menu_container : Control = $loadMenu

@onready var main_save_btn : Button= $mainMenu/mainMenuScreen/buttonVBoxContainer/saveButton
@onready var main_load_btn : Button = $mainMenu/mainMenuScreen/buttonVBoxContainer/loadButton
@onready var save_back_btn : Button = $saveMenu/saveMenuScreen/buttonVBoxContainer/backButton
@onready var load_back_btn : Button = $loadMenu/loadMenuScreen/buttonVBoxContainer/backButton


func _ready():

	main_save_btn.pressed.connect(_on_main_save_btn_pressed)
	main_load_btn.pressed.connect(_on_main_load_btn_pressed)

	save_back_btn.pressed.connect(_on_back_btn_pressed)
	load_back_btn.pressed.connect(_on_back_btn_pressed)

	# Set Initial State
	show_only_menu(main_menu_container)


func show_only_menu(menu_to_show: Control):
	# hide everything just to be safe.
	main_menu_container.visible = false
	save_menu_container.visible = false
	load_menu_container.visible = false

	# Then turn on main menu
	menu_to_show.visible = true

func _on_main_save_btn_pressed():
	print("Switching to Save Menu")
	show_only_menu(save_menu_container)

func _on_main_load_btn_pressed():
	print("Switching to Load Menu")
	show_only_menu(load_menu_container)

func _on_back_btn_pressed():
	print("Returning to Main Menu")
	show_only_menu(main_menu_container)

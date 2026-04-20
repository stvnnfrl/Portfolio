extends Control

@onready var icon: TextureRect = $Panel/MarginContainer/HBoxContainer/Icon
@onready var name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/Name_Label
@onready var descriptive_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/Decriptive_Label

func set_unit(unit_name: String, texture: Texture2D, desc: String) -> void:
	name_label.text = unit_name
	icon.texture = texture
	descriptive_label.text = desc
	
	

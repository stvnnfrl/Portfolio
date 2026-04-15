extends Control

signal spell_selected(spell_index: int)
signal closed

@onready var dim_bg: ColorRect = $DimBg
@onready var latch_btn: Button = $BookCenter/BookPanel/BookLayout/TopBar/LatchButton
@onready var left_page : GridContainer = $BookCenter/BookPanel/BookLayout/Pages/LeftPage
@onready var right_page: MarginContainer = $BookCenter/BookPanel/BookLayout/Pages/RightPage
@onready var spell_panels: Array = [
	left_page.get_node("Spell1Container"),
	left_page.get_node("Spell2Container"),
	left_page.get_node("Spell3Container"),
	left_page.get_node("Spell4Container")
]

var current_spells: Array[Dictionary] = []
var armed_spell_index: int = -1

func _ready() -> void:
	latch_btn.pressed.connect(close)
	dim_bg.gui_input.connect(_on_dim_bg_input)
	right_page.gesture_matched.connect(_on_gesture_matched)
	
	for i in range(spell_panels.size()):
		var panel = spell_panels[i]
		panel.gui_input.connect(_on_panel_gui_input.bind(i))
	
	# Standalone test: show immediately. As battlefield child: start hidden.
	if get_parent() == get_tree().root:
		visible = true
	else:
		visible = false


func open(hero_spells: Array[Dictionary]) -> void:
	current_spells = hero_spells
	_load_spells_into_ui()
	visible = true

func close() -> void:
	visible = false
	closed.emit()

func _on_dim_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()

func _load_spells_into_ui() -> void:
	for i in range(spell_panels.size()):
		var panel = spell_panels[i]
		var vbox = panel.get_node("VBoxContainer")
		
		var drawing_rect = vbox.get_node("SpellDrawing")
		var name_label = vbox.get_node("SpellLabel")
		var desc_label = vbox.get_node("SpellDescription")
		
		var spell_data = current_spells[i]
		name_label.text = spell_data["name"]
		desc_label.text = spell_data["description"]
		if spell_data.has("texture") and spell_data["texture"] != null:
			drawing_rect.texture = spell_data["texture"]
		else:
			drawing_rect.texture = null
		
		panel.visible = true 
			

func _on_panel_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if index < current_spells.size():
			
			# Check if the clicked spell is the one they just drew!
			if index == armed_spell_index:
				print("[SpellBook] CASTING: ", current_spells[index]["name"])
				spell_selected.emit(index)
				close()
			else:
				print("You must draw this spell's gesture first!")
			

func _on_gesture_matched(recognized_name: String) -> void:
	# Reset all panels to their normal color first
	for panel in spell_panels:
		panel.modulate = Color(1.0, 1.0, 1.0)
	armed_spell_index = -1
		
	# Check if the recognized gesture matches any of the hero's 4 spells
	for i in range(current_spells.size()):
		if current_spells[i]["name"] == recognized_name:
			
			# Highlight the matching slot (making it glow slightly yellow/gold)
			spell_panels[i].modulate = Color(1.5, 1.4, 0.8) 
			armed_spell_index = i 
			
			print("Spell Armed: ", recognized_name)
			return

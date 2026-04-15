extends Control

signal spell_selected(spell_index: int)
signal closed

@export var spell_selected_style : StyleBoxFlat

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
@onready var drawing_pad : Panel = $BookCenter/BookPanel/BookLayout/Pages/RightPage/drawingPad

var current_spells: Array[Dictionary] = []
var armed_spell_index: int = -1
var pulse_tween: Tween

func _ready() -> void:
	# connect signal from drawing controller
	right_page.gesture_matched.connect(_on_gesture_matched)
	
	# connect spell panels with their indexes
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
	
	# reset spell selection and clear the drawing pad
	_reset_all_panels()
	drawing_pad.clear_pad()
	
	right_page.set_available_spells(hero_spells)
	_load_spells_into_ui()
	visible = true

func _close() -> void:
	visible = false
	closed.emit()

func _on_dim_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close()

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
				_play_cast_animation_and_close(spell_panels[index], index)
			else:
				print("You must draw this spell's gesture first!")
			
			
func _play_cast_animation_and_close(panel: Control, index: int) -> void:
	# Stop the breathing animation so it doesn't conflict
	if pulse_tween:
		pulse_tween.kill()
		
	var cast_tween = create_tween()
	
	# Retrieve the dynamic StyleBoxFlat we applied during the highlight phase
	var active_style = panel.get_theme_stylebox("panel") as StyleBoxFlat
	
	if active_style:
		# compress
		cast_tween.tween_property(active_style, "shadow_size", 0, 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		# pop
		cast_tween.tween_property(active_style, "shadow_size", 35, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		cast_tween.parallel().tween_property(active_style, "shadow_color", Color(0.4, 1.0, 0.4, 0.7), 0.2)
	else:
		# Fallback just in case the stylebox is missing, so the UI still closes
		await get_tree().create_timer(0.2).timeout
	
	# Wait for the entire tween sequence to finish before executing game logic
	await cast_tween.finished
	
	spell_selected.emit(index)
	_close()
	

func _on_gesture_matched(recognized_name: String) -> void:
	# Reset all panels to their normal color first
	_reset_all_panels()
		
	# Check if the recognized gesture matches any of the hero's 4 spells
	for i in range(current_spells.size()):
		if current_spells[i]["name"] == recognized_name:
			armed_spell_index = i 
			_highlight_armed_panel(spell_panels[i])
			print("Spell Armed: ", recognized_name)
			return


func _reset_all_panels() -> void:
	armed_spell_index = -1
	
	# Kill the idle animation if it's running
	if pulse_tween:
		pulse_tween.kill()
		
	for panel in spell_panels:
		panel.remove_theme_stylebox_override("panel")
		panel.scale = Vector2(1.0, 1.0)
		panel.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _highlight_armed_panel(panel: Control) -> void:
	# duplicate the resource so we don't overwrite the original .tres file
	var dynamic_style = spell_selected_style.duplicate() as StyleBoxFlat
	panel.add_theme_stylebox_override("panel", dynamic_style)
	
	# animate the shadow
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(dynamic_style, "shadow_size", 20, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(dynamic_style, "shadow_size", 8, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

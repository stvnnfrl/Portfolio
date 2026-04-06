extends Control
## Spell Book UI — displays available spells from the Battlefield
##
## Usage:
##   1. Add this scene (spellbook.tscn) as a child of the battlefield scene
##   2. Call $SpellBook.open() / $SpellBook.close() from code
##   3. spell_selected signal is emitted when a spell is clicked

signal spell_selected(spell_index: int)
signal closed

# Replace with actual hero-specific data later
# Names from Spec doc section 4.1.7 mockup
var spell_data: Array[Dictionary] = [
	{"name": "Death by 1000\nPaper Cuts"},
	{"name": "Hot off the\nPress"},
	{"name": "Margin\nCollapse"},
	{"name": "Paper Airplane\nBarrage"}
]

const SPELLS_PER_SPREAD: int = 8  # Both pages combined
const SPELLS_PER_PAGE: int = 4     # 2 columns x 3 rows
const GRID_COLS: int = 2

var current_spread: int = 0
var total_spreads: int = 1

@onready var dim_bg: ColorRect = $DimBg
@onready var left_grid: GridContainer = $BookCenter/BookPanel/BookLayout/Pages/LeftPage
#@onready var right_grid: GridContainer = $BookCenter/BookPanel/BookLayout/Pages/RightPage
#@onready var page_label: Label = $BookCenter/BookPanel/BookLayout/NavBar/PageLabel
#@onready var prev_btn: Button = $BookCenter/BookPanel/BookLayout/NavBar/PrevButton
#@onready var next_btn: Button = $BookCenter/BookPanel/BookLayout/NavBar/NextButton
@onready var latch_btn: Button = $BookCenter/BookPanel/BookLayout/TopBar/LatchButton


func _ready() -> void:
	total_spreads = maxi(1, ceili(float(spell_data.size()) / SPELLS_PER_SPREAD))
	
	#prev_btn.pressed.connect(_on_prev_pressed)
	#next_btn.pressed.connect(_on_next_pressed)
	latch_btn.pressed.connect(close)
	dim_bg.gui_input.connect(_on_dim_bg_input)
	
	# Standalone test: show immediately. As battlefield child: start hidden.
	if get_parent() == get_tree().root:
		visible = true
	else:
		visible = false
	#_refresh_spells()


func open() -> void:
	current_spread = 0
	_refresh_spells()
	visible = true

func close() -> void:
	visible = false
	closed.emit()


#func _on_prev_pressed() -> void:
	#if current_spread > 0:
		#current_spread -= 1
		#_refresh_spells()
#
#func _on_next_pressed() -> void:
	#if current_spread < total_spreads - 1:
		#current_spread += 1
		#_refresh_spells()

func _on_dim_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func _refresh_spells() -> void:
	_clear_grid(left_grid)
	#_clear_grid(right_grid)
	
	var start: int = current_spread * SPELLS_PER_SPREAD
	
	for i in range(SPELLS_PER_PAGE):
		var spell_index: int = start + i
		if spell_index < spell_data.size():
			left_grid.add_child(_create_spell_slot(spell_data[spell_index], spell_index))
		else:
			left_grid.add_child(_create_empty_slot())
	
	#for i in range(SPELLS_PER_PAGE):
		#var spell_index: int = start + SPELLS_PER_PAGE + i
		#if spell_index < spell_data.size():
			#right_grid.add_child(_create_spell_slot(spell_data[spell_index], spell_index))
		#else:
			#right_grid.add_child(_create_empty_slot())
	
	#page_label.text = str(current_spread + 1) + " / " + str(total_spreads)
	#prev_btn.disabled = (current_spread == 0)
	#next_btn.disabled = (current_spread >= total_spreads - 1)


func _create_spell_slot(data: Dictionary, index: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(200, 300)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.93, 0.88)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	slot.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(vbox)
	
	# Placeholder — replace with TextureRect when spell icons are ready
	var icon_placeholder := ColorRect.new()
	icon_placeholder.custom_minimum_size = Vector2(120, 120)
	icon_placeholder.color = Color(0.65, 0.70, 0.80)
	icon_placeholder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon_placeholder)
	
	var label := Label.new()
	label.text = data["name"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	var font = load("res://screens/resources/Excalifont-Regular.woff2")
	label.add_theme_font_override("font", font)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(label)
	
	# MOUSE_FILTER_IGNORE on children ensures clicks reach slot's gui_input
	slot.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_spell_clicked(index)
	)
	
	return slot


func _create_empty_slot() -> PanelContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(120, 140)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.9, 0.88, 0.83, 0.3)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	slot.add_theme_stylebox_override("panel", style)
	
	return slot


func _clear_grid(grid: GridContainer) -> void:
	for child in grid.get_children():
		child.queue_free()


func _on_spell_clicked(index: int) -> void:
	print("[SpellBook] Selected: ", spell_data[index]["name"])
	spell_selected.emit(index)
	# TODO: Decide whether to close after selection

extends GridContainer
## Player 2 unit selection panel for Match Setup.
## Identical logic to selection_P1.gd; only node paths differ (SelectionP2).

const HERO_SCENES: Array[String] = [
	"res://army/heroes/general.tscn",
	"res://army/heroes/king.tscn",
	"res://army/heroes/samourai.tscn",
	"res://army/heroes/soul.tscn"
]

@onready var troop_labels = [$Troop1, $Troop2, $Troop3, $Troop4]
@onready var cost_labels = [$CostForTroop1, $CostForTroop2, $CostForTroop3, $CostForTroop4]
@onready var qty_labels = [
	get_node("/root/Control/ArmySetup/SelectionP2/QtyTroop1/QtyLabel"),
	get_node("/root/Control/ArmySetup/SelectionP2/QtyTroop2/QtyLabel"),
	get_node("/root/Control/ArmySetup/SelectionP2/QtyTroop3/QtyLabel"),
	get_node("/root/Control/ArmySetup/SelectionP2/QtyTroop4/QtyLabel"),
]
@onready var total_label = get_node("/root/Control/ArmySetup/SelectionP2/Total")
@onready var money_label = get_node("/root/Control/MatchSettings/CP_Count")
@onready var cp_used_label = $CP_Used
@onready var cp_remaining_label = $CP_Remaining
@onready var hero_option = $HBoxContainer/OptionButton

var quantities: Array[int] = [0, 0, 0, 0]
var costs: Array[int] = [0, 0, 0, 0]
var unit_count: int = 0
var money: int = 0

var selected_hero : Hero


#Tooltip will constantly read the Hero selected hence the 
#following 2 Arrays
var unit_scenes: Array[PackedScene] = [null, null, null, null]
var unit_data_cache: Array[Dictionary] = [ {}, {}, {}, {} ]

func _ready():
	var btn_pairs = [
		[$QtyTroop1/MinusButton, $QtyTroop1/PlusButton],
		[$QtyTroop2/MinusButton, $QtyTroop2/PlusButton],
		[$QtyTroop3/MinusButton, $QtyTroop3/PlusButton],
		[$QtyTroop4/MinusButton, $QtyTroop4/PlusButton],
	]
	for i in range(btn_pairs.size()):
		var idx = i
		btn_pairs[i][0].pressed.connect(func(): _change_qty(idx, -1))
		btn_pairs[i][1].pressed.connect(func(): _change_qty(idx, 1))
		
	_setup_dropdown_tooltips()

	hero_option.item_selected.connect(_on_hero_selected)
	money = _parse_money(money_label.text)
	_on_hero_selected(hero_option.selected)


func _on_hero_selected(index: int) -> void:
	money = _parse_money(money_label.text)
	quantities = [0, 0, 0, 0]

	if index >= HERO_SCENES.size():
		push_warning("Hero index out of range: " + str(index))
		return

	var hero_scene = load(HERO_SCENES[index])
	if hero_scene == null:
		push_warning("Could not load hero scene: " + HERO_SCENES[index])
		return

	# Free old hero if one exists
	if selected_hero:
		selected_hero.queue_free()

	# Temporarily instantiate to extract unit metadata (name, cost)
	selected_hero = hero_scene.instantiate() as Hero
	if selected_hero == null:
		push_warning("Hero scene did not return a Hero instance")
		return

	hero_option.tooltip_text = selected_hero.description
	
	#to display info
	_preload_unit_data()

	unit_count = mini(selected_hero.units.size(), 4)

	for i in range(4):
		if i < unit_count:
			var unit_instance = selected_hero.units[i].instantiate() as Unit
			troop_labels[i].text = unit_instance.unit_name
			costs[i] = unit_instance.cost
			cost_labels[i].text = str(unit_instance.cost)
			unit_instance.queue_free()
		else:
			troop_labels[i].text = "—"
			costs[i] = 0
			cost_labels[i].text = "0"

	_update_ui()

func _change_qty(index: int, delta: int) -> void:
	if index >= unit_count:
		return
	var new_qty = quantities[index] + delta
	if new_qty < 0:
		return
	if delta > 0 and costs[index] > money:
		return
	quantities[index] = new_qty
	money -= delta * costs[index]
	_update_ui()


func _update_ui() -> void:
	var total_units = 0
	var total_cost = 0
	for i in range(4):
		qty_labels[i].text = "x" + str(quantities[i])
		total_units += quantities[i]
		total_cost += quantities[i] * costs[i]
	total_label.text = "Total: " + str(total_units)
	cp_used_label.text = "CP Used: " + str(total_cost)
	cp_remaining_label.text = "CP Remaining: " + str(money)


func _parse_money(text: String) -> int:
	var parts = text.split(":")
	return int(parts[1].strip_edges())
	
	
func _setup_dropdown_tooltips() -> void:
	for i in range(hero_option.item_count):
		if i < HERO_SCENES.size():
			var hero_scene = load(HERO_SCENES[i])
			if hero_scene:
				var temp_hero = hero_scene.instantiate() as Hero
				# Set the tooltip for the specific item in the dropdown list
				hero_option.set_item_tooltip(i, temp_hero.description)
				# delete the temp hero instance
				temp_hero.queue_free()
				
# Instantiates each unit temporarily to extract name, cost,description and icon to be displayed by 
#the tooltip using  unit_data_cache and updates the UI labels.
func _preload_unit_data()->void:
	unit_count = mini(selected_hero.units.size(), 4)
	
	for i in range(4):
		if i < unit_count:
			var unit_scene: PackedScene = selected_hero.units[i]
			unit_scenes[i] = unit_scene
			
			# Instantiate temporarily to read all needed data
			var unit_instance = unit_scene.instantiate() as Unit
			troop_labels[i].text = unit_instance.unit_name
			costs[i] = unit_instance.cost
			cost_labels[i].text = str(unit_instance.cost)
			
			# Store tooltip data in cache
			unit_data_cache[i] = {
				"name": unit_instance.unit_name,
				"cost": unit_instance.cost,
				"description": unit_instance.description,
				"icon": unit_instance.icon_texture
				}
			unit_instance.queue_free()
			
		else:
			troop_labels[i].text = "—"
			costs[i] = 0
			cost_labels[i].text = "0"
			unit_scenes[i] = null
			unit_data_cache[i] = {}
				
			_update_ui()

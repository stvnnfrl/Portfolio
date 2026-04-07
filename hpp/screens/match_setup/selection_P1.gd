extends GridContainer
## Player 1 unit selection panel for Match Setup.
## Dynamically loads unit names and costs from Hero scene data
## when the player selects a different army from the dropdown.

# Maps OptionButton index to Hero scene path.
# Update these paths as new army scenes are created.
const HERO_SCENES: Array[String] = [
	"res://army/heroes/general.tscn",
	"res://army/heroes/king.tscn",
	"res://army/heroes/samourai.tscn",
	"res://army/heroes/soul.tscn"
]

@onready var troop_labels = [$Troop1, $Troop2, $Troop3, $Troop4]
@onready var cost_labels = [$CostForTroop1, $CostForTroop2, $CostForTroop3, $CostForTroop4]
@onready var qty_labels = [
	get_node("/root/Control/ArmySetup/SelectionP1/QtyTroop1/QtyLabel"),
	get_node("/root/Control/ArmySetup/SelectionP1/QtyTroop2/QtyLabel"),
	get_node("/root/Control/ArmySetup/SelectionP1/QtyTroop3/QtyLabel"),
	get_node("/root/Control/ArmySetup/SelectionP1/QtyTroop4/QtyLabel"),
]
@onready var total_label = get_node("/root/Control/ArmySetup/SelectionP1/Total")
@onready var money_label = get_node("/root/Control/MatchSettings/CP_Count")
@onready var cp_used_label = $CP_Used
@onready var cp_remaining_label = $CP_Remaining
@onready var hero_option = $HBoxContainer/OptionButton

var quantities: Array[int] = [0, 0, 0, 0]
var costs: Array[int] = [0, 0, 0, 0]
var unit_count: int = 0
var money: int = 0

var selected_hero : Hero

func _ready():
	var btn_pairs = [
		[$QtyTroop1/MinusButton, $QtyTroop1/PlusButton],
		[$QtyTroop2/MinusButton, $QtyTroop2/PlusButton],
		[$QtyTroop3/MinusButton, $QtyTroop3/PlusButton],
		[$QtyTroop4/MinusButton, $QtyTroop4/PlusButton],
	]
	for i in range(btn_pairs.size()):
		var idx = i  # capture for lambda
		btn_pairs[i][0].pressed.connect(func(): _change_qty(idx, -1))
		btn_pairs[i][1].pressed.connect(func(): _change_qty(idx, 1))

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

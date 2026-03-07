extends GridContainer

@onready var qty1_label = get_node("/root/Control/ArmySetup/SelectionP2/QtyTroop1/QtyLabel")
@onready var qty2_label = get_node("/root/Control/ArmySetup/SelectionP2/QtyTroop2/QtyLabel")
@onready var qty3_label = get_node("/root/Control/ArmySetup/SelectionP2/QtyTroop3/QtyLabel")
@onready var total_label = get_node("/root/Control/ArmySetup/SelectionP2/Total")

@onready var money_label = get_node("/root/Control/MatchSettings/CP_Count")

@onready var cost1_label = $CostForTroop1
@onready var cost2_label = $CostForTroop2
@onready var cost3_label = $CostForTroop3


@onready var cp_used_label = $CP_Used
@onready var cp_remaining_label = $CP_Remaining

# --- Buttons ---
@onready var q1_minus = $QtyTroop1/MinusButton
@onready var q1_plus  = $QtyTroop1/PlusButton
@onready var q2_minus = $QtyTroop2/MinusButton
@onready var q2_plus  = $QtyTroop2/PlusButton
@onready var q3_minus = $QtyTroop3/MinusButton
@onready var q3_plus  = $QtyTroop3/PlusButton

var q1 = 0
var q2 = 0
var q3 = 0

var money = 0

var cost1 = 0
var cost2 = 0
var cost3 = 0


# --- Connect the buttons ---
func _ready():
	q1_minus.pressed.connect(decrease_q1)
	q1_plus.pressed.connect(increase_q1)
	q2_minus.pressed.connect(decrease_q2)
	q2_plus.pressed.connect(increase_q2)
	q3_minus.pressed.connect(decrease_q3)
	q3_plus.pressed.connect(increase_q3)
	
	money = parse_money(money_label.text)
	
	cost1 = int(cost1_label.text)
	cost2 = int(cost2_label.text)
	cost3 = int(cost3_label.text)
	
	update_ui()

# Convert "CP: 150" → 150
func parse_money(text: String) -> int:
	var parts = text.split(":")
	return int(parts[1].strip_edges())
	

# --- Button Functions ---
func increase_q1():
	if can_increase(cost1):
		q1 += 1
		money -= cost1
		update_ui()

func decrease_q1():
	if can_decrease(q1):
		q1 -= 1
		money += cost1
		update_ui()

func increase_q2():
	if can_increase(cost2):
		q2 += 1
		money -= cost2
		update_ui()

func decrease_q2():
	if can_decrease(q2):
		q2 -= 1
		money += cost2
		update_ui()

func increase_q3():
	if can_increase(cost3):
		q3 += 1
		money -= cost3
		update_ui()

func decrease_q3():
	if can_decrease(q3):
		q3 -= 1
		money += cost3
		update_ui()


# Helper methods for cost
func total_cost() -> int:
	return q1 * cost1 + q2 * cost2 + q3 * cost3
	
func can_increase(cost: int) -> bool:
	return cost <= money
	
func can_decrease(qty:int) -> bool:
	return qty > 0

# --- Update Labels ---
func update_ui():
	qty1_label.text = "x" + str(q1)
	qty2_label.text = "x" + str(q2)
	qty3_label.text = "x" + str(q3)
	total_label.text = "Total: " + str(q1 + q2 + q3)
	
	cp_remaining_label.text = "CP Remaining: " + str(money)
	cp_used_label.text = "CP Used: " + str(total_cost())
	
	

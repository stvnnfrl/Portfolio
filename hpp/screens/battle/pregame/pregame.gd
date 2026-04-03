class_name Pregame extends Control

signal units_updated(units: Array[Unit])
signal selected_unit_updated(unit: Unit)

@export var grid: Node

var current_player: int

var current_units: Array[Unit]
var current_unit_counts: Array[int]
var selected_unit: Unit
var selected_index: int

# store player info so we can hand it back once we're done
var _hero1: Hero
var _hero2: Hero
var _units1: Array[Unit]
var _units2: Array[Unit]
var _unit_counts1: Array[int]
var _unit_counts2: Array[int]

func init(hero1: Hero, unit_counts1: Array[int], hero2: Hero, unit_counts2: Array[int]):
	_hero1 = hero1
	_hero2 = hero2
	_unit_counts1 = unit_counts1
	_unit_counts2 = unit_counts2
	
	# instantiate units so other scripts can work with fields directly
	_units1 = []
	for unit_scene in hero1.units:
		_units1.append(unit_scene.instantiate())
	_units2 = []
	for unit_scene in hero2.units:
		_units2.append(unit_scene.instantiate())
	
	# initialize state
	current_player = 1
	change_units_to(_units1)
	current_unit_counts = _unit_counts1

func change_units_to(new_units: Array[Unit]):
	current_units = new_units
	
	change_selected_unit_to(-1)  # unselect
	units_updated.emit(current_units)

func change_selected_unit_to(index: int):
	selected_index = index
	
	selected_unit = null
	if selected_index >= 0:
		selected_unit = current_units[selected_index]
	
	selected_unit_updated.emit(selected_unit)

# returns a callback to purchase a unit if it can be afforded
func can_purchase() -> Callable:
	if current_unit_counts[selected_index] > 0:
		return func(): current_unit_counts[selected_index] -= 1
	
	return Callable()  # equivalent to null

# returns a callback to refund a unit
func can_refund(index: int) -> Callable:
	return func(): current_unit_counts[index] += 1

# handle next button
func _on_button_pressed() -> void:
	if current_player == 1:
		current_player = 2
		change_units_to(_units2)
		current_unit_counts = _unit_counts2
	else:
		SceneManager.load_game_over()

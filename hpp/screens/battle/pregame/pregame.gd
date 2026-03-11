extends Control

@export var units_script: Node
@export var info_script: Node

# initialize with random data (only for testing)
func _ready() -> void:
	init(
		[ {"movement": 1, "attack": 2, "defense": 3, "health": 4, "name": "swordsman", "flavor_text": "swords..."}
		, {"movement": 4, "attack": 3, "defense": 2, "health": 1, "name": "pikeman", "flavor_text": "pikes..."}
		, {"movement": 4, "attack": 5, "defense": 6, "health": 1, "name": "archer", "flavor_text": "bows..."}
		, {"movement": 4, "attack": 6, "defense": 5, "health": 1, "name": "cow", "flavor_text": "moo..."} ] )

func init(units: Array[Dictionary]):
	units_script.init(units)
	info_script.init(units)

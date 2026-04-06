extends Node2D
class_name Battlefield

var hero_1 : Hero
var hero_2 : Hero
var army_1 : Array[Unit] = []
var army_2 : Array[Unit] = []

func init(hero1: Hero, units1: Array[Unit], hero2: Hero, units2: Array[Unit]):
	hero_1 = hero1
	hero_2 = hero2
	army_1 = units1
	army_2 = units2
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

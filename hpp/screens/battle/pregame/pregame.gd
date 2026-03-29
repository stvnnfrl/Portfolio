extends Control

@export var units_script: Node
@export var info_script: Node
@export var drag_script: Node
@export var grid_script: Node

func init(hero1: Hero, _units_counts1: Array[int], hero2: Hero, _units_counts2: Array[int]):
	var units1: Array[Unit] = []
	for unit_scene in hero1.units:
		units1.append(unit_scene.instantiate())
		
	var units2: Array[Unit] = []
	for unit_scene in hero2.units:
		units2.append(unit_scene.instantiate())
	
	units_script.init(units1, units2)
	info_script.init()
	drag_script.init()
	grid_script.init()


# initialize with random data (only for testing)

@export var test_unit_texture_atlas: Texture2D

var monarch: Hero = load("res://army/Monarch/monarch.tscn").instantiate()

func _ready() -> void:
	init \
		( monarch, [ 1, 2, 3, 4 ]
		, monarch, [ 4, 3, 2, 1 ] )

func create_atlas_texture(x: int, y: int) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = test_unit_texture_atlas
	atlas.region = Rect2(x*128, y*128, 128, 128)
	return atlas


func _on_button_pressed() -> void:
	SceneManager.load_game_over()

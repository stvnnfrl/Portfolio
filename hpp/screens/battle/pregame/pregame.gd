extends Control

@export var units_script: Node
@export var info_script: Node
@export var drag_script: Node

func init(units: Array[Dictionary]):
	units_script.init(units)
	info_script.init(units)
	drag_script.init(units)


# initialize with random data (only for testing)

@export var test_unit_texture_atlas: Texture2D

func _ready() -> void:
	init(
		[ {"movement": 1, "attack": 2, "defense": 3, "health": 4, "name": "swordsman", "flavor_text": "swords...", "texture": create_atlas_texture(0, 0) }
		, {"movement": 4, "attack": 3, "defense": 2, "health": 1, "name": "pikeman", "flavor_text": "pikes...", "texture": create_atlas_texture(1, 0)}
		, {"movement": 4, "attack": 5, "defense": 6, "health": 1, "name": "archer", "flavor_text": "bows...", "texture": create_atlas_texture(0, 1)}
		, {"movement": 4, "attack": 6, "defense": 5, "health": 1, "name": "cow", "flavor_text": "moo...", "texture": create_atlas_texture(1, 1)} ] )

func create_atlas_texture(x: int, y: int) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = test_unit_texture_atlas
	atlas.region = Rect2(x*128, y*128, 128, 128)
	return atlas

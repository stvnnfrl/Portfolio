class_name Unit extends Node2D

@export var unit_name : String
@export var description : String

@export var max_health : int
var health : int
@export var speed : int
@export var movement : int
@export var dmg_min : int
@export var dmg_max : int
@export var reach : int

@export var cost : int

var cubic_pos : Vector3i
var army_id : int

@export var anim_sprite : AnimatedSprite2D
@export var hex_halo : Sprite2D
@export var health_bar : ProgressBar

func _ready() -> void:
	_ensure_node_refs()
	health = max_health

	if anim_sprite:
		anim_sprite.play("idle")
		
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func _ensure_node_refs() -> void:
	if anim_sprite == null:
		anim_sprite = get_node_or_null("AnimatedPixelArt")
	if hex_halo == null:
		hex_halo = get_node_or_null("HexHalo")
	if health_bar == null:
		health_bar = get_node_or_null("HealthBar")

# functions
		
func take_damage(amount : int):
	health -= amount
	
	if health_bar:
		health_bar.value = health
		
func get_attack_damage() -> int:
	return randi_range(dmg_min, dmg_max)

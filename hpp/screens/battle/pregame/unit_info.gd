extends VBoxContainer

@export var name_label: Label
@export var description_label: Label

@export var health_label: Label
@export var speed_label: Label
@export var movement_label: Label
@export var damage_label: Label
@export var reach_label: Label

func unset_labels() -> void:
	set_labels_to \
		( "no unit selected", "..." 
		, "-", "-", "-", "-", "-" )

func _on_pregame_selected_unit_updated(unit: Unit) -> void:
	if unit == null:  # deselected
		unset_labels()
		return
	
	set_labels_to \
		# main info
		( str(unit.name)
		, str(unit.description)
		# stats
		, str(unit.health) + "/" + str(unit.max_health)
		, str(unit.speed)
		, str(unit.movement)
		, str(unit.dmg_min) + "-" + str(unit.dmg_max)
		, str(unit.reach)
		)

func set_labels_to \
		( unit_name: String, description: String
		, health: String, speed: String, movement: String, damage: String, reach: String ) \
		-> void:
	
	name_label.text = unit_name
	description_label.text = description
	
	health_label.text = health
	speed_label.text = speed
	movement_label.text = movement
	damage_label.text = damage
	reach_label.text = reach

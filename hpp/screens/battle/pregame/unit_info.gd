extends VBoxContainer

var units: Array[Variant]

@export var name_label: Label
@export var flavor_label: Label

@export var movement_label: Label
@export var attack_label: Label
@export var defense_label: Label
@export var health_label: Label

func init(units_: Array[Dictionary]) -> void:
	units = units_
	unset_labels()

func unset_labels() -> void:
	set_labels_to \
		( "no unit selected", "..." 
		, "-", "-", "-", "-" )

func set_labels_to \
		( unit_name: String, flavor_text: String
		, movement: String, attack: String, defense: String, health: String ) \
		-> void:

	name_label.text = unit_name
	flavor_label.text = flavor_text
	
	movement_label.text = movement
	attack_label.text = attack
	defense_label.text = defense
	health_label.text = health

func _on_unit_selector_selected_unit_changed(index: int) -> void:
	if index < 0:  # deselected
		unset_labels()
		return

	var unit = units[index]
	set_labels_to \
		# main info
		( str(unit.name)
		, str(unit.flavor_text)
		# stats
		, str(unit.movement)
		, str(unit.attack)
		, str(unit.defense)
		, str(unit.health)  )

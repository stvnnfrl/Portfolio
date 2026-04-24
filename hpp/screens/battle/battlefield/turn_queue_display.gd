extends PanelContainer
class_name TurnQueueDisplay

const PORTRAIT_PATH_TEMPLATE := "res://screens/battle/battlefield/assets/%s.png"

@export var army_1_background := Color(0.933, 0.102, 0.102, 0.4)
@export var army_2_background := Color(0.106, 0.106, 0.89, 0.4)
@export var army_1_active_background := Color(0.917, 0.0, 0.188, 0.9)
@export var army_2_active_background := Color(0.301, 0.036, 1.0, 0.9)
@export var neutral_background := Color(0.34, 0.34, 0.34, 0.86)

@onready var queue_row: HBoxContainer = $QueuePadding/QueueRow
@onready var slot_template: Control = $SlotTemplate


func _ready() -> void:
	slot_template.hide()
	hide()


func set_units(units: Array) -> void:
	_clear_slots()

	var slot_index := 0
	for unit in units:
		if unit is Unit and is_instance_valid(unit):
			_add_unit_slot(unit, slot_index == 0)
			slot_index += 1

	visible = queue_row.get_child_count() > 0


func _clear_slots() -> void:
	for child in queue_row.get_children():
		queue_row.remove_child(child)
		child.queue_free()


func _add_unit_slot(unit: Unit, is_active: bool = false) -> void:
	if slot_template == null:
		return

	var slot := slot_template.duplicate() as Control
	slot.show()
	queue_row.add_child(slot)

	var portrait_path := PORTRAIT_PATH_TEMPLATE % unit.unit_id
	var background := slot.get_node("Background") as ColorRect
	var portrait := slot.get_node("PortraitCenter/PortraitTexture") as TextureRect

	background.color = _get_team_background(unit, is_active)
	if ResourceLoader.exists(portrait_path, "Texture2D"):
		portrait.texture = load(portrait_path) as Texture2D


func _get_team_background(unit: Unit, is_active: bool = false) -> Color:
	if unit.army_id == 1:
		return army_1_active_background if is_active else army_1_background
	if unit.army_id == 2:
		return army_2_active_background if is_active else army_2_background
	return neutral_background

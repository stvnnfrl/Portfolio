extends Sprite2D

var units: Array[Variant]

@export var unset_unit_texture: Texture2D
@export var size: Vector2

func init(units_: Array[Dictionary]) -> void:
	units = units_
	unset_unit()

func _on_unit_selector_selected_unit_changed(index: int) -> void:
	set_unit_to(index)

func unset_unit() -> void:
	set_unit_to(-1)

func set_unit_to(index: int) -> void:
	if index < 0:
		texture = unset_unit_texture
	else:
		var unit = units[index]
		texture = unit.texture
	
	# resize the sprite to get a consistent size
	# if a unit ever requires a bigger preview,
	# we can add extra parameters on the unit to multiply this scale
	scale = size / texture.get_size()

# might be able to make this on mouse movement instead
func _process(_delta: float) -> void:
	position = get_viewport().get_mouse_position()

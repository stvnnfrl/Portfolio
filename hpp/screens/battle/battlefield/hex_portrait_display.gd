extends Control
class_name HexPortraitDisplay

@export var fill_color := Color(0.96, 0.95, 0.92, 1.0)
@export var border_color := Color(0.12, 0.12, 0.12, 0.96)
@export var shadow_color := Color(0, 0, 0, 0.18)
@export var portrait_texture: Texture2D
@export var portrait_modulate := Color(1, 1, 1, 1)
@export var portrait_fill_multiplier := 1.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var shadow_offset := Vector2(0, 7)
	var hex_rect := Rect2(Vector2(8, 6), size - Vector2(16, 14))
	var polygon := _build_hex_polygon(hex_rect)
	var shadow_polygon := PackedVector2Array()
	for point in polygon:
		shadow_polygon.append(point + shadow_offset)

	draw_colored_polygon(shadow_polygon, shadow_color)
	draw_colored_polygon(polygon, fill_color)
	draw_polyline(_closed_polygon(polygon), border_color, 4.0, true)

	if portrait_texture == null:
		return

	var portrait_bounds := _get_portrait_bounds(hex_rect)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_texture_rect(portrait_texture, portrait_bounds, false, portrait_modulate)


func _get_portrait_bounds(hex_rect: Rect2) -> Rect2:
	var texture_size: Vector2 = portrait_texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return hex_rect

	# Fit portraits fully inside the hex safe area.
	var inset_x := hex_rect.size.x * 0.10
	var inset_top := hex_rect.size.y * 0.08
	var inset_bottom := hex_rect.size.y * 0.12
	var portrait_area := Rect2(
		hex_rect.position + Vector2(inset_x, inset_top),
		Vector2(
			hex_rect.size.x - inset_x * 2.0,
			hex_rect.size.y - inset_top - inset_bottom
		)
	)

	var fit_scale: float = min(portrait_area.size.x / texture_size.x, portrait_area.size.y / texture_size.y)
	fit_scale *= portrait_fill_multiplier
	var draw_size: Vector2 = texture_size * fit_scale
	var draw_position: Vector2 = portrait_area.position + (portrait_area.size - draw_size) * 0.5
	return Rect2(draw_position, draw_size)


func _build_hex_polygon(rect: Rect2) -> PackedVector2Array:
	var cut := rect.size.x * 0.22
	var mid_y := rect.position.y + rect.size.y * 0.5
	return PackedVector2Array([
		Vector2(rect.position.x + cut, rect.position.y),
		Vector2(rect.position.x + rect.size.x - cut, rect.position.y),
		Vector2(rect.position.x + rect.size.x, mid_y),
		Vector2(rect.position.x + rect.size.x - cut, rect.position.y + rect.size.y),
		Vector2(rect.position.x + cut, rect.position.y + rect.size.y),
		Vector2(rect.position.x, mid_y),
	])


func _closed_polygon(points: PackedVector2Array) -> PackedVector2Array:
	var closed := PackedVector2Array(points)
	if not closed.is_empty():
		closed.append(closed[0])
	return closed

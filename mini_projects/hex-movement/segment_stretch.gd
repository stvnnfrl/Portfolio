class_name Stretch extends Sprite2D

const scroll_speed = 256

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	region_enabled = true
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	region_rect.size = texture.get_size()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	region_rect.position.x -= scroll_speed * delta
	region_rect.position.x = fmod(region_rect.position.x, texture.get_width())
	pass

func stretch(start: Vector2, end: Vector2):
	global_position = (start + end)/2
	var diff = end - start
	global_rotation = diff.angle()
	region_rect.size.x = diff.length()

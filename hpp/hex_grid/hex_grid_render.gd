class_name HexGridRender extends CanvasItem

@export var cubic: CubicCoords
@export var color: Color = Color.BLACK
@export var border_frac: float = 0.93
 # default some arbitrary big rect to not limit
@export var limit_rect: Rect2 = Rect2(-1000, -1000, 4000, 4000):
	set(value):
		set_instance_shader_parameter("limit_rect", value)
		limit_rect = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.material = load("res://hex_grid/hex_grid_render.tres")
	# TODO validate final hex grid size to be consistent with battlefield
	cubic.size = 84.0
	set_instance_shader_parameter("size", cubic.size)
	set_instance_shader_parameter("border_frac", border_frac)
	set_instance_shader_parameter("limit_rect", limit_rect)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	set_instance_shader_parameter("rect_size", get_viewport_rect().size)
	pass
	
func _draw() -> void:
	self.draw_rect(get_viewport_rect(), color)

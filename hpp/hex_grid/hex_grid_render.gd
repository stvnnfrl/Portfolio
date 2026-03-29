extends CanvasItem

@export var cubic: CubicCoords
@export var color: Color = Color.BLACK
@export var border_frac: float = 0.9



var unit_1 = {
	"speed" = 2,
	"health" = 10,
	"damage" = 2
}

var unit_2 = {
	"speed" = 4,
	"health" = 5,
	"damage" = 3
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.material = load("res://hex_grid/hex_grid_render.tres")
	set_instance_shader_parameter("size", cubic.size)
	set_instance_shader_parameter("border_frac", border_frac)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_instance_shader_parameter("rect_size", get_viewport_rect().size)
	pass
	
func _draw() -> void:
	self.draw_rect(get_viewport_rect(), color)

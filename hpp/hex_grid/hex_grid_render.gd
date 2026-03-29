extends CanvasItem

@export var cubic: CubicCoords
@export var color: Color = Color.BLACK
@export var border_frac: float = 0.9

var turn_queue : Array = []

var army_1 : Array = []
var army_2 : Array = []

var unit_1 = {
	"stats" = {
		"speed" = 2,
		"movement" = 3,
		"health" = 10,
		"damage" = 2
	},
	"coords" = Vector3i(1,1,1)
}

var unit_2 = {
	"stats" = {
		"speed" = 4,
		"movement" = 2,
		"health" = 5,
		"damage" = 3
	},
	"coords" = Vector3(4,1,1)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.material = load("res://hex_grid/hex_grid_render.tres")
	set_instance_shader_parameter("size", cubic.size)
	set_instance_shader_parameter("border_frac", border_frac)
	
	# init armies
	_setup_army()
	
	# init turn
	_init_turn()
	
	print(turn_queue)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_instance_shader_parameter("rect_size", get_viewport_rect().size)
	pass
	
func _setup_army():
	army_1.append(unit_1)
	army_2.append(unit_2)
	
	

func _init_turn():
	#turn_queue.clear()
	
	var pointer_1 = 0
	var pointer_2 = 0
	
	while pointer_1 < army_1.size() or pointer_2 < army_2.size():
		
		if pointer_2 == army_2.size() or (pointer_1 < army_1.size() and army_1[pointer_1]["stats"]["speed"] > army_2[pointer_2]["stats"]["speed"]):
			turn_queue.append(army_1[pointer_1])
			pointer_1 += 1
		else:
			turn_queue.append(army_2[pointer_2])
			pointer_2 += 1

func _draw() -> void:
	self.draw_rect(get_viewport_rect(), color)

extends CanvasItem

@export var cubic: CubicCoords
@export var color: Color = Color.BLACK
@export var border_frac: float = 0.9
@export var unit_scene : PackedScene

var turn_queue : Array = []
var curr_subturn_index : int = -1
var active_unit : Dictionary
var is_waiting_for_input : bool = false

var army_1 : Array = []
var army_2 : Array = []

var unit_1 = {
	"stats" = {
		"speed" = 2,
		"movement" = 3,
		"health" = 10,
		"damage" = 2
	},
	"coords" = Vector3i(4,-1,-3)
}

var unit_2 = {
	"stats" = {
		"speed" = 4,
		"movement" = 2,
		"health" = 5,
		"damage" = 3
	},
	"coords" = Vector3i(7,-4,-3)
}

var unit_3 = {
	"stats" = {
		"speed" = 5,
		"movement" = 3,
		"health" = 20,
		"damage" = 1
	},
	"coords" = Vector3i(5, 0, -5)
}

var unit_4 = {
	"stats" = {
		"speed" = 1,
		"movement" = 1,
		"health" = 7,
		"damage" = 10
	},
	"coords" = Vector3i(8, -3, -5)
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
	
	# start turn
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_instance_shader_parameter("rect_size", get_viewport_rect().size)
	pass
	
func _setup_army():
	
	_instantiate_unit_scene(unit_1, Color.RED)
	army_1.append(unit_1)
	
	_instantiate_unit_scene(unit_3, Color.RED)
	army_1.append(unit_3)
	
	_instantiate_unit_scene(unit_2, Color.BLUE)
	army_2.append(unit_2)
	
	_instantiate_unit_scene(unit_4, Color.BLUE)
	army_2.append(unit_4)
	

func _instantiate_unit_scene(unit : Dictionary, color: Color):
	var u_scene = unit_scene.instantiate()
	add_child(u_scene)
	u_scene.position = cubic.cubic_to_pos2D(unit["coords"])
	u_scene.modulate = color
	unit["hex"] = u_scene
	

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


func _start_next_sub_turn():
	curr_subturn_index += 1
	
	if curr_subturn_index >= turn_queue.size():
		curr_subturn_index = 0
		
	active_unit = turn_queue[curr_subturn_index]
	is_waiting_for_input = true
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_waiting_for_input:
			var pos = get_viewport().get_mouse_position()
			var cubic_pos = cubic.pos2D_to_cubic(pos)
			
			print(cubic_pos)
			
			## FOR TESTING: Hardcoding a destination to test the turn loop
			#var test_dest = active_unit["coords"] + Vector3i(1, -1, 0)
			#_try_move_active_unit(test_dest)

func _draw() -> void:
	self.draw_rect(get_viewport_rect(), color)

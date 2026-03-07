extends Node2D

@export var bar: CubicCoords

@onready var label = $Label
@onready var label2 = $Label2
@onready var bg = $"../Sprite2D2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(JSON.stringify(self, '\t'))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(label.get_rect().size)
	var pos = position
	var cubic_pos = bar.pos2D_to_cubic(pos) #- get_viewport_rect().size/2)
	if Input.is_action_pressed("m1"):
		pos = get_viewport().get_mouse_position()
		cubic_pos = bar.pos2D_to_cubic(pos) #- get_viewport_rect().size/2)
	else:
		cubic_pos = bar.cubic_round(cubic_pos)
	#bg.set_instance_shader_parameter("mouse_pos", pos)
	
	self.position = bar.cubic_to_pos2D(cubic_pos)# + get_viewport_rect().size/2
	label.text = str(cubic_pos)
	label2.text = str(bar.cubic_round(cubic_pos))
	pass

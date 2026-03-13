extends MarginContainer

@export var save_slot_scene : PackedScene
@onready var saves_container = $HBoxContainer/NavigationContainer/VBoxContainer/ScrollContainer/SavesContainer

var stub_saves_data = [
		{
			"save_name": "Save 1",
			"mode": "Multiplayer",
			"date": "2026-01-17T01:05"
		},
		{
			"save_name": "Save 2",
			"mode": "Singleplayer",
			"date": "2026-01-15T11:57"
		},
		{
			"save_name": "Save 3",
			"mode": "Multiplayer",
			"date": "2026-01-16T14:23"
		},
		{
			"save_name": "Save 4",
			"mode": "Singleplayer",
			"date": "2026-01-16T14:33"
		},
		{
			"save_name": "Save 5",
			"mode": "Singleplayer",
			"date": "2026-01-16T14:34"
		},
		{
			"save_name": "Save 6",
			"mode": "Multiplayer",
			"date": "2026-01-16T14:35"
		}
	]


func _ready():
	# Get saves from 
	# Call to load manager autoload
	
	# Populate accordingly
	populate_saves_list()

func populate_saves_list():
	# clear to be safe
	for child in saves_container.get_children():
		child.queue_free()
	
	# Create slot for every save
	for metadata in stub_saves_data:
		var slot = save_slot_scene.instantiate()
		saves_container.add_child(slot)
		slot.setup(metadata)
		slot.pressed.connect(_on_save_slot_pressed.bind(metadata))



func _on_save_slot_pressed(metadata: Dictionary):
	print("Player clicked on: ", metadata["save_name"])

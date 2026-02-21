extends CanvasLayer

@onready var recognizer = $testNode
@onready var drawing_pad = $mainLayout/drawingPadMargin/drawingPad
@onready var spell_slots = [
	$mainLayout/MarginContainer/spellBar/spellSlot1,
	$mainLayout/MarginContainer/spellBar/spellSlot2,
	$mainLayout/MarginContainer/spellBar/spellSlot3,
	$mainLayout/MarginContainer/spellBar/spellSlot4
]

# State variables
var is_recording_mode = false # true = train, false = play
var current_target_spell = "spell1"

func _ready():
	# Connect the drawing pad
	drawing_pad.drawing_finished.connect(_on_drawing_finished)
	
	# Connect spell clicks (this is for the training part) by listening for GUI input on the slots
	for i in range(spell_slots.size()):
		var tmp_slot = spell_slots[i]
		tmp_slot.gui_input.connect(_on_slot_input.bind(i))
		
	if is_recording_mode:
		print("Currently training")
	else:
		print("Currently playing")
	update_ui_color()

func _on_slot_input(event, index):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_target_spell = "spell" + str(index + 1)
		highlight_slot(index)

func _on_drawing_finished(raw_points: PackedVector2Array):
	if is_recording_mode:
		recognizer.add_template(current_target_spell, raw_points)
		flash_feedback(Color.GREEN)
	else:
		var normalized = recognizer.normalize(raw_points)
		var result = recognizer.recognize(normalized, recognizer.templates)
		
		if result["score"] > 0.85:
			var spell_index : int = int(result["name"].replace("spell", "")) - 1
			highlight_slot(spell_index)
			flash_feedback(Color.WEB_GREEN)
			print("Recognized: ", result["name"], " Score: ", result["score"])
		else:
			highlight_slot(-1)
			flash_feedback(Color.CRIMSON)
			print("Not recognized well enough.")

# Visual helpers

func highlight_slot(index):
	for slot in spell_slots:
		slot.modulate = Color(0.5, 0.5, 0.5)
	# make the selected spell bright
	if index >= 0 and index < spell_slots.size():
		spell_slots[index].modulate = Color(1.5, 1.5, 1.5)

func update_ui_color():
	if is_recording_mode:
		$background.color = Color.CRIMSON
	else:
		$background.color = Color(0.2, 0.2, 0.2)

func flash_feedback(color: Color):
	var original_color = drawing_pad.self_modulate
	drawing_pad.self_modulate = color
	await get_tree().create_timer(0.2).timeout
	drawing_pad.self_modulate = original_color

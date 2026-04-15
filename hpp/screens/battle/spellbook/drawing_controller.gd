extends MarginContainer

signal gesture_matched(recognized_spell_name: String)

@onready var recognizer = $gestureRecognizer
@onready var drawing_pad = $drawingPad
@export var is_recording_mode: bool = false 

var current_target_spell: String = "TestSpell"

func _ready():
	drawing_pad.drawing_finished.connect(_on_drawing_finished)

func _on_drawing_finished(raw_points: PackedVector2Array):
	if is_recording_mode:
		recognizer.add_template(current_target_spell, raw_points)
		flash_feedback(Color.GREEN)
		print("Saved template for: ", current_target_spell)
	else:
		var normalized = recognizer.normalize(raw_points)
		var result = recognizer.recognize(normalized, recognizer.templates)
		
		if result["score"] > 0.80:
			flash_feedback(Color.WEB_GREEN)
			print("Recognized: ", result["name"], " Score: ", result["score"])
			gesture_matched.emit(result["name"])
		else:
			flash_feedback(Color.CRIMSON)
			print("Not recognized well enough. Score: ", result["score"])

func flash_feedback(color: Color):
	var original_color = drawing_pad.self_modulate
	drawing_pad.self_modulate = color
	await get_tree().create_timer(0.2).timeout
	drawing_pad.self_modulate = original_color

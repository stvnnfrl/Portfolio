extends MarginContainer

signal gesture_matched(recognized_spell_name: String)

@onready var recognizer = $gestureRecognizer
@onready var drawing_pad = $drawingPad
@export var is_recording_mode: bool = false 

var current_target_spell: String = "TestSpell"
var available_spell_names : Array[String] = []

func _ready():
	drawing_pad.drawing_finished.connect(_on_drawing_finished)

func set_available_spells(spells: Array[Dictionary]) -> void:
	available_spell_names.clear()
	for spell in spells:
		available_spell_names.append(spell["name"])

func _on_drawing_finished(raw_points: PackedVector2Array):
	if is_recording_mode:
		recognizer.add_template(current_target_spell, raw_points)
		flash_feedback(Color.GREEN)
		print("Saved template for: ", current_target_spell)
	else:
		var normalized = recognizer.normalize(raw_points)
		
		# Filter for available templates
		var filtered_templates = {}
		for spell_name in available_spell_names:
			if recognizer.templates.has(spell_name):
				filtered_templates[spell_name] = recognizer.templates[spell_name]
		
		var result = recognizer.recognize(normalized, filtered_templates)
		
		if result["score"] > 0.85 and result["name"] != "No Templates Loaded":
			flash_feedback(Color.WEB_GREEN)
			print("Recognized: ", result["name"], " Score: ", result["score"])
			gesture_matched.emit(result["name"])
		else:
			flash_feedback(Color.CRIMSON)
			print("Not recognized well enough. Score: ", result["score"])


func flash_feedback(color: Color):
	var original_color = drawing_pad.self_modulate
	drawing_pad.self_modulate = color
	await get_tree().create_timer(0.4).timeout
	drawing_pad.self_modulate = original_color

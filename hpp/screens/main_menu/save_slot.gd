extends Button

@onready var save_name_label = $MarginContainer/VBoxContainer/TopRow/SaveTitle
@onready var mode_label = $MarginContainer/VBoxContainer/TopRow/GameMode
@onready var date_label = $MarginContainer/VBoxContainer/DateLabel

# We store the file path so we know which file to load when clicked
var file_path: String = ""

# The SaveManager will call this function and pass in a dictionary of data
func setup(metadata: Dictionary):
	save_name_label.text = metadata.get("save_name", "Unknown Save")
	mode_label.text = metadata.get("mode", "Singleplayer")
	date_label.text = metadata.get("date", "Unknown Date")
	file_path = metadata.get("file_path", "")

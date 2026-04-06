extends Button

@onready var save_name_label = $MarginContainer/VBoxContainer/TopRow/SaveTitle
@onready var mode_label = $MarginContainer/VBoxContainer/TopRow/GameMode
@onready var date_label = $MarginContainer/VBoxContainer/DateLabel

var _hover_style: StyleBox

# We store the file path so we know which file to load when clicked
var file_path: String = ""

# The SaveManager will call this function and pass in a dictionary of data
func setup(metadata: Dictionary):
	save_name_label.text = metadata.get("save_name", "Unknown Save")
	mode_label.text = metadata.get("mode", "Singleplayer")
	date_label.text = metadata.get("date", "Unknown Date")
	file_path = metadata.get("file_path", "")

func _ready() -> void:
	_hover_style = get_theme_stylebox("hover")
	focus_mode = Control.FOCUS_NONE

func set_selected(selected: bool) -> void:
	if selected:
		add_theme_stylebox_override("normal", _hover_style)
		return

	if has_theme_stylebox_override("normal"):
		remove_theme_stylebox_override("normal")

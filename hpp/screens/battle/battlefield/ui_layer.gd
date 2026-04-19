extends CanvasLayer
class_name UIManager

@onready var game_menu : Control = $GameMenu
@onready var spellbook_menu : Control = $SpellBookMenu
@onready var battlefield_manager : BattlefieldManager = $"../BattlefieldManager"

func _ready() -> void:
	game_menu.hide()
	spellbook_menu.hide()


func _on_pause_button_pressed() -> void:
	game_menu.visible = !game_menu.visible
	spellbook_menu.hide()


func _on_spell_book_button_pressed() -> void:
	game_menu.hide()
	
	if spellbook_menu.visible:
		spellbook_menu.close()
	else:
		# Check if the active hero is allowed to cast before opening the book
		if battlefield_manager.can_active_hero_cast_spell():
			var spell_data = battlefield_manager.get_current_hero_spells()
			spellbook_menu.open(spell_data)
		else:
			print("You have already cast a spell this round!")

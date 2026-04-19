extends CanvasLayer
class_name UIManager

@onready var game_menu : Control = $GameMenu
@onready var spellbook_menu : Control = $SpellBookMenu
@onready var battlefield_manager : BattlefieldManager = $"../BattlefieldManager"

func _ready() -> void:
	game_menu.hide()
	spellbook_menu.hide()
	var spell_button := $HUD/MarginContainer/BottomBarUI/CurrentTroopInfo/DockPadding/DockLayout/LeftActionZone/SpellRow/SpellButton as BaseButton
	if spell_button != null and not spell_button.pressed.is_connected(_on_spell_book_button_pressed):
		spell_button.pressed.connect(_on_spell_book_button_pressed)
	battlefield_manager.active_unit_changed.connect(_on_active_unit_changed)
	_on_active_unit_changed(battlefield_manager.active_unit, int(battlefield_manager.current_phase))
	spellbook_menu.spell_selected.connect(battlefield_manager._on_spellbook_spell_selected)


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

func _on_active_unit_changed(unit: Unit, _phase: int) -> void:
	var troop_info := $HUD/MarginContainer/BottomBarUI/CurrentTroopInfo as CurrentTroopInfo
	if troop_info == null:
		return
	troop_info.set_context(unit)

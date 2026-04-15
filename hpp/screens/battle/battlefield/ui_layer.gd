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

func _on_pause_button_pressed() -> void:
	game_menu.visible = !game_menu.visible
	spellbook_menu.hide()

func _on_spell_book_button_pressed() -> void:
	game_menu.hide()
	
	if spellbook_menu.visible:
		spellbook_menu.close()
	else:
		var spell_data = battlefield_manager.get_current_hero_spells()
		spellbook_menu.open(spell_data)

func _on_active_unit_changed(unit: Unit, phase: int) -> void:
	var troop_info := $HUD/MarginContainer/BottomBarUI/CurrentTroopInfo as CurrentTroopInfo
	if troop_info == null:
		return
	troop_info.set_context(unit, phase)
	troop_info.set_visual_state(CurrentTroopInfo.STATE_ACTIVE_TURN if unit != null else CurrentTroopInfo.STATE_IDLE)

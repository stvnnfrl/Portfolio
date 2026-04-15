extends PanelContainer
class_name CurrentTroopInfo

const STATE_IDLE := "idle"
const STATE_ACTIVE_TURN := "active_turn"
const PORTRAIT_PATH_TEMPLATE := "res://screens/battle/battlefield/assets/%s.png"

@onready var stats_panel: PanelContainer = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsPanel
@onready var name_label: Label = $DockPadding/DockLayout/UnitInfo/UnitInfoContent/NameLabel
@onready var description_label: Label = $DockPadding/DockLayout/UnitInfo/UnitInfoContent/DescriptionLabel
@onready var movement_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsPanel/StatsPadding/StatsContent/StatsRow/MovementStat/MovementValue
@onready var speed_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsPanel/StatsPadding/StatsContent/StatsRow/SpeedStat/SpeedValue
@onready var damage_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsPanel/StatsPadding/StatsContent/StatsRow/DamageStat/DamageValue
@onready var range_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsPanel/StatsPadding/StatsContent/StatsRow/RangeStat/RangeValue
@onready var health_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsPanel/StatsPadding/StatsContent/StatsRow/HealthStat/HealthValue
#@onready var effect_overlay: ColorRect = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsPanel/EffectOverlay
@onready var portrait_hex: HexPortraitDisplay = $DockPadding/DockLayout/PortraitCenter/PortraitHex

var _stats_panel_normal: StyleBoxFlat

func _ready() -> void:
	_cache_styles()
	clear_context()
	set_visual_state(STATE_IDLE)


func set_context(unit: Unit, phase: int) -> void:
	if unit == null:
		clear_context()
		return

	name_label.text = unit.unit_name
	description_label.text = unit.description
	_update_portrait(unit)

	movement_value_label.text = str(unit.movement)
	speed_value_label.text = str(unit.speed)
	damage_value_label.text = "%d-%d" % [unit.dmg_min, unit.dmg_max]
	range_value_label.text = str(unit.reach)
	health_value_label.text = "%d/%d" % [unit.health, unit.max_health]

	if phase >= 0:
		set_visual_state(STATE_ACTIVE_TURN)
	else:
		set_visual_state(STATE_IDLE)


func clear_context() -> void:
	name_label.text = "No active troop"
	description_label.text = ""
	_set_portrait_texture(null)
	movement_value_label.text = "-"
	speed_value_label.text = "-"
	damage_value_label.text = "-"
	range_value_label.text = "-"
	health_value_label.text = "-"


func set_visual_state(state_name: String) -> void:
	if stats_panel == null: # or effect_overlay == null:
		return

	if _stats_panel_normal == null:
		_cache_styles()

	match state_name:
		STATE_ACTIVE_TURN:
			stats_panel.add_theme_stylebox_override("panel", _stats_panel_normal)
			#effect_overlay.visible = false
		_:
			stats_panel.add_theme_stylebox_override("panel", _stats_panel_normal)
			#effect_overlay.visible = false


func _cache_styles() -> void:
	if stats_panel == null:
		_stats_panel_normal = StyleBoxFlat.new()
		return

	var panel_style := stats_panel.get_theme_stylebox("panel")
	if panel_style is StyleBoxFlat:
		_stats_panel_normal = panel_style.duplicate() as StyleBoxFlat
	else:
		_stats_panel_normal = StyleBoxFlat.new()


func _update_portrait(unit: Unit) -> void:
	var portrait_path := PORTRAIT_PATH_TEMPLATE % unit.unit_id
	if ResourceLoader.exists(portrait_path, "Texture2D"):
		_set_portrait_texture(load(portrait_path) as Texture2D)
	else:
		_set_portrait_texture(null)


func _set_portrait_texture(texture: Texture2D) -> void:
	if portrait_hex == null:
		return

	portrait_hex.portrait_texture = texture
	portrait_hex.queue_redraw()

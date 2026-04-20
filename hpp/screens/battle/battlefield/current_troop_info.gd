extends PanelContainer
class_name CurrentTroopInfo

const PORTRAIT_PATH_TEMPLATE := "res://screens/battle/battlefield/assets/%s.png"

@onready var name_label: Label = $DockPadding/DockLayout/UnitInfo/UnitInfoContent/NameLabel
@onready var description_label: Label = $DockPadding/DockLayout/UnitInfo/UnitInfoContent/DescriptionLabel
@onready var movement_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsContent/StatsRow/MovementStat/MovementValue
@onready var speed_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsContent/StatsRow/SpeedStat/SpeedValue
@onready var damage_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsContent/StatsRow/DamageStat/DamageValue
@onready var range_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsContent/StatsRow/RangeStat/RangeValue
@onready var health_value_label: Label = $DockPadding/DockLayout/CenterInfoZone/StatsCenter/StatsContent/StatsRow/HealthStat/HealthValue
@onready var portrait_texture: TextureRect = $DockPadding/DockLayout/PortraitCenter/PortraitFrame/PortraitTexture

func _ready() -> void:
	clear_context()


func set_context(unit: Unit) -> void:
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


func clear_context() -> void:
	name_label.text = "No active troop"
	description_label.text = ""
	_set_portrait_texture(null)
	movement_value_label.text = "-"
	speed_value_label.text = "-"
	damage_value_label.text = "-"
	range_value_label.text = "-"
	health_value_label.text = "-"


func _update_portrait(unit: Unit) -> void:
	var portrait_path := PORTRAIT_PATH_TEMPLATE % unit.unit_id
	if ResourceLoader.exists(portrait_path, "Texture2D"):
		_set_portrait_texture(load(portrait_path) as Texture2D)
	else:
		_set_portrait_texture(null)


func _set_portrait_texture(texture: Texture2D) -> void:
	if portrait_texture == null:
		return

	portrait_texture.texture = texture

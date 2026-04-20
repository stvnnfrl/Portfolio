extends Unit
class_name Lich

func spawn_ghoul(spawn_rate: float) -> Unit:
	if randf() <= spawn_rate:
		var anim = get_node("AnimatedPixelArt")
		anim.play("summon")
		await get_tree().create_timer(0.6).timeout
		anim.play("idle")
		
		var ghoul_scene = preload("res://army/units/ghoul.tscn")
		
		
		return ghoul_scene.instantiate()
	return null

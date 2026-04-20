extends Unit
class_name SpectralRider

var phase1 = true

func has_phase2():
	if phase1:
		phase1 = false
		return true
	return false


func transform_to_phase2() -> Unit:
	var horse_scene = preload("res://army/units/spectral_horse.tscn")
	var horse = horse_scene.instantiate()

	horse.cubic_pos = cubic_pos
	horse.army_id = army_id

	return horse

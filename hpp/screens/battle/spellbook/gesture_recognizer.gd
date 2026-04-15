class_name GestureRecognizer
extends Node

func _ready() -> void:
	load_templates()

# Template pipeline

var templates : Dictionary = {}

func normalize(points : PackedVector2Array, point_count : int = 64) -> PackedVector2Array:
	# run step 1 to 3 of algorithm
	points = resample(points, point_count)
	points = rotate_to_zero(points)
	points = scale_to_square(points, 250)
	points = translate_to_origin(points)
	return points
	
func add_template(spell_name: String, raw_points: PackedVector2Array):
	var normalized_points : PackedVector2Array = normalize(raw_points)
	
	if not templates.has(spell_name):
		templates[spell_name] = []
	
	templates[spell_name].append(normalized_points)
	save_templates()
	
func save_templates():
	var file = FileAccess.open("res://common/spells_resources/spells.json", FileAccess.WRITE)
	if file:
		var data_to_save : Dictionary = {}
		for spell_name in templates:
			data_to_save[spell_name] = []
			for example in templates[spell_name]:
				# convert to array for Json file
				var point_list : Array = []
				for p in example:
					point_list.append([p.x, p.y])
				data_to_save[spell_name].append(point_list)
		
		file.store_string(JSON.stringify(data_to_save))
		file.close()

func load_templates():
	# check if file exists
	if not FileAccess.file_exists("res://common/spells_resources/spells.json"):
		return
		
	var file : FileAccess = FileAccess.open("res://common/spells_resources/spells.json", FileAccess.READ)
	var text : String = file.get_as_text()
	var json : JSON = JSON.new()
	var parse_result : Error = json.parse(text)
	
	if parse_result == OK:
		var loaded_data = json.data
		# clear dictionnary to make sure it is empty before adding data from file
		templates.clear()
		
		# Convert arrays [x, y] back to Vector2 for algorithm
		for spell_name in loaded_data:
			templates[spell_name] = []
			for example_array in loaded_data[spell_name]:
				var vec_array : PackedVector2Array = PackedVector2Array()
				for p_data in example_array:
					vec_array.append(Vector2(p_data[0], p_data[1]))
				templates[spell_name].append(vec_array)


# $1 algorithm code

# Step 1: Resampling

func resample(points: PackedVector2Array, n: int = 64) -> PackedVector2Array:
	
	# Don't bother resampling if the drawing is too small
	if points.size() < 2:
		return points
		
	var total_length : float = _path_length(points)
	# Don't bother resampling if the drawing is too small
	if total_length < 1.0:
		return points
	
	var interval : float = total_length / (n - 1)
	var distance : float = 0.0
	
	var new_points : PackedVector2Array = PackedVector2Array()
	new_points.append(points[0])
	
	var i : int = 1
	
	while i < points.size():
		var p1 : Vector2 = points[i - 1]
		var p2 : Vector2 = points[i]
		var tmp_distance : float = p1.distance_to(p2)
		
		if (distance + tmp_distance) >= interval:
			var interpolation_factor : float = ((interval - distance) / tmp_distance)
			var new_x : float = p1[0] + interpolation_factor * (p2[0] - p1[0])
			var new_y : float = p1[1] + interpolation_factor * (p2[1] - p1[1])
			var new_vector : Vector2 = Vector2(new_x, new_y)
			new_points.append(new_vector)
			points.insert(i, new_vector)
			distance = 0.0
		else:
			distance += tmp_distance
			
		i += 1
				
	return new_points

func _path_length(points: PackedVector2Array) -> float:
	
	var distance : float = 0.0
	for i in range(points.size() - 1):
		distance += points[i].distance_to(points[i + 1])	
	return distance

# Step 2: Rotating points

func rotate_to_zero(points : PackedVector2Array) -> PackedVector2Array:
	
	var new_points : PackedVector2Array = PackedVector2Array()
	
	var centroid : Vector2 = _centroid(points)
	var theta : float = atan2(centroid[1] - points[0][1], centroid[0] - points[0][0])
	
	new_points = _rotate_by(points, -theta)
	return new_points

func _centroid(points : PackedVector2Array) -> Vector2:
	
	var centroid : Vector2 = Vector2.ZERO
	for point in points:
		centroid += point
		
	centroid /= points.size()
	return centroid

func _rotate_by(points : PackedVector2Array, theta : float) -> PackedVector2Array:
	var centroid : Vector2 = _centroid(points)
	var new_points : PackedVector2Array = PackedVector2Array()
	
	for point in points:
		var new_x : float = (point[0] - centroid[0]) * cos(theta) - (point[1] - centroid[1]) * sin(theta) + centroid[0]
		var new_y : float = (point[0] - centroid[0]) * sin(theta) + (point[1] - centroid[1]) * cos(theta) + centroid[1]
		new_points.append(Vector2(new_x, new_y))
		
	return new_points

# Step 3: scaling

func scale_to_square(points : PackedVector2Array, size : int) -> PackedVector2Array:
	var bounding_box : Vector2 = _find_width_height_BB(points)
	var new_points : PackedVector2Array = PackedVector2Array()
	
	for point in points:
		var new_x : float = point[0] * (size / bounding_box[0])
		var new_y : float = point[1] * (size / bounding_box[1])
		new_points.append(Vector2(new_x, new_y))
	
	return new_points

func translate_to_origin(points : PackedVector2Array) -> PackedVector2Array:
	var centroid : Vector2 = _centroid(points)
	var new_points : PackedVector2Array = PackedVector2Array()
	
	for point in points:
		var new_x : float = point[0] - centroid[0]
		var new_y : float = point[1] - centroid[1]
		new_points.append(Vector2(new_x, new_y))
		
	return new_points

func _find_width_height_BB(points: PackedVector2Array) -> Vector2:
	var min_x : float = INF
	var max_x : float = -INF
	var min_y : float = INF
	var max_y : float = -INF
	
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	var width = max(max_x - min_x, 0.01)
	var height = max(max_y - min_y, 0.01)
	
	return Vector2(width, height)

# Step 4 : recognizing

func recognize(points: PackedVector2Array, template_dict: Dictionary) -> Dictionary:
	# safety check
	if template_dict.is_empty():
		return { "name": "No Templates Loaded", "score": 0.0 }
	
	var best_distance : float = INF
	var best_name : String = "TBD"
	
	for spell_name in template_dict:
		for template_points in template_dict[spell_name]:
			var distance : float = _distance_at_best_angle(points, template_points, -PI/4, PI/4, 2.0 * PI / 180.0)
		
			if distance < best_distance:
				best_distance = distance
				best_name = spell_name

	# Box size TBD !!
	var box_size : float = 250.0
	var tmp_half_sqrt : float = sqrt(2 * pow(box_size, 2)) / 2.0
	var score : float = 1.0 - (best_distance / tmp_half_sqrt)
	
	return { "name": best_name, "score": score }

func _distance_at_best_angle(points: PackedVector2Array, T: PackedVector2Array, theta_a: float, theta_b: float, theta_delta: float) -> float:
	var phi : float = 0.5 * (-1.0 + sqrt(5.0))
	
	var x1 : float = phi * theta_a + (1.0 - phi) * theta_b
	var f1 : float = _distance_at_angle(points, T, x1)
	var x2 : float = (1.0 - phi) * theta_a + phi * theta_b
	var f2 : float = _distance_at_angle(points, T, x2)
	
	while abs(theta_b - theta_a) > theta_delta:
		if f1 < f2:
			theta_b = x2
			x2 = x1
			f2 = f1
			x1 = phi * theta_a + (1.0 - phi) * theta_b
			f1 = _distance_at_angle(points, T, x1)
		else:
			theta_a = x1
			x1 = x2
			f1 = f2
			x2 = (1.0 - phi) * theta_a + phi * theta_b
			f2 = _distance_at_angle(points, T, x2)

	return min(f1, f2)

func _distance_at_angle(points: PackedVector2Array, T: PackedVector2Array, theta: float) -> float:
	var new_points : PackedVector2Array = _rotate_by(points, theta)
	return _path_distance(new_points, T)

func _path_distance(points_1 : PackedVector2Array, points_2 : PackedVector2Array) -> float:
	var distance : float = 0.0
	# safety to make sure we don't get an out of bounds error
	var length : int = min(points_1.size(), points_2.size())
	
	for i in range(length):
		distance += points_1[i].distance_to(points_2[i])

	return distance / len(points_1)

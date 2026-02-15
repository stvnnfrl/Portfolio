class_name GestureRecognizer
extends Node

# ------- New file code --------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_resampler()
	test_rotation()

# Test function
func test_resampler():
	print("--- STARTING RESAMPLE TEST ---")
	
	# 1. Create a simple 3-point line (Total length = 100)
	var input_line = PackedVector2Array([
		Vector2(0, 0),
		Vector2(50, 0),
		Vector2(100, 0)
	])
	
	# 2. Resample it to 11 points (Target interval should be 10.0)
	var result = resample(input_line, 11)
	
	print("Original Points: ", input_line.size())
	print("Resampled Points: ", result.size())
	
	# 3. Verify distances
	print("Checking intervals (Should all be ~10.0):")
	for i in range(1, result.size()):
		var dist = result[i-1].distance_to(result[i])
		print("Segment ", i, ": ", snapped(dist, 0.001)) # Rounding for cleaner output
		
	print("--- TEST FINISHED ---")

func test_rotation():
	print("--- STARTING ROTATION TEST ---")
	
	# 1. Create a Vertical Line (Angle is 90 degrees / PI/2)
	# Start at (0,0), End at (0, 100). Centroid is at (0, 50).
	var input_line = PackedVector2Array([
		Vector2(0, 0),
		Vector2(0, 50),
		Vector2(0, 100)
	])
	
	print("Original Line First Point: ", input_line[0])
	print("Original Line Last Point: ", input_line[-1])
	
	# 2. Run your rotation function
	# This should rotate the shape so the "Start -> Centroid" vector points to 0 degrees (Right)
	var result = rotate_to_zero(input_line)
	
	# 3. Verify the output
	print("\n--- RESULTS ---")
	for i in range(result.size()):
		var p = result[i]
		# We use snapped() because float math often gives numbers like 0.0000001 instead of 0
		print("Point ", i, ": (", snapped(p.x, 0.01), ", ", snapped(p.y, 0.01), ")")

	# CHECK: The Y values should all be roughly the same (Points lie on a flat horizontal line)
	# Since we rotate around the centroid (0, 50), the centroid stays at (0, 50).
	# A vertical line through (0, 50) rotated 90 deg becomes a horizontal line through (0, 50).
	# So we expect Y to be approx 50.0 for all points.
	
	print("--- TEST FINISHED ---")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# ------- $1 algorithm code -------

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

#func scale_to_square(points : PackedVector2Array, size : int) -> PackedVector2Array:
	#
	#var bounding_box : Vector2 = _find_width_height_BB(points)
	#
	#for point in points:
		#var new_x : float = point[0] * (size / )
		
		
#func _find_width_height_BB(points : PackedVector2Array) -> Vector2:
	#
	#var min_x : float = INF
	#var max_x : float = INF
	#
	#for point in points:
		#var tmp_x : float = point[0]
		#var tmp_y : flaot = point[1]
		
		

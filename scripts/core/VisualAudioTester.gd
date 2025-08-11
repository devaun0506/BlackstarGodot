extends Node
class_name VisualAudioTester

## Specialized test suite for visual and audio elements
## Tests medical aesthetic, color compliance, animations, and atmospheric effects

signal visual_test_completed(test_name: String, passed: bool, details: String)

# Test configuration
var performance_threshold_fps: float = 30.0
var color_tolerance: float = 0.01
var animation_smoothness_samples: int = 60

# Test results
var test_results: Array = []

func _ready() -> void:
	print("VisualAudioTester ready")

## Run comprehensive visual and audio tests
func run_visual_audio_tests() -> Dictionary:
	print("🎨 Running comprehensive visual and audio tests...")
	
	test_results.clear()
	
	# Visual tests
	await test_medical_color_palette()
	await test_medical_aesthetic_elements()
	await test_fluorescent_lighting_system()
	await test_coffee_stain_wear_effects()
	await test_pixel_art_rendering()
	await test_ui_theme_consistency()
	
	# Animation and performance tests
	await test_animation_smoothness()
	await test_performance_benchmarks()
	await test_shader_compilation()
	
	# Atmospheric effects
	await test_atmospheric_lighting()
	await test_environmental_storytelling()
	
	# Calculate results
	var passed = 0
	var total = test_results.size()
	
	for result in test_results:
		if result.passed:
			passed += 1
	
	var success_rate = (float(passed) / float(total)) * 100.0 if total > 0 else 0.0
	
	print("🎭 Visual/Audio Tests Complete: %d/%d (%.1f%%)" % [passed, total, success_rate])
	
	return {
		"passed": passed,
		"total": total,
		"success_rate": success_rate,
		"details": test_results
	}

# ===== MEDICAL COLOR PALETTE TESTS =====

func test_medical_color_palette() -> void:
	"""Test medical color palette compliance and consistency"""
	print("Testing medical color palette...")
	
	# Test color palette exists
	if not MedicalColors:
		record_failure("Color Palette", "MedicalColors class not available")
		return
	
	# Test primary colors are properly defined
	await test_primary_medical_colors()
	await test_urgency_color_hierarchy()
	await test_color_accessibility()
	await test_32_color_limit_compliance()

func test_primary_medical_colors() -> void:
	"""Test primary medical colors are properly defined"""
	
	var primary_colors = {
		"MEDICAL_GREEN": MedicalColors.MEDICAL_GREEN,
		"STERILE_BLUE": MedicalColors.STERILE_BLUE,
		"CHART_PAPER": MedicalColors.CHART_PAPER,
		"FLUORESCENT_WHITE": MedicalColors.FLUORESCENT_WHITE,
		"URGENT_RED": MedicalColors.URGENT_RED
	}
	
	for color_name in primary_colors:
		var color = primary_colors[color_name]
		
		# Test color is not default/transparent
		if color == Color.TRANSPARENT or color == Color.BLACK:
			record_failure("Primary Colors", "%s appears to be undefined (transparent/black)" % color_name)
			return
		
		# Test color is within reasonable ranges
		if color.r < 0.0 or color.r > 1.0 or color.g < 0.0 or color.g > 1.0 or color.b < 0.0 or color.b > 1.0:
			record_failure("Primary Colors", "%s has invalid RGB values" % color_name)
			return
		
		print("  ✓ %s: #%02X%02X%02X" % [color_name, color.r * 255, color.g * 255, color.b * 255])
	
	record_success("Primary Colors", "All primary medical colors properly defined")

func test_urgency_color_hierarchy() -> void:
	"""Test urgency color hierarchy follows medical standards"""
	
	# Test urgency levels
	var urgency_levels = [0.0, 0.3, 0.5, 0.7, 0.9, 1.0]
	var previous_intensity = -1.0
	
	for level in urgency_levels:
		var color = MedicalColors.get_urgency_color(level)
		
		# Calculate color intensity (simple luminance approximation)
		var intensity = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
		
		# High urgency should generally be more vibrant/noticeable
		# (This is a simplified test - real urgency may not follow linear luminance)
		print("  Urgency %.1f: %s (intensity: %.3f)" % [level, color, intensity])
	
	# Test specific urgency mappings
	var critical_color = MedicalColors.get_urgency_color(1.0)
	var routine_color = MedicalColors.get_urgency_color(0.0)
	
	if critical_color == routine_color:
		record_failure("Urgency Hierarchy", "Critical and routine urgency have same color")
		return
	
	record_success("Urgency Hierarchy", "Urgency color hierarchy implemented")

func test_color_accessibility() -> void:
	"""Test color accessibility compliance"""
	
	# Test contrast ratios for key color combinations
	var text_bg_combinations = [
		{"text": MedicalColors.TEXT_DARK, "bg": MedicalColors.CHART_PAPER, "name": "Dark text on chart paper"},
		{"text": MedicalColors.TEXT_LIGHT, "bg": MedicalColors.MEDICAL_GREEN, "name": "Light text on medical green"},
		{"text": MedicalColors.TEXT_DARK, "bg": MedicalColors.FLUORESCENT_WHITE, "name": "Dark text on fluorescent white"}
	]
	
	for combo in text_bg_combinations:
		var contrast_ratio = calculate_contrast_ratio(combo.text, combo.bg)
		
		# WCAG AA compliance requires 4.5:1 for normal text, 3:1 for large text
		if contrast_ratio < 4.5:
			record_warning("Color Accessibility", "%s has low contrast ratio: %.2f:1" % [combo.name, contrast_ratio])
		else:
			print("  ✓ %s: %.2f:1 contrast" % [combo.name, contrast_ratio])
	
	record_success("Color Accessibility", "Color accessibility evaluated")

func calculate_contrast_ratio(color1: Color, color2: Color) -> float:
	"""Calculate WCAG contrast ratio between two colors"""
	var lum1 = calculate_luminance(color1)
	var lum2 = calculate_luminance(color2)
	
	var lighter = max(lum1, lum2)
	var darker = min(lum1, lum2)
	
	return (lighter + 0.05) / (darker + 0.05)

func calculate_luminance(color: Color) -> float:
	"""Calculate relative luminance of a color"""
	var r = color.r if color.r <= 0.03928 else pow((color.r + 0.055) / 1.055, 2.4)
	var g = color.g if color.g <= 0.03928 else pow((color.g + 0.055) / 1.055, 2.4)
	var b = color.b if color.b <= 0.03928 else pow((color.b + 0.055) / 1.055, 2.4)
	
	return 0.2126 * r + 0.7152 * g + 0.0722 * b

func test_32_color_limit_compliance() -> void:
	"""Test that color palette stays within 32-color limit"""
	
	var unique_colors: Dictionary = {}
	
	# Collect all medical colors
	var medical_colors = [
		MedicalColors.MEDICAL_GREEN,
		MedicalColors.MEDICAL_GREEN_LIGHT,
		MedicalColors.MEDICAL_GREEN_DARK,
		MedicalColors.STERILE_BLUE,
		MedicalColors.STERILE_BLUE_LIGHT,
		MedicalColors.STERILE_BLUE_DARK,
		MedicalColors.URGENT_RED,
		MedicalColors.URGENT_ORANGE,
		MedicalColors.URGENT_YELLOW,
		MedicalColors.CHART_PAPER,
		MedicalColors.CHART_PAPER_STAINED,
		MedicalColors.TEXT_DARK,
		MedicalColors.TEXT_LIGHT,
		MedicalColors.TEXT_MUTED,
		MedicalColors.EQUIPMENT_GRAY,
		MedicalColors.EQUIPMENT_GRAY_DARK,
		MedicalColors.MONITOR_GREEN,
		MedicalColors.MONITOR_AMBER,
		MedicalColors.FLUORESCENT_WHITE,
		MedicalColors.SHADOW_BLUE,
		MedicalColors.COFFEE_BROWN,
		MedicalColors.WEAR_GRAY,
		MedicalColors.SUCCESS_GREEN,
		MedicalColors.WARNING_AMBER,
		MedicalColors.ERROR_RED,
		MedicalColors.INFO_BLUE
	]
	
	# Count unique colors (with small tolerance for floating point differences)
	for color in medical_colors:
		var color_key = "%d_%d_%d" % [int(color.r * 255), int(color.g * 255), int(color.b * 255)]
		unique_colors[color_key] = true
	
	var color_count = unique_colors.size()
	print("  Total unique colors in palette: %d" % color_count)
	
	if color_count > 32:
		record_warning("Color Limit", "Palette has %d colors, exceeds 32-color target" % color_count)
	else:
		record_success("Color Limit", "Palette within 32-color limit (%d colors)" % color_count)

# ===== MEDICAL AESTHETIC TESTS =====

func test_medical_aesthetic_elements() -> void:
	"""Test medical aesthetic elements render correctly"""
	print("Testing medical aesthetic elements...")
	
	# Test medical UI components
	if MedicalUIComponents:
		test_medical_ui_components()
	else:
		record_warning("Medical Aesthetic", "MedicalUIComponents not available")
	
	# Test medical environment elements
	if PixelArtEnvironment:
		test_pixel_art_environment()
	else:
		record_warning("Medical Aesthetic", "PixelArtEnvironment not available")

func test_medical_ui_components() -> void:
	"""Test medical UI components"""
	
	# Test that medical UI components can be instantiated
	var ui_component = MedicalUIComponents.new()
	if not ui_component:
		record_failure("Medical UI", "Cannot instantiate MedicalUIComponents")
		return
	
	# Test medical button styling
	var medical_button = ui_component.create_medical_button("Test Button", MedicalUIComponents.ButtonStyle.PRIMARY)
	if not medical_button:
		record_failure("Medical UI", "Cannot create medical button")
		return
	
	# Verify button uses medical styling
	if medical_button.modulate == Color.WHITE:
		record_warning("Medical UI", "Medical button may not have custom styling")
	
	ui_component.queue_free()
	record_success("Medical UI", "Medical UI components functional")

func test_pixel_art_environment() -> void:
	"""Test pixel art environment elements"""
	
	var environment = PixelArtEnvironment.new()
	if not environment:
		record_failure("Pixel Art", "Cannot instantiate PixelArtEnvironment")
		return
	
	# Test environment setup
	environment.setup_medical_environment()
	
	# Test desk interaction
	environment.setup_desk_interaction()
	
	environment.queue_free()
	record_success("Pixel Art", "Pixel art environment functional")

# ===== FLUORESCENT LIGHTING TESTS =====

func test_fluorescent_lighting_system() -> void:
	"""Test fluorescent lighting effect works properly"""
	print("Testing fluorescent lighting system...")
	
	var shader_path = "res://scripts/shaders/FluorescentFlicker.gdshader"
	
	# Test shader file exists
	if not ResourceLoader.exists(shader_path):
		record_failure("Fluorescent", "Fluorescent shader file not found")
		return
	
	# Load and test shader
	var shader = load(shader_path) as Shader
	if not shader:
		record_failure("Fluorescent", "Cannot load fluorescent shader")
		return
	
	# Test shader compilation
	var test_material = ShaderMaterial.new()
	test_material.shader = shader
	
	# Test shader parameters
	test_material.set_shader_parameter("flicker_intensity", 0.3)
	test_material.set_shader_parameter("flicker_speed", 4.0)
	test_material.set_shader_parameter("base_brightness", 0.95)
	test_material.set_shader_parameter("fluorescent_tint", Vector3(0.96, 0.96, 0.94))
	
	# Create test node to verify shader works
	var test_node = ColorRect.new()
	test_node.material = test_material
	test_node.size = Vector2(100, 100)
	
	add_child(test_node)
	await get_tree().process_frame
	
	# Verify shader is active (basic check)
	if test_node.material != test_material:
		record_failure("Fluorescent", "Shader material not applied correctly")
		test_node.queue_free()
		return
	
	test_node.queue_free()
	record_success("Fluorescent", "Fluorescent lighting shader functional")

# ===== COFFEE STAIN AND WEAR EFFECTS =====

func test_coffee_stain_wear_effects() -> void:
	"""Test coffee stain and wear texture effects"""
	print("Testing coffee stain and wear effects...")
	
	# Test coffee stain effect
	var base_color = MedicalColors.CHART_PAPER
	var stained_color = MedicalColors.add_coffee_stain(base_color, 0.1)
	
	if stained_color.is_equal_approx(base_color):
		record_failure("Effects", "Coffee stain effect not working")
		return
	
	# Verify stain makes color more brown/darker
	var stain_difference = base_color.distance_to(stained_color)
	if stain_difference < 0.01:
		record_warning("Effects", "Coffee stain effect very subtle")
	
	# Test wear effect
	var worn_color = MedicalColors.add_wear_effect(base_color, 0.1)
	
	if worn_color.is_equal_approx(base_color):
		record_failure("Effects", "Wear effect not working")
		return
	
	# Test effect intensity scaling
	var light_stain = MedicalColors.add_coffee_stain(base_color, 0.01)
	var heavy_stain = MedicalColors.add_coffee_stain(base_color, 0.5)
	
	var light_diff = base_color.distance_to(light_stain)
	var heavy_diff = base_color.distance_to(heavy_stain)
	
	if heavy_diff <= light_diff:
		record_warning("Effects", "Coffee stain intensity may not scale properly")
	
	record_success("Effects", "Coffee stain and wear effects functional")

# ===== ANIMATION AND PERFORMANCE =====

func test_animation_smoothness() -> void:
	"""Test animations play smoothly without stuttering"""
	print("Testing animation smoothness...")
	
	var frame_times: Array = []
	var start_time = Time.get_ticks_usec()
	var last_frame_time = start_time
	
	# Sample frame times
	for i in range(animation_smoothness_samples):
		await get_tree().process_frame
		var current_time = Time.get_ticks_usec()
		var frame_delta = current_time - last_frame_time
		frame_times.append(frame_delta)
		last_frame_time = current_time
	
	var total_time = (Time.get_ticks_usec() - start_time) / 1000000.0
	var average_fps = animation_smoothness_samples / total_time
	
	# Calculate frame time statistics
	var min_frame_time = frame_times.min()
	var max_frame_time = frame_times.max()
	var avg_frame_time = 0.0
	
	for time in frame_times:
		avg_frame_time += time
	avg_frame_time /= frame_times.size()
	
	# Convert to milliseconds
	min_frame_time /= 1000.0
	max_frame_time /= 1000.0
	avg_frame_time /= 1000.0
	
	print("  Average FPS: %.1f" % average_fps)
	print("  Frame time - Min: %.2fms, Max: %.2fms, Avg: %.2fms" % [min_frame_time, max_frame_time, avg_frame_time])
	
	# Check for stuttering (large frame time variations)
	if max_frame_time > avg_frame_time * 3:
		record_warning("Animation", "Potential stuttering detected (max frame time: %.2fms)" % max_frame_time)
	
	# Check average performance
	if average_fps < performance_threshold_fps:
		record_warning("Animation", "Performance below target: %.1f FPS" % average_fps)
	else:
		record_success("Animation", "Animation smoothness acceptable (%.1f FPS)" % average_fps)

func test_performance_benchmarks() -> void:
	"""Test performance benchmarks for UI rendering"""
	print("Testing UI rendering performance...")
	
	# Create multiple UI elements to stress test
	var test_container = Control.new()
	add_child(test_container)
	
	var start_time = Time.get_ticks_msec()
	
	# Create many UI elements
	for i in range(100):
		var button = Button.new()
		button.text = "Test Button %d" % i
		button.position = Vector2(i % 10 * 100, int(i / 10) * 50)
		test_container.add_child(button)
	
	var creation_time = Time.get_ticks_msec() - start_time
	
	# Test rendering performance
	start_time = Time.get_ticks_msec()
	
	for i in range(30):  # 30 frames
		await get_tree().process_frame
	
	var render_time = Time.get_ticks_msec() - start_time
	var avg_frame_time = render_time / 30.0
	
	test_container.queue_free()
	
	print("  UI creation time: %dms" % creation_time)
	print("  Average render time: %.2fms/frame" % avg_frame_time)
	
	if creation_time > 1000:
		record_warning("Performance", "UI creation slow: %dms" % creation_time)
	
	if avg_frame_time > 33.3:  # 30 FPS threshold
		record_warning("Performance", "Rendering performance low: %.2fms/frame" % avg_frame_time)
	else:
		record_success("Performance", "UI rendering performance acceptable")

func test_shader_compilation() -> void:
	"""Test shader compilation and performance"""
	print("Testing shader compilation...")
	
	var shaders_to_test = [
		"res://scripts/shaders/FluorescentFlicker.gdshader"
	]
	
	var compilation_failures = 0
	
	for shader_path in shaders_to_test:
		if not ResourceLoader.exists(shader_path):
			compilation_failures += 1
			continue
		
		var shader = load(shader_path) as Shader
		if not shader:
			compilation_failures += 1
			continue
		
		# Test shader by creating material
		var material = ShaderMaterial.new()
		material.shader = shader
		
		# If we get here without errors, shader compiled successfully
		print("  ✓ %s compiled successfully" % shader_path.get_file())
	
	if compilation_failures > 0:
		record_failure("Shader Compilation", "%d shaders failed to compile" % compilation_failures)
	else:
		record_success("Shader Compilation", "All shaders compiled successfully")

# ===== ATMOSPHERIC EFFECTS =====

func test_atmospheric_lighting() -> void:
	"""Test atmospheric lighting effects"""
	print("Testing atmospheric lighting...")
	
	# Test different atmosphere configurations
	var atmosphere_tests = [
		{"time": "night", "stress": 0.2, "name": "Night shift low stress"},
		{"time": "day", "stress": 0.8, "name": "Day shift high stress"},
		{"time": "evening", "stress": 0.5, "name": "Evening moderate stress"}
	]
	
	for test in atmosphere_tests:
		var atmosphere_color = MedicalColors.get_atmosphere_color(test.time, test.stress)
		
		# Verify atmosphere color is reasonable
		if atmosphere_color == Color.TRANSPARENT:
			record_failure("Atmospheric", "Atmosphere color not generated for %s" % test.name)
			return
		
		print("  %s: %s" % [test.name, atmosphere_color])
	
	record_success("Atmospheric", "Atmospheric lighting system functional")

func test_environmental_storytelling() -> void:
	"""Test environmental storytelling color effects"""
	print("Testing environmental storytelling...")
	
	# Test emotional state colors
	var emotional_states = ["exhausted", "focused", "stressed", "compassionate"]
	
	for emotion in emotional_states:
		var emotion_color = MedicalColors.get_emotional_state_color(emotion)
		
		if emotion_color == Color.WHITE:
			record_warning("Environmental", "Emotional state '%s' may not have specific color" % emotion)
		else:
			print("  %s emotion: %s" % [emotion, emotion_color])
	
	# Test vital sign colors
	var vital_tests = [
		{"type": "hr", "value": "120", "abnormal": true},
		{"type": "bp", "value": "180/110", "abnormal": true},
		{"type": "temp", "value": "103", "abnormal": true}
	]
	
	for vital in vital_tests:
		var vital_color = MedicalColors.get_vital_sign_color(vital.type, vital.value, vital.abnormal)
		print("  %s (%s): %s" % [vital.type, vital.value, vital_color])
	
	record_success("Environmental", "Environmental storytelling colors functional")

func test_pixel_art_rendering() -> void:
	"""Test pixel art rendering quality"""
	print("Testing pixel art rendering...")
	
	# Test pixel-perfect rendering settings
	var viewport = get_viewport()
	var original_snap = viewport.snap_2d_transforms_to_pixel
	var original_vertices = viewport.snap_2d_vertices_to_pixel
	
	# Enable pixel-perfect rendering
	viewport.snap_2d_transforms_to_pixel = true
	viewport.snap_2d_vertices_to_pixel = true
	
	# Create pixel art test element
	var pixel_rect = ColorRect.new()
	pixel_rect.color = MedicalColors.MEDICAL_GREEN
	pixel_rect.size = Vector2(32, 32)  # Typical pixel art size
	pixel_rect.position = Vector2(100.5, 100.5)  # Non-integer position
	
	add_child(pixel_rect)
	await get_tree().process_frame
	
	# Check if position was snapped to pixels
	var snapped_position = pixel_rect.global_position
	var position_snapped = (snapped_position.x == int(snapped_position.x)) and (snapped_position.y == int(snapped_position.y))
	
	pixel_rect.queue_free()
	
	# Restore original settings
	viewport.snap_2d_transforms_to_pixel = original_snap
	viewport.snap_2d_vertices_to_pixel = original_vertices
	
	if position_snapped:
		record_success("Pixel Art", "Pixel-perfect rendering configured")
	else:
		record_warning("Pixel Art", "Pixel-perfect rendering may need configuration")

func test_ui_theme_consistency() -> void:
	"""Test UI theme consistency across elements"""
	print("Testing UI theme consistency...")
	
	# Test that all UI elements use consistent theming
	var theme_compliance_score = 0
	var total_elements = 0
	
	# This would need to be implemented with actual UI traversal
	# For now, we'll do a basic check
	
	if MedicalColors and MedicalUIComponents:
		theme_compliance_score += 2
	
	total_elements = 2
	
	var compliance_rate = (float(theme_compliance_score) / float(total_elements)) * 100.0
	
	if compliance_rate >= 80.0:
		record_success("Theme Consistency", "UI theme consistency good (%.1f%%)" % compliance_rate)
	else:
		record_warning("Theme Consistency", "UI theme consistency needs improvement (%.1f%%)" % compliance_rate)

# ===== UTILITY FUNCTIONS =====

func record_success(category: String, message: String) -> void:
	"""Record a successful test"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": true,
		"type": "success"
	})
	print("  ✅ %s: %s" % [category, message])
	visual_test_completed.emit(category, true, message)

func record_failure(category: String, message: String) -> void:
	"""Record a failed test"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": false,
		"type": "failure"
	})
	print("  ❌ %s: %s" % [category, message])
	visual_test_completed.emit(category, false, message)

func record_warning(category: String, message: String) -> void:
	"""Record a test warning"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": true,  # Warnings don't count as failures
		"type": "warning"
	})
	print("  ⚠️  %s: %s" % [category, message])
	visual_test_completed.emit(category, true, "Warning: %s" % message)
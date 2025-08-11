extends RefCounted
class_name MenuScenePostFixValidator

## Post-Fix Validation Test Suite for MenuScene
##
## Comprehensive testing procedures to validate MenuScene after CodeReviewAgent fixes
## Ensures compilation, medical theming, and functionality remain intact after corrections

signal test_completed(results: Dictionary)
signal test_progress(test_name: String, status: String)

# Test configuration
var test_timeout: float = 30.0
var skip_visual_tests: bool = false
var verbose_output: bool = true

# Test results tracking
var test_results: Dictionary = {
	"compilation": {},
	"medical_theming": {},
	"functionality": {},
	"visual_rendering": {},
	"responsive_design": {},
	"performance": {},
	"summary": {}
}

func run_post_fix_validation() -> Dictionary:
	"""Run complete post-fix validation suite for MenuScene"""
	
	print("\n=== MENUSCENE POST-FIX VALIDATION SUITE ===")
	print("Testing MenuScene after CodeReviewAgent fixes...")
	print("Target: Ensure no regressions after error corrections\n")
	
	var start_time = Time.get_ticks_msec()
	
	# 1. CRITICAL: Compilation and Loading Tests
	_emit_progress("Compilation Tests", "running")
	test_results.compilation = await _run_compilation_tests()
	_emit_progress("Compilation Tests", "completed")
	
	# Only proceed if compilation passes
	if not test_results.compilation.get("all_passed", false):
		print("❌ CRITICAL: Compilation tests failed - stopping validation")
		return _finalize_results(start_time)
	
	# 2. Medical Theming Preservation Tests
	_emit_progress("Medical Theming Tests", "running")
	test_results.medical_theming = await _run_medical_theming_tests()
	_emit_progress("Medical Theming Tests", "completed")
	
	# 3. Core Functionality Tests
	_emit_progress("Functionality Tests", "running") 
	test_results.functionality = await _run_functionality_tests()
	_emit_progress("Functionality Tests", "completed")
	
	# 4. Visual Rendering Tests
	if not skip_visual_tests:
		_emit_progress("Visual Rendering Tests", "running")
		test_results.visual_rendering = await _run_visual_rendering_tests()
		_emit_progress("Visual Rendering Tests", "completed")
	
	# 5. Responsive Design Tests
	_emit_progress("Responsive Design Tests", "running")
	test_results.responsive_design = await _run_responsive_design_tests()
	_emit_progress("Responsive Design Tests", "completed")
	
	# 6. Performance Impact Tests
	_emit_progress("Performance Tests", "running")
	test_results.performance = await _run_performance_tests()
	_emit_progress("Performance Tests", "completed")
	
	return _finalize_results(start_time)

func _run_compilation_tests() -> Dictionary:
	"""Test that MenuScene compiles and loads without errors"""
	
	var results = {
		"all_passed": false,
		"tests": [],
		"errors": []
	}
	
	print("📋 COMPILATION TESTS")
	print("====================")
	
	# Test 1: Script compilation
	var script_test = await _test_script_compilation()
	results.tests.append(script_test)
	if not script_test.passed:
		results.errors.append(script_test.error)
	
	# Test 2: Scene loading
	var scene_test = await _test_scene_loading()
	results.tests.append(scene_test)
	if not scene_test.passed:
		results.errors.append(scene_test.error)
	
	# Test 3: Dependencies availability
	var deps_test = await _test_dependency_availability()
	results.tests.append(deps_test)
	if not deps_test.passed:
		results.errors.append(deps_test.error)
	
	# Test 4: Scene instantiation
	var instantiation_test = await _test_scene_instantiation()
	results.tests.append(instantiation_test)
	if not instantiation_test.passed:
		results.errors.append(instantiation_test.error)
	
	# Calculate overall success
	var passed_count = 0
	for test in results.tests:
		if test.passed:
			passed_count += 1
	
	results.all_passed = passed_count == results.tests.size()
	
	print("Compilation Tests: %d/%d passed\n" % [passed_count, results.tests.size()])
	
	return results

func _test_script_compilation() -> Dictionary:
	"""Test MenuScene.gd compiles without parser errors"""
	
	var test_result = {
		"name": "MenuScene Script Compilation",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	# Attempt to load the script directly
	var script = load("res://scripts/ui/MenuScene.gd")
	if script:
		test_result.passed = true
		test_result.details.script_resource = str(script)
		if verbose_output:
			print("  ✅ MenuScene.gd compiles successfully")
	else:
		test_result.error = "MenuScene.gd failed to load as script resource"
		if verbose_output:
			print("  ❌ MenuScene.gd compilation failed")
	
	return test_result

func _test_scene_loading() -> Dictionary:
	"""Test MenuScene.tscn loads without errors"""
	
	var test_result = {
		"name": "MenuScene Scene Loading",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	# Check if scene file exists
	if not ResourceLoader.exists("res://scenes/MenuScene.tscn"):
		test_result.error = "MenuScene.tscn file not found"
		if verbose_output:
			print("  ❌ MenuScene.tscn file missing")
		return test_result
	
	# Attempt to load scene
	var scene_resource = load("res://scenes/MenuScene.tscn")
	if scene_resource and scene_resource is PackedScene:
		test_result.passed = true
		test_result.details.scene_resource = str(scene_resource)
		if verbose_output:
			print("  ✅ MenuScene.tscn loads successfully")
	else:
		test_result.error = "MenuScene.tscn failed to load as PackedScene"
		if verbose_output:
			print("  ❌ MenuScene.tscn loading failed")
	
	return test_result

func _test_dependency_availability() -> Dictionary:
	"""Test that all MenuScene dependencies are available"""
	
	var test_result = {
		"name": "MenuScene Dependencies",
		"passed": false,
		"error": "",
		"details": {
			"available_classes": [],
			"missing_classes": []
		}
	}
	
	# Check required dependency classes
	var required_classes = [
		"MedicalColors",
		"MedicalFont",
		"AtmosphereController",
		"MobileResponsiveUI"
	]
	
	var missing_classes = []
	var available_classes = []
	
	for class_name in required_classes:
		if ClassDB.class_exists(class_name) or _can_instantiate_class(class_name):
			available_classes.append(class_name)
			if verbose_output:
				print("  ✅ %s dependency available" % class_name)
		else:
			missing_classes.append(class_name)
			if verbose_output:
				print("  ❌ %s dependency missing" % class_name)
	
	test_result.details.available_classes = available_classes
	test_result.details.missing_classes = missing_classes
	
	if missing_classes.size() == 0:
		test_result.passed = true
	else:
		test_result.error = "Missing required dependencies: " + str(missing_classes)
	
	return test_result

func _can_instantiate_class(class_name: String) -> bool:
	"""Check if a custom class can be instantiated"""
	
	var class_paths = {
		"MedicalColors": "res://scripts/ui/medical_theme/MedicalColors.gd",
		"MedicalFont": "res://scripts/ui/medical_theme/MedicalFont.gd",
		"AtmosphereController": "res://scripts/systems/AtmosphereController.gd",
		"MobileResponsiveUI": "res://scripts/ui/medical_theme/MobileResponsiveUI.gd"
	}
	
	if class_name in class_paths:
		var path = class_paths[class_name]
		return ResourceLoader.exists(path)
	
	return false

func _test_scene_instantiation() -> Dictionary:
	"""Test that MenuScene can be instantiated without runtime errors"""
	
	var test_result = {
		"name": "MenuScene Instantiation",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Load and instantiate scene
		var scene_resource = load("res://scenes/MenuScene.tscn")
		if scene_resource:
			var scene_instance = scene_resource.instantiate()
			if scene_instance:
				test_result.passed = true
				test_result.details.instance_type = str(scene_instance.get_script())
				
				# Clean up
				scene_instance.queue_free()
				
				if verbose_output:
					print("  ✅ MenuScene instantiates successfully")
			else:
				test_result.error = "MenuScene instantiation returned null"
				if verbose_output:
					print("  ❌ MenuScene instantiation failed")
		else:
			test_result.error = "MenuScene scene resource not available"
			if verbose_output:
				print("  ❌ MenuScene scene resource unavailable")
	
	
	return test_result

func _run_medical_theming_tests() -> Dictionary:
	"""Test that medical theming is preserved after fixes"""
	
	var results = {
		"all_passed": false,
		"tests": [],
		"errors": []
	}
	
	print("🏥 MEDICAL THEMING TESTS")
	print("=========================")
	
	# Test medical color palette access
	var colors_test = await _test_medical_colors_access()
	results.tests.append(colors_test)
	if not colors_test.passed:
		results.errors.append(colors_test.error)
	
	# Test medical font configuration
	var fonts_test = await _test_medical_font_access()
	results.tests.append(fonts_test)
	if not fonts_test.passed:
		results.errors.append(fonts_test.error)
	
	# Test medical UI component styling
	var styling_test = await _test_medical_ui_styling()
	results.tests.append(styling_test)
	if not styling_test.passed:
		results.errors.append(styling_test.error)
	
	# Test medical atmosphere integration
	var atmosphere_test = await _test_medical_atmosphere_integration()
	results.tests.append(atmosphere_test)
	if not atmosphere_test.passed:
		results.errors.append(atmosphere_test.error)
	
	# Calculate overall success
	var passed_count = 0
	for test in results.tests:
		if test.passed:
			passed_count += 1
	
	results.all_passed = passed_count == results.tests.size()
	
	print("Medical Theming Tests: %d/%d passed\n" % [passed_count, results.tests.size()])
	
	return results

func _test_medical_colors_access() -> Dictionary:
	"""Test that medical color constants are accessible"""
	
	var test_result = {
		"name": "Medical Colors Access",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test key medical colors used in MenuScene
		var medical_green = MedicalColors.MEDICAL_GREEN
		var urgent_red = MedicalColors.URGENT_RED
		var fluorescent_white = MedicalColors.FLUORESCENT_WHITE
		var chart_paper = MedicalColors.CHART_PAPER
		var equipment_gray = MedicalColors.EQUIPMENT_GRAY
		
		# Validate color values are reasonable
		if medical_green is Color and urgent_red is Color and fluorescent_white is Color:
			test_result.passed = true
			test_result.details.colors_tested = 5
			if verbose_output:
				print("  ✅ Medical colors accessible and valid")
		else:
			test_result.error = "Medical colors are not Color objects"
			if verbose_output:
				print("  ❌ Medical colors invalid types")
	
	
	return test_result

func _test_medical_font_access() -> Dictionary:
	"""Test that medical font configurations are accessible"""
	
	var test_result = {
		"name": "Medical Font Access",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test medical font configuration methods
		var chart_config = MedicalFont.get_chart_header_font_config()
		var button_config = MedicalFont.get_button_font_config()
		
		# Validate font configurations have required properties
		if chart_config.has("size") and chart_config.has("font_color") and \
		   button_config.has("size") and button_config.has("outline_size"):
			test_result.passed = true
			test_result.details.configs_tested = 2
			if verbose_output:
				print("  ✅ Medical font configurations accessible")
		else:
			test_result.error = "Medical font configurations missing required properties"
			if verbose_output:
				print("  ❌ Medical font configurations incomplete")
	
	
	return test_result

func _test_medical_ui_styling() -> Dictionary:
	"""Test that medical UI styling methods work"""
	
	var test_result = {
		"name": "Medical UI Styling",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test medical styling constants and methods
		var colors_applied = 0
		
		# Test color combinations used in button styling
		var primary_style = MedicalColors.URGENT_RED
		var secondary_style = MedicalColors.EQUIPMENT_GRAY
		var feedback_style = MedicalColors.INFO_BLUE
		var quit_style = MedicalColors.SHADOW_BLUE
		
		if primary_style is Color:
			colors_applied += 1
		if secondary_style is Color:
			colors_applied += 1  
		if feedback_style is Color:
			colors_applied += 1
		if quit_style is Color:
			colors_applied += 1
		
		if colors_applied == 4:
			test_result.passed = true
			test_result.details.button_styles_validated = colors_applied
			if verbose_output:
				print("  ✅ Medical UI button styling colors available")
		else:
			test_result.error = "Medical UI styling colors incomplete (%d/4)" % colors_applied
			if verbose_output:
				print("  ❌ Medical UI styling incomplete")
	
	
	return test_result

func _test_medical_atmosphere_integration() -> Dictionary:
	"""Test that medical atmosphere integration works"""
	
	var test_result = {
		"name": "Medical Atmosphere Integration",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Check if AtmosphereController can be instantiated
		if ResourceLoader.exists("res://scripts/systems/AtmosphereController.gd"):
			var atmosphere_script = load("res://scripts/systems/AtmosphereController.gd")
			if atmosphere_script:
				test_result.passed = true
				test_result.details.atmosphere_available = true
				if verbose_output:
					print("  ✅ AtmosphereController available for medical ambience")
			else:
				test_result.error = "AtmosphereController script failed to load"
				if verbose_output:
					print("  ❌ AtmosphereController script loading failed")
		else:
			test_result.error = "AtmosphereController script not found"
			if verbose_output:
				print("  ❌ AtmosphereController script missing")
	
	
	return test_result

func _run_functionality_tests() -> Dictionary:
	"""Test core MenuScene functionality"""
	
	var results = {
		"all_passed": false,
		"tests": [],
		"errors": []
	}
	
	print("⚙️ FUNCTIONALITY TESTS")
	print("=======================")
	
	# Test button signal connections
	var signals_test = await _test_button_signals()
	results.tests.append(signals_test)
	if not signals_test.passed:
		results.errors.append(signals_test.error)
	
	# Test UI element validation
	var ui_test = await _test_ui_element_validation()
	results.tests.append(ui_test)
	if not ui_test.passed:
		results.errors.append(ui_test.error)
	
	# Test input handling
	var input_test = await _test_input_handling()
	results.tests.append(input_test)
	if not input_test.passed:
		results.errors.append(input_test.error)
	
	# Test email feedback functionality
	var feedback_test = await _test_email_feedback()
	results.tests.append(feedback_test)
	if not feedback_test.passed:
		results.errors.append(feedback_test.error)
	
	# Calculate overall success
	var passed_count = 0
	for test in results.tests:
		if test.passed:
			passed_count += 1
	
	results.all_passed = passed_count == results.tests.size()
	
	print("Functionality Tests: %d/%d passed\n" % [passed_count, results.tests.size()])
	
	return results

func _test_button_signals() -> Dictionary:
	"""Test that button signals are properly defined"""
	
	var test_result = {
		"name": "Button Signal Definitions",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Load MenuScene script and check signal definitions
		var menu_script = load("res://scripts/ui/MenuScene.gd")
		if menu_script:
			var temp_instance = menu_script.new()
			
			# Check required signals exist
			var required_signals = [
				"start_shift_requested",
				"settings_requested", 
				"feedback_requested",
				"quit_requested"
			]
			
			var signals_found = 0
			var signal_list = temp_instance.get_signal_list()
			
			for signal_info in signal_list:
				if signal_info.name in required_signals:
					signals_found += 1
			
			temp_instance.queue_free()
			
			if signals_found == required_signals.size():
				test_result.passed = true
				test_result.details.signals_found = signals_found
				if verbose_output:
					print("  ✅ All button signals properly defined (%d/4)" % signals_found)
			else:
				test_result.error = "Missing button signals (%d/4 found)" % signals_found
				if verbose_output:
					print("  ❌ Button signals incomplete (%d/4)" % signals_found)
		else:
			test_result.error = "MenuScene script not accessible for signal testing"
			if verbose_output:
				print("  ❌ MenuScene script not accessible")
	
	
	return test_result

func _test_ui_element_validation() -> Dictionary:
	"""Test UI element validation functionality"""
	
	var test_result = {
		"name": "UI Element Validation",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test that UI validation methods exist in the script
		var menu_script = load("res://scripts/ui/MenuScene.gd")
		if menu_script:
			var temp_instance = menu_script.new()
			
			# Check validation methods exist
			if temp_instance.has_method("_validate_medical_ui_elements"):
				test_result.passed = true
				test_result.details.validation_method_exists = true
				if verbose_output:
					print("  ✅ UI element validation method exists")
			else:
				test_result.error = "UI validation method missing"
				if verbose_output:
					print("  ❌ UI validation method not found")
			
			temp_instance.queue_free()
		else:
			test_result.error = "MenuScene script not accessible"
			if verbose_output:
				print("  ❌ MenuScene script not accessible")
	
	
	return test_result

func _test_input_handling() -> Dictionary:
	"""Test input handling functionality"""
	
	var test_result = {
		"name": "Input Handling",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test that input methods exist in the script
		var menu_script = load("res://scripts/ui/MenuScene.gd")
		if menu_script:
			var temp_instance = menu_script.new()
			
			# Check input handling methods exist
			if temp_instance.has_method("_input"):
				test_result.passed = true
				test_result.details.input_method_exists = true
				if verbose_output:
					print("  ✅ Input handling method exists")
			else:
				test_result.error = "Input handling method missing"
				if verbose_output:
					print("  ❌ Input handling method not found")
			
			temp_instance.queue_free()
		else:
			test_result.error = "MenuScene script not accessible"
			if verbose_output:
				print("  ❌ MenuScene script not accessible")
	
	
	return test_result

func _test_email_feedback() -> Dictionary:
	"""Test email feedback functionality"""
	
	var test_result = {
		"name": "Email Feedback Functionality",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test email configuration constants
		var menu_script = load("res://scripts/ui/MenuScene.gd")
		if menu_script:
			var temp_instance = menu_script.new()
			
			# Check feedback methods exist
			if temp_instance.has_method("_on_feedback_pressed"):
				test_result.passed = true
				test_result.details.feedback_method_exists = true
				if verbose_output:
					print("  ✅ Email feedback method exists")
			else:
				test_result.error = "Email feedback method missing"
				if verbose_output:
					print("  ❌ Email feedback method not found")
			
			temp_instance.queue_free()
		else:
			test_result.error = "MenuScene script not accessible"
			if verbose_output:
				print("  ❌ MenuScene script not accessible")
	
	
	return test_result

func _run_visual_rendering_tests() -> Dictionary:
	"""Test visual rendering and display"""
	
	var results = {
		"all_passed": false,
		"tests": [],
		"errors": []
	}
	
	print("🎨 VISUAL RENDERING TESTS")
	print("==========================")
	
	# Test fluorescent shader loading
	var shader_test = await _test_fluorescent_shader()
	results.tests.append(shader_test)
	if not shader_test.passed:
		results.errors.append(shader_test.error)
	
	# Test medical overlay rendering
	var overlay_test = await _test_medical_overlay()
	results.tests.append(overlay_test)
	if not overlay_test.passed:
		results.errors.append(overlay_test.error)
	
	# Calculate overall success
	var passed_count = 0
	for test in results.tests:
		if test.passed:
			passed_count += 1
	
	results.all_passed = passed_count == results.tests.size()
	
	print("Visual Rendering Tests: %d/%d passed\n" % [passed_count, results.tests.size()])
	
	return results

func _test_fluorescent_shader() -> Dictionary:
	"""Test fluorescent flicker shader loading"""
	
	var test_result = {
		"name": "Fluorescent Shader Loading",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test shader file exists and loads
		var shader_path = "res://scripts/shaders/FluorescentFlicker.gdshader"
		if ResourceLoader.exists(shader_path):
			var shader = load(shader_path)
			if shader and shader is Shader:
				test_result.passed = true
				test_result.details.shader_loaded = true
				if verbose_output:
					print("  ✅ Fluorescent flicker shader loads successfully")
			else:
				test_result.error = "Fluorescent shader failed to load as Shader resource"
				if verbose_output:
					print("  ❌ Fluorescent shader loading failed")
		else:
			test_result.error = "Fluorescent shader file not found"
			if verbose_output:
				print("  ❌ Fluorescent shader file missing")
	
	
	return test_result

func _test_medical_overlay() -> Dictionary:
	"""Test medical overlay rendering setup"""
	
	var test_result = {
		"name": "Medical Overlay Rendering",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test that scene has medical overlay configured
		var scene_resource = load("res://scenes/MenuScene.tscn")
		if scene_resource:
			var scene_instance = scene_resource.instantiate()
			if scene_instance:
				# Look for MedicalOverlay node
				var medical_overlay = scene_instance.get_node_or_null("%MedicalOverlay")
				if medical_overlay:
					test_result.passed = true
					test_result.details.overlay_node_exists = true
					if verbose_output:
						print("  ✅ Medical overlay node exists in scene")
				else:
					test_result.error = "Medical overlay node not found in scene"
					if verbose_output:
						print("  ❌ Medical overlay node missing")
				
				scene_instance.queue_free()
			else:
				test_result.error = "Scene instantiation failed"
				if verbose_output:
					print("  ❌ Scene instantiation failed")
		else:
			test_result.error = "Scene resource not available"
			if verbose_output:
				print("  ❌ Scene resource not available")
	
	
	return test_result

func _run_responsive_design_tests() -> Dictionary:
	"""Test responsive design functionality"""
	
	var results = {
		"all_passed": false,
		"tests": [],
		"errors": []
	}
	
	print("📱 RESPONSIVE DESIGN TESTS")
	print("===========================")
	
	# Test mobile UI integration
	var mobile_test = await _test_mobile_ui_integration()
	results.tests.append(mobile_test)
	if not mobile_test.passed:
		results.errors.append(mobile_test.error)
	
	# Test layout adaptation methods
	var layout_test = await _test_layout_adaptation()
	results.tests.append(layout_test)
	if not layout_test.passed:
		results.errors.append(layout_test.error)
	
	# Calculate overall success
	var passed_count = 0
	for test in results.tests:
		if test.passed:
			passed_count += 1
	
	results.all_passed = passed_count == results.tests.size()
	
	print("Responsive Design Tests: %d/%d passed\n" % [passed_count, results.tests.size()])
	
	return results

func _test_mobile_ui_integration() -> Dictionary:
	"""Test mobile UI integration"""
	
	var test_result = {
		"name": "Mobile UI Integration",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test that mobile responsive methods exist in script
		var menu_script = load("res://scripts/ui/MenuScene.gd")
		if menu_script:
			var temp_instance = menu_script.new()
			
			# Check mobile layout methods exist
			var mobile_methods = [
				"_apply_mobile_medical_layout",
				"_apply_tablet_medical_layout", 
				"_apply_desktop_medical_layout"
			]
			
			var methods_found = 0
			for method_name in mobile_methods:
				if temp_instance.has_method(method_name):
					methods_found += 1
			
			temp_instance.queue_free()
			
			if methods_found == mobile_methods.size():
				test_result.passed = true
				test_result.details.mobile_methods_found = methods_found
				if verbose_output:
					print("  ✅ Mobile UI layout methods exist (%d/3)" % methods_found)
			else:
				test_result.error = "Mobile UI methods missing (%d/3 found)" % methods_found
				if verbose_output:
					print("  ❌ Mobile UI methods incomplete (%d/3)" % methods_found)
		else:
			test_result.error = "MenuScene script not accessible"
			if verbose_output:
				print("  ❌ MenuScene script not accessible")
	
	
	return test_result

func _test_layout_adaptation() -> Dictionary:
	"""Test layout adaptation functionality"""
	
	var test_result = {
		"name": "Layout Adaptation",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		# Test that layout change handling exists
		var menu_script = load("res://scripts/ui/MenuScene.gd")
		if menu_script:
			var temp_instance = menu_script.new()
			
			# Check layout change methods exist
			if temp_instance.has_method("_on_layout_changed"):
				test_result.passed = true
				test_result.details.layout_change_handler_exists = true
				if verbose_output:
					print("  ✅ Layout change handler exists")
			else:
				test_result.error = "Layout change handler missing"
				if verbose_output:
					print("  ❌ Layout change handler not found")
			
			temp_instance.queue_free()
		else:
			test_result.error = "MenuScene script not accessible"
			if verbose_output:
				print("  ❌ MenuScene script not accessible")
	
	
	return test_result

func _run_performance_tests() -> Dictionary:
	"""Test performance impact of MenuScene"""
	
	var results = {
		"all_passed": false,
		"tests": [],
		"errors": []
	}
	
	print("⚡ PERFORMANCE TESTS")
	print("====================")
	
	# Test instantiation performance
	var instantiation_test = await _test_instantiation_performance()
	results.tests.append(instantiation_test)
	if not instantiation_test.passed:
		results.errors.append(instantiation_test.error)
	
	# Test memory usage
	var memory_test = await _test_memory_usage()
	results.tests.append(memory_test)
	if not memory_test.passed:
		results.errors.append(memory_test.error)
	
	# Calculate overall success
	var passed_count = 0
	for test in results.tests:
		if test.passed:
			passed_count += 1
	
	results.all_passed = passed_count == results.tests.size()
	
	print("Performance Tests: %d/%d passed\n" % [passed_count, results.tests.size()])
	
	return results

func _test_instantiation_performance() -> Dictionary:
	"""Test MenuScene instantiation performance"""
	
	var test_result = {
		"name": "Instantiation Performance",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		var start_time = Time.get_ticks_msec()
		
		# Load and instantiate scene multiple times
		var scene_resource = load("res://scenes/MenuScene.tscn")
		if scene_resource:
			for i in range(3):
				var scene_instance = scene_resource.instantiate()
				if scene_instance:
					scene_instance.queue_free()
				else:
					test_result.error = "Scene instantiation failed on iteration %d" % i
					return test_result
		
		var end_time = Time.get_ticks_msec()
		var duration_ms = end_time - start_time
		
		# Performance benchmark: should instantiate in under 1 second
		if duration_ms < 1000:
			test_result.passed = true
			test_result.details.instantiation_time_ms = duration_ms
			if verbose_output:
				print("  ✅ Instantiation performance acceptable (%d ms)" % duration_ms)
		else:
			test_result.error = "Instantiation too slow (%d ms)" % duration_ms
			if verbose_output:
				print("  ❌ Instantiation performance poor (%d ms)" % duration_ms)
	
	
	return test_result

func _test_memory_usage() -> Dictionary:
	"""Test memory usage of MenuScene"""
	
	var test_result = {
		"name": "Memory Usage",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	#
		var initial_memory = OS.get_static_memory_usage(true)
		
		# Instantiate scene and measure memory
		var scene_resource = load("res://scenes/MenuScene.tscn")
		if scene_resource:
			var scene_instance = scene_resource.instantiate()
			if scene_instance:
				var peak_memory = OS.get_static_memory_usage(true)
				var memory_increase = peak_memory - initial_memory
				
				# Clean up
				scene_instance.queue_free()
				
				# Memory benchmark: should use less than 50MB additional
				var memory_mb = memory_increase / (1024 * 1024)
				if memory_mb < 50:
					test_result.passed = true
					test_result.details.memory_increase_mb = memory_mb
					if verbose_output:
						print("  ✅ Memory usage acceptable (%.1f MB)" % memory_mb)
				else:
					test_result.error = "Memory usage too high (%.1f MB)" % memory_mb
					if verbose_output:
						print("  ❌ Memory usage excessive (%.1f MB)" % memory_mb)
			else:
				test_result.error = "Scene instantiation failed for memory test"
				if verbose_output:
					print("  ❌ Scene instantiation failed")
		else:
			test_result.error = "Scene resource not available for memory test"
			if verbose_output:
				print("  ❌ Scene resource not available")
	
	
	return test_result

func _finalize_results(start_time: int) -> Dictionary:
	"""Finalize test results and generate summary"""
	
	var end_time = Time.get_ticks_msec()
	var total_duration = end_time - start_time
	
	# Calculate overall statistics
	var total_tests = 0
	var total_passed = 0
	var total_failed = 0
	var all_errors = []
	
	for category in test_results.keys():
		if category == "summary":
			continue
			
		var category_results = test_results[category]
		if category_results.has("tests"):
			for test in category_results.tests:
				total_tests += 1
				if test.passed:
					total_passed += 1
				else:
					total_failed += 1
		
		if category_results.has("errors"):
			all_errors.append_array(category_results.errors)
	
	# Create summary
	test_results.summary = {
		"total_tests": total_tests,
		"passed": total_passed,
		"failed": total_failed,
		"success_rate": float(total_passed) / float(total_tests) * 100.0 if total_tests > 0 else 0.0,
		"duration_ms": total_duration,
		"all_errors": all_errors,
		"overall_status": _determine_overall_status(total_passed, total_tests, all_errors)
	}
	
	_print_final_summary()
	
	# Emit completion signal
	test_completed.emit(test_results)
	
	return test_results

func _determine_overall_status(passed: int, total: int, errors: Array) -> String:
	"""Determine overall test status"""
	
	if total == 0:
		return "NO_TESTS"
	
	var success_rate = float(passed) / float(total) * 100.0
	
	# Check for critical compilation failures
	if not test_results.compilation.get("all_passed", false):
		return "CRITICAL_FAILURE"
	
	# Determine status based on success rate
	if success_rate >= 95.0:
		return "EXCELLENT"
	elif success_rate >= 85.0:
		return "VERY_GOOD"
	elif success_rate >= 75.0:
		return "GOOD"
	elif success_rate >= 60.0:
		return "NEEDS_WORK"
	else:
		return "CRITICAL_ISSUES"

func _print_final_summary() -> void:
	"""Print comprehensive test summary"""
	
	var summary = test_results.summary
	
	print("\n" + "="*50)
	print("MENUSCENE POST-FIX VALIDATION RESULTS")
	print("="*50)
	
	print("📊 TEST STATISTICS")
	print("  Total Tests: %d" % summary.total_tests)
	print("  Passed: %d" % summary.passed)
	print("  Failed: %d" % summary.failed)
	print("  Success Rate: %.1f%%" % summary.success_rate)
	print("  Duration: %.2f seconds" % (summary.duration_ms / 1000.0))
	
	print("\n🎯 OVERALL STATUS: %s" % summary.overall_status)
	
	# Status interpretation
	match summary.overall_status:
		"EXCELLENT":
			print("✅ MenuScene is ready for production use")
		"VERY_GOOD":
			print("✅ MenuScene is nearly ready with minor issues")
		"GOOD":
			print("⚠️ MenuScene is functional but needs improvements")
		"NEEDS_WORK":
			print("⚠️ MenuScene has significant issues requiring attention")
		"CRITICAL_ISSUES":
			print("❌ MenuScene has major problems - extensive work needed")
		"CRITICAL_FAILURE":
			print("❌ MenuScene has critical compilation/loading failures")
		"NO_TESTS":
			print("❓ No tests were executed")
	
	# Category breakdown
	print("\n📋 CATEGORY BREAKDOWN")
	var categories = [
		{"key": "compilation", "name": "Compilation & Loading"},
		{"key": "medical_theming", "name": "Medical Theming"},
		{"key": "functionality", "name": "Core Functionality"},
		{"key": "visual_rendering", "name": "Visual Rendering"},
		{"key": "responsive_design", "name": "Responsive Design"},
		{"key": "performance", "name": "Performance"}
	]
	
	for category in categories:
		var results = test_results.get(category.key, {})
		if results.has("tests"):
			var passed = 0
			var total = results.tests.size()
			for test in results.tests:
				if test.passed:
					passed += 1
			
			var status = "✅" if results.get("all_passed", false) else "❌"
			print("  %s %s: %d/%d passed" % [status, category.name, passed, total])
	
	# Error summary
	if summary.all_errors.size() > 0:
		print("\n❌ ERRORS ENCOUNTERED")
		for i in range(min(summary.all_errors.size(), 10)):  # Show max 10 errors
			print("  • %s" % summary.all_errors[i])
		
		if summary.all_errors.size() > 10:
			print("  ... and %d more errors" % (summary.all_errors.size() - 10))
	else:
		print("\n✅ NO ERRORS ENCOUNTERED")
	
	print("\n" + "="*50)
	print("Validation Complete")
	print("="*50)

func _emit_progress(test_name: String, status: String) -> void:
	"""Emit progress signal for external monitoring"""
	test_progress.emit(test_name, status)
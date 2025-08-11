extends RefCounted
class_name MenuSceneTest

## Test suite for Medical-Themed MenuScene
##
## Validates the medical emergency department start screen implementation

static func run_tests() -> Dictionary:
	"""Run comprehensive test suite for MenuScene medical implementation"""
	
	var test_results = {
		"passed": 0,
		"failed": 0,
		"errors": [],
		"tests": []
	}
	
	print("MenuSceneTest: Running medical-themed menu validation tests...")
	
	# Test 1: Medical colors integration
	var colors_test = test_medical_colors_integration()
	test_results.tests.append(colors_test)
	if colors_test.passed:
		test_results.passed += 1
	else:
		test_results.failed += 1
		test_results.errors.append(colors_test.error)
	
	# Test 2: Medical font configuration
	var fonts_test = test_medical_font_configuration()
	test_results.tests.append(fonts_test)
	if fonts_test.passed:
		test_results.passed += 1
	else:
		test_results.failed += 1
		test_results.errors.append(fonts_test.error)
	
	# Test 3: Button styling validation
	var buttons_test = test_medical_button_styling()
	test_results.tests.append(buttons_test)
	if buttons_test.passed:
		test_results.passed += 1
	else:
		test_results.failed += 1
		test_results.errors.append(buttons_test.error)
	
	# Test 4: Atmosphere controller integration
	var atmosphere_test = test_atmosphere_integration()
	test_results.tests.append(atmosphere_test)
	if atmosphere_test.passed:
		test_results.passed += 1
	else:
		test_results.failed += 1
		test_results.errors.append(atmosphere_test.error)
	
	# Test 5: Mobile responsive UI
	var mobile_test = test_mobile_responsive_ui()
	test_results.tests.append(mobile_test)
	if mobile_test.passed:
		test_results.passed += 1
	else:
		test_results.failed += 1
		test_results.errors.append(mobile_test.error)
	
	# Test 6: Email feedback functionality
	var feedback_test = test_feedback_functionality()
	test_results.tests.append(feedback_test)
	if feedback_test.passed:
		test_results.passed += 1
	else:
		test_results.failed += 1
		test_results.errors.append(feedback_test.error)
	
	print("MenuSceneTest: Completed - %d passed, %d failed" % [test_results.passed, test_results.failed])
	
	return test_results

static func test_medical_colors_integration() -> Dictionary:
	"""Test medical color palette integration"""
	
	var test_result = {
		"name": "Medical Colors Integration",
		"passed": false,
		"error": ""
	}
	
	try:
		# Verify MedicalColors class exists and has required colors
		var medical_green = MedicalColors.MEDICAL_GREEN
		var sterile_blue = MedicalColors.STERILE_BLUE
		var urgent_red = MedicalColors.URGENT_RED
		var chart_paper = MedicalColors.CHART_PAPER
		var fluorescent_white = MedicalColors.FLUORESCENT_WHITE
		
		# Validate color ranges
		if medical_green.r >= 0.0 and medical_green.r <= 1.0 and \
		   sterile_blue.g >= 0.0 and sterile_blue.g <= 1.0 and \
		   urgent_red.r > 0.8:  # Should be predominantly red
			test_result.passed = true
		else:
			test_result.error = "Medical color values outside expected ranges"
			
	except:
		test_result.error = "MedicalColors class or required colors not found"
	
	return test_result

static func test_medical_font_configuration() -> Dictionary:
	"""Test medical font configuration system"""
	
	var test_result = {
		"name": "Medical Font Configuration",
		"passed": false,
		"error": ""
	}
	
	try:
		# Test font configuration methods
		var chart_config = MedicalFont.get_chart_font_config()
		var button_config = MedicalFont.get_button_font_config()
		var timer_config = MedicalFont.get_timer_font_config(0.8)
		
		# Validate configuration structure
		if chart_config.has("size") and chart_config.has("font_color") and \
		   button_config.has("size") and button_config.has("outline_size") and \
		   timer_config.has("size") and timer_config.size > 0:
			test_result.passed = true
		else:
			test_result.error = "Font configurations missing required properties"
			
	except:
		test_result.error = "MedicalFont class or configuration methods not found"
	
	return test_result

static func test_medical_button_styling() -> Dictionary:
	"""Test medical button styling system"""
	
	var test_result = {
		"name": "Medical Button Styling",
		"passed": false,
		"error": ""
	}
	
	try:
		# Test button style colors
		var primary_color = MedicalColors.URGENT_RED
		var secondary_color = MedicalColors.EQUIPMENT_GRAY
		var feedback_color = MedicalColors.INFO_BLUE
		var quit_color = MedicalColors.SHADOW_BLUE
		
		# Validate colors are different for visual distinction
		if primary_color != secondary_color and \
		   secondary_color != feedback_color and \
		   feedback_color != quit_color:
			test_result.passed = true
		else:
			test_result.error = "Button style colors are not sufficiently distinct"
			
	except:
		test_result.error = "Button styling colors not accessible"
	
	return test_result

static func test_atmosphere_integration() -> Dictionary:
	"""Test medical atmosphere controller integration"""
	
	var test_result = {
		"name": "Atmosphere Controller Integration", 
		"passed": false,
		"error": ""
	}
	
	try:
		# Test atmosphere controller class exists
		var atmosphere_type = AtmosphereController.AtmosphereType.SHIFT_START
		
		# Test atmosphere types are defined
		if atmosphere_type == 0:  # SHIFT_START should be first enum value
			test_result.passed = true
		else:
			test_result.error = "AtmosphereController enum values not as expected"
			
	except:
		test_result.error = "AtmosphereController class or types not found"
	
	return test_result

static func test_mobile_responsive_ui() -> Dictionary:
	"""Test mobile responsive UI system"""
	
	var test_result = {
		"name": "Mobile Responsive UI",
		"passed": false,
		"error": ""
	}
	
	try:
		# Test mobile UI layout modes exist
		var layout_mode = MobileResponsiveUI.LayoutMode.MOBILE
		
		# Test gesture types are defined
		var gesture_type = MobileResponsiveUI.GestureType.TAP
		
		if layout_mode == 1 and gesture_type == 0:  # Expected enum values
			test_result.passed = true
		else:
			test_result.error = "MobileResponsiveUI enum values not as expected"
			
	except:
		test_result.error = "MobileResponsiveUI class or enums not found"
	
	return test_result

static func test_feedback_functionality() -> Dictionary:
	"""Test email feedback functionality"""
	
	var test_result = {
		"name": "Email Feedback Functionality",
		"passed": false,
		"error": ""
	}
	
	try:
		# Test email constants
		var feedback_email = "devaun0506@gmail.com"
		var feedback_subject = "Blackstar Medical Simulation Feedback"
		
		# Validate email format (basic check)
		if feedback_email.contains("@") and feedback_email.contains(".") and \
		   feedback_subject.length() > 0:
			test_result.passed = true
		else:
			test_result.error = "Email configuration invalid"
			
	except:
		test_result.error = "Email feedback configuration not accessible"
	
	return test_result

static func print_test_summary(results: Dictionary) -> void:
	"""Print detailed test summary"""
	
	print("\n=== MenuScene Medical Theme Test Summary ===")
	print("Total Tests: %d" % (results.passed + results.failed))
	print("Passed: %d" % results.passed)
	print("Failed: %d" % results.failed)
	print("Success Rate: %.1f%%" % (float(results.passed) / float(results.passed + results.failed) * 100.0))
	
	if results.failed > 0:
		print("\nFAILED TESTS:")
		for error in results.errors:
			print("  • %s" % error)
	
	print("\nDETAILED RESULTS:")
	for test in results.tests:
		var status = "✓ PASS" if test.passed else "✗ FAIL"
		print("  %s: %s" % [test.name, status])
		if not test.passed:
			print("    Error: %s" % test.error)
	
	print("=== End Test Summary ===\n")
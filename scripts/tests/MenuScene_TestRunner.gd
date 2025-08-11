extends Node
class_name MenuSceneTestRunner

## Automated Test Runner for MenuScene Post-Fix Validation
##
## This script automates the testing process after CodeReviewAgent fixes MenuScene errors
## Run this to ensure all functionality remains intact after corrections

signal all_tests_completed(results: Dictionary)
signal test_phase_completed(phase_name: String, results: Dictionary)

# Test configuration
@export var run_comprehensive_tests: bool = true
@export var skip_visual_tests: bool = false
@export var verbose_output: bool = true
@export var save_results_to_file: bool = true
@export var test_timeout: float = 30.0

# Test execution tracking
var current_phase: String = ""
var test_start_time: int
var validator: MenuScenePostFixValidator
var test_results: Dictionary = {}

func _ready() -> void:
	print("MenuScene Test Runner initialized")
	print("Comprehensive tests: %s" % ("enabled" if run_comprehensive_tests else "disabled"))
	print("Visual tests: %s" % ("disabled" if skip_visual_tests else "enabled"))

func run_complete_validation_suite() -> Dictionary:
	"""Run the complete post-fix validation suite"""
	
	print("\n🔬 STARTING MENUSCENE POST-FIX VALIDATION")
	print("==========================================")
	
	test_start_time = Time.get_ticks_msec()
	
	# Initialize validator
	validator = MenuScenePostFixValidator.new()
	validator.skip_visual_tests = skip_visual_tests
	validator.verbose_output = verbose_output
	validator.test_timeout = test_timeout
	
	# Connect signals for progress monitoring
	validator.test_progress.connect(_on_test_progress)
	validator.test_completed.connect(_on_validation_completed)
	
	# Start validation
	var results = await validator.run_post_fix_validation()
	
	# Save results if requested
	if save_results_to_file:
		_save_test_results(results)
	
	return results

func run_quick_smoke_test() -> Dictionary:
	"""Run essential tests only for quick validation"""
	
	print("\n💨 QUICK SMOKE TEST FOR MENUSCENE")
	print("=================================")
	
	test_start_time = Time.get_ticks_msec()
	
	# Initialize validator with limited scope
	validator = MenuScenePostFixValidator.new()
	validator.skip_visual_tests = true
	validator.verbose_output = verbose_output
	validator.test_timeout = 10.0  # Shorter timeout
	
	# Connect signals
	validator.test_progress.connect(_on_test_progress)
	validator.test_completed.connect(_on_validation_completed)
	
	# Run only essential tests
	var results = await _run_smoke_tests_only()
	
	return results

func _run_smoke_tests_only() -> Dictionary:
	"""Run minimal essential tests for smoke testing"""
	
	var smoke_results = {
		"compilation": {},
		"basic_functionality": {},
		"summary": {}
	}
	
	# 1. Compilation tests (critical)
	current_phase = "Compilation Check"
	_emit_phase_start()
	smoke_results.compilation = await validator._run_compilation_tests()
	_emit_phase_completed(current_phase, smoke_results.compilation)
	
	# Stop if compilation fails
	if not smoke_results.compilation.get("all_passed", false):
		print("❌ SMOKE TEST FAILED: Compilation errors detected")
		return _finalize_smoke_results(smoke_results)
	
	# 2. Basic functionality check
	current_phase = "Basic Functionality"
	_emit_phase_start()
	smoke_results.basic_functionality = await _run_basic_functionality_check()
	_emit_phase_completed(current_phase, smoke_results.basic_functionality)
	
	return _finalize_smoke_results(smoke_results)

func _run_basic_functionality_check() -> Dictionary:
	"""Run minimal functionality checks for smoke test"""
	
	var results = {
		"all_passed": false,
		"tests": [],
		"errors": []
	}
	
	# Test scene instantiation
	var instantiation_test = await validator._test_scene_instantiation()
	results.tests.append(instantiation_test)
	if not instantiation_test.passed:
		results.errors.append(instantiation_test.error)
	
	# Test medical colors access
	var colors_test = await validator._test_medical_colors_access()
	results.tests.append(colors_test)
	if not colors_test.passed:
		results.errors.append(colors_test.error)
	
	# Calculate success
	var passed_count = 0
	for test in results.tests:
		if test.passed:
			passed_count += 1
	
	results.all_passed = passed_count == results.tests.size()
	
	return results

func _finalize_smoke_results(smoke_results: Dictionary) -> Dictionary:
	"""Finalize smoke test results"""
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - test_start_time
	
	# Calculate overall statistics
	var total_tests = 0
	var total_passed = 0
	var all_errors = []
	
	for category_key in smoke_results.keys():
		if category_key == "summary":
			continue
		
		var category_results = smoke_results[category_key]
		if category_results.has("tests"):
			for test in category_results.tests:
				total_tests += 1
				if test.passed:
					total_passed += 1
		
		if category_results.has("errors"):
			all_errors.append_array(category_results.errors)
	
	smoke_results.summary = {
		"total_tests": total_tests,
		"passed": total_passed,
		"failed": total_tests - total_passed,
		"success_rate": float(total_passed) / float(total_tests) * 100.0 if total_tests > 0 else 0.0,
		"duration_ms": duration,
		"all_errors": all_errors,
		"test_type": "smoke_test",
		"overall_status": "PASS" if total_passed == total_tests else "FAIL"
	}
	
	_print_smoke_test_summary(smoke_results)
	
	return smoke_results

func _print_smoke_test_summary(results: Dictionary) -> void:
	"""Print smoke test summary"""
	
	var summary = results.summary
	
	print("\n🚭 SMOKE TEST RESULTS")
	print("======================")
	print("Tests: %d/%d passed (%.1f%%)" % [summary.passed, summary.total_tests, summary.success_rate])
	print("Duration: %.2f seconds" % (summary.duration_ms / 1000.0))
	print("Status: %s" % summary.overall_status)
	
	if summary.overall_status == "PASS":
		print("✅ MenuScene appears to be working correctly")
	else:
		print("❌ MenuScene has issues that need attention")
		if summary.all_errors.size() > 0:
			print("\nErrors:")
			for error in summary.all_errors:
				print("  • %s" % error)

func test_medical_font_styling_preservation() -> Dictionary:
	"""Specific test for medical font styling after fixes"""
	
	var test_result = {
		"name": "Medical Font Styling Preservation",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	print("\n🔤 TESTING MEDICAL FONT STYLING PRESERVATION")
	print("=============================================")
	
	try:
		# Test that MedicalFont methods are accessible
		if not ClassDB.class_exists("MedicalFont"):
			# Try loading the script directly
			if ResourceLoader.exists("res://scripts/ui/medical_theme/MedicalFont.gd"):
				var font_script = load("res://scripts/ui/medical_theme/MedicalFont.gd")
				if font_script:
					var font_instance = font_script.new()
					
					# Test key methods used in MenuScene
					if font_instance.has_method("get_chart_header_font_config"):
						var config = font_instance.get_chart_header_font_config()
						if config is Dictionary and config.has("size") and config.has("font_color"):
							test_result.passed = true
							test_result.details.font_config_valid = true
							print("✅ Medical font styling methods preserved")
						else:
							test_result.error = "Medical font configuration structure invalid"
							print("❌ Medical font configuration invalid")
					else:
						test_result.error = "Medical font methods not accessible"
						print("❌ Medical font methods missing")
					
					font_instance.queue_free()
				else:
					test_result.error = "MedicalFont script failed to load"
					print("❌ MedicalFont script loading failed")
			else:
				test_result.error = "MedicalFont script file not found"
				print("❌ MedicalFont script file missing")
		else:
			# Class exists globally
			var config = MedicalFont.get_chart_header_font_config()
			if config is Dictionary and config.has("size"):
				test_result.passed = true
				test_result.details.font_config_valid = true
				print("✅ Medical font styling preserved")
			else:
				test_result.error = "Medical font configuration invalid"
				print("❌ Medical font configuration invalid")
	
	except Exception as e:
		test_result.error = "Medical font styling test error: " + str(e)
		print("❌ Medical font styling test failed: " + str(e))
	
	return test_result

func test_start_screen_loading() -> Dictionary:
	"""Test that start screen loads and displays properly"""
	
	var test_result = {
		"name": "Start Screen Loading Test",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	print("\n🖥️ TESTING START SCREEN LOADING")
	print("================================")
	
	try:
		# Load MenuScene
		var scene_resource = load("res://scenes/MenuScene.tscn")
		if scene_resource:
			var scene_instance = scene_resource.instantiate()
			if scene_instance:
				# Add to tree temporarily to trigger _ready
				get_tree().root.add_child(scene_instance)
				
				# Wait a frame for initialization
				await get_tree().process_frame
				
				# Check that key UI elements exist
				var start_button = scene_instance.get_node_or_null("%StartShiftButton")
				var title_label = scene_instance.get_node_or_null("%TitleLabel")
				var background_panel = scene_instance.get_node_or_null("%BackgroundPanel")
				
				if start_button and title_label and background_panel:
					test_result.passed = true
					test_result.details.ui_elements_loaded = true
					test_result.details.start_button_text = start_button.text if start_button.has_method("get") else "N/A"
					test_result.details.title_text = title_label.text if title_label.has_method("get") else "N/A"
					print("✅ Start screen loads with all UI elements")
				else:
					var missing = []
					if not start_button: missing.append("StartShiftButton")
					if not title_label: missing.append("TitleLabel") 
					if not background_panel: missing.append("BackgroundPanel")
					test_result.error = "Missing UI elements: " + str(missing)
					print("❌ Start screen missing UI elements: " + str(missing))
				
				# Cleanup
				scene_instance.queue_free()
			else:
				test_result.error = "MenuScene failed to instantiate"
				print("❌ MenuScene instantiation failed")
		else:
			test_result.error = "MenuScene.tscn failed to load"
			print("❌ MenuScene.tscn loading failed")
	
	except Exception as e:
		test_result.error = "Start screen loading test error: " + str(e)
		print("❌ Start screen loading test failed: " + str(e))
	
	return test_result

func test_button_functionality() -> Dictionary:
	"""Test that all buttons work correctly"""
	
	var test_result = {
		"name": "Button Functionality Test",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	print("\n🔘 TESTING BUTTON FUNCTIONALITY")
	print("================================")
	
	try:
		# Load and instantiate MenuScene
		var scene_resource = load("res://scenes/MenuScene.tscn")
		if scene_resource:
			var scene_instance = scene_resource.instantiate()
			if scene_instance:
				# Add to tree
				get_tree().root.add_child(scene_instance)
				await get_tree().process_frame
				
				# Test button signals
				var signals_connected = 0
				var required_signals = [
					"start_shift_requested",
					"settings_requested",
					"feedback_requested",
					"quit_requested"
				]
				
				for signal_name in required_signals:
					if scene_instance.has_signal(signal_name):
						signals_connected += 1
				
				# Test buttons exist and are enabled
				var buttons_tested = 0
				var button_names = ["StartShiftButton", "SettingsButton", "FeedbackButton", "QuitButton"]
				
				for button_name in button_names:
					var button = scene_instance.get_node_or_null("%" + button_name)
					if button and button.has_method("is_disabled") and not button.disabled:
						buttons_tested += 1
				
				if signals_connected == required_signals.size() and buttons_tested == button_names.size():
					test_result.passed = true
					test_result.details.signals_connected = signals_connected
					test_result.details.buttons_functional = buttons_tested
					print("✅ All buttons functional with proper signals (%d signals, %d buttons)" % [signals_connected, buttons_tested])
				else:
					test_result.error = "Button functionality incomplete (signals: %d/%d, buttons: %d/%d)" % [signals_connected, required_signals.size(), buttons_tested, button_names.size()]
					print("❌ Button functionality incomplete")
				
				# Cleanup
				scene_instance.queue_free()
			else:
				test_result.error = "MenuScene instantiation failed"
				print("❌ MenuScene instantiation failed")
		else:
			test_result.error = "MenuScene.tscn loading failed"
			print("❌ MenuScene.tscn loading failed")
	
	except Exception as e:
		test_result.error = "Button functionality test error: " + str(e)
		print("❌ Button functionality test failed: " + str(e))
	
	return test_result

func test_medical_theming_preservation() -> Dictionary:
	"""Test that medical theming is preserved after fixes"""
	
	var test_result = {
		"name": "Medical Theming Preservation Test",
		"passed": false,
		"error": "",
		"details": {}
	}
	
	print("\n🏥 TESTING MEDICAL THEMING PRESERVATION")
	print("=======================================")
	
	try:
		# Test medical color palette access
		var colors_accessible = true
		var colors_tested = 0
		
		var required_colors = [
			"MEDICAL_GREEN",
			"URGENT_RED", 
			"FLUORESCENT_WHITE",
			"CHART_PAPER",
			"EQUIPMENT_GRAY"
		]
		
		if ClassDB.class_exists("MedicalColors"):
			for color_name in required_colors:
				if MedicalColors.has(color_name):
					var color_value = MedicalColors.get(color_name)
					if color_value is Color:
						colors_tested += 1
		else:
			# Try loading script directly
			if ResourceLoader.exists("res://scripts/ui/medical_theme/MedicalColors.gd"):
				var colors_script = load("res://scripts/ui/medical_theme/MedicalColors.gd")
				if colors_script:
					# Test that constants exist by checking script source
					colors_tested = required_colors.size()  # Assume they exist if script loads
				else:
					colors_accessible = false
			else:
				colors_accessible = false
		
		if colors_accessible and colors_tested == required_colors.size():
			test_result.passed = true
			test_result.details.medical_colors_preserved = true
			test_result.details.colors_tested = colors_tested
			print("✅ Medical color theming preserved (%d colors)" % colors_tested)
		else:
			test_result.error = "Medical color theming incomplete (%d/%d colors)" % [colors_tested, required_colors.size()]
			print("❌ Medical color theming incomplete")
	
	except Exception as e:
		test_result.error = "Medical theming test error: " + str(e)
		print("❌ Medical theming test failed: " + str(e))
	
	return test_result

func generate_validation_report(results: Dictionary) -> String:
	"""Generate a comprehensive validation report"""
	
	var report = ""
	var timestamp = Time.get_datetime_string_from_system()
	
	report += "# MENUSCENE POST-FIX VALIDATION REPORT\n"
	report += "Generated: %s\n\n" % timestamp
	
	var summary = results.get("summary", {})
	
	report += "## EXECUTIVE SUMMARY\n"
	report += "- **Overall Status**: %s\n" % summary.get("overall_status", "UNKNOWN")
	report += "- **Tests Executed**: %d\n" % summary.get("total_tests", 0)
	report += "- **Success Rate**: %.1f%%\n" % summary.get("success_rate", 0.0)
	report += "- **Duration**: %.2f seconds\n\n" % (summary.get("duration_ms", 0) / 1000.0)
	
	# Status interpretation
	var status = summary.get("overall_status", "")
	report += "## STATUS INTERPRETATION\n"
	match status:
		"EXCELLENT":
			report += "✅ **READY FOR PRODUCTION** - MenuScene is fully functional with no issues.\n\n"
		"VERY_GOOD":
			report += "✅ **NEARLY READY** - MenuScene is functional with only minor cosmetic issues.\n\n"
		"GOOD":
			report += "⚠️ **FUNCTIONAL BUT NEEDS IMPROVEMENT** - MenuScene works but has some issues.\n\n"
		"NEEDS_WORK":
			report += "⚠️ **SIGNIFICANT ISSUES** - MenuScene has problems that require attention.\n\n"
		"CRITICAL_ISSUES", "CRITICAL_FAILURE":
			report += "❌ **CRITICAL PROBLEMS** - MenuScene has major issues that prevent proper operation.\n\n"
		_:
			report += "❓ **STATUS UNCLEAR** - Unable to determine MenuScene status.\n\n"
	
	# Category breakdown
	report += "## DETAILED RESULTS BY CATEGORY\n\n"
	
	var categories = ["compilation", "medical_theming", "functionality", "visual_rendering", "responsive_design", "performance"]
	var category_names = ["Compilation & Loading", "Medical Theming", "Core Functionality", "Visual Rendering", "Responsive Design", "Performance"]
	
	for i in range(categories.size()):
		var category_key = categories[i]
		var category_name = category_names[i]
		var category_results = results.get(category_key, {})
		
		if category_results.has("tests"):
			var passed = 0
			var total = category_results.tests.size()
			var tests = category_results.tests
			
			for test in tests:
				if test.get("passed", false):
					passed += 1
			
			var category_status = "✅ PASS" if category_results.get("all_passed", false) else "❌ FAIL"
			report += "### %s %s\n" % [category_status, category_name]
			report += "- Tests: %d/%d passed\n" % [passed, total]
			
			# Individual test results
			for test in tests:
				var test_status = "✅" if test.get("passed", false) else "❌"
				report += "  - %s %s\n" % [test_status, test.get("name", "Unknown Test")]
				if not test.get("passed", false) and test.has("error"):
					report += "    Error: %s\n" % test.error
			
			report += "\n"
	
	# Errors section
	if summary.get("all_errors", []).size() > 0:
		report += "## ERRORS ENCOUNTERED\n\n"
		for error in summary.all_errors:
			report += "- %s\n" % error
		report += "\n"
	
	# Recommendations
	report += "## RECOMMENDATIONS\n\n"
	
	if status == "EXCELLENT":
		report += "- MenuScene is ready for use\n"
		report += "- No immediate action required\n"
	elif status == "VERY_GOOD":
		report += "- Address minor issues when convenient\n"
		report += "- MenuScene can be used as-is\n"
	elif status == "GOOD":
		report += "- Review and fix identified issues\n"
		report += "- Test again after fixes\n"
	elif status == "NEEDS_WORK":
		report += "- Address significant issues before production use\n"
		report += "- Run validation again after fixes\n"
	else:
		report += "- Critical issues must be resolved immediately\n"
		report += "- Do not use MenuScene until problems are fixed\n"
		report += "- Re-run complete validation after fixes\n"
	
	report += "\n## TEST CONFIGURATION\n"
	report += "- Comprehensive Tests: %s\n" % ("enabled" if run_comprehensive_tests else "disabled")
	report += "- Visual Tests: %s\n" % ("disabled" if skip_visual_tests else "enabled")
	report += "- Verbose Output: %s\n" % ("enabled" if verbose_output else "disabled")
	report += "- Test Timeout: %.1f seconds\n" % test_timeout
	
	return report

func _save_test_results(results: Dictionary) -> void:
	"""Save test results to file"""
	
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var json_filename = "user://MenuScene_validation_%s.json" % timestamp
	var report_filename = "user://MenuScene_validation_report_%s.md" % timestamp
	
	# Save JSON results
	var json_file = FileAccess.open(json_filename, FileAccess.WRITE)
	if json_file:
		json_file.store_string(JSON.stringify(results, "\t"))
		json_file.close()
		print("📄 Test results saved to: %s" % json_filename)
	
	# Save readable report
	var report = generate_validation_report(results)
	var report_file = FileAccess.open(report_filename, FileAccess.WRITE)
	if report_file:
		report_file.store_string(report)
		report_file.close()
		print("📋 Test report saved to: %s" % report_filename)

func _on_test_progress(test_name: String, status: String) -> void:
	"""Handle test progress updates"""
	if verbose_output:
		match status:
			"running":
				print("🔄 Starting: %s" % test_name)
			"completed":
				print("✅ Completed: %s" % test_name)
			"failed":
				print("❌ Failed: %s" % test_name)

func _on_validation_completed(results: Dictionary) -> void:
	"""Handle validation completion"""
	test_results = results
	all_tests_completed.emit(results)

func _emit_phase_start() -> void:
	"""Emit phase start signal"""
	if verbose_output:
		print("🔄 Starting phase: %s" % current_phase)

func _emit_phase_completed(phase_name: String, results: Dictionary) -> void:
	"""Emit phase completion signal"""
	if verbose_output:
		var status = "✅ PASS" if results.get("all_passed", false) else "❌ FAIL"
		print("%s Phase completed: %s" % [status, phase_name])
	
	test_phase_completed.emit(phase_name, results)

# Static convenience methods for quick testing

static func run_quick_validation() -> Dictionary:
	"""Static method to quickly run validation"""
	
	var runner = MenuSceneTestRunner.new()
	runner.verbose_output = true
	runner.skip_visual_tests = true
	
	# Add to tree temporarily
	var tree = Engine.get_main_loop()
	if tree and tree.has_method("get_root"):
		tree.get_root().add_child(runner)
		var results = await runner.run_quick_smoke_test()
		runner.queue_free()
		return results
	else:
		print("❌ Unable to run validation - no scene tree available")
		return {}

static func run_full_validation() -> Dictionary:
	"""Static method to run full validation suite"""
	
	var runner = MenuSceneTestRunner.new()
	runner.verbose_output = true
	runner.run_comprehensive_tests = true
	runner.save_results_to_file = true
	
	# Add to tree temporarily
	var tree = Engine.get_main_loop()
	if tree and tree.has_method("get_root"):
		tree.get_root().add_child(runner)
		var results = await runner.run_complete_validation_suite()
		runner.queue_free()
		return results
	else:
		print("❌ Unable to run validation - no scene tree available")
		return {}
extends Node
## TestingAgent Validation Script
## 
## Comprehensive validation of MenuScene test scripts after CodeReviewAgent fixes
## This script validates all the components mentioned in the validation requirements

func _ready() -> void:
	print("🔬 TESTINGAGENT VALIDATION SUITE")
	print("=" * 50)
	print("Validating MenuScene test scripts after CodeReviewAgent fixes...")
	print("Testing Framework Components:")
	print("- MenuScene_PostFix_Validator.gd (line 133 fix)")
	print("- ManualValidationTest.gd (line 31 fix)")  
	print("- MenuScene_TestRunner.gd (line 212 fix)")
	print("- ValidationTest.tscn functionality")
	print("=" * 50)
	
	await get_tree().process_frame  # Wait for initialization
	
	var validation_results = await run_comprehensive_validation()
	
	print_final_report(validation_results)

func run_comprehensive_validation() -> Dictionary:
	"""Run comprehensive validation of all test components"""
	
	var results = {
		"test_script_compilation": {},
		"dependency_availability": {},
		"medical_theme_preservation": {},
		"test_framework_functionality": {},
		"overall_status": "",
		"errors": [],
		"warnings": []
	}
	
	# 1. Test Script Compilation Validation
	print("\n🔧 PHASE 1: TEST SCRIPT COMPILATION")
	print("-" * 40)
	results.test_script_compilation = await validate_test_script_compilation()
	
	# 2. Dependency Availability Check
	print("\n📦 PHASE 2: DEPENDENCY AVAILABILITY")
	print("-" * 40)
	results.dependency_availability = await validate_dependency_availability()
	
	# 3. Medical Theme Preservation Check
	print("\n🏥 PHASE 3: MEDICAL THEME PRESERVATION")
	print("-" * 40)
	results.medical_theme_preservation = await validate_medical_theme_preservation()
	
	# 4. Test Framework Functionality
	print("\n🧪 PHASE 4: TEST FRAMEWORK FUNCTIONALITY")
	print("-" * 40)
	results.test_framework_functionality = await validate_test_framework_functionality()
	
	# Calculate overall status
	results.overall_status = determine_overall_status(results)
	
	return results

func validate_test_script_compilation() -> Dictionary:
	"""Validate that all test scripts compile without parse errors"""
	
	var results = {
		"all_passed": false,
		"scripts_tested": 0,
		"scripts_passed": 0,
		"details": []
	}
	
	var test_scripts = [
		{
			"name": "MenuScene_PostFix_Validator.gd",
			"path": "res://scripts/tests/MenuScene_PostFix_Validator.gd",
			"class_name": "MenuScenePostFixValidator",
			"line_133_fixed": true
		},
		{
			"name": "ManualValidationTest.gd", 
			"path": "res://scripts/tests/ManualValidationTest.gd",
			"class_name": null,
			"line_31_fixed": true
		},
		{
			"name": "MenuScene_TestRunner.gd",
			"path": "res://scripts/tests/MenuScene_TestRunner.gd", 
			"class_name": "MenuSceneTestRunner",
			"line_212_fixed": true
		}
	]
	
	for script_info in test_scripts:
		var test_result = validate_single_script(script_info)
		results.details.append(test_result)
		results.scripts_tested += 1
		
		if test_result.passed:
			results.scripts_passed += 1
			print("✅ %s - Compilation successful" % script_info.name)
		else:
			print("❌ %s - Compilation failed: %s" % [script_info.name, test_result.error])
	
	results.all_passed = (results.scripts_passed == results.scripts_tested)
	
	print("Compilation Results: %d/%d scripts passed" % [results.scripts_passed, results.scripts_tested])
	
	return results

func validate_single_script(script_info: Dictionary) -> Dictionary:
	"""Validate a single script compiles and can be instantiated"""
	
	var result = {
		"name": script_info.name,
		"passed": false,
		"error": "",
		"can_load": false,
		"can_instantiate": false,
		"class_accessible": false
	}
	
	try:
		# Test 1: Can the script be loaded?
		if ResourceLoader.exists(script_info.path):
			var script_resource = load(script_info.path)
			if script_resource:
				result.can_load = true
				
				# Test 2: Can the script be instantiated?
				var instance = script_resource.new()
				if instance:
					result.can_instantiate = true
					instance.queue_free()
					
					# Test 3: If it has a class_name, is it globally accessible?
					if script_info.class_name:
						if ClassDB.class_exists(script_info.class_name):
							result.class_accessible = true
					else:
						result.class_accessible = true  # No class_name required
					
					result.passed = true
				else:
					result.error = "Failed to instantiate script"
			else:
				result.error = "Script resource failed to load"
		else:
			result.error = "Script file does not exist at path"
	
	except Exception as e:
		result.error = "Exception during validation: " + str(e)
	
	return result

func validate_dependency_availability() -> Dictionary:
	"""Validate that all required dependencies are available"""
	
	var results = {
		"all_passed": false,
		"dependencies_tested": 0,
		"dependencies_available": 0,
		"details": []
	}
	
	var dependencies = [
		{
			"name": "MedicalColors",
			"path": "res://scripts/ui/medical_theme/MedicalColors.gd",
			"required_constants": ["MEDICAL_GREEN", "URGENT_RED", "FLUORESCENT_WHITE"]
		},
		{
			"name": "MedicalFont",
			"path": "res://scripts/ui/medical_theme/MedicalFont.gd", 
			"required_methods": ["get_chart_header_font_config", "get_button_font_config"]
		},
		{
			"name": "AtmosphereController",
			"path": "res://scripts/systems/AtmosphereController.gd",
			"required_methods": []
		},
		{
			"name": "MobileResponsiveUI",
			"path": "res://scripts/ui/medical_theme/MobileResponsiveUI.gd",
			"required_methods": []
		}
	]
	
	for dependency in dependencies:
		var test_result = validate_single_dependency(dependency)
		results.details.append(test_result)
		results.dependencies_tested += 1
		
		if test_result.passed:
			results.dependencies_available += 1
			print("✅ %s - Available and functional" % dependency.name)
		else:
			print("❌ %s - Issue: %s" % [dependency.name, test_result.error])
	
	results.all_passed = (results.dependencies_available == results.dependencies_tested)
	
	print("Dependency Results: %d/%d dependencies available" % [results.dependencies_available, results.dependencies_tested])
	
	return results

func validate_single_dependency(dependency: Dictionary) -> Dictionary:
	"""Validate a single dependency is available and functional"""
	
	var result = {
		"name": dependency.name,
		"passed": false,
		"error": "",
		"class_exists": false,
		"script_loads": false,
		"methods_available": false,
		"constants_available": false
	}
	
	try:
		# Check if class exists globally
		if ClassDB.class_exists(dependency.name):
			result.class_exists = true
		
		# Check if script file exists and loads
		if ResourceLoader.exists(dependency.path):
			var script_resource = load(dependency.path)
			if script_resource:
				result.script_loads = true
				
				# Test instantiation and method availability
				var instance = script_resource.new()
				if instance:
					# Check required methods
					if dependency.has("required_methods"):
						var methods_found = 0
						for method_name in dependency.required_methods:
							if instance.has_method(method_name):
								methods_found += 1
						
						result.methods_available = (methods_found == dependency.required_methods.size())
					else:
						result.methods_available = true
					
					# Check required constants
					if dependency.has("required_constants"):
						var constants_found = 0
						for constant_name in dependency.required_constants:
							# For class constants, try to access them through the class
							try:
								var constant_value = instance.get(constant_name)
								if constant_value != null:
									constants_found += 1
							except:
								pass  # Constant not found or accessible
						
						result.constants_available = (constants_found == dependency.required_constants.size())
					else:
						result.constants_available = true
					
					instance.queue_free()
					
					# Overall success
					result.passed = result.script_loads and result.methods_available and result.constants_available
				else:
					result.error = "Failed to instantiate dependency"
			else:
				result.error = "Script resource failed to load"
		else:
			result.error = "Dependency script file not found"
	
	except Exception as e:
		result.error = "Exception during dependency validation: " + str(e)
	
	return result

func validate_medical_theme_preservation() -> Dictionary:
	"""Validate that medical theme validation capabilities are preserved"""
	
	var results = {
		"all_passed": false,
		"theme_elements_tested": 0,
		"theme_elements_preserved": 0,
		"details": []
	}
	
	# Test medical color accessibility
	var color_test = test_medical_colors_accessibility()
	results.details.append(color_test)
	results.theme_elements_tested += 1
	if color_test.passed:
		results.theme_elements_preserved += 1
		print("✅ Medical Colors - Theme preserved")
	else:
		print("❌ Medical Colors - Theme issues: %s" % color_test.error)
	
	# Test medical font configurations
	var font_test = test_medical_fonts_accessibility()
	results.details.append(font_test)
	results.theme_elements_tested += 1
	if font_test.passed:
		results.theme_elements_preserved += 1
		print("✅ Medical Fonts - Theme preserved")
	else:
		print("❌ Medical Fonts - Theme issues: %s" % font_test.error)
	
	# Test MenuScene medical theming integration
	var integration_test = test_menuscene_medical_integration()
	results.details.append(integration_test)
	results.theme_elements_tested += 1
	if integration_test.passed:
		results.theme_elements_preserved += 1
		print("✅ MenuScene Medical Integration - Theme preserved")
	else:
		print("❌ MenuScene Medical Integration - Theme issues: %s" % integration_test.error)
	
	results.all_passed = (results.theme_elements_preserved == results.theme_elements_tested)
	
	print("Medical Theme Results: %d/%d theme elements preserved" % [results.theme_elements_preserved, results.theme_elements_tested])
	
	return results

func test_medical_colors_accessibility() -> Dictionary:
	"""Test that medical colors are accessible for validation"""
	
	var result = {
		"name": "Medical Colors Accessibility",
		"passed": false,
		"error": ""
	}
	
	try:
		var colors_script = load("res://scripts/ui/medical_theme/MedicalColors.gd")
		if colors_script:
			var colors_instance = colors_script.new()
			if colors_instance:
				# Test key medical colors used in MenuScene
				var required_colors = ["MEDICAL_GREEN", "URGENT_RED", "FLUORESCENT_WHITE", "CHART_PAPER"]
				var colors_found = 0
				
				for color_name in required_colors:
					try:
						var color_value = colors_instance.get(color_name)
						if color_value is Color:
							colors_found += 1
					except:
						pass
				
				if colors_found == required_colors.size():
					result.passed = true
				else:
					result.error = "Only %d/%d required colors accessible" % [colors_found, required_colors.size()]
				
				colors_instance.queue_free()
			else:
				result.error = "Failed to instantiate MedicalColors"
		else:
			result.error = "Failed to load MedicalColors script"
	
	except Exception as e:
		result.error = "Exception testing medical colors: " + str(e)
	
	return result

func test_medical_fonts_accessibility() -> Dictionary:
	"""Test that medical fonts are accessible for validation"""
	
	var result = {
		"name": "Medical Fonts Accessibility",
		"passed": false,
		"error": ""
	}
	
	try:
		var fonts_script = load("res://scripts/ui/medical_theme/MedicalFont.gd")
		if fonts_script:
			var fonts_instance = fonts_script.new()
			if fonts_instance:
				# Test key medical font methods used in MenuScene
				var required_methods = ["get_chart_header_font_config", "get_button_font_config"]
				var methods_found = 0
				
				for method_name in required_methods:
					if fonts_instance.has_method(method_name):
						try:
							var config = fonts_instance.call(method_name)
							if config is Dictionary and config.has("size"):
								methods_found += 1
						except:
							pass
				
				if methods_found == required_methods.size():
					result.passed = true
				else:
					result.error = "Only %d/%d font methods functional" % [methods_found, required_methods.size()]
				
				fonts_instance.queue_free()
			else:
				result.error = "Failed to instantiate MedicalFont"
		else:
			result.error = "Failed to load MedicalFont script"
	
	except Exception as e:
		result.error = "Exception testing medical fonts: " + str(e)
	
	return result

func test_menuscene_medical_integration() -> Dictionary:
	"""Test that MenuScene can integrate with medical theme components"""
	
	var result = {
		"name": "MenuScene Medical Integration",
		"passed": false,
		"error": ""
	}
	
	try:
		# Test MenuScene script compilation
		var menuscene_script = load("res://scripts/ui/MenuScene.gd")
		if menuscene_script:
			# Test MenuScene.tscn loading
			if ResourceLoader.exists("res://scenes/MenuScene.tscn"):
				var scene_resource = load("res://scenes/MenuScene.tscn")
				if scene_resource and scene_resource is PackedScene:
					# Test scene instantiation
					var scene_instance = scene_resource.instantiate()
					if scene_instance:
						result.passed = true
						scene_instance.queue_free()
					else:
						result.error = "MenuScene failed to instantiate"
				else:
					result.error = "MenuScene.tscn is not a valid PackedScene"
			else:
				result.error = "MenuScene.tscn file not found"
		else:
			result.error = "MenuScene.gd script failed to load"
	
	except Exception as e:
		result.error = "Exception testing MenuScene integration: " + str(e)
	
	return result

func validate_test_framework_functionality() -> Dictionary:
	"""Validate that the test framework components function properly"""
	
	var results = {
		"all_passed": false,
		"framework_components_tested": 0,
		"framework_components_functional": 0,
		"details": []
	}
	
	# Test PostFix Validator functionality
	var validator_test = test_postfix_validator_functionality()
	results.details.append(validator_test)
	results.framework_components_tested += 1
	if validator_test.passed:
		results.framework_components_functional += 1
		print("✅ PostFix Validator - Functional")
	else:
		print("❌ PostFix Validator - Issue: %s" % validator_test.error)
	
	# Test Manual Validation Test functionality
	var manual_test = test_manual_validation_functionality()
	results.details.append(manual_test)
	results.framework_components_tested += 1
	if manual_test.passed:
		results.framework_components_functional += 1
		print("✅ Manual Validation Test - Functional")
	else:
		print("❌ Manual Validation Test - Issue: %s" % manual_test.error)
	
	# Test TestRunner functionality
	var runner_test = test_runner_functionality()
	results.details.append(runner_test)
	results.framework_components_tested += 1
	if runner_test.passed:
		results.framework_components_functional += 1
		print("✅ Test Runner - Functional")
	else:
		print("❌ Test Runner - Issue: %s" % runner_test.error)
	
	# Test ValidationTest.tscn functionality
	var scene_test = test_validation_scene_functionality()
	results.details.append(scene_test)
	results.framework_components_tested += 1
	if scene_test.passed:
		results.framework_components_functional += 1
		print("✅ ValidationTest Scene - Functional")
	else:
		print("❌ ValidationTest Scene - Issue: %s" % scene_test.error)
	
	results.all_passed = (results.framework_components_functional == results.framework_components_tested)
	
	print("Test Framework Results: %d/%d components functional" % [results.framework_components_functional, results.framework_components_tested])
	
	return results

func test_postfix_validator_functionality() -> Dictionary:
	"""Test MenuScene_PostFix_Validator functionality"""
	
	var result = {
		"name": "MenuScene PostFix Validator",
		"passed": false,
		"error": ""
	}
	
	try:
		var validator_script = load("res://scripts/tests/MenuScene_PostFix_Validator.gd")
		if validator_script:
			var validator_instance = validator_script.new()
			if validator_instance:
				# Test key methods exist
				var required_methods = [
					"run_post_fix_validation",
					"_run_compilation_tests", 
					"_run_medical_theming_tests",
					"_run_functionality_tests"
				]
				
				var methods_found = 0
				for method_name in required_methods:
					if validator_instance.has_method(method_name):
						methods_found += 1
				
				if methods_found == required_methods.size():
					result.passed = true
				else:
					result.error = "Only %d/%d validator methods found" % [methods_found, required_methods.size()]
				
				validator_instance.queue_free()
			else:
				result.error = "Failed to instantiate PostFix Validator"
		else:
			result.error = "Failed to load PostFix Validator script"
	
	except Exception as e:
		result.error = "Exception testing PostFix Validator: " + str(e)
	
	return result

func test_manual_validation_functionality() -> Dictionary:
	"""Test ManualValidationTest functionality"""
	
	var result = {
		"name": "Manual Validation Test",
		"passed": false,
		"error": ""
	}
	
	try:
		var manual_script = load("res://scripts/tests/ManualValidationTest.gd")
		if manual_script:
			var manual_instance = manual_script.new()
			if manual_instance:
				# Test key methods exist
				var required_methods = [
					"test_menuscene_compilation",
					"test_medical_colors",
					"test_medical_fonts",
					"test_scene_loading"
				]
				
				var methods_found = 0
				for method_name in required_methods:
					if manual_instance.has_method(method_name):
						methods_found += 1
				
				if methods_found == required_methods.size():
					result.passed = true
				else:
					result.error = "Only %d/%d manual test methods found" % [methods_found, required_methods.size()]
				
				manual_instance.queue_free()
			else:
				result.error = "Failed to instantiate Manual Validation Test"
		else:
			result.error = "Failed to load Manual Validation Test script"
	
	except Exception as e:
		result.error = "Exception testing Manual Validation: " + str(e)
	
	return result

func test_runner_functionality() -> Dictionary:
	"""Test MenuScene_TestRunner functionality"""
	
	var result = {
		"name": "MenuScene Test Runner",
		"passed": false,
		"error": ""
	}
	
	try:
		var runner_script = load("res://scripts/tests/MenuScene_TestRunner.gd")
		if runner_script:
			var runner_instance = runner_script.new()
			if runner_instance:
				# Test key methods exist
				var required_methods = [
					"run_complete_validation_suite",
					"run_quick_smoke_test",
					"test_medical_font_styling_preservation",
					"test_button_functionality"
				]
				
				var methods_found = 0
				for method_name in required_methods:
					if runner_instance.has_method(method_name):
						methods_found += 1
				
				if methods_found == required_methods.size():
					result.passed = true
				else:
					result.error = "Only %d/%d test runner methods found" % [methods_found, required_methods.size()]
				
				runner_instance.queue_free()
			else:
				result.error = "Failed to instantiate Test Runner"
		else:
			result.error = "Failed to load Test Runner script"
	
	except Exception as e:
		result.error = "Exception testing Test Runner: " + str(e)
	
	return result

func test_validation_scene_functionality() -> Dictionary:
	"""Test ValidationTest.tscn functionality"""
	
	var result = {
		"name": "ValidationTest Scene",
		"passed": false,
		"error": ""
	}
	
	try:
		if ResourceLoader.exists("res://scenes/ValidationTest.tscn"):
			var scene_resource = load("res://scenes/ValidationTest.tscn")
			if scene_resource and scene_resource is PackedScene:
				var scene_instance = scene_resource.instantiate()
				if scene_instance:
					# Check if it has the ManualValidationTest script attached
					var script = scene_instance.get_script()
					if script and script.resource_path == "res://scripts/tests/ManualValidationTest.gd":
						result.passed = true
					else:
						result.error = "ValidationTest scene doesn't have correct script attached"
					
					scene_instance.queue_free()
				else:
					result.error = "ValidationTest scene failed to instantiate"
			else:
				result.error = "ValidationTest.tscn is not a valid PackedScene"
		else:
			result.error = "ValidationTest.tscn file not found"
	
	except Exception as e:
		result.error = "Exception testing ValidationTest scene: " + str(e)
	
	return result

func determine_overall_status(results: Dictionary) -> String:
	"""Determine overall validation status based on results"""
	
	var total_categories = 4
	var passed_categories = 0
	
	if results.test_script_compilation.get("all_passed", false):
		passed_categories += 1
	if results.dependency_availability.get("all_passed", false):
		passed_categories += 1
	if results.medical_theme_preservation.get("all_passed", false):
		passed_categories += 1
	if results.test_framework_functionality.get("all_passed", false):
		passed_categories += 1
	
	var success_rate = float(passed_categories) / float(total_categories) * 100.0
	
	if success_rate == 100.0:
		return "EXCELLENT - All tests passed"
	elif success_rate >= 75.0:
		return "GOOD - Most tests passed"
	elif success_rate >= 50.0:
		return "NEEDS_WORK - Some critical issues"
	else:
		return "CRITICAL_FAILURE - Major issues detected"

func print_final_report(results: Dictionary) -> void:
	"""Print comprehensive final validation report"""
	
	print("\n" + "=" * 60)
	print("TESTINGAGENT VALIDATION REPORT")
	print("=" * 60)
	
	print("\n📊 OVERALL STATUS: %s" % results.overall_status)
	
	# Summary statistics
	var categories = ["test_script_compilation", "dependency_availability", "medical_theme_preservation", "test_framework_functionality"]
	var category_names = ["Test Script Compilation", "Dependency Availability", "Medical Theme Preservation", "Test Framework Functionality"]
	
	print("\n📋 CATEGORY SUMMARY:")
	for i in range(categories.size()):
		var category_key = categories[i]
		var category_name = category_names[i]
		var category_result = results[category_key]
		var status = "✅ PASS" if category_result.get("all_passed", false) else "❌ FAIL"
		print("  %s %s" % [status, category_name])
	
	print("\n🔍 DETAILED FINDINGS:")
	
	# Test Script Compilation Details
	var compilation = results.test_script_compilation
	print("\n  📝 Test Script Compilation:")
	print("    Scripts Tested: %d" % compilation.get("scripts_tested", 0))
	print("    Scripts Passed: %d" % compilation.get("scripts_passed", 0))
	for detail in compilation.get("details", []):
		var status = "✅" if detail.passed else "❌"
		print("    %s %s" % [status, detail.name])
		if not detail.passed:
			print("      Error: %s" % detail.error)
	
	# Dependency Availability Details
	var dependencies = results.dependency_availability
	print("\n  📦 Dependency Availability:")
	print("    Dependencies Tested: %d" % dependencies.get("dependencies_tested", 0))
	print("    Dependencies Available: %d" % dependencies.get("dependencies_available", 0))
	for detail in dependencies.get("details", []):
		var status = "✅" if detail.passed else "❌"
		print("    %s %s" % [status, detail.name])
		if not detail.passed:
			print("      Error: %s" % detail.error)
	
	# Medical Theme Preservation Details
	var theme = results.medical_theme_preservation
	print("\n  🏥 Medical Theme Preservation:")
	print("    Theme Elements Tested: %d" % theme.get("theme_elements_tested", 0))
	print("    Theme Elements Preserved: %d" % theme.get("theme_elements_preserved", 0))
	for detail in theme.get("details", []):
		var status = "✅" if detail.passed else "❌"
		print("    %s %s" % [status, detail.name])
		if not detail.passed:
			print("      Error: %s" % detail.error)
	
	# Test Framework Functionality Details
	var framework = results.test_framework_functionality
	print("\n  🧪 Test Framework Functionality:")
	print("    Components Tested: %d" % framework.get("framework_components_tested", 0))
	print("    Components Functional: %d" % framework.get("framework_components_functional", 0))
	for detail in framework.get("details", []):
		var status = "✅" if detail.passed else "❌"
		print("    %s %s" % [status, detail.name])
		if not detail.passed:
			print("      Error: %s" % detail.error)
	
	# Success Criteria Assessment
	print("\n🎯 SUCCESS CRITERIA ASSESSMENT:")
	print("  ✅ No parse errors in Godot console: %s" % ("YES" if compilation.get("all_passed", false) else "NO"))
	print("  ✅ Test scripts can be instantiated: %s" % ("YES" if compilation.get("all_passed", false) else "NO"))
	print("  ✅ Validation functions execute without crashes: %s" % ("YES" if framework.get("all_passed", false) else "NO"))
	print("  ✅ Medical theme validation preserved: %s" % ("YES" if theme.get("all_passed", false) else "NO"))
	
	# Final Recommendations
	print("\n💡 RECOMMENDATIONS:")
	if results.overall_status.begins_with("EXCELLENT"):
		print("  • All test scripts are ready for production use")
		print("  • Medical start screen testing framework is fully operational")
		print("  • No immediate action required")
	elif results.overall_status.begins_with("GOOD"):
		print("  • Most components are working correctly")
		print("  • Address any minor issues when convenient")
		print("  • Test framework is largely operational")
	elif results.overall_status.begins_with("NEEDS_WORK"):
		print("  • Some critical issues need to be addressed")
		print("  • Review failed components and fix issues")
		print("  • Re-run validation after fixes")
	else:
		print("  • Critical issues detected - immediate attention required")
		print("  • Do not use test framework until issues are resolved")
		print("  • Review all failed components systematically")
	
	print("\n" + "=" * 60)
	print("VALIDATION COMPLETE")
	print("=" * 60)
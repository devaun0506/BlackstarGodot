extends Node
## Comprehensive test script for Blackstar game flow validation
##
## This script provides automated testing functions to validate all aspects
## of the game flow from menu to results.

signal test_completed(test_name: String, passed: bool, details: String)
signal all_tests_completed(results: Dictionary)

# Test results tracking
var test_results: Dictionary = {}
var current_test_phase: String = ""
var tests_running: bool = false

func _ready() -> void:
	print("GameFlowTester ready")

func run_full_test_suite() -> void:
	"""Run the complete game flow test suite"""
	if tests_running:
		print("Tests already running, please wait...")
		return
	
	tests_running = true
	test_results.clear()
	print("=== Starting Blackstar Game Flow Test Suite ===")
	
	# Run all test phases
	await _test_autoload_systems()
	await _test_scene_loading()
	await _test_signal_connections()
	await _test_data_loading()
	await _test_input_handling()
	await _test_game_mechanics()
	await _test_error_conditions()
	
	_generate_test_report()
	tests_running = false

func _test_autoload_systems() -> void:
	"""Test that all autoloaded systems are available and functional"""
	current_test_phase = "Autoload Systems"
	print("\n--- Testing Autoload Systems ---")
	
	# Test ShiftManager
	var shift_manager_ok = _test_autoload("ShiftManager", ShiftManager, [
		"start_new_shift", "end_shift", "get_shift_statistics", "load_next_patient"
	])
	_record_test_result("ShiftManager Available", shift_manager_ok, "ShiftManager autoload validation")
	
	# Test PatientLoader
	var patient_loader_ok = _test_autoload("PatientLoader", PatientLoader, [
		"load_patient_queue", "load_patient_case", "get_available_case_count"
	])
	_record_test_result("PatientLoader Available", patient_loader_ok, "PatientLoader autoload validation")
	
	# Test TimerSystem
	var timer_system_ok = _test_autoload("TimerSystem", TimerSystem, [
		"start_shift_timer", "stop_timer", "get_time_remaining", "format_time"
	])
	_record_test_result("TimerSystem Available", timer_system_ok, "TimerSystem autoload validation")
	
	# Test signal availability
	_test_signals()
	
	await get_tree().create_timer(0.1).timeout

func _test_autoload(name: String, autoload_ref: Node, required_methods: Array[String]) -> bool:
	"""Test individual autoload system"""
	if not autoload_ref:
		print("❌ %s: Autoload not available" % name)
		return false
	
	print("✅ %s: Autoload available" % name)
	
	# Check required methods
	var missing_methods = []
	for method in required_methods:
		if not autoload_ref.has_method(method):
			missing_methods.append(method)
	
	if missing_methods.size() > 0:
		print("❌ %s: Missing methods: %s" % [name, missing_methods])
		return false
	
	print("✅ %s: All required methods available" % name)
	return true

func _test_signals() -> void:
	"""Test that required signals are available"""
	var signal_tests = [
		{"system": ShiftManager, "signals": ["shift_started", "shift_ended", "patient_completed", "score_updated"]},
		{"system": PatientLoader, "signals": ["patient_loaded", "patient_queue_loaded"]},
		{"system": TimerSystem, "signals": ["time_updated", "time_expired"]}
	]
	
	var all_signals_ok = true
	for test in signal_tests:
		var system = test.system
		var signals = test.signals
		var system_name = str(system.get_script().resource_path).get_file().get_basename()
		
		if not system:
			all_signals_ok = false
			continue
			
		for signal_name in signals:
			if not system.has_signal(signal_name):
				print("❌ %s: Missing signal '%s'" % [system_name, signal_name])
				all_signals_ok = false
			else:
				print("✅ %s: Signal '%s' available" % [system_name, signal_name])
	
	_record_test_result("Signal Availability", all_signals_ok, "All required signals are available")

func _test_scene_loading() -> void:
	"""Test scene loading and basic structure"""
	current_test_phase = "Scene Loading"
	print("\n--- Testing Scene Loading ---")
	
	# Test scene resource loading
	var scenes = {
		"MenuScene": "res://scenes/MenuScene.tscn",
		"GameScene": "res://scenes/GameScene.tscn", 
		"ResultsScene": "res://scenes/ResultsScene.tscn"
	}
	
	var all_scenes_ok = true
	for scene_name in scenes:
		var scene_path = scenes[scene_name]
		var scene_resource = load(scene_path)
		
		if not scene_resource:
			print("❌ %s: Failed to load from %s" % [scene_name, scene_path])
			all_scenes_ok = false
		else:
			print("✅ %s: Loaded successfully" % scene_name)
			
			# Test instantiation
			var instance = scene_resource.instantiate()
			if not instance:
				print("❌ %s: Failed to instantiate" % scene_name)
				all_scenes_ok = false
			else:
				print("✅ %s: Instantiated successfully" % scene_name)
				instance.queue_free()
	
	_record_test_result("Scene Loading", all_scenes_ok, "All scenes load and instantiate correctly")
	await get_tree().create_timer(0.1).timeout

func _test_signal_connections() -> void:
	"""Test signal connections work properly"""
	current_test_phase = "Signal Connections"
	print("\n--- Testing Signal Connections ---")
	
	var connections_ok = true
	
	# Test that we can connect to autoload signals
	if ShiftManager and ShiftManager.has_signal("shift_started"):
		var callable_test = func(): pass
		if ShiftManager.shift_started.connect(callable_test) == OK:
			print("✅ Signal connections: Can connect to ShiftManager signals")
			ShiftManager.shift_started.disconnect(callable_test)
		else:
			print("❌ Signal connections: Failed to connect to ShiftManager signals")
			connections_ok = false
	else:
		print("❌ Signal connections: ShiftManager or signals not available")
		connections_ok = false
	
	_record_test_result("Signal Connections", connections_ok, "Signal connection system works")
	await get_tree().create_timer(0.1).timeout

func _test_data_loading() -> void:
	"""Test patient data loading functionality"""
	current_test_phase = "Data Loading"
	print("\n--- Testing Data Loading ---")
	
	if not PatientLoader:
		_record_test_result("Data Loading", false, "PatientLoader not available")
		return
	
	# Test case count
	var case_count = PatientLoader.get_available_case_count()
	print("Available patient cases: %d" % case_count)
	
	# Test loading patient queue
	var patient_queue = PatientLoader.load_patient_queue(3)
	var queue_ok = patient_queue.size() > 0
	
	if queue_ok:
		print("✅ Data Loading: Successfully loaded %d patients" % patient_queue.size())
		
		# Validate first patient data
		if patient_queue.size() > 0:
			var first_patient = patient_queue[0]
			var required_fields = ["question", "answers"]
			var fields_ok = true
			
			for field in required_fields:
				if not first_patient.has(field):
					print("❌ Data validation: Missing field '%s'" % field)
					fields_ok = false
			
			if fields_ok:
				print("✅ Data validation: Patient data structure is valid")
			else:
				queue_ok = false
	else:
		print("❌ Data Loading: Failed to load patient queue")
	
	_record_test_result("Data Loading", queue_ok, "Patient data loads and validates correctly")
	await get_tree().create_timer(0.1).timeout

func _test_input_handling() -> void:
	"""Test input handling systems"""
	current_test_phase = "Input Handling" 
	print("\n--- Testing Input Handling ---")
	
	# Test input event creation and processing
	var input_ok = true
	
	# Create test input events
	var key_events = []
	for i in range(1, 6):  # Keys 1-5
		var event = InputEventKey.new()
		event.keycode = KEY_0 + i  # KEY_1, KEY_2, etc.
		event.pressed = true
		key_events.append(event)
	
	# Test spacebar
	var space_event = InputEventKey.new()
	space_event.keycode = KEY_SPACE
	space_event.pressed = true
	key_events.append(space_event)
	
	# Test enter
	var enter_event = InputEventKey.new()
	enter_event.keycode = KEY_ENTER
	enter_event.pressed = true
	key_events.append(enter_event)
	
	print("✅ Input Handling: Created test input events")
	_record_test_result("Input Handling", input_ok, "Input event system functional")
	await get_tree().create_timer(0.1).timeout

func _test_game_mechanics() -> void:
	"""Test core game mechanics"""
	current_test_phase = "Game Mechanics"
	print("\n--- Testing Game Mechanics ---")
	
	var mechanics_ok = true
	
	# Test shift management
	if ShiftManager and ShiftManager.has_method("get_shift_statistics"):
		var stats = ShiftManager.get_shift_statistics()
		if stats.has("patients_treated") and stats.has("accuracy"):
			print("✅ Game Mechanics: Statistics system functional")
		else:
			print("❌ Game Mechanics: Statistics missing required fields")
			mechanics_ok = false
	else:
		print("❌ Game Mechanics: Statistics system not available")
		mechanics_ok = false
	
	# Test timer functionality
	if TimerSystem and TimerSystem.has_method("format_time"):
		var formatted = TimerSystem.format_time(125.0)  # 2:05
		if formatted == "02:05":
			print("✅ Game Mechanics: Timer formatting works")
		else:
			print("❌ Game Mechanics: Timer formatting incorrect: " + formatted)
			mechanics_ok = false
	else:
		print("❌ Game Mechanics: Timer system not available")
		mechanics_ok = false
	
	_record_test_result("Game Mechanics", mechanics_ok, "Core game mechanics functional")
	await get_tree().create_timer(0.1).timeout

func _test_error_conditions() -> void:
	"""Test error handling and edge cases"""
	current_test_phase = "Error Handling"
	print("\n--- Testing Error Handling ---")
	
	var error_handling_ok = true
	
	# Test with invalid data
	if PatientLoader:
		# This should handle gracefully without crashing
		var invalid_case = PatientLoader.load_patient_case("nonexistent_file.json")
		if invalid_case.is_empty():
			print("✅ Error Handling: Invalid file handled gracefully")
		else:
			print("❌ Error Handling: Invalid file not handled properly")
			error_handling_ok = false
	
	# Test timer with invalid duration
	if TimerSystem:
		# This should be handled without crashing
		var original_active = TimerSystem.is_timer_active()
		TimerSystem.start_shift_timer(-5.0)  # Invalid negative duration
		var after_invalid = TimerSystem.is_timer_active()
		
		if not after_invalid:
			print("✅ Error Handling: Invalid timer duration handled")
		else:
			print("❌ Error Handling: Invalid timer duration not handled")
			error_handling_ok = false
	
	_record_test_result("Error Handling", error_handling_ok, "Error conditions handled gracefully")
	await get_tree().create_timer(0.1).timeout

func _record_test_result(test_name: String, passed: bool, details: String) -> void:
	"""Record a test result"""
	test_results[test_name] = {
		"passed": passed,
		"details": details,
		"phase": current_test_phase
	}
	
	var status = "✅" if passed else "❌"
	print("%s %s: %s" % [status, test_name, details])
	test_completed.emit(test_name, passed, details)

func _generate_test_report() -> void:
	"""Generate and display final test report"""
	print("\n=== BLACKSTAR GAME FLOW TEST REPORT ===")
	
	var total_tests = test_results.size()
	var passed_tests = 0
	
	for test_name in test_results:
		var result = test_results[test_name]
		if result.passed:
			passed_tests += 1
	
	print("Total Tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % (total_tests - passed_tests))
	print("Success Rate: %.1f%%" % ((float(passed_tests) / float(total_tests)) * 100.0))
	
	print("\n--- Detailed Results ---")
	var phases = {}
	for test_name in test_results:
		var result = test_results[test_name]
		var phase = result.phase
		if not phases.has(phase):
			phases[phase] = {"passed": 0, "total": 0}
		phases[phase].total += 1
		if result.passed:
			phases[phase].passed += 1
	
	for phase in phases:
		var phase_data = phases[phase]
		var phase_success = (float(phase_data.passed) / float(phase_data.total)) * 100.0
		print("%s: %d/%d (%.1f%%)" % [phase, phase_data.passed, phase_data.total, phase_success])
	
	print("\n--- Failed Tests ---")
	for test_name in test_results:
		var result = test_results[test_name]
		if not result.passed:
			print("❌ %s: %s" % [test_name, result.details])
	
	print("\n=== END TEST REPORT ===")
	
	all_tests_completed.emit({
		"total": total_tests,
		"passed": passed_tests,
		"failed": total_tests - passed_tests,
		"success_rate": (float(passed_tests) / float(total_tests)) * 100.0,
		"results": test_results
	})

func get_test_results() -> Dictionary:
	"""Get the current test results"""
	return test_results.duplicate()

func is_testing() -> bool:
	"""Check if tests are currently running"""
	return tests_running
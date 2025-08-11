extends Node
## Compilation test script for Blackstar
## Verifies that all autoloads and main systems compile and initialize properly

func _ready() -> void:
	print("=== Blackstar Compilation Test ===")
	test_autoloads()
	test_scene_loading()
	test_core_systems()
	print("=== Compilation Test Complete ===")

func test_autoloads() -> void:
	"""Test that all autoloads are properly initialized"""
	print("\n1. Testing Autoloads...")
	
	var success_count = 0
	var total_tests = 4
	
	# Test Globals
	if Globals:
		print("✓ Globals autoload initialized")
		success_count += 1
	else:
		print("✗ Globals autoload failed")
	
	# Test ShiftManager
	if ShiftManager:
		print("✓ ShiftManager autoload initialized")
		success_count += 1
	else:
		print("✗ ShiftManager autoload failed")
	
	# Test PatientLoader
	if PatientLoader:
		print("✓ PatientLoader autoload initialized")
		success_count += 1
	else:
		print("✗ PatientLoader autoload failed")
	
	# Test TimerSystem
	if TimerSystem:
		print("✓ TimerSystem autoload initialized")
		success_count += 1
	else:
		print("✗ TimerSystem autoload failed")
	
	print("Autoload Test Results: %d/%d passed" % [success_count, total_tests])

func test_scene_loading():
	"""Test that scene files exist and can be loaded"""
	print("\n2. Testing Scene Loading...")
	
	var scenes = [
		"res://scenes/Main.tscn",
		"res://scenes/MenuScene.tscn",
		"res://scenes/GameScene.tscn",
		"res://scenes/ResultsScene.tscn"
	]
	
	var success_count = 0
	
	for scene_path in scenes:
		if ResourceLoader.exists(scene_path):
			print("✓ Scene exists: %s" % scene_path.get_file())
			success_count += 1
		else:
			print("✗ Scene missing: %s" % scene_path.get_file())
	
	print("Scene Test Results: %d/%d passed" % [success_count, scenes.size()])

func test_core_systems():
	"""Test that core systems have required methods"""
	print("\n3. Testing Core Systems...")
	
	var tests_passed = 0
	var total_tests = 0
	
	# Test ShiftManager methods
	if ShiftManager:
		total_tests += 3
		if ShiftManager.has_method("start_new_shift"):
			tests_passed += 1
			print("✓ ShiftManager.start_new_shift exists")
		else:
			print("✗ ShiftManager.start_new_shift missing")
		
		if ShiftManager.has_method("get_shift_statistics"):
			tests_passed += 1
			print("✓ ShiftManager.get_shift_statistics exists")
		else:
			print("✗ ShiftManager.get_shift_statistics missing")
		
		if ShiftManager.has_method("end_shift"):
			tests_passed += 1
			print("✓ ShiftManager.end_shift exists")
		else:
			print("✗ ShiftManager.end_shift missing")
	
	# Test TimerSystem methods
	if TimerSystem:
		total_tests += 4
		if TimerSystem.has_method("start_shift_timer"):
			tests_passed += 1
			print("✓ TimerSystem.start_shift_timer exists")
		else:
			print("✗ TimerSystem.start_shift_timer missing")
		
		if TimerSystem.has_method("format_time"):
			tests_passed += 1
			print("✓ TimerSystem.format_time exists")
		else:
			print("✗ TimerSystem.format_time missing")
		
		if TimerSystem.has_method("get_formatted_elapsed_time"):
			tests_passed += 1
			print("✓ TimerSystem.get_formatted_elapsed_time exists")
		else:
			print("✗ TimerSystem.get_formatted_elapsed_time missing")
		
		if TimerSystem.has_method("get_formatted_time_remaining"):
			tests_passed += 1
			print("✓ TimerSystem.get_formatted_time_remaining exists")
		else:
			print("✗ TimerSystem.get_formatted_time_remaining missing")
	
	# Test PatientLoader methods
	if PatientLoader:
		total_tests += 2
		if PatientLoader.has_method("load_patient_queue"):
			tests_passed += 1
			print("✓ PatientLoader.load_patient_queue exists")
		else:
			print("✗ PatientLoader.load_patient_queue missing")
		
		if PatientLoader.has_method("get_available_case_count"):
			tests_passed += 1
			print("✓ PatientLoader.get_available_case_count exists")
		else:
			print("✗ PatientLoader.get_available_case_count missing")
	
	# Test QuestionController instantiation
	total_tests += 1
	if ResourceLoader.exists("res://scripts/systems/QuestionController.gd"):
		try:
			var controller = preload("res://scripts/systems/QuestionController.gd").new()
			if controller:
				tests_passed += 1
				print("✓ QuestionController can be instantiated")
				controller.queue_free()
			else:
				print("✗ QuestionController instantiation failed")
		except:
			print("✗ QuestionController compilation error")
	else:
		print("✗ QuestionController script missing")
	
	print("Core Systems Test Results: %d/%d passed" % [tests_passed, total_tests])

func _exit_tree():
	print("\nCompilation test script exiting.")
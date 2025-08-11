extends Node
## Test script for verifying autoload system integration
##
## This script can be used to validate that all autoloads are properly
## initialized and can communicate with each other without errors.

func _ready() -> void:
	print("=== Autoload System Integration Test ===")
	test_autoload_availability()
	test_signal_connections()
	test_basic_functionality()
	print("=== Test Complete ===")

func test_autoload_availability() -> void:
	"""Test that all expected autoloads are available"""
	print("\n1. Testing autoload availability...")
	
	if ShiftManager:
		print("✓ ShiftManager autoload is available")
	else:
		print("✗ ShiftManager autoload is NOT available")
	
	if PatientLoader:
		print("✓ PatientLoader autoload is available")
	else:
		print("✗ PatientLoader autoload is NOT available")
	
	if TimerSystem:
		print("✓ TimerSystem autoload is available")
	else:
		print("✗ TimerSystem autoload is NOT available")

func test_signal_connections() -> void:
	"""Test that autoloads can connect their signals"""
	print("\n2. Testing signal connections...")
	
	# Test ShiftManager signals
	if ShiftManager and ShiftManager.has_signal("shift_started"):
		print("✓ ShiftManager.shift_started signal available")
	else:
		print("✗ ShiftManager.shift_started signal NOT available")
	
	if ShiftManager and ShiftManager.has_signal("shift_ended"):
		print("✓ ShiftManager.shift_ended signal available")
	else:
		print("✗ ShiftManager.shift_ended signal NOT available")
	
	# Test PatientLoader signals
	if PatientLoader and PatientLoader.has_signal("patient_loaded"):
		print("✓ PatientLoader.patient_loaded signal available")
	else:
		print("✗ PatientLoader.patient_loaded signal NOT available")
	
	# Test TimerSystem signals
	if TimerSystem and TimerSystem.has_signal("time_updated"):
		print("✓ TimerSystem.time_updated signal available")
	else:
		print("✗ TimerSystem.time_updated signal NOT available")

func test_basic_functionality() -> void:
	"""Test basic methods of each autoload"""
	print("\n3. Testing basic functionality...")
	
	# Test PatientLoader
	if PatientLoader and PatientLoader.has_method("get_available_case_count"):
		var case_count = PatientLoader.get_available_case_count()
		print("✓ PatientLoader.get_available_case_count() returned: %d" % case_count)
	else:
		print("✗ PatientLoader.get_available_case_count() method NOT available")
	
	# Test TimerSystem
	if TimerSystem and TimerSystem.has_method("format_time"):
		var formatted = TimerSystem.format_time(125.5)
		print("✓ TimerSystem.format_time(125.5) returned: %s" % formatted)
	else:
		print("✗ TimerSystem.format_time() method NOT available")
	
	# Test ShiftManager
	if ShiftManager and ShiftManager.has_method("get_shift_statistics"):
		var stats = ShiftManager.get_shift_statistics()
		print("✓ ShiftManager.get_shift_statistics() returned: %s" % str(stats))
	else:
		print("✗ ShiftManager.get_shift_statistics() method NOT available")
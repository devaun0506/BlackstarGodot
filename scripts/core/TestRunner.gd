extends Node
## Simple test runner for Blackstar game flow validation
##
## This script provides a simple interface to run game flow tests
## and can be attached to any scene or run independently.

func _ready() -> void:
	print("TestRunner ready - Use run_tests() to start testing")

func run_tests() -> void:
	"""Run the complete test suite"""
	print("Creating GameFlowTester...")
	var tester = preload("res://scripts/core/GameFlowTester.gd").new()
	add_child(tester)
	
	# Connect to test completion signal
	tester.all_tests_completed.connect(_on_tests_completed)
	
	print("Starting test suite...")
	await tester.run_full_test_suite()

func _on_tests_completed(results: Dictionary) -> void:
	"""Handle test completion"""
	print("\n🎯 TEST SUITE COMPLETED")
	print("Results: %d/%d tests passed (%.1f%%)" % [results.passed, results.total, results.success_rate])
	
	if results.success_rate >= 100.0:
		print("🎉 ALL TESTS PASSED! Game flow is ready.")
	elif results.success_rate >= 80.0:
		print("⚠️ Most tests passed. Minor issues detected.")
	else:
		print("❌ Significant issues found. Review failed tests.")

# Quick test function for console/debugger
func quick_autoload_test() -> void:
	"""Quick test of autoload systems only"""
	print("=== Quick Autoload Test ===")
	
	var systems = [
		{"name": "ShiftManager", "ref": ShiftManager},
		{"name": "PatientLoader", "ref": PatientLoader}, 
		{"name": "TimerSystem", "ref": TimerSystem}
	]
	
	for system in systems:
		if system.ref:
			print("✅ %s is available" % system.name)
		else:
			print("❌ %s is NOT available" % system.name)
	
	print("=== End Quick Test ===")

# Test individual system
func test_patient_loading() -> void:
	"""Test patient loading system specifically"""
	print("=== Patient Loading Test ===")
	
	if not PatientLoader:
		print("❌ PatientLoader not available")
		return
	
	print("Available cases: %d" % PatientLoader.get_available_case_count())
	
	var queue = PatientLoader.load_patient_queue(2)
	if queue.size() > 0:
		print("✅ Loaded %d patients" % queue.size())
		var first = queue[0]
		print("First patient has keys: %s" % first.keys())
	else:
		print("❌ Failed to load patient queue")
	
	print("=== End Patient Loading Test ===")

func test_timer_system() -> void:
	"""Test timer system specifically"""
	print("=== Timer System Test ===")
	
	if not TimerSystem:
		print("❌ TimerSystem not available") 
		return
	
	print("✅ TimerSystem available")
	print("Format test: 125.0 seconds = %s" % TimerSystem.format_time(125.0))
	print("Currently active: %s" % TimerSystem.is_timer_active())
	
	print("=== End Timer System Test ===")

# Console helper function
func help() -> void:
	"""Show available test functions"""
	print("=== TestRunner Help ===")
	print("Available functions:")
	print("• run_tests() - Complete test suite")
	print("• quick_autoload_test() - Quick autoload check")
	print("• test_patient_loading() - Test patient data loading")
	print("• test_timer_system() - Test timer functionality")
	print("• help() - Show this help")
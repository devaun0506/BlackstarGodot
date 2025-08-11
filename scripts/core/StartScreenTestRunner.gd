extends Node
class_name StartScreenTestRunner

## Comprehensive test runner for start screen functionality
## Integrates all specialized test suites and provides detailed reporting

signal test_suite_completed(results: Dictionary)

# Test suite instances
var start_screen_tester: StartScreenTester
var feedback_integration_tester: FeedbackIntegrationTester
var visual_audio_tester: VisualAudioTester
var responsive_design_tester: ResponsiveDesignTester
var error_handling_tester: ErrorHandlingTester

# Test configuration
var run_comprehensive_tests: bool = true
var skip_long_running_tests: bool = false
var output_detailed_report: bool = true

# Results tracking
var test_suite_results: Dictionary = {
	"start_screen": {},
	"email_integration": {},
	"visual_audio": {},
	"responsive_design": {},
	"error_handling": {},
	"overall": {
		"total_tests": 0,
		"passed_tests": 0,
		"failed_tests": 0,
		"success_rate": 0.0,
		"duration_seconds": 0.0
	}
}

func _ready() -> void:
	print("StartScreenTestRunner ready")

## Run the complete start screen test suite
func run_complete_test_suite() -> void:
	print("🚀 Starting comprehensive start screen test suite...")
	print("=" * 60)
	
	var start_time = Time.get_ticks_msec() / 1000.0
	
	# Initialize all test suites
	await initialize_test_suites()
	
	# Run all test categories
	if run_comprehensive_tests:
		await run_all_test_categories()
	else:
		await run_essential_tests_only()
	
	# Calculate final results
	var end_time = Time.get_ticks_msec() / 1000.0
	test_suite_results.overall.duration_seconds = end_time - start_time
	
	# Generate and display report
	calculate_overall_results()
	display_final_report()
	
	# Cleanup
	cleanup_test_suites()
	
	# Emit completion signal
	test_suite_completed.emit(test_suite_results)

## Initialize all test suite instances
func initialize_test_suites() -> void:
	print("🔧 Initializing test suites...")
	
	# Create test suite instances
	start_screen_tester = StartScreenTester.new()
	feedback_integration_tester = FeedbackIntegrationTester.new()
	visual_audio_tester = VisualAudioTester.new()
	responsive_design_tester = ResponsiveDesignTester.new()
	error_handling_tester = ErrorHandlingTester.new()
	
	# Add to scene tree
	add_child(start_screen_tester)
	add_child(feedback_integration_tester)
	add_child(visual_audio_tester)
	add_child(responsive_design_tester)
	add_child(error_handling_tester)
	
	print("✅ All test suites initialized")

## Run all test categories
func run_all_test_categories() -> void:
	print("📋 Running all test categories...")
	
	# Run core functionality tests
	print("\n" + "=" * 40)
	print("🎯 CORE FUNCTIONALITY TESTS")
	print("=" * 40)
	test_suite_results.start_screen = await start_screen_tester.run_full_test_suite()
	
	# Run email integration tests
	print("\n" + "=" * 40)
	print("📧 EMAIL INTEGRATION TESTS")
	print("=" * 40)
	test_suite_results.email_integration = await feedback_integration_tester.run_email_integration_tests()
	
	# Run visual/audio tests (skip if requested)
	if not skip_long_running_tests:
		print("\n" + "=" * 40)
		print("🎨 VISUAL/AUDIO TESTS")
		print("=" * 40)
		test_suite_results.visual_audio = await visual_audio_tester.run_visual_audio_tests()
	
	# Run responsive design tests
	print("\n" + "=" * 40)
	print("📱 RESPONSIVE DESIGN TESTS")
	print("=" * 40)
	test_suite_results.responsive_design = await responsive_design_tester.run_responsive_design_tests()
	
	# Run error handling tests
	print("\n" + "=" * 40)
	print("🛡️ ERROR HANDLING TESTS")
	print("=" * 40)
	test_suite_results.error_handling = await error_handling_tester.run_error_handling_tests()

## Run only essential tests (faster execution)
func run_essential_tests_only() -> void:
	print("⚡ Running essential tests only...")
	
	# Core functionality (essential)
	print("\n🎯 Core Functionality Tests")
	test_suite_results.start_screen = await start_screen_tester.run_full_test_suite()
	
	# Basic email integration (essential)
	print("\n📧 Email Integration Tests")
	test_suite_results.email_integration = await feedback_integration_tester.run_email_integration_tests()
	
	# Skip visual/audio tests (can be time-consuming)
	test_suite_results.visual_audio = {"passed": 0, "total": 0, "success_rate": 100.0, "details": []}
	
	# Basic responsive design (essential)
	print("\n📱 Responsive Design Tests")
	test_suite_results.responsive_design = await responsive_design_tester.run_responsive_design_tests()
	
	# Basic error handling (essential)
	print("\n🛡️ Error Handling Tests")
	test_suite_results.error_handling = await error_handling_tester.run_error_handling_tests()

## Calculate overall results from all test suites
func calculate_overall_results() -> void:
	var total_tests = 0
	var passed_tests = 0
	
	for category in ["start_screen", "email_integration", "visual_audio", "responsive_design", "error_handling"]:
		var results = test_suite_results[category]
		if results.has("total") and results.has("passed"):
			total_tests += results.total
			passed_tests += results.passed
	
	test_suite_results.overall.total_tests = total_tests
	test_suite_results.overall.passed_tests = passed_tests
	test_suite_results.overall.failed_tests = total_tests - passed_tests
	test_suite_results.overall.success_rate = (float(passed_tests) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0

## Display final comprehensive report
func display_final_report() -> void:
	print("\n" + "=" * 60)
	print("📊 COMPREHENSIVE START SCREEN TEST REPORT")
	print("=" * 60)
	
	# Overall summary
	var overall = test_suite_results.overall
	print("🎯 OVERALL RESULTS:")
	print("   Total Tests: %d" % overall.total_tests)
	print("   Passed: %d" % overall.passed_tests)
	print("   Failed: %d" % overall.failed_tests)
	print("   Success Rate: %.1f%%" % overall.success_rate)
	print("   Duration: %.1f seconds" % overall.duration_seconds)
	print("")
	
	# Category breakdown
	print("📋 CATEGORY BREAKDOWN:")
	display_category_results("Core Functionality", test_suite_results.start_screen)
	display_category_results("Email Integration", test_suite_results.email_integration)
	display_category_results("Visual/Audio", test_suite_results.visual_audio)
	display_category_results("Responsive Design", test_suite_results.responsive_design)
	display_category_results("Error Handling", test_suite_results.error_handling)
	
	# Quality assessment
	display_quality_assessment()
	
	# Recommendations
	display_recommendations()
	
	print("=" * 60)

func display_category_results(category_name: String, results: Dictionary) -> void:
	"""Display results for a specific test category"""
	
	if results.is_empty():
		print("   %s: Skipped" % category_name)
		return
	
	var passed = results.get("passed", 0)
	var total = results.get("total", 0)
	var success_rate = results.get("success_rate", 0.0)
	
	var status_icon = "✅" if success_rate >= 90.0 else ("⚠️" if success_rate >= 70.0 else "❌")
	print("   %s %s: %d/%d (%.1f%%)" % [status_icon, category_name, passed, total, success_rate])

func display_quality_assessment() -> void:
	"""Display quality assessment based on test results"""
	
	print("\n🏆 QUALITY ASSESSMENT:")
	
	var overall_success = test_suite_results.overall.success_rate
	
	if overall_success >= 95.0:
		print("   🌟 EXCELLENT - Start screen is production-ready!")
		print("   Outstanding quality with minimal issues detected.")
	
	elif overall_success >= 85.0:
		print("   ✨ VERY GOOD - Start screen is nearly ready for production.")
		print("   High quality with only minor issues to address.")
	
	elif overall_success >= 75.0:
		print("   👍 GOOD - Start screen is functional with some improvements needed.")
		print("   Solid foundation with moderate issues to resolve.")
	
	elif overall_success >= 60.0:
		print("   ⚠️  NEEDS WORK - Start screen has significant issues.")
		print("   Core functionality present but requires substantial improvements.")
	
	else:
		print("   🚨 CRITICAL - Start screen has major problems.")
		print("   Extensive work needed before production readiness.")

func display_recommendations() -> void:
	"""Display recommendations based on test results"""
	
	print("\n💡 RECOMMENDATIONS:")
	
	var recommendations = generate_recommendations()
	
	if recommendations.is_empty():
		print("   🎉 No specific recommendations - excellent work!")
		return
	
	for i in range(recommendations.size()):
		print("   %d. %s" % [i + 1, recommendations[i]])

func generate_recommendations() -> Array[String]:
	"""Generate specific recommendations based on test results"""
	
	var recommendations: Array[String] = []
	
	# Check each category for specific issues
	if test_suite_results.start_screen.get("success_rate", 100.0) < 90.0:
		recommendations.append("Review and fix core functionality issues in the start screen")
	
	if test_suite_results.email_integration.get("success_rate", 100.0) < 80.0:
		recommendations.append("Implement robust email integration with proper fallbacks")
	
	if test_suite_results.visual_audio.get("success_rate", 100.0) < 85.0:
		recommendations.append("Optimize visual rendering and ensure medical theme consistency")
	
	if test_suite_results.responsive_design.get("success_rate", 100.0) < 80.0:
		recommendations.append("Improve responsive design and mobile compatibility")
	
	if test_suite_results.error_handling.get("success_rate", 100.0) < 85.0:
		recommendations.append("Strengthen error handling and recovery mechanisms")
	
	# Overall performance recommendations
	if test_suite_results.overall.success_rate < 90.0:
		recommendations.append("Consider implementing automated testing in your development workflow")
		recommendations.append("Set up continuous integration to catch issues early")
	
	# Specific technical recommendations
	if test_suite_results.overall.success_rate >= 80.0:
		recommendations.append("Consider adding user analytics to monitor real-world usage")
		recommendations.append("Implement A/B testing for UI improvements")
	
	return recommendations

## Quick test function for development
func run_quick_smoke_test() -> void:
	"""Run a quick smoke test of essential functionality"""
	print("💨 Running quick smoke test...")
	
	var start_time = Time.get_ticks_msec() / 1000.0
	
	# Initialize minimal test setup
	start_screen_tester = StartScreenTester.new()
	add_child(start_screen_tester)
	
	# Run core tests only
	var core_results = await start_screen_tester.run_full_test_suite()
	
	var end_time = Time.get_ticks_msec() / 1000.0
	var duration = end_time - start_time
	
	print("💨 Smoke test completed in %.1f seconds" % duration)
	print("   Result: %d/%d tests passed (%.1f%%)" % 
		[core_results.get("passed", 0), core_results.get("total", 0), core_results.get("success_rate", 0.0)])
	
	start_screen_tester.queue_free()

## Export test results to JSON
func export_test_results() -> String:
	"""Export test results as JSON string"""
	
	var json = JSON.new()
	var json_string = json.stringify(test_suite_results, "\t")
	
	print("📄 Test results exported to JSON (%d characters)" % json_string.length())
	
	return json_string

## Save test results to file
func save_test_results_to_file(file_path: String = "user://start_screen_test_results.json") -> bool:
	"""Save test results to a file"""
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("❌ Failed to open file for writing: %s" % file_path)
		return false
	
	var json_string = export_test_results()
	file.store_string(json_string)
	file.close()
	
	print("💾 Test results saved to: %s" % file_path)
	return true

## Cleanup all test suites
func cleanup_test_suites() -> void:
	"""Clean up all test suite instances"""
	
	if start_screen_tester and is_instance_valid(start_screen_tester):
		start_screen_tester.queue_free()
	
	if feedback_integration_tester and is_instance_valid(feedback_integration_tester):
		feedback_integration_tester.queue_free()
	
	if visual_audio_tester and is_instance_valid(visual_audio_tester):
		visual_audio_tester.queue_free()
	
	if responsive_design_tester and is_instance_valid(responsive_design_tester):
		responsive_design_tester.queue_free()
	
	if error_handling_tester and is_instance_valid(error_handling_tester):
		error_handling_tester.queue_free()

# ===== CONSOLE HELPER FUNCTIONS =====

## Show help for using the test runner
func help() -> void:
	"""Display help information"""
	print("=" * 50)
	print("📚 START SCREEN TEST RUNNER HELP")
	print("=" * 50)
	print("Available functions:")
	print("• run_complete_test_suite() - Run all tests (comprehensive)")
	print("• run_quick_smoke_test() - Run essential tests only (fast)")
	print("• export_test_results() - Export results as JSON string")
	print("• save_test_results_to_file() - Save results to file")
	print("• help() - Show this help")
	print("")
	print("Configuration options:")
	print("• run_comprehensive_tests = true/false")
	print("• skip_long_running_tests = true/false")
	print("• output_detailed_report = true/false")
	print("=" * 50)

## Set test configuration for different scenarios
func configure_for_ci() -> void:
	"""Configure for continuous integration testing"""
	run_comprehensive_tests = true
	skip_long_running_tests = false  # Run all tests in CI
	output_detailed_report = true
	print("🤖 Configured for CI/automated testing")

func configure_for_development() -> void:
	"""Configure for development testing"""
	run_comprehensive_tests = false  # Skip some tests for speed
	skip_long_running_tests = true
	output_detailed_report = false
	print("🛠️  Configured for development testing")
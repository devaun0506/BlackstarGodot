extends SceneTree
## Command-line validation runner for Blackstar
## Run with: godot --headless -s run_validation_test.gd

func _init():
    print("=== BLACKSTAR VALIDATION TEST RUNNER ===")
    print("Validating fixes from CodeReviewAgent and PerformanceAgent")
    print("Target: Zero parser errors + 60 FPS performance + Medical functionality preserved")
    
    # Create test runner
    var test_runner = load("res://scripts/tests/ComprehensiveTestRunner.gd").new()
    root.add_child(test_runner)
    
    # Run validation
    await _run_validation(test_runner)
    
    # Exit
    quit()

func _run_validation(test_runner):
    print("\nStarting comprehensive validation...")
    
    var results = await test_runner.run_comprehensive_validation()
    
    # Print final summary
    var summary = results.validation_summary
    
    print("\n" + "="*50)
    print("BLACKSTAR VALIDATION RESULTS")
    print("="*50)
    print("Parser Errors Resolved: " + ("✅ PASS" if summary.parser_errors_resolved else "❌ FAIL"))
    print("Medical Systems Functional: " + ("✅ PASS" if summary.medical_systems_functional else "❌ FAIL"))  
    print("60 FPS Performance Achieved: " + ("✅ PASS" if summary.performance_60fps_achieved else "❌ FAIL"))
    print("Feedback System Working: " + ("✅ PASS" if summary.feedback_system_working else "❌ FAIL"))
    print("Overall Validation: " + ("✅ SUCCESS" if summary.overall_validation_success else "❌ FAILED"))
    print("="*50)
    
    if summary.overall_validation_success:
        print("🎉 VALIDATION SUCCESSFUL! All fixes working correctly.")
        set_exit_code(0)
    else:
        print("❌ VALIDATION FAILED! Check detailed results for issues.")
        set_exit_code(1)
    
    # Show performance summary if available
    if results.has("performance_metrics") and not results.performance_metrics.is_empty():
        print("\nPerformance Summary:")
        for test_name in results.performance_metrics:
            var metrics = results.performance_metrics[test_name]
            if metrics.has("average_fps"):
                var status = "✅" if metrics.average_fps >= 60.0 else "❌"
                print("  %s: %.1f FPS %s" % [test_name, metrics.average_fps, status])

func set_exit_code(code: int):
    # Set appropriate exit code for CI/CD systems
    if code != 0:
        OS.exit_code = code
extends Control
class_name ValidationTestScene

## Simple UI for running comprehensive validation tests
## Can be attached to a scene or run as a standalone test

@onready var test_runner: ComprehensiveTestRunner
@onready var results_display: RichTextLabel
@onready var progress_bar: ProgressBar
@onready var run_button: Button
@onready var quick_test_button: Button

signal validation_completed(success: bool)

func _ready():
    _setup_ui()
    _setup_test_runner()

func _setup_ui():
    # Create UI elements if they don't exist
    if not results_display:
        results_display = RichTextLabel.new()
        results_display.fit_content = true
        results_display.scroll_following = true
        add_child(results_display)
    
    if not progress_bar:
        progress_bar = ProgressBar.new()
        progress_bar.min_value = 0.0
        progress_bar.max_value = 1.0
        add_child(progress_bar)
    
    if not run_button:
        run_button = Button.new()
        run_button.text = "Run Comprehensive Validation"
        run_button.pressed.connect(_on_run_comprehensive_pressed)
        add_child(run_button)
    
    if not quick_test_button:
        quick_test_button = Button.new()
        quick_test_button.text = "Quick Smoke Test"
        quick_test_button.pressed.connect(_on_quick_test_pressed)
        add_child(quick_test_button)
    
    # Arrange UI elements
    _arrange_ui_elements()

func _arrange_ui_elements():
    # Simple vertical layout
    var button_height = 50
    var margin = 10
    
    run_button.position = Vector2(margin, margin)
    run_button.size = Vector2(300, button_height)
    
    quick_test_button.position = Vector2(margin + 310, margin)
    quick_test_button.size = Vector2(200, button_height)
    
    progress_bar.position = Vector2(margin, margin * 2 + button_height)
    progress_bar.size = Vector2(510, 30)
    
    results_display.position = Vector2(margin, margin * 3 + button_height + 30)
    results_display.size = Vector2(800, 500)

func _setup_test_runner():
    test_runner = ComprehensiveTestRunner.new()
    add_child(test_runner)
    
    # Connect signals
    test_runner.test_progress_updated.connect(_on_progress_updated)
    test_runner.test_suite_completed.connect(_on_validation_completed)

func _on_run_comprehensive_pressed():
    _log_message("Starting comprehensive validation...")
    run_button.disabled = true
    quick_test_button.disabled = true
    
    var results = await test_runner.run_comprehensive_validation()
    
    _display_results(results)
    run_button.disabled = false
    quick_test_button.disabled = false

func _on_quick_test_pressed():
    _log_message("Running quick smoke test...")
    run_button.disabled = true
    quick_test_button.disabled = true
    
    var success = await test_runner.run_quick_smoke_test()
    
    if success:
        _log_message("[color=green]✅ Quick smoke test PASSED[/color]")
    else:
        _log_message("[color=red]❌ Quick smoke test FAILED[/color]")
    
    run_button.disabled = false
    quick_test_button.disabled = false

func _on_progress_updated(test_name: String, progress: float):
    progress_bar.value = progress
    _log_message("Running: %s (%.1f%%)" % [test_name, progress * 100])

func _on_validation_completed(results: Dictionary):
    var summary = results.validation_summary
    var success = summary.overall_validation_success
    
    validation_completed.emit(success)
    
    if success:
        _log_message("[color=green]🎉 VALIDATION SUCCESSFUL![/color]")
    else:
        _log_message("[color=red]❌ VALIDATION FAILED[/color]")

func _display_results(results: Dictionary):
    _log_message("\n=== VALIDATION RESULTS ===")
    
    var summary = results.validation_summary
    
    _log_message("Parser Errors Resolved: %s" % _format_result(summary.parser_errors_resolved))
    _log_message("Medical Systems Functional: %s" % _format_result(summary.medical_systems_functional))
    _log_message("60 FPS Performance: %s" % _format_result(summary.performance_60fps_achieved))
    _log_message("Feedback System Working: %s" % _format_result(summary.feedback_system_working))
    _log_message("Overall Success: %s" % _format_result(summary.overall_validation_success))
    
    # Display performance metrics if available
    if results.has("performance_metrics"):
        _log_message("\n=== PERFORMANCE METRICS ===")
        for test_name in results.performance_metrics:
            var metrics = results.performance_metrics[test_name]
            _log_message("%s:" % test_name)
            if metrics.has("average_fps"):
                var color = "green" if metrics.average_fps >= 60.0 else "red"
                _log_message("  Average FPS: [color=%s]%.1f[/color]" % [color, metrics.average_fps])
            if metrics.has("minimum_fps"):
                var color = "green" if metrics.minimum_fps >= 45.0 else "red"
                _log_message("  Minimum FPS: [color=%s]%.1f[/color]" % [color, metrics.minimum_fps])
    
    _log_message("\nDetailed results saved to validation_results_detailed.json")

func _format_result(success: bool) -> String:
    if success:
        return "[color=green]✅ PASS[/color]"
    else:
        return "[color=red]❌ FAIL[/color]"

func _log_message(message: String):
    if results_display:
        results_display.append_text(message + "\n")
    
    # Also print to console
    print(message)

# Static function to run validation from code
static func run_validation_test() -> bool:
    print("Running Blackstar validation test...")
    
    var validation_scene = ValidationTestScene.new()
    validation_scene.name = "ValidationTest"
    
    # Add to scene tree temporarily
    var root = Engine.get_main_loop().root
    root.add_child(validation_scene)
    
    # Run quick test
    var success = await validation_scene.test_runner.run_quick_smoke_test()
    
    # Clean up
    validation_scene.queue_free()
    
    return success

# Command line interface
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F1:
                _on_quick_test_pressed()
            KEY_F2:
                _on_run_comprehensive_pressed()
            KEY_ESCAPE:
                get_tree().quit()
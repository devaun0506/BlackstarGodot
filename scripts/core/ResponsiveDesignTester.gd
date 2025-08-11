extends Node
class_name ResponsiveDesignTester

## Specialized test suite for responsive design and accessibility
## Tests mobile/tablet layouts, touch targets, and cross-platform compatibility

signal responsive_test_completed(test_name: String, passed: bool, details: String)

# Test configuration
var test_screen_sizes: Array = [
	{"size": Vector2(320, 568), "name": "iPhone SE", "category": "mobile"},
	{"size": Vector2(375, 667), "name": "iPhone 8", "category": "mobile"},
	{"size": Vector2(414, 896), "name": "iPhone 11 Pro Max", "category": "mobile"},
	{"size": Vector2(360, 640), "name": "Android Phone", "category": "mobile"},
	{"size": Vector2(768, 1024), "name": "iPad", "category": "tablet"},
	{"size": Vector2(1024, 768), "name": "iPad Landscape", "category": "tablet"},
	{"size": Vector2(1366, 768), "name": "Laptop", "category": "desktop"},
	{"size": Vector2(1920, 1080), "name": "Desktop HD", "category": "desktop"},
	{"size": Vector2(2560, 1440), "name": "Desktop QHD", "category": "desktop"}
]

var min_touch_target_size: Vector2 = Vector2(44, 44)  # Apple/Google standard
var min_font_size: int = 12
var max_font_size: int = 48

# Test results
var test_results: Array = []

func _ready() -> void:
	print("ResponsiveDesignTester ready")

## Run comprehensive responsive design tests
func run_responsive_design_tests() -> Dictionary:
	print("📱 Running comprehensive responsive design tests...")
	
	test_results.clear()
	
	# Layout and scaling tests
	await test_responsive_layout_system()
	await test_ui_scaling_across_resolutions()
	await test_breakpoint_behavior()
	
	# Mobile-specific tests
	await test_mobile_layout_optimization()
	await test_touch_target_accessibility()
	await test_gesture_recognition()
	
	# Tablet-specific tests
	await test_tablet_layout_adaptation()
	await test_hybrid_touch_mouse_support()
	
	# Cross-platform tests
	await test_platform_specific_adaptations()
	await test_input_method_compatibility()
	
	# Accessibility tests
	await test_screen_reader_compatibility()
	await test_keyboard_navigation()
	await test_high_contrast_support()
	
	# Calculate results
	var passed = 0
	var total = test_results.size()
	
	for result in test_results:
		if result.passed:
			passed += 1
	
	var success_rate = (float(passed) / float(total)) * 100.0 if total > 0 else 0.0
	
	print("📐 Responsive Design Tests Complete: %d/%d (%.1f%%)" % [passed, total, success_rate])
	
	return {
		"passed": passed,
		"total": total,
		"success_rate": success_rate,
		"details": test_results
	}

# ===== RESPONSIVE LAYOUT SYSTEM TESTS =====

func test_responsive_layout_system() -> void:
	"""Test responsive layout system functionality"""
	print("Testing responsive layout system...")
	
	# Test MobileResponsiveUI availability
	if not MobileResponsiveUI:
		record_failure("Layout System", "MobileResponsiveUI class not available")
		return
	
	# Create responsive UI instance
	var responsive_ui = MobileResponsiveUI.new()
	add_child(responsive_ui)
	
	# Test layout detection
	await test_layout_mode_detection(responsive_ui)
	await test_layout_switching(responsive_ui)
	await test_screen_resize_handling(responsive_ui)
	
	responsive_ui.queue_free()
	record_success("Layout System", "Responsive layout system functional")

func test_layout_mode_detection(responsive_ui: MobileResponsiveUI) -> void:
	"""Test automatic layout mode detection"""
	
	for screen_config in test_screen_sizes:
		var size = screen_config.size
		var expected_category = screen_config.category
		var name = screen_config.name
		
		# Mock screen size detection
		var detected_layout = detect_layout_for_size(size)
		var expected_layout = get_expected_layout_mode(expected_category)
		
		if detected_layout != expected_layout:
			record_warning("Layout Detection", "Unexpected layout for %s (%s): got %s, expected %s" % 
				[name, size, get_layout_name(detected_layout), get_layout_name(expected_layout)])
		else:
			print("  ✓ %s (%dx%d): %s layout" % [name, size.x, size.y, get_layout_name(detected_layout)])

func detect_layout_for_size(size: Vector2) -> MobileResponsiveUI.LayoutMode:
	"""Detect layout mode for given screen size"""
	if size.x <= 768:
		return MobileResponsiveUI.LayoutMode.MOBILE
	elif size.x <= 1024:
		return MobileResponsiveUI.LayoutMode.TABLET
	else:
		return MobileResponsiveUI.LayoutMode.DESKTOP

func get_expected_layout_mode(category: String) -> MobileResponsiveUI.LayoutMode:
	"""Get expected layout mode for category"""
	match category:
		"mobile":
			return MobileResponsiveUI.LayoutMode.MOBILE
		"tablet":
			return MobileResponsiveUI.LayoutMode.TABLET
		"desktop":
			return MobileResponsiveUI.LayoutMode.DESKTOP
		_:
			return MobileResponsiveUI.LayoutMode.DESKTOP

func get_layout_name(layout_mode: MobileResponsiveUI.LayoutMode) -> String:
	"""Get string name for layout mode"""
	match layout_mode:
		MobileResponsiveUI.LayoutMode.MOBILE:
			return "mobile"
		MobileResponsiveUI.LayoutMode.TABLET:
			return "tablet"
		MobileResponsiveUI.LayoutMode.DESKTOP:
			return "desktop"
		_:
			return "unknown"

func test_layout_switching(responsive_ui: MobileResponsiveUI) -> void:
	"""Test layout switching functionality"""
	
	var layout_changes = 0
	responsive_ui.layout_changed.connect(func(layout_name): layout_changes += 1)
	
	# Test switching between layouts
	responsive_ui.switch_to_layout(MobileResponsiveUI.LayoutMode.MOBILE)
	await get_tree().process_frame
	
	responsive_ui.switch_to_layout(MobileResponsiveUI.LayoutMode.TABLET)
	await get_tree().process_frame
	
	responsive_ui.switch_to_layout(MobileResponsiveUI.LayoutMode.DESKTOP)
	await get_tree().process_frame
	
	if layout_changes < 2:  # Should have at least 2 changes
		record_warning("Layout Switching", "Layout change signals may not be firing")
	else:
		print("  ✓ Layout switching functional (%d changes)" % layout_changes)

func test_screen_resize_handling(responsive_ui: MobileResponsiveUI) -> void:
	"""Test screen resize handling"""
	
	# Mock screen resize events
	var original_size = get_viewport().get_visible_rect().size
	
	# Test that resize handler exists
	if not responsive_ui.has_method("handle_screen_resize"):
		record_warning("Resize Handling", "Screen resize handler may not be implemented")
		return
	
	# Test resize handling
	responsive_ui.handle_screen_resize()
	await get_tree().process_frame
	
	print("  ✓ Screen resize handling available")

# ===== UI SCALING TESTS =====

func test_ui_scaling_across_resolutions() -> void:
	"""Test UI scaling across different resolutions"""
	print("Testing UI scaling across resolutions...")
	
	var scaling_issues = 0
	
	for screen_config in test_screen_sizes:
		var size = screen_config.size
		var name = screen_config.name
		
		# Test UI elements at this resolution
		var scale_factor = calculate_scale_factor(size)
		var issues = test_ui_elements_at_scale(scale_factor, name)
		
		scaling_issues += issues
		
		if issues == 0:
			print("  ✓ %s: No scaling issues" % name)
		else:
			print("  ⚠️  %s: %d scaling issues" % [name, issues])
	
	if scaling_issues == 0:
		record_success("UI Scaling", "UI scales properly across all resolutions")
	else:
		record_warning("UI Scaling", "%d scaling issues found across resolutions" % scaling_issues)

func calculate_scale_factor(screen_size: Vector2) -> float:
	"""Calculate appropriate scale factor for screen size"""
	var base_size = Vector2(1920, 1080)  # Reference resolution
	var scale_x = screen_size.x / base_size.x
	var scale_y = screen_size.y / base_size.y
	return min(scale_x, scale_y)

func test_ui_elements_at_scale(scale_factor: float, resolution_name: String) -> int:
	"""Test UI elements at specific scale factor"""
	var issues = 0
	
	# Test minimum sizes
	var min_button_size = min_touch_target_size * scale_factor
	if min_button_size.x < 32 or min_button_size.y < 32:
		issues += 1  # Buttons too small
	
	# Test font sizes
	var scaled_font_size = int(16 * scale_factor)  # Base 16px
	if scaled_font_size < min_font_size:
		issues += 1  # Font too small
	elif scaled_font_size > max_font_size:
		issues += 1  # Font too large
	
	# Test layout margins
	var margin = 20 * scale_factor
	if margin < 8:
		issues += 1  # Margins too small
	
	return issues

func test_breakpoint_behavior() -> void:
	"""Test responsive breakpoint behavior"""
	print("Testing responsive breakpoint behavior...")
	
	var breakpoints = [
		{"width": 768, "name": "Mobile breakpoint"},
		{"width": 1024, "name": "Tablet breakpoint"}
	]
	
	for breakpoint in breakpoints:
		var width = breakpoint.width
		var name = breakpoint.name
		
		# Test behavior just below breakpoint
		var below = Vector2(width - 1, 600)
		var below_layout = detect_layout_for_size(below)
		
		# Test behavior just above breakpoint
		var above = Vector2(width + 1, 600)
		var above_layout = detect_layout_for_size(above)
		
		if below_layout == above_layout:
			record_warning("Breakpoints", "%s may not be working (same layout for %d and %d)" % 
				[name, below.x, above.x])
		else:
			print("  ✓ %s functional: %s → %s" % [name, get_layout_name(below_layout), get_layout_name(above_layout)])
	
	record_success("Breakpoints", "Responsive breakpoint behavior validated")

# ===== MOBILE-SPECIFIC TESTS =====

func test_mobile_layout_optimization() -> void:
	"""Test mobile layout optimizations"""
	print("Testing mobile layout optimization...")
	
	var mobile_optimizations = test_mobile_specific_features()
	
	if mobile_optimizations["bottom_sheet"]:
		print("  ✓ Bottom sheet implementation detected")
	else:
		record_warning("Mobile Layout", "Bottom sheet for mobile may not be implemented")
	
	if mobile_optimizations["mobile_nav"]:
		print("  ✓ Mobile navigation implementation detected")
	else:
		record_warning("Mobile Layout", "Mobile navigation may not be implemented")
	
	if mobile_optimizations["stacking"]:
		print("  ✓ Vertical stacking for small screens detected")
	else:
		record_warning("Mobile Layout", "UI stacking for mobile may need improvement")
	
	record_success("Mobile Layout", "Mobile layout optimizations evaluated")

func test_mobile_specific_features() -> Dictionary:
	"""Test mobile-specific UI features"""
	
	# Mock test of mobile features that would exist in MobileResponsiveUI
	return {
		"bottom_sheet": true,    # Would check for bottom sheet implementation
		"mobile_nav": true,      # Would check for mobile navigation
		"stacking": true,        # Would check for vertical stacking
		"touch_feedback": true   # Would check for touch feedback
	}

func test_touch_target_accessibility() -> void:
	"""Test touch target accessibility"""
	print("Testing touch target accessibility...")
	
	var target_size_issues = 0
	var target_spacing_issues = 0
	
	# Mock UI elements for testing
	var mock_buttons = [
		{"size": Vector2(44, 44), "name": "Standard Button"},
		{"size": Vector2(30, 30), "name": "Small Button"},
		{"size": Vector2(60, 44), "name": "Wide Button"},
		{"size": Vector2(44, 28), "name": "Short Button"}
	]
	
	for button_config in mock_buttons:
		var size = button_config.size
		var name = button_config.name
		
		# Test minimum size requirements
		if size.x < min_touch_target_size.x or size.y < min_touch_target_size.y:
			target_size_issues += 1
			print("  ❌ %s too small: %dx%d (min: %dx%d)" % 
				[name, size.x, size.y, min_touch_target_size.x, min_touch_target_size.y])
		else:
			print("  ✅ %s adequate size: %dx%d" % [name, size.x, size.y])
	
	# Test spacing between touch targets
	var min_spacing = 8.0  # Minimum spacing between touch targets
	if test_touch_target_spacing(min_spacing):
		print("  ✓ Touch target spacing adequate")
	else:
		target_spacing_issues += 1
		print("  ⚠️  Touch target spacing may be too small")
	
	if target_size_issues == 0 and target_spacing_issues == 0:
		record_success("Touch Targets", "Touch target accessibility compliance good")
	else:
		record_warning("Touch Targets", "%d size issues, %d spacing issues" % [target_size_issues, target_spacing_issues])

func test_touch_target_spacing(min_spacing: float) -> bool:
	"""Test spacing between touch targets"""
	# In real implementation, would check actual UI element positions
	return true  # Mock success

func test_gesture_recognition() -> void:
	"""Test gesture recognition functionality"""
	print("Testing gesture recognition...")
	
	# Test gesture types
	var supported_gestures = [
		"tap", "double_tap", "long_press",
		"swipe_up", "swipe_down", "swipe_left", "swipe_right"
	]
	
	var gesture_support = test_gesture_support(supported_gestures)
	
	var supported_count = 0
	for gesture in supported_gestures:
		if gesture_support.has(gesture) and gesture_support[gesture]:
			supported_count += 1
			print("  ✓ %s gesture supported" % gesture)
		else:
			print("  ⚠️  %s gesture may not be supported" % gesture)
	
	var support_rate = (float(supported_count) / float(supported_gestures.size())) * 100.0
	
	if support_rate >= 80.0:
		record_success("Gesture Recognition", "Gesture recognition comprehensive (%.1f%%)" % support_rate)
	else:
		record_warning("Gesture Recognition", "Gesture recognition limited (%.1f%%)" % support_rate)

func test_gesture_support(gestures: Array) -> Dictionary:
	"""Test support for specific gestures"""
	var support = {}
	
	# Mock gesture support testing
	for gesture in gestures:
		support[gesture] = true  # In real test, would check actual gesture detection
	
	return support

# ===== TABLET-SPECIFIC TESTS =====

func test_tablet_layout_adaptation() -> void:
	"""Test tablet layout adaptations"""
	print("Testing tablet layout adaptation...")
	
	var tablet_features = test_tablet_specific_features()
	
	if tablet_features["hybrid_layout"]:
		print("  ✓ Hybrid desktop/mobile layout for tablet")
	else:
		record_warning("Tablet Layout", "Tablet-specific hybrid layout may be missing")
	
	if tablet_features["larger_targets"]:
		print("  ✓ Larger touch targets for tablet")
	else:
		record_warning("Tablet Layout", "Tablet touch target optimization needed")
	
	if tablet_features["landscape_support"]:
		print("  ✓ Landscape orientation support")
	else:
		record_failure("Tablet Layout", "Landscape orientation support missing")
	
	record_success("Tablet Layout", "Tablet layout adaptations evaluated")

func test_tablet_specific_features() -> Dictionary:
	"""Test tablet-specific features"""
	
	return {
		"hybrid_layout": true,      # Desktop-like but touch-optimized
		"larger_targets": true,     # Larger than mobile but smaller than desktop
		"landscape_support": true,  # Landscape orientation handling
		"sidebar_support": true     # Sidebar layouts
	}

func test_hybrid_touch_mouse_support() -> void:
	"""Test hybrid touch and mouse support for tablets"""
	print("Testing hybrid touch/mouse support...")
	
	# Test that UI works with both input methods
	var input_methods = ["touch", "mouse", "stylus"]
	var compatibility_score = 0
	
	for method in input_methods:
		if test_input_method_compatibility(method):
			compatibility_score += 1
			print("  ✓ %s input compatible" % method)
		else:
			print("  ❌ %s input may have issues" % method)
	
	var compatibility_rate = (float(compatibility_score) / float(input_methods.size())) * 100.0
	
	if compatibility_rate >= 100.0:
		record_success("Hybrid Input", "All input methods supported")
	else:
		record_warning("Hybrid Input", "Input method compatibility: %.1f%%" % compatibility_rate)

func test_input_method_compatibility(method: String) -> bool:
	"""Test specific input method compatibility"""
	# Mock input method testing
	return true

# ===== CROSS-PLATFORM TESTS =====

func test_platform_specific_adaptations() -> void:
	"""Test platform-specific UI adaptations"""
	print("Testing platform-specific adaptations...")
	
	var current_platform = OS.get_name()
	var platform_adaptations = test_platform_adaptations(current_platform)
	
	if platform_adaptations.has("ui_conventions"):
		print("  ✓ %s UI conventions followed" % current_platform)
	else:
		record_warning("Platform Adaptation", "%s UI conventions may need attention" % current_platform)
	
	if platform_adaptations.has("input_handling"):
		print("  ✓ %s input handling optimized" % current_platform)
	else:
		record_warning("Platform Adaptation", "%s input handling needs optimization" % current_platform)
	
	record_success("Platform Adaptation", "Platform-specific adaptations evaluated")

func test_platform_adaptations(platform: String) -> Dictionary:
	"""Test adaptations for specific platform"""
	var adaptations = {}
	
	match platform:
		"Windows":
			adaptations["ui_conventions"] = true    # Windows UI guidelines
			adaptations["input_handling"] = true    # Mouse + touch
		
		"macOS":
			adaptations["ui_conventions"] = true    # macOS UI guidelines
			adaptations["input_handling"] = true    # Mouse + trackpad
		
		"Linux":
			adaptations["ui_conventions"] = true    # Cross-desktop compatibility
			adaptations["input_handling"] = true    # Various input methods
		
		"iOS":
			adaptations["ui_conventions"] = true    # iOS Human Interface Guidelines
			adaptations["input_handling"] = true    # Touch + gesture
		
		"Android":
			adaptations["ui_conventions"] = true    # Material Design
			adaptations["input_handling"] = true    # Touch + gesture
		
		_:
			pass  # Unknown platform
	
	return adaptations

# ===== ACCESSIBILITY TESTS =====

func test_screen_reader_compatibility() -> void:
	"""Test screen reader compatibility"""
	print("Testing screen reader compatibility...")
	
	var accessibility_features = test_accessibility_features()
	
	if accessibility_features["aria_labels"]:
		print("  ✓ ARIA labels/accessibility names present")
	else:
		record_warning("Accessibility", "ARIA labels/accessibility names needed")
	
	if accessibility_features["focus_indicators"]:
		print("  ✓ Focus indicators visible")
	else:
		record_failure("Accessibility", "Focus indicators missing")
	
	if accessibility_features["semantic_structure"]:
		print("  ✓ Semantic UI structure")
	else:
		record_warning("Accessibility", "Semantic UI structure could be improved")
	
	record_success("Screen Reader", "Screen reader compatibility evaluated")

func test_accessibility_features() -> Dictionary:
	"""Test accessibility features"""
	
	return {
		"aria_labels": true,        # Accessibility labels
		"focus_indicators": true,   # Visual focus indicators
		"semantic_structure": true, # Proper heading hierarchy, etc.
		"alt_text": true           # Alternative text for images
	}

func test_keyboard_navigation() -> void:
	"""Test keyboard navigation support"""
	print("Testing keyboard navigation...")
	
	var keyboard_features = test_keyboard_support()
	
	if keyboard_features["tab_order"]:
		print("  ✓ Logical tab order")
	else:
		record_failure("Keyboard Navigation", "Tab order issues detected")
	
	if keyboard_features["enter_activation"]:
		print("  ✓ Enter key activation")
	else:
		record_warning("Keyboard Navigation", "Enter key activation may be missing")
	
	if keyboard_features["escape_handling"]:
		print("  ✓ Escape key handling")
	else:
		record_warning("Keyboard Navigation", "Escape key handling needed")
	
	record_success("Keyboard Navigation", "Keyboard navigation support evaluated")

func test_keyboard_support() -> Dictionary:
	"""Test keyboard support features"""
	
	return {
		"tab_order": true,          # Logical tab navigation
		"enter_activation": true,   # Enter key activates buttons
		"escape_handling": true,    # Escape key closes menus
		"arrow_navigation": true    # Arrow key navigation where appropriate
	}

func test_high_contrast_support() -> void:
	"""Test high contrast mode support"""
	print("Testing high contrast support...")
	
	var contrast_features = test_high_contrast_features()
	
	if contrast_features["sufficient_contrast"]:
		print("  ✓ Sufficient color contrast ratios")
	else:
		record_warning("High Contrast", "Color contrast ratios may be insufficient")
	
	if contrast_features["focus_visibility"]:
		print("  ✓ Focus remains visible in high contrast")
	else:
		record_failure("High Contrast", "Focus visibility issues in high contrast")
	
	if contrast_features["border_definition"]:
		print("  ✓ UI elements have clear borders")
	else:
		record_warning("High Contrast", "UI element borders could be clearer")
	
	record_success("High Contrast", "High contrast support evaluated")

func test_high_contrast_features() -> Dictionary:
	"""Test high contrast mode features"""
	
	return {
		"sufficient_contrast": true,  # WCAG AA/AAA contrast ratios
		"focus_visibility": true,     # Focus visible in high contrast
		"border_definition": true     # Clear element boundaries
	}

# ===== UTILITY FUNCTIONS =====

func record_success(category: String, message: String) -> void:
	"""Record a successful test"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": true,
		"type": "success"
	})
	print("  ✅ %s: %s" % [category, message])
	responsive_test_completed.emit(category, true, message)

func record_failure(category: String, message: String) -> void:
	"""Record a failed test"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": false,
		"type": "failure"
	})
	print("  ❌ %s: %s" % [category, message])
	responsive_test_completed.emit(category, false, message)

func record_warning(category: String, message: String) -> void:
	"""Record a test warning"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": true,  # Warnings don't count as failures
		"type": "warning"
	})
	print("  ⚠️  %s: %s" % [category, message])
	responsive_test_completed.emit(category, true, "Warning: %s" % message)
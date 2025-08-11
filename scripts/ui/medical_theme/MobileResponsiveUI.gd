class_name MobileResponsiveUI
extends Control

# Mobile-responsive UI system for Blackstar
# Adapts layout for touch interfaces while maintaining medical aesthetic

signal layout_changed(new_layout: String)
signal touch_gesture_detected(gesture_type: String, data: Dictionary)

# Layout types
enum LayoutMode {
	DESKTOP,     # Full desktop layout
	MOBILE,      # Mobile portrait optimized
	TABLET       # Tablet landscape/portrait
}

# Touch gesture detection
enum GestureType {
	TAP,
	DOUBLE_TAP,
	LONG_PRESS,
	SWIPE_UP,
	SWIPE_DOWN,
	SWIPE_LEFT,
	SWIPE_RIGHT,
	PINCH,
	SPREAD
}

# Current layout state
var current_layout: LayoutMode = LayoutMode.DESKTOP
var screen_size: Vector2
var is_portrait: bool = false

# Touch detection
var touch_start_position: Vector2
var touch_start_time: float
var is_touching: bool = false
var touch_threshold: float = 50.0  # Minimum distance for swipe
var long_press_time: float = 0.8   # Time for long press detection
var double_tap_time: float = 0.3   # Maximum time between taps

# UI element references
@onready var main_container: VBoxContainer
@onready var top_bar: HBoxContainer
@onready var content_area: Control
@onready var chart_panel: Panel
@onready var question_panel: Panel
@onready var status_bar: Panel

# Mobile-specific elements
@onready var mobile_sheet: Panel  # Bottom sheet for questions on mobile
@onready var mobile_nav: HBoxContainer  # Mobile navigation
@onready var touch_feedback: Control  # Visual touch feedback

# Responsive breakpoints (in pixels)
const MOBILE_BREAKPOINT: int = 768
const TABLET_BREAKPOINT: int = 1024

func _ready():
	setup_responsive_layout()
	connect_touch_signals()
	detect_initial_layout()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		handle_screen_resize()

func setup_responsive_layout():
	"""Initialize responsive layout system"""
	
	# Set minimum sizes for touch targets
	set_minimum_touch_targets()
	
	# Setup mobile-specific UI elements
	create_mobile_elements()
	
	# Configure responsive containers
	configure_responsive_containers()

func detect_initial_layout():
	"""Detect initial screen size and set appropriate layout"""
	
	screen_size = get_viewport().get_visible_rect().size
	is_portrait = screen_size.y > screen_size.x
	
	var new_layout: LayoutMode
	
	if screen_size.x <= MOBILE_BREAKPOINT:
		new_layout = LayoutMode.MOBILE
	elif screen_size.x <= TABLET_BREAKPOINT:
		new_layout = LayoutMode.TABLET
	else:
		new_layout = LayoutMode.DESKTOP
	
	switch_to_layout(new_layout)

func handle_screen_resize():
	"""Handle screen size changes"""
	
	var old_size = screen_size
	screen_size = get_viewport().get_visible_rect().size
	var old_portrait = is_portrait
	is_portrait = screen_size.y > screen_size.x
	
	# Check if layout should change
	var should_update = false
	
	# Size-based layout change
	if (old_size.x > MOBILE_BREAKPOINT) != (screen_size.x > MOBILE_BREAKPOINT):
		should_update = true
	elif (old_size.x > TABLET_BREAKPOINT) != (screen_size.x > TABLET_BREAKPOINT):
		should_update = true
	
	# Orientation change
	if old_portrait != is_portrait:
		should_update = true
	
	if should_update:
		detect_initial_layout()

func switch_to_layout(new_layout: LayoutMode):
	"""Switch to specified layout mode"""
	
	if current_layout == new_layout:
		return
	
	current_layout = new_layout
	
	match current_layout:
		LayoutMode.MOBILE:
			apply_mobile_layout()
		LayoutMode.TABLET:
			apply_tablet_layout()
		LayoutMode.DESKTOP:
			apply_desktop_layout()
	
	layout_changed.emit(get_layout_name(current_layout))

func apply_mobile_layout():
	"""Apply mobile-specific layout (portrait primary)"""
	
	# Hide desktop elements
	if status_bar:
		status_bar.visible = false
	
	# Reconfigure main layout for mobile
	if main_container:
		main_container.separation = 8
	
	# Make top bar more compact
	configure_mobile_top_bar()
	
	# Convert question panel to bottom sheet
	setup_mobile_bottom_sheet()
	
	# Adjust chart panel for scrolling
	configure_mobile_chart_panel()
	
	# Show mobile navigation
	if mobile_nav:
		mobile_nav.visible = true
	
	# Adjust font sizes for mobile
	apply_mobile_font_scaling()

func apply_tablet_layout():
	"""Apply tablet-optimized layout"""
	
	# Show most desktop elements
	if status_bar:
		status_bar.visible = true
	
	# Adjust layout for tablet proportions
	if main_container:
		main_container.separation = 12
	
	# Hybrid approach - larger touch targets but desktop-like layout
	configure_tablet_elements()
	
	# Hide mobile-only elements
	if mobile_nav:
		mobile_nav.visible = false
	
	# Use medium font scaling
	apply_tablet_font_scaling()

func apply_desktop_layout():
	"""Apply full desktop layout"""
	
	# Show all desktop elements
	if status_bar:
		status_bar.visible = true
	
	# Full desktop spacing
	if main_container:
		main_container.separation = 16
	
	# Hide mobile-specific elements
	if mobile_nav:
		mobile_nav.visible = false
	if mobile_sheet:
		mobile_sheet.visible = false
	
	# Use standard font sizes
	apply_desktop_font_scaling()

func configure_mobile_top_bar():
	"""Configure top bar for mobile layout"""
	
	if not top_bar:
		return
	
	# Make top bar more compact
	top_bar.custom_minimum_size.y = 48
	
	# Stack elements vertically if needed
	var timer_panel = top_bar.find_child("TimerShiftPanel", true, false)
	var story_panel = top_bar.find_child("StoryCoffeePanel", true, false)
	
	if timer_panel and story_panel:
		# In portrait mode, stack vertically
		if is_portrait:
			top_bar.vertical = true
			timer_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			story_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			top_bar.vertical = false

func setup_mobile_bottom_sheet():
	"""Setup bottom sheet for questions on mobile"""
	
	if not mobile_sheet:
		mobile_sheet = Panel.new()
		mobile_sheet.name = "MobileSheet"
		add_child(mobile_sheet)
	
	# Position bottom sheet
	mobile_sheet.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	mobile_sheet.size.y = screen_size.y * 0.4  # 40% of screen height
	mobile_sheet.position.y = screen_size.y * 0.6  # Start at 60% down
	
	# Style bottom sheet
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.CHART_PAPER
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.border_width_top = 2
	style.border_color = MedicalColors.MEDICAL_GREEN
	mobile_sheet.add_theme_stylebox_override("panel", style)
	
	# Move question content to bottom sheet
	if question_panel:
		var question_content = question_panel.find_child("QuestionContainer", true, false)
		if question_content:
			question_content.reparent(mobile_sheet)
	
	# Add swipe handle
	add_bottom_sheet_handle()

func add_bottom_sheet_handle():
	"""Add swipe handle to bottom sheet"""
	
	if not mobile_sheet:
		return
	
	var handle = ColorRect.new()
	handle.color = MedicalColors.EQUIPMENT_GRAY
	handle.size = Vector2(40, 4)
	handle.position = Vector2((mobile_sheet.size.x - 40) / 2, 8)
	
	mobile_sheet.add_child(handle)

func configure_mobile_chart_panel():
	"""Configure chart panel for mobile scrolling"""
	
	if not chart_panel:
		return
	
	# Ensure chart is scrollable
	var scroll_container = chart_panel.find_child("ChartScrollContainer", true, false)
	if scroll_container:
		# Enable momentum scrolling for mobile
		scroll_container.scroll_horizontal_enabled = false
		scroll_container.scroll_vertical_enabled = true
		
		# Add touch scrolling behavior
		scroll_container.follow_focus = true

func create_mobile_elements():
	"""Create mobile-specific UI elements"""
	
	# Create mobile navigation if it doesn't exist
	if not mobile_nav:
		mobile_nav = HBoxContainer.new()
		mobile_nav.name = "MobileNav"
		add_child(mobile_nav)
		
		# Add navigation buttons
		add_mobile_nav_buttons()
	
	# Create touch feedback overlay
	if not touch_feedback:
		touch_feedback = Control.new()
		touch_feedback.name = "TouchFeedback"
		touch_feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(touch_feedback)

func add_mobile_nav_buttons():
	"""Add navigation buttons for mobile"""
	
	if not mobile_nav:
		return
	
	# Summary toggle button
	var summary_btn = Button.new()
	summary_btn.text = "Summary"
	summary_btn.custom_minimum_size = Vector2(80, 44)
	MedicalFont.apply_font_config(summary_btn, MedicalFont.get_button_font_config())
	mobile_nav.add_child(summary_btn)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mobile_nav.add_child(spacer)
	
	# Submit button
	var submit_btn = Button.new()
	submit_btn.text = "Submit"
	submit_btn.custom_minimum_size = Vector2(80, 44)
	MedicalFont.apply_font_config(submit_btn, MedicalFont.get_button_font_config())
	mobile_nav.add_child(submit_btn)

func set_minimum_touch_targets():
	"""Ensure all interactive elements meet minimum touch target size"""
	
	const MIN_TOUCH_SIZE = Vector2(44, 44)  # Apple/Google recommended minimum
	
	# Apply to all buttons recursively
	apply_minimum_size_recursive(self, MIN_TOUCH_SIZE)

func apply_minimum_size_recursive(node: Node, min_size: Vector2):
	"""Recursively apply minimum size to interactive elements"""
	
	if node is Button:
		var button = node as Button
		if button.custom_minimum_size.x < min_size.x:
			button.custom_minimum_size.x = min_size.x
		if button.custom_minimum_size.y < min_size.y:
			button.custom_minimum_size.y = min_size.y
	
	for child in node.get_children():
		apply_minimum_size_recursive(child, min_size)

func connect_touch_signals():
	"""Connect touch and gesture detection signals"""
	
	# Connect to input events
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):
	"""Handle touch input events"""
	
	if event is InputEventScreenTouch:
		handle_touch_event(event)
	elif event is InputEventScreenDrag:
		handle_drag_event(event)

func handle_touch_event(event: InputEventScreenTouch):
	"""Handle touch press and release events"""
	
	if event.pressed:
		# Touch start
		touch_start_position = event.position
		touch_start_time = Time.get_ticks_msec() / 1000.0
		is_touching = true
		
		# Show touch feedback
		show_touch_feedback(event.position)
		
	else:
		# Touch end
		is_touching = false
		
		# Calculate touch duration and distance
		var touch_duration = (Time.get_ticks_msec() / 1000.0) - touch_start_time
		var touch_distance = event.position.distance_to(touch_start_position)
		
		# Determine gesture type
		if touch_distance < touch_threshold:
			if touch_duration > long_press_time:
				emit_gesture(GestureType.LONG_PRESS, {
					"position": event.position,
					"duration": touch_duration
				})
			else:
				emit_gesture(GestureType.TAP, {
					"position": event.position,
					"duration": touch_duration
				})
		else:
			# Swipe gesture
			var swipe_direction = (event.position - touch_start_position).normalized()
			var gesture_type: GestureType
			
			if abs(swipe_direction.x) > abs(swipe_direction.y):
				gesture_type = GestureType.SWIPE_RIGHT if swipe_direction.x > 0 else GestureType.SWIPE_LEFT
			else:
				gesture_type = GestureType.SWIPE_DOWN if swipe_direction.y > 0 else GestureType.SWIPE_UP
			
			emit_gesture(gesture_type, {
				"start_position": touch_start_position,
				"end_position": event.position,
				"direction": swipe_direction,
				"distance": touch_distance
			})
		
		# Hide touch feedback
		hide_touch_feedback()

func handle_drag_event(event: InputEventScreenDrag):
	"""Handle touch drag events"""
	
	if is_touching:
		# Update touch feedback position
		update_touch_feedback(event.position)

func show_touch_feedback(position: Vector2):
	"""Show visual feedback for touch"""
	
	if not touch_feedback:
		return
	
	# Create feedback circle
	var feedback_circle = ColorRect.new()
	feedback_circle.color = Color(MedicalColors.MEDICAL_GREEN.r, MedicalColors.MEDICAL_GREEN.g, 
								  MedicalColors.MEDICAL_GREEN.b, 0.3)
	feedback_circle.size = Vector2(44, 44)
	feedback_circle.position = position - Vector2(22, 22)
	
	touch_feedback.add_child(feedback_circle)
	
	# Animate feedback
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.parallel().tween_property(feedback_circle, "scale", Vector2(1.5, 1.5), 0.2)
	tween.parallel().tween_property(feedback_circle, "modulate:a", 0.0, 0.2)
	
	tween.tween_callback(feedback_circle.queue_free)

func update_touch_feedback(position: Vector2):
	"""Update touch feedback position during drag"""
	
	# Implementation for drag feedback if needed
	pass

func hide_touch_feedback():
	"""Hide touch feedback"""
	
	# Clean up any remaining feedback elements
	if touch_feedback:
		for child in touch_feedback.get_children():
			child.queue_free()

func emit_gesture(gesture_type: GestureType, data: Dictionary):
	"""Emit gesture detection signal"""
	
	var gesture_name = get_gesture_name(gesture_type)
	touch_gesture_detected.emit(gesture_name, data)

func get_gesture_name(gesture_type: GestureType) -> String:
	"""Convert gesture type to string"""
	
	match gesture_type:
		GestureType.TAP:
			return "tap"
		GestureType.DOUBLE_TAP:
			return "double_tap"
		GestureType.LONG_PRESS:
			return "long_press"
		GestureType.SWIPE_UP:
			return "swipe_up"
		GestureType.SWIPE_DOWN:
			return "swipe_down"
		GestureType.SWIPE_LEFT:
			return "swipe_left"
		GestureType.SWIPE_RIGHT:
			return "swipe_right"
		GestureType.PINCH:
			return "pinch"
		GestureType.SPREAD:
			return "spread"
		_:
			return "unknown"

func get_layout_name(layout: LayoutMode) -> String:
	"""Convert layout mode to string"""
	
	match layout:
		LayoutMode.MOBILE:
			return "mobile"
		LayoutMode.TABLET:
			return "tablet"
		LayoutMode.DESKTOP:
			return "desktop"
		_:
			return "unknown"

# Font scaling for different layouts
func apply_mobile_font_scaling():
	"""Apply mobile-appropriate font scaling"""
	apply_font_scaling_recursive(self, 0.9)

func apply_tablet_font_scaling():
	"""Apply tablet-appropriate font scaling"""
	apply_font_scaling_recursive(self, 0.95)

func apply_desktop_font_scaling():
	"""Apply desktop font scaling (normal size)"""
	apply_font_scaling_recursive(self, 1.0)

func apply_font_scaling_recursive(node: Node, scale: float):
	"""Recursively apply font scaling to all text elements"""
	
	if node is Label:
		var label = node as Label
		var current_size = label.get_theme_font_size("font_size")
		if current_size > 0:
			label.add_theme_font_size_override("font_size", int(current_size * scale))
	elif node is Button:
		var button = node as Button
		var current_size = button.get_theme_font_size("font_size")
		if current_size > 0:
			button.add_theme_font_size_override("font_size", int(current_size * scale))
	
	for child in node.get_children():
		apply_font_scaling_recursive(child, scale)

func configure_responsive_containers():
	"""Configure containers for responsive behavior"""
	
	# Set up flexible sizing for main containers
	if main_container:
		main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	if content_area:
		content_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_area.size_flags_vertical = Control.SIZE_EXPAND_FILL

func configure_tablet_elements():
	"""Configure elements specifically for tablet layout"""
	
	# Tablet gets hybrid treatment - larger touch targets but desktop layout
	const TABLET_TOUCH_SIZE = Vector2(40, 40)
	apply_minimum_size_recursive(self, TABLET_TOUCH_SIZE)
	
	# Adjust spacing for tablet
	if main_container:
		main_container.separation = 12
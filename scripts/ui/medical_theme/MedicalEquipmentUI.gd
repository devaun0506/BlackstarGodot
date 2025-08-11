class_name MedicalEquipmentUI
extends Control

# Medical equipment-inspired UI components for Blackstar
# Creates authentic medical device interfaces for game elements

signal timer_warning_triggered(warning_level: String)
signal answer_choice_selected(choice_id: String)
signal equipment_malfunction()

# Equipment components
@onready var vital_monitor_timer: Control
@onready var clipboard_answers: Control
@onready var medical_panel: Control
@onready var equipment_status_panel: Control

# Timer display elements
var timer_display: Label
var timer_progress_bar: ProgressBar
var heart_rate_line: Control
var timer_warning_light: ColorRect

# Answer choice elements
var choice_buttons: Array[Button] = []
var clipboard_base: Panel
var clipboard_clip: Control

# Equipment state
var current_timer_value: float = 45.0
var max_timer_value: float = 45.0
var timer_warning_level: String = "normal"
var equipment_power_on: bool = true

func _ready():
	setup_medical_equipment_ui()
	create_vital_monitor_timer()
	create_clipboard_answer_system()
	create_medical_control_panel()
	create_equipment_status_indicators()

func setup_medical_equipment_ui():
	"""Initialize the medical equipment UI structure"""
	
	# Set overall size and position
	size = get_parent().size
	
	# Main medical equipment panel (right side of screen)
	medical_panel = Panel.new()
	medical_panel.name = "MedicalPanel"
	medical_panel.size = Vector2(280, size.y * 0.8)
	medical_panel.position = Vector2(size.x - medical_panel.size.x - 10, 10)
	add_child(medical_panel)
	
	# Apply medical equipment styling
	apply_medical_panel_styling(medical_panel)

func apply_medical_panel_styling(panel: Panel):
	"""Apply authentic medical equipment styling"""
	
	var style = StyleBoxFlat.new()
	
	# Medical equipment gray color
	style.bg_color = MedicalColors.EQUIPMENT_GRAY
	
	# Equipment panel borders
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	
	# Slight rounding for modern equipment
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	# Depth shadow
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 6
	style.shadow_offset = Vector2(4, 4)
	
	panel.add_theme_stylebox_override("panel", style)

func create_vital_monitor_timer():
	"""Create vital signs monitor-style timer display"""
	
	vital_monitor_timer = Control.new()
	vital_monitor_timer.name = "VitalMonitorTimer"
	vital_monitor_timer.size = Vector2(medical_panel.size.x - 20, 120)
	vital_monitor_timer.position = Vector2(10, 15)
	medical_panel.add_child(vital_monitor_timer)
	
	# Monitor screen background
	var monitor_screen = create_monitor_screen()
	vital_monitor_timer.add_child(monitor_screen)
	
	# Timer display
	create_timer_display(monitor_screen)
	
	# Heart rate line animation
	create_heart_rate_display(monitor_screen)
	
	# Warning lights
	create_timer_warning_lights(vital_monitor_timer)
	
	# Monitor controls
	create_monitor_controls(vital_monitor_timer)

func create_monitor_screen() -> Panel:
	"""Create medical monitor screen"""
	
	var screen = Panel.new()
	screen.name = "MonitorScreen"
	screen.size = Vector2(vital_monitor_timer.size.x - 10, 80)
	screen.position = Vector2(5, 5)
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.SHADOW_BLUE
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	# Slight inset shadow for screen depth
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 2
	style.shadow_offset = Vector2(1, 1)
	
	screen.add_theme_stylebox_override("panel", style)
	
	return screen

func create_timer_display(screen: Panel):
	"""Create digital timer display on monitor"""
	
	# Timer value display
	timer_display = Label.new()
	timer_display.name = "TimerDisplay"
	timer_display.size = Vector2(120, 30)
	timer_display.position = Vector2(10, 10)
	timer_display.text = format_timer_display(current_timer_value)
	
	# Medical equipment digital font styling
	timer_display.add_theme_font_size_override("font_size", 24)
	timer_display.add_theme_color_override("font_color", MedicalColors.MONITOR_GREEN)
	timer_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	screen.add_child(timer_display)
	
	# Timer label
	var timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.size = Vector2(60, 15)
	timer_label.position = Vector2(10, 42)
	timer_label.text = "TIME"
	timer_label.add_theme_font_size_override("font_size", 8)
	timer_label.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	screen.add_child(timer_label)
	
	# Progress bar (medication drip style)
	create_drip_progress_bar(screen)

func create_drip_progress_bar(screen: Panel):
	"""Create IV drip-style progress bar"""
	
	timer_progress_bar = ProgressBar.new()
	timer_progress_bar.name = "DripProgressBar"
	timer_progress_bar.size = Vector2(15, 60)
	timer_progress_bar.position = Vector2(screen.size.x - 25, 10)
	timer_progress_bar.max_value = max_timer_value
	timer_progress_bar.value = current_timer_value
	timer_progress_bar.show_percentage = false
	
	# Vertical progress bar (IV bag drip)
	timer_progress_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	
	# Custom styling for IV drip appearance
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(MedicalColors.CHART_PAPER_STAINED.r, MedicalColors.CHART_PAPER_STAINED.g, MedicalColors.CHART_PAPER_STAINED.b, 0.8)
	bg_style.border_width_left = 1
	bg_style.border_width_top = 1
	bg_style.border_width_right = 1
	bg_style.border_width_bottom = 1
	bg_style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	bg_style.corner_radius_top_left = 2
	bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_left = 8
	bg_style.corner_radius_bottom_right = 8
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = MedicalColors.MONITOR_GREEN  # Will change based on urgency
	fill_style.corner_radius_top_left = 1
	fill_style.corner_radius_top_right = 1
	fill_style.corner_radius_bottom_left = 7
	fill_style.corner_radius_bottom_right = 7
	
	timer_progress_bar.add_theme_stylebox_override("background", bg_style)
	timer_progress_bar.add_theme_stylebox_override("fill", fill_style)
	
	screen.add_child(timer_progress_bar)
	
	# IV bag at top of progress bar
	create_iv_bag_icon(screen, Vector2(timer_progress_bar.position.x - 2, timer_progress_bar.position.y - 10))

func create_iv_bag_icon(parent: Control, pos: Vector2):
	"""Create IV bag icon above progress bar"""
	
	var iv_bag = Panel.new()
	iv_bag.name = "IVBag"
	iv_bag.size = Vector2(19, 12)
	iv_bag.position = pos
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(MedicalColors.CHART_PAPER.r, MedicalColors.CHART_PAPER.g, MedicalColors.CHART_PAPER.b, 0.9)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	
	iv_bag.add_theme_stylebox_override("panel", style)
	parent.add_child(iv_bag)
	
	# IV bag label
	var bag_label = Label.new()
	bag_label.text = "Rx"
	bag_label.size = iv_bag.size
	bag_label.add_theme_font_size_override("font_size", 6)
	bag_label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
	bag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bag_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	iv_bag.add_child(bag_label)

func create_heart_rate_display(screen: Panel):
	"""Create animated heart rate line"""
	
	heart_rate_line = Control.new()
	heart_rate_line.name = "HeartRateLine"
	heart_rate_line.size = Vector2(140, 20)
	heart_rate_line.position = Vector2(10, 55)
	screen.add_child(heart_rate_line)
	
	# Create ECG line
	create_ecg_line()
	
	# Animate the ECG
	start_ecg_animation()

func create_ecg_line():
	"""Create ECG line visual"""
	
	# Baseline
	var baseline = ColorRect.new()
	baseline.name = "ECGBaseline"
	baseline.size = Vector2(heart_rate_line.size.x, 1)
	baseline.position = Vector2(0, heart_rate_line.size.y / 2)
	baseline.color = MedicalColors.MONITOR_GREEN
	heart_rate_line.add_child(baseline)
	
	# Heartbeat spikes (will be animated)
	for i in range(7):
		var spike = create_heartbeat_spike(Vector2(i * 20 + 10, heart_rate_line.size.y / 2))
		heart_rate_line.add_child(spike)

func create_heartbeat_spike(pos: Vector2) -> Control:
	"""Create individual heartbeat spike"""
	
	var spike_container = Control.new()
	spike_container.position = pos
	spike_container.size = Vector2(8, 12)
	
	# QRS complex shape (simplified)
	var spike_points = [
		Vector2(0, 0),
		Vector2(2, -8),
		Vector2(4, 12),
		Vector2(6, -4),
		Vector2(8, 0)
	]
	
	for i in range(spike_points.size() - 1):
		var line = ColorRect.new()
		line.size = Vector2(2, 1)
		line.position = spike_points[i]
		line.color = MedicalColors.MONITOR_GREEN
		spike_container.add_child(line)
	
	return spike_container

func start_ecg_animation():
	"""Start ECG heartbeat animation"""
	
	var tween = create_tween()
	tween.set_loops()
	
	# Animate heartbeat pattern
	animate_heartbeat_pattern(tween)

func animate_heartbeat_pattern(tween: Tween):
	"""Animate the heartbeat pattern"""
	
	while equipment_power_on:
		# Normal heartbeat
		tween.tween_callback(pulse_heartbeat_spikes)
		tween.tween_delay(0.8)  # Normal heart rate timing
		
		# Adjust timing based on urgency
		var delay_modifier = 1.0
		match timer_warning_level:
			"warning":
				delay_modifier = 0.9
			"critical":
				delay_modifier = 0.7
			"urgent":
				delay_modifier = 0.5
		
		tween.tween_delay(0.8 * delay_modifier)

func pulse_heartbeat_spikes():
	"""Create heartbeat pulse effect"""
	
	for child in heart_rate_line.get_children():
		if "spike" in child.name.to_lower():
			var pulse_tween = create_tween()
			pulse_tween.tween_property(child, "modulate", Color(1.2, 1.2, 1.2), 0.1)
			pulse_tween.tween_property(child, "modulate", Color.WHITE, 0.1)

func create_timer_warning_lights(parent: Control):
	"""Create warning lights for timer alerts"""
	
	# Critical warning light
	timer_warning_light = ColorRect.new()
	timer_warning_light.name = "WarningLight"
	timer_warning_light.size = Vector2(8, 8)
	timer_warning_light.position = Vector2(parent.size.x - 20, 90)
	timer_warning_light.color = MedicalColors.MONITOR_GREEN
	
	# Make it circular
	var style = StyleBoxFlat.new()
	style.bg_color = timer_warning_light.color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	timer_warning_light.add_theme_stylebox_override("panel", style)
	parent.add_child(timer_warning_light)
	
	# Warning light label
	var warning_label = Label.new()
	warning_label.name = "WarningLabel"
	warning_label.text = "ALERT"
	warning_label.size = Vector2(30, 10)
	warning_label.position = Vector2(timer_warning_light.position.x - 25, timer_warning_light.position.y + 10)
	warning_label.add_theme_font_size_override("font_size", 6)
	warning_label.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(warning_label)

func create_monitor_controls(parent: Control):
	"""Create monitor control buttons"""
	
	var controls_container = HBoxContainer.new()
	controls_container.name = "MonitorControls"
	controls_container.size = Vector2(parent.size.x - 10, 25)
	controls_container.position = Vector2(5, parent.size.y - 30)
	controls_container.add_theme_constant_override("separation", 8)
	parent.add_child(controls_container)
	
	# Power button
	var power_btn = create_equipment_button("PWR", MedicalColors.URGENT_RED, Vector2(35, 20))
	controls_container.add_child(power_btn)
	
	# Settings button
	var settings_btn = create_equipment_button("SET", MedicalColors.WARNING_AMBER, Vector2(35, 20))
	controls_container.add_child(settings_btn)
	
	# Silence alarms button
	var silence_btn = create_equipment_button("SIL", MedicalColors.STERILE_BLUE, Vector2(35, 20))
	controls_container.add_child(silence_btn)

func create_equipment_button(text: String, color: Color, button_size: Vector2) -> Button:
	"""Create medical equipment style button"""
	
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = button_size
	
	# Equipment button styling
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = color
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	normal_style.corner_radius_top_left = 3
	normal_style.corner_radius_top_right = 3
	normal_style.corner_radius_bottom_left = 3
	normal_style.corner_radius_bottom_right = 3
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(color.r * 0.8, color.g * 0.8, color.b * 0.8)
	pressed_style.border_width_left = 2
	pressed_style.border_width_top = 2
	pressed_style.border_width_right = 2
	pressed_style.border_width_bottom = 2
	pressed_style.border_color = MedicalColors.SHADOW_BLUE
	pressed_style.corner_radius_top_left = 3
	pressed_style.corner_radius_top_right = 3
	pressed_style.corner_radius_bottom_left = 3
	pressed_style.corner_radius_bottom_right = 3
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Button text styling
	button.add_theme_font_size_override("font_size", 8)
	button.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	
	return button

func create_clipboard_answer_system():
	"""Create clipboard-style answer choice system"""
	
	clipboard_answers = Control.new()
	clipboard_answers.name = "ClipboardAnswers"
	clipboard_answers.size = Vector2(medical_panel.size.x - 20, 300)
	clipboard_answers.position = Vector2(10, 150)
	medical_panel.add_child(clipboard_answers)
	
	# Clipboard base
	create_clipboard_base()
	
	# Answer choice buttons
	create_answer_choice_buttons()

func create_clipboard_base():
	"""Create clipboard backing"""
	
	clipboard_base = Panel.new()
	clipboard_base.name = "ClipboardBase"
	clipboard_base.size = clipboard_answers.size
	clipboard_base.position = Vector2.ZERO
	
	# Clipboard styling
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.add_wear_effect(MedicalColors.EQUIPMENT_GRAY, 0.1)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	
	clipboard_base.add_theme_stylebox_override("panel", style)
	clipboard_answers.add_child(clipboard_base)
	
	# Clipboard clip at top
	create_clipboard_clip()
	
	# Medical form header
	create_clipboard_header()

func create_clipboard_clip():
	"""Create clipboard clip detail"""
	
	clipboard_clip = Control.new()
	clipboard_clip.name = "ClipboardClip"
	clipboard_clip.size = Vector2(40, 15)
	clipboard_clip.position = Vector2((clipboard_base.size.x - 40) / 2, -5)
	clipboard_answers.add_child(clipboard_clip)
	
	# Clip base
	var clip_base = ColorRect.new()
	clip_base.size = Vector2(40, 12)
	clip_base.color = MedicalColors.EQUIPMENT_GRAY_DARK
	clipboard_clip.add_child(clip_base)
	
	# Clip spring mechanism
	var spring1 = ColorRect.new()
	spring1.size = Vector2(2, 8)
	spring1.position = Vector2(10, 2)
	spring1.color = MedicalColors.SHADOW_BLUE
	clipboard_clip.add_child(spring1)
	
	var spring2 = ColorRect.new()
	spring2.size = Vector2(2, 8)
	spring2.position = Vector2(28, 2)
	spring2.color = MedicalColors.SHADOW_BLUE
	clipboard_clip.add_child(spring2)

func create_clipboard_header():
	"""Create medical form header on clipboard"""
	
	var header_container = VBoxContainer.new()
	header_container.name = "FormHeader"
	header_container.size = Vector2(clipboard_base.size.x - 20, 40)
	header_container.position = Vector2(10, 15)
	clipboard_base.add_child(header_container)
	
	# Hospital header
	var hospital_label = Label.new()
	hospital_label.text = "BLACKSTAR GENERAL - EMERGENCY DEPT"
	hospital_label.add_theme_font_size_override("font_size", 8)
	hospital_label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
	hospital_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_container.add_child(hospital_label)
	
	# Form title
	var form_label = Label.new()
	form_label.text = "CLINICAL DECISION FORM"
	form_label.add_theme_font_size_override("font_size", 10)
	form_label.add_theme_color_override("font_color", MedicalColors.MEDICAL_GREEN_DARK)
	form_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_container.add_child(form_label)
	
	# Separator line
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", MedicalColors.TEXT_MUTED)
	header_container.add_child(separator)

func create_answer_choice_buttons():
	"""Create answer choice buttons on clipboard"""
	
	choice_buttons.clear()
	
	var buttons_container = VBoxContainer.new()
	buttons_container.name = "ChoiceButtons"
	buttons_container.size = Vector2(clipboard_base.size.x - 30, clipboard_base.size.y - 80)
	buttons_container.position = Vector2(15, 60)
	buttons_container.add_theme_constant_override("separation", 8)
	clipboard_base.add_child(buttons_container)
	
	# Create 5 choice buttons
	var choice_letters = ["A", "B", "C", "D", "E"]
	
	for i in range(5):
		var choice_button = create_clipboard_choice_button(choice_letters[i], i)
		buttons_container.add_child(choice_button)
		choice_buttons.append(choice_button)

func create_clipboard_choice_button(letter: String, index: int) -> Button:
	"""Create individual choice button with checkbox styling"""
	
	var button = Button.new()
	button.name = "Choice" + letter
	button.custom_minimum_size = Vector2(clipboard_base.size.x - 40, 35)
	button.text = letter + ") Loading..."
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Medical form checkbox styling
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = MedicalColors.CHART_PAPER
	normal_style.border_width_left = 1
	normal_style.border_width_top = 1
	normal_style.border_width_right = 1
	normal_style.border_width_bottom = 1
	normal_style.border_color = MedicalColors.TEXT_MUTED
	normal_style.corner_radius_top_left = 2
	normal_style.corner_radius_top_right = 2
	normal_style.corner_radius_bottom_left = 2
	normal_style.corner_radius_bottom_right = 2
	normal_style.content_margin_left = 25
	normal_style.content_margin_right = 10
	normal_style.content_margin_top = 6
	normal_style.content_margin_bottom = 6
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = MedicalColors.STERILE_BLUE_LIGHT
	hover_style.border_width_left = 2
	hover_style.border_width_top = 2
	hover_style.border_width_right = 2
	hover_style.border_width_bottom = 2
	hover_style.border_color = MedicalColors.STERILE_BLUE
	hover_style.corner_radius_top_left = 2
	hover_style.corner_radius_top_right = 2
	hover_style.corner_radius_bottom_left = 2
	hover_style.corner_radius_bottom_right = 2
	hover_style.content_margin_left = 25
	hover_style.content_margin_right = 10
	hover_style.content_margin_top = 6
	hover_style.content_margin_bottom = 6
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = MedicalColors.SUCCESS_GREEN
	pressed_style.border_width_left = 2
	pressed_style.border_width_top = 2
	pressed_style.border_width_right = 2
	pressed_style.border_width_bottom = 2
	pressed_style.border_color = MedicalColors.MONITOR_GREEN
	pressed_style.corner_radius_top_left = 2
	pressed_style.corner_radius_top_right = 2
	pressed_style.corner_radius_bottom_left = 2
	pressed_style.corner_radius_bottom_right = 2
	pressed_style.content_margin_left = 25
	pressed_style.content_margin_right = 10
	pressed_style.content_margin_top = 6
	pressed_style.content_margin_bottom = 6
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Button text styling
	button.add_theme_font_size_override("font_size", 9)
	button.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
	
	# Add checkbox visual
	add_choice_checkbox(button, letter)
	
	# Connect button signal
	button.pressed.connect(_on_choice_button_pressed.bind(letter))
	
	return button

func add_choice_checkbox(button: Button, letter: String):
	"""Add checkbox visual to choice button"""
	
	var checkbox = ColorRect.new()
	checkbox.name = "Checkbox" + letter
	checkbox.size = Vector2(12, 12)
	checkbox.position = Vector2(8, (button.custom_minimum_size.y - 12) / 2)
	checkbox.color = Color.TRANSPARENT
	
	# Checkbox border
	var checkbox_style = StyleBoxFlat.new()
	checkbox_style.bg_color = Color.TRANSPARENT
	checkbox_style.border_width_left = 2
	checkbox_style.border_width_top = 2
	checkbox_style.border_width_right = 2
	checkbox_style.border_width_bottom = 2
	checkbox_style.border_color = MedicalColors.TEXT_DARK
	checkbox_style.corner_radius_top_left = 1
	checkbox_style.corner_radius_top_right = 1
	checkbox_style.corner_radius_bottom_left = 1
	checkbox_style.corner_radius_bottom_right = 1
	
	checkbox.add_theme_stylebox_override("panel", checkbox_style)
	button.add_child(checkbox)

func create_medical_control_panel():
	"""Create additional medical control panel"""
	
	equipment_status_panel = Panel.new()
	equipment_status_panel.name = "EquipmentStatus"
	equipment_status_panel.size = Vector2(medical_panel.size.x - 20, 80)
	equipment_status_panel.position = Vector2(10, medical_panel.size.y - 90)
	
	# Status panel styling
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.SHADOW_BLUE
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	equipment_status_panel.add_theme_stylebox_override("panel", style)
	medical_panel.add_child(equipment_status_panel)
	
	# Add status indicators
	create_equipment_status_indicators()

func create_equipment_status_indicators():
	"""Create equipment status indicators"""
	
	var indicators_container = HBoxContainer.new()
	indicators_container.name = "StatusIndicators"
	indicators_container.size = Vector2(equipment_status_panel.size.x - 20, 30)
	indicators_container.position = Vector2(10, 10)
	indicators_container.add_theme_constant_override("separation", 12)
	equipment_status_panel.add_child(indicators_container)
	
	# Power status
	create_status_indicator(indicators_container, "PWR", MedicalColors.MONITOR_GREEN, true)
	
	# Network status
	create_status_indicator(indicators_container, "NET", MedicalColors.WARNING_AMBER, true)
	
	# Battery status
	create_status_indicator(indicators_container, "BAT", MedicalColors.MONITOR_GREEN, false)
	
	# Equipment status labels
	var status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "SYSTEM STATUS: OPERATIONAL"
	status_label.size = Vector2(equipment_status_panel.size.x - 20, 15)
	status_label.position = Vector2(10, 45)
	status_label.add_theme_font_size_override("font_size", 8)
	status_label.add_theme_color_override("font_color", MedicalColors.MONITOR_GREEN)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipment_status_panel.add_child(status_label)

func create_status_indicator(parent: HBoxContainer, label: String, color: Color, is_active: bool):
	"""Create individual status indicator"""
	
	var indicator_container = VBoxContainer.new()
	indicator_container.custom_minimum_size = Vector2(35, 30)
	parent.add_child(indicator_container)
	
	# Status light
	var light = ColorRect.new()
	light.name = label + "Light"
	light.size = Vector2(8, 8)
	light.color = color if is_active else MedicalColors.EQUIPMENT_GRAY
	
	# Make circular
	var light_style = StyleBoxFlat.new()
	light_style.bg_color = light.color
	light_style.corner_radius_top_left = 4
	light_style.corner_radius_top_right = 4
	light_style.corner_radius_bottom_left = 4
	light_style.corner_radius_bottom_right = 4
	
	light.add_theme_stylebox_override("panel", light_style)
	
	# Center the light
	var light_container = Control.new()
	light_container.size = Vector2(35, 12)
	light_container.add_child(light)
	light.position = Vector2((35 - 8) / 2, 2)
	indicator_container.add_child(light_container)
	
	# Status label
	var status_label = Label.new()
	status_label.text = label
	status_label.add_theme_font_size_override("font_size", 6)
	status_label.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	indicator_container.add_child(status_label)

# Public interface functions

func update_timer_display(time_remaining: float, max_time: float):
	"""Update timer display with new time"""
	
	current_timer_value = time_remaining
	max_timer_value = max_time
	
	if timer_display:
		timer_display.text = format_timer_display(time_remaining)
		
		# Update color based on urgency
		var urgency_level = 1.0 - (time_remaining / max_time)
		var color = MedicalColors.get_timer_color(time_remaining, max_time)
		timer_display.add_theme_color_override("font_color", color)
	
	if timer_progress_bar:
		timer_progress_bar.value = time_remaining
		timer_progress_bar.max_value = max_time
		
		# Update progress bar color
		var fill_style = timer_progress_bar.get_theme_stylebox("fill")
		if fill_style is StyleBoxFlat:
			(fill_style as StyleBoxFlat).bg_color = MedicalColors.get_timer_color(time_remaining, max_time)
	
	# Update warning level
	update_timer_warning_level(time_remaining, max_time)

func format_timer_display(time_seconds: float) -> String:
	"""Format time for medical equipment display"""
	
	var minutes = int(time_seconds) // 60
	var seconds = int(time_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func update_timer_warning_level(time_remaining: float, max_time: float):
	"""Update warning level based on remaining time"""
	
	var time_percentage = time_remaining / max_time
	var new_warning_level: String
	
	if time_percentage > 0.5:
		new_warning_level = "normal"
	elif time_percentage > 0.25:
		new_warning_level = "warning"
	elif time_percentage > 0.1:
		new_warning_level = "critical"
	else:
		new_warning_level = "urgent"
	
	if new_warning_level != timer_warning_level:
		timer_warning_level = new_warning_level
		update_warning_light()
		timer_warning_triggered.emit(new_warning_level)

func update_warning_light():
	"""Update warning light based on current level"""
	
	if not timer_warning_light:
		return
	
	var light_color: Color
	var should_blink: bool = false
	
	match timer_warning_level:
		"normal":
			light_color = MedicalColors.MONITOR_GREEN
		"warning":
			light_color = MedicalColors.WARNING_AMBER
		"critical":
			light_color = MedicalColors.URGENT_ORANGE
			should_blink = true
		"urgent":
			light_color = MedicalColors.URGENT_RED
			should_blink = true
	
	timer_warning_light.color = light_color
	var light_style = timer_warning_light.get_theme_stylebox("panel")
	if light_style is StyleBoxFlat:
		(light_style as StyleBoxFlat).bg_color = light_color
	
	if should_blink:
		start_warning_blink()
	else:
		stop_warning_blink()

func start_warning_blink():
	"""Start warning light blinking"""
	
	var blink_tween = create_tween()
	blink_tween.set_loops()
	
	while timer_warning_level in ["critical", "urgent"] and equipment_power_on:
		blink_tween.tween_property(timer_warning_light, "modulate:a", 0.3, 0.3)
		blink_tween.tween_property(timer_warning_light, "modulate:a", 1.0, 0.3)

func stop_warning_blink():
	"""Stop warning light blinking"""
	
	if timer_warning_light:
		timer_warning_light.modulate.a = 1.0

func update_answer_choices(choices: Array):
	"""Update answer choice buttons with new choices"""
	
	for i in range(choice_buttons.size()):
		if i < choices.size():
			var choice = choices[i]
			var button = choice_buttons[i]
			
			if choice is Dictionary:
				button.text = choice.get("id", char(65 + i)) + ") " + choice.get("text", "")
			else:
				button.text = char(65 + i) + ") " + str(choice)
			
			button.visible = true
			button.disabled = false
			
			# Reset checkbox
			reset_choice_checkbox(button, char(65 + i))
		else:
			choice_buttons[i].visible = false

func reset_choice_checkbox(button: Button, letter: String):
	"""Reset choice checkbox to unchecked state"""
	
	var checkbox = button.find_child("Checkbox" + letter)
	if checkbox:
		checkbox.color = Color.TRANSPARENT

func mark_choice_selected(choice_id: String):
	"""Mark a choice as selected with checkbox"""
	
	for button in choice_buttons:
		var button_letter = button.name.replace("Choice", "")
		var checkbox = button.find_child("Checkbox" + button_letter)
		
		if checkbox:
			if button_letter == choice_id:
				# Mark as selected
				checkbox.color = MedicalColors.MONITOR_GREEN
				
				# Add checkmark
				add_checkmark(checkbox)
			else:
				# Deselect others
				checkbox.color = Color.TRANSPARENT
				remove_checkmark(checkbox)

func add_checkmark(checkbox: ColorRect):
	"""Add checkmark to selected checkbox"""
	
	# Remove existing checkmark
	remove_checkmark(checkbox)
	
	# Add checkmark lines
	var check1 = ColorRect.new()
	check1.name = "CheckLine1"
	check1.size = Vector2(6, 1)
	check1.position = Vector2(2, 7)
	check1.color = MedicalColors.TEXT_LIGHT
	check1.rotation = 0.5
	checkbox.add_child(check1)
	
	var check2 = ColorRect.new()
	check2.name = "CheckLine2"
	check2.size = Vector2(8, 1)
	check2.position = Vector2(4, 6)
	check2.color = MedicalColors.TEXT_LIGHT
	check2.rotation = -0.7
	checkbox.add_child(check2)

func remove_checkmark(checkbox: ColorRect):
	"""Remove checkmark from checkbox"""
	
	var check1 = checkbox.find_child("CheckLine1")
	var check2 = checkbox.find_child("CheckLine2")
	
	if check1:
		check1.queue_free()
	if check2:
		check2.queue_free()

func disable_answer_choices():
	"""Disable all answer choice buttons"""
	
	for button in choice_buttons:
		button.disabled = true

func enable_answer_choices():
	"""Enable all answer choice buttons"""
	
	for button in choice_buttons:
		button.disabled = false

func set_equipment_power(power_on: bool):
	"""Set equipment power state"""
	
	equipment_power_on = power_on
	
	if not power_on:
		# Power off effects
		modulate = Color(0.3, 0.3, 0.3)
		stop_warning_blink()
	else:
		# Power on effects
		modulate = Color.WHITE
		start_ecg_animation()

func trigger_equipment_malfunction():
	"""Trigger equipment malfunction effect"""
	
	equipment_malfunction.emit()
	
	# Visual malfunction effects
	var malfunction_tween = create_tween()
	
	# Screen flicker
	for i in range(5):
		malfunction_tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5), 0.1)
		malfunction_tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	# Brief power loss to warning light
	if timer_warning_light:
		malfunction_tween.tween_property(timer_warning_light, "modulate:a", 0.0, 0.2)
		malfunction_tween.tween_property(timer_warning_light, "modulate:a", 1.0, 0.3)

# Signal handlers

func _on_choice_button_pressed(choice_id: String):
	"""Handle choice button press"""
	
	mark_choice_selected(choice_id)
	answer_choice_selected.emit(choice_id)
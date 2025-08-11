class_name ChartAnimationSystem
extends Control

# Enhanced chart animation system for Blackstar
# Orchestrates patient chart sliding, highlighting, and critical information display

signal chart_animation_complete()
signal critical_information_highlighted(info_type: String)
signal chart_interaction_started(interaction_type: String)
signal chart_slide_in_complete()
signal chart_slide_out_complete()
signal priority_highlight_complete()

# Animation components
@onready var chart_container: Control
@onready var active_chart: PixelArtChart
@onready var highlight_system: Control
@onready var priority_indicators: Control

# Animation states
enum AnimationState {
	IDLE,
	SLIDING_IN,
	ON_DESK,
	HIGHLIGHTING,
	SLIDING_OUT
}

var current_state: AnimationState = AnimationState.IDLE
var animation_queue: Array[Dictionary] = []
var is_processing_animation: bool = false

# Timing settings
var slide_in_duration: float = 0.8
var highlight_duration: float = 1.5
var slide_out_duration: float = 0.6
var critical_blink_duration: float = 2.0

# Chart management
var chart_stack: Array[PixelArtChart] = []
var max_charts_on_desk: int = 3
var current_chart_urgency: float = 0.0

# Audio elements
@onready var paper_slide_sound: AudioStreamPlayer
@onready var paper_turn_sound: AudioStreamPlayer
@onready var paper_rustle_sound: AudioStreamPlayer

func _ready():
	setup_animation_system()
	setup_audio()
	setup_highlight_effects()
	create_priority_indicators()

func setup_animation_system():
	"""Initialize the chart animation system"""
	
	# Chart container for managing multiple charts
	chart_container = Control.new()
	chart_container.name = "ChartContainer"
	chart_container.size = size
	chart_container.position = Vector2.ZERO
	add_child(chart_container)
	
	# Highlight system overlay
	highlight_system = Control.new()
	highlight_system.name = "HighlightSystem"
	highlight_system.size = size
	highlight_system.position = Vector2.ZERO
	highlight_system.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(highlight_system)
	
	# Priority indicators (urgent alerts, etc.)
	priority_indicators = Control.new()
	priority_indicators.name = "PriorityIndicators"
	priority_indicators.size = size
	priority_indicators.position = Vector2.ZERO
	priority_indicators.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(priority_indicators)

func setup_audio():
	"""Setup paper sound effects"""
	if not paper_slide_sound:
		paper_slide_sound = AudioStreamPlayer.new()
		paper_slide_sound.name = "PaperSlideSound"
		add_child(paper_slide_sound)
		# Would load actual paper sliding sound file
	
	if not paper_turn_sound:
		paper_turn_sound = AudioStreamPlayer.new()
		paper_turn_sound.name = "PaperTurnSound"
		add_child(paper_turn_sound)
		# Would load page turning sound file
	
	if not paper_rustle_sound:
		paper_rustle_sound = AudioStreamPlayer.new()
		paper_rustle_sound.name = "PaperRustleSound"
		add_child(paper_rustle_sound)
		# Would load paper rustling sound file

func setup_highlight_effects():
	"""Setup highlight effect overlays"""
	
	# Critical information spotlight
	var spotlight = create_spotlight_effect()
	highlight_system.add_child(spotlight)
	
	# Urgency pulse overlay
	var pulse_overlay = create_pulse_overlay()
	highlight_system.add_child(pulse_overlay)
	
	# Section highlight frames
	create_section_highlight_frames()

func create_spotlight_effect() -> Control:
	"""Create spotlight effect for highlighting critical information"""
	
	var spotlight = Control.new()
	spotlight.name = "CriticalSpotlight"
	spotlight.size = Vector2(200, 150)
	spotlight.visible = false
	
	# Spotlight background (darkens everything else)
	var dark_overlay = ColorRect.new()
	dark_overlay.name = "DarkOverlay"
	dark_overlay.size = size
	dark_overlay.position = Vector2(-spotlight.size.x/2, -spotlight.size.y/2)
	dark_overlay.color = Color(0, 0, 0, 0.6)
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spotlight.add_child(dark_overlay)
	
	# Spotlight circle (clears the dark overlay)
	var spotlight_circle = ColorRect.new()
	spotlight_circle.name = "SpotlightCircle"
	spotlight_circle.size = Vector2(180, 120)
	spotlight_circle.position = Vector2(-90, -60)
	spotlight_circle.color = Color.TRANSPARENT
	
	# Make circular with shader or styling
	var circle_style = StyleBoxFlat.new()
	circle_style.bg_color = Color.TRANSPARENT
	circle_style.border_width_left = 3
	circle_style.border_width_top = 3
	circle_style.border_width_right = 3
	circle_style.border_width_bottom = 3
	circle_style.border_color = MedicalColors.CRITICAL_RED
	circle_style.corner_radius_top_left = 90
	circle_style.corner_radius_top_right = 90
	circle_style.corner_radius_bottom_left = 90
	circle_style.corner_radius_bottom_right = 90
	
	spotlight_circle.add_theme_stylebox_override("panel", circle_style)
	spotlight.add_child(spotlight_circle)
	
	return spotlight

func create_pulse_overlay() -> Control:
	"""Create pulsing overlay for urgent information"""
	
	var pulse_overlay = ColorRect.new()
	pulse_overlay.name = "UrgencyPulse"
	pulse_overlay.size = size
	pulse_overlay.color = Color.TRANSPARENT
	pulse_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pulse_overlay.visible = false
	
	return pulse_overlay

func create_section_highlight_frames():
	"""Create highlight frames for chart sections"""
	
	var sections = ["VITAL_SIGNS", "DEMOGRAPHICS", "HISTORY", "PHYSICAL_EXAM", "LABS"]
	
	for section in sections:
		var frame = create_section_frame(section)
		highlight_system.add_child(frame)

func create_section_frame(section_name: String) -> Control:
	"""Create highlight frame for specific chart section"""
	
	var frame = Panel.new()
	frame.name = section_name + "_Frame"
	frame.size = Vector2(280, 60)  # Default size, will be adjusted
	frame.visible = false
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = MedicalColors.URGENT_YELLOW
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	# Add animated glow effect
	style.shadow_color = Color(MedicalColors.URGENT_YELLOW.r, MedicalColors.URGENT_YELLOW.g, MedicalColors.URGENT_YELLOW.b, 0.5)
	style.shadow_size = 8
	
	frame.add_theme_stylebox_override("panel", style)
	
	return frame

func create_priority_indicators():
	"""Create priority level indicators"""
	
	# Critical alert banner
	var critical_banner = create_critical_alert_banner()
	priority_indicators.add_child(critical_banner)
	
	# Urgency level indicator
	var urgency_indicator = create_urgency_level_indicator()
	priority_indicators.add_child(urgency_indicator)
	
	# Time pressure indicator
	var time_indicator = create_time_pressure_indicator()
	priority_indicators.add_child(time_indicator)

func create_critical_alert_banner() -> Control:
	"""Create critical alert banner that appears at top"""
	
	var banner = Panel.new()
	banner.name = "CriticalAlertBanner"
	banner.size = Vector2(size.x - 40, 40)
	banner.position = Vector2(20, -50)  # Start above screen
	banner.visible = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.CRITICAL_RED
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = MedicalColors.URGENT_RED
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	
	banner.add_theme_stylebox_override("panel", style)
	
	# Banner text
	var banner_text = Label.new()
	banner_text.name = "BannerText"
	banner_text.text = "⚠ CRITICAL PATIENT ⚠"
	banner_text.size = banner.size
	banner_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_text.add_theme_font_size_override("font_size", 16)
	banner_text.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	banner.add_child(banner_text)
	
	return banner

func create_urgency_level_indicator() -> Control:
	"""Create urgency level visual indicator"""
	
	var indicator_container = VBoxContainer.new()
	indicator_container.name = "UrgencyIndicator"
	indicator_container.size = Vector2(60, 150)
	indicator_container.position = Vector2(size.x - 80, size.y / 4)
	indicator_container.visible = false
	
	# Urgency bars (like volume bars)
	var urgency_levels = 5
	for i in range(urgency_levels):
		var bar = create_urgency_bar(i, urgency_levels)
		indicator_container.add_child(bar)
	
	return indicator_container

func create_urgency_bar(level: int, total_levels: int) -> ColorRect:
	"""Create individual urgency level bar"""
	
	var bar = ColorRect.new()
	bar.name = "UrgencyBar" + str(level)
	bar.size = Vector2(50, 20)
	
	# Color based on urgency level
	var urgency_ratio = float(level) / float(total_levels - 1)
	bar.color = MedicalColors.get_urgency_color(urgency_ratio)
	
	var style = StyleBoxFlat.new()
	style.bg_color = bar.color
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	
	bar.add_theme_stylebox_override("panel", style)
	
	return bar

func create_time_pressure_indicator() -> Control:
	"""Create time pressure visual indicator"""
	
	var time_container = Control.new()
	time_container.name = "TimePressureIndicator"
	time_container.size = Vector2(100, 30)
	time_container.position = Vector2(size.x / 2 - 50, 20)
	time_container.visible = false
	
	# Time pressure bar
	var pressure_bar = ProgressBar.new()
	pressure_bar.name = "PressureBar"
	pressure_bar.size = Vector2(100, 8)
	pressure_bar.position = Vector2(0, 22)
	pressure_bar.max_value = 1.0
	pressure_bar.value = 0.0
	pressure_bar.show_percentage = false
	
	# Styling for time pressure
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = MedicalColors.SHADOW_BLUE
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = MedicalColors.URGENT_RED
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	
	pressure_bar.add_theme_stylebox_override("background", bg_style)
	pressure_bar.add_theme_stylebox_override("fill", fill_style)
	
	time_container.add_child(pressure_bar)
	
	# Time pressure label
	var pressure_label = Label.new()
	pressure_label.name = "PressureLabel"
	pressure_label.text = "TIME CRITICAL"
	pressure_label.size = Vector2(100, 20)
	pressure_label.position = Vector2(0, 0)
	pressure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pressure_label.add_theme_font_size_override("font_size", 10)
	pressure_label.add_theme_color_override("font_color", MedicalColors.URGENT_RED)
	time_container.add_child(pressure_label)
	
	return time_container

# Main animation functions

func animate_chart_in(patient_data: Dictionary, urgency_level: float = 0.0, wear_level: float = 0.0):
	"""Animate a new patient chart sliding in"""
	
	if current_state != AnimationState.IDLE:
		# Queue the animation
		animation_queue.append({
			"type": "slide_in",
			"data": patient_data,
			"urgency": urgency_level,
			"wear": wear_level
		})
		return
	
	current_state = AnimationState.SLIDING_IN
	current_chart_urgency = urgency_level
	chart_interaction_started.emit("chart_slide_in")
	
	# Create new chart
	active_chart = PixelArtChart.new()
	active_chart.position = Vector2(-active_chart.chart_base_size.x, size.y * 0.4)
	chart_container.add_child(active_chart)
	
	# Load chart data
	active_chart.load_patient_chart(patient_data, urgency_level, wear_level)
	
	# Connect chart signals
	active_chart.chart_slide_complete.connect(_on_chart_slide_complete)
	active_chart.critical_info_blink.connect(_on_critical_info_blink)
	
	# Manage chart stack
	manage_chart_stack(active_chart)
	
	# Show priority indicators if high urgency
	if urgency_level > 0.6:
		show_priority_indicators(urgency_level)
	
	# Play paper slide sound
	if paper_slide_sound:
		paper_slide_sound.play()
	
	# Start slide animation
	active_chart.slide_in_from_left(slide_in_duration)
	
	# Add environmental effects
	add_slide_in_effects(urgency_level)

func add_slide_in_effects(urgency_level: float):
	"""Add environmental effects during chart slide in"""
	
	if urgency_level > 0.8:
		# Critical case - add urgent visual cues
		start_critical_alert_animation()
	elif urgency_level > 0.5:
		# High urgency - add attention-getting effects
		start_attention_effects()

func start_critical_alert_animation():
	"""Start critical alert visual effects"""
	
	var critical_banner = priority_indicators.find_child("CriticalAlertBanner")
	if critical_banner:
		critical_banner.visible = true
		
		# Slide banner down from top
		var slide_tween = create_tween()
		slide_tween.tween_property(critical_banner, "position:y", 10, 0.4)
		slide_tween.tween_delay(3.0)  # Show for 3 seconds
		slide_tween.tween_property(critical_banner, "position:y", -50, 0.4)
		slide_tween.tween_callback(func(): critical_banner.visible = false)
	
	# Add screen flash effect
	add_screen_flash(MedicalColors.CRITICAL_RED)

func start_attention_effects():
	"""Start attention-getting effects for high urgency"""
	
	# Pulse the urgency indicator
	var urgency_indicator = priority_indicators.find_child("UrgencyIndicator")
	if urgency_indicator:
		urgency_indicator.visible = true
		animate_urgency_bars(current_chart_urgency)
		
		# Hide after delay
		var hide_timer = Timer.new()
		hide_timer.wait_time = 4.0
		hide_timer.one_shot = true
		hide_timer.timeout.connect(func(): 
			urgency_indicator.visible = false
			hide_timer.queue_free()
		)
		add_child(hide_timer)
		hide_timer.start()

func add_screen_flash(flash_color: Color):
	"""Add screen flash effect"""
	
	var flash_overlay = ColorRect.new()
	flash_overlay.size = size
	flash_overlay.color = Color(flash_color.r, flash_color.g, flash_color.b, 0.0)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash_overlay)
	
	var flash_tween = create_tween()
	flash_tween.tween_property(flash_overlay, "color:a", 0.3, 0.1)
	flash_tween.tween_property(flash_overlay, "color:a", 0.0, 0.2)
	flash_tween.tween_callback(flash_overlay.queue_free)

func animate_urgency_bars(urgency_level: float):
	"""Animate urgency level bars"""
	
	var urgency_indicator = priority_indicators.find_child("UrgencyIndicator")
	if not urgency_indicator:
		return
	
	var total_bars = 5
	var active_bars = int(urgency_level * total_bars)
	
	# Animate bars filling up
	var fill_tween = create_tween()
	
	for i in range(total_bars):
		var bar = urgency_indicator.find_child("UrgencyBar" + str(i))
		if bar:
			if i <= active_bars:
				# Bar should be active
				fill_tween.tween_property(bar, "modulate:a", 1.0, 0.1)
				fill_tween.parallel().tween_property(bar, "scale", Vector2(1.1, 1.1), 0.1)
				fill_tween.tween_property(bar, "scale", Vector2.ONE, 0.1)
			else:
				# Bar should be inactive
				fill_tween.tween_property(bar, "modulate:a", 0.3, 0.05)
		
		fill_tween.tween_delay(0.1)  # Stagger the animation

func highlight_critical_information(info_type: String, chart_section: String = ""):
	"""Highlight critical information on the chart"""
	
	if not active_chart or current_state != AnimationState.ON_DESK:
		return
	
	current_state = AnimationState.HIGHLIGHTING
	
	match info_type.to_lower():
		"vital_signs":
			highlight_vital_signs()
		
		"lab_results":
			highlight_lab_results()
		
		"all_critical":
			highlight_all_critical_info()
		
		"section":
			if chart_section != "":
				highlight_chart_section(chart_section)
	
	critical_information_highlighted.emit(info_type)

func highlight_vital_signs():
	"""Highlight abnormal vital signs"""
	
	# Use spotlight effect on vital signs section
	var spotlight = highlight_system.find_child("CriticalSpotlight")
	if spotlight:
		# Position spotlight over vital signs area of chart
		var vital_signs_pos = get_vital_signs_position()
		spotlight.position = vital_signs_pos
		spotlight.visible = true
		
		# Animate spotlight
		animate_spotlight(spotlight)
	
	# Also highlight the section frame
	highlight_chart_section("VITAL_SIGNS")

func get_vital_signs_position() -> Vector2:
	"""Get position of vital signs section on chart"""
	
	if active_chart:
		# Estimate position based on chart structure
		return Vector2(
			active_chart.position.x + active_chart.chart_base_size.x * 0.3,
			active_chart.position.y + active_chart.chart_base_size.y * 0.4
		)
	
	return Vector2(size.x * 0.4, size.y * 0.5)

func animate_spotlight(spotlight: Control):
	"""Animate the spotlight effect"""
	
	var spotlight_tween = create_tween()
	spotlight_tween.set_loops(3)
	
	# Pulse the spotlight border
	var border_circle = spotlight.find_child("SpotlightCircle")
	if border_circle:
		spotlight_tween.tween_property(border_circle, "modulate", Color(1.2, 1.2, 1.2), 0.4)
		spotlight_tween.tween_property(border_circle, "modulate", Color.WHITE, 0.4)
	
	# Hide spotlight after animation
	spotlight_tween.tween_callback(func(): 
		spotlight.visible = false
		current_state = AnimationState.ON_DESK
	)

func highlight_chart_section(section_name: String):
	"""Highlight specific chart section"""
	
	var frame = highlight_system.find_child(section_name + "_Frame")
	if frame:
		# Position frame over chart section
		var section_pos = get_section_position(section_name)
		frame.position = section_pos
		frame.visible = true
		
		# Animate frame
		animate_section_frame(frame)

func get_section_position(section_name: String) -> Vector2:
	"""Get position of chart section"""
	
	if not active_chart:
		return Vector2.ZERO
	
	var base_x = active_chart.position.x + 10
	var base_y = active_chart.position.y + 60
	
	match section_name:
		"DEMOGRAPHICS":
			return Vector2(base_x, base_y)
		"VITAL_SIGNS":
			return Vector2(base_x, base_y + 70)
		"HISTORY":
			return Vector2(base_x, base_y + 130)
		"PHYSICAL_EXAM":
			return Vector2(base_x, base_y + 180)
		"LABS":
			return Vector2(base_x, base_y + 220)
		_:
			return Vector2(base_x, base_y)

func animate_section_frame(frame: Control):
	"""Animate section highlight frame"""
	
	var frame_tween = create_tween()
	frame_tween.set_loops(2)
	
	# Pulse animation
	frame_tween.tween_property(frame, "modulate:a", 1.0, 0.3)
	frame_tween.tween_property(frame, "modulate:a", 0.7, 0.3)
	
	# Hide frame after animation
	frame_tween.tween_callback(func(): 
		frame.visible = false
		if current_state == AnimationState.HIGHLIGHTING:
			current_state = AnimationState.ON_DESK
	)

func highlight_all_critical_info():
	"""Highlight all critical information on chart"""
	
	# Start with vital signs
	highlight_vital_signs()
	
	# After delay, highlight labs if abnormal
	var highlight_timer = Timer.new()
	highlight_timer.wait_time = 1.0
	highlight_timer.one_shot = true
	highlight_timer.timeout.connect(func():
		highlight_lab_results()
		highlight_timer.queue_free()
	)
	add_child(highlight_timer)
	highlight_timer.start()
	
	# Add urgency pulse overlay
	start_urgency_pulse()

func highlight_lab_results():
	"""Highlight abnormal lab results"""
	
	highlight_chart_section("LABS")

func start_urgency_pulse():
	"""Start urgency pulse overlay"""
	
	var pulse_overlay = highlight_system.find_child("UrgencyPulse")
	if pulse_overlay:
		pulse_overlay.visible = true
		pulse_overlay.color = Color(MedicalColors.URGENT_RED.r, MedicalColors.URGENT_RED.g, MedicalColors.URGENT_RED.b, 0.0)
		
		var pulse_tween = create_tween()
		pulse_tween.set_loops(4)
		
		pulse_tween.tween_property(pulse_overlay, "color:a", 0.1, 0.5)
		pulse_tween.tween_property(pulse_overlay, "color:a", 0.0, 0.5)
		
		pulse_tween.tween_callback(func(): pulse_overlay.visible = false)

func animate_chart_out():
	"""Animate chart sliding out"""
	
	if not active_chart or current_state == AnimationState.SLIDING_OUT:
		return
	
	current_state = AnimationState.SLIDING_OUT
	chart_interaction_started.emit("chart_slide_out")
	
	# Hide all highlight effects
	hide_all_highlights()
	
	# Play paper slide sound
	if paper_slide_sound:
		paper_slide_sound.play()
	
	# Slide chart out
	active_chart.slide_out_to_right(slide_out_duration)
	
	# Process next animation in queue after delay
	var process_timer = Timer.new()
	process_timer.wait_time = slide_out_duration + 0.2
	process_timer.one_shot = true
	process_timer.timeout.connect(func():
		_on_chart_slide_out_complete()
		process_timer.queue_free()
	)
	add_child(process_timer)
	process_timer.start()

func hide_all_highlights():
	"""Hide all highlight effects"""
	
	# Hide spotlight
	var spotlight = highlight_system.find_child("CriticalSpotlight")
	if spotlight:
		spotlight.visible = false
	
	# Hide pulse overlay
	var pulse_overlay = highlight_system.find_child("UrgencyPulse")
	if pulse_overlay:
		pulse_overlay.visible = false
	
	# Hide section frames
	for child in highlight_system.get_children():
		if "_Frame" in child.name:
			child.visible = false
	
	# Hide priority indicators
	hide_priority_indicators()

func hide_priority_indicators():
	"""Hide priority indicators"""
	
	for child in priority_indicators.get_children():
		child.visible = false

func show_priority_indicators(urgency_level: float):
	"""Show appropriate priority indicators"""
	
	if urgency_level > 0.8:
		# Show critical banner
		var critical_banner = priority_indicators.find_child("CriticalAlertBanner")
		if critical_banner:
			critical_banner.visible = true
	
	if urgency_level > 0.5:
		# Show urgency indicator
		var urgency_indicator = priority_indicators.find_child("UrgencyIndicator")
		if urgency_indicator:
			urgency_indicator.visible = true
			animate_urgency_bars(urgency_level)

func manage_chart_stack(new_chart: PixelArtChart):
	"""Manage multiple charts on desk"""
	
	chart_stack.append(new_chart)
	
	# If too many charts, slide out the oldest
	while chart_stack.size() > max_charts_on_desk:
		var old_chart = chart_stack.pop_front()
		if old_chart and old_chart != active_chart:
			old_chart.slide_out_to_right(slide_out_duration * 0.5)

func update_time_pressure(time_remaining: float, total_time: float):
	"""Update time pressure indicator"""
	
	var time_indicator = priority_indicators.find_child("TimePressureIndicator")
	if not time_indicator:
		return
	
	var pressure_ratio = 1.0 - (time_remaining / total_time)
	
	if pressure_ratio > 0.7:
		time_indicator.visible = true
		
		var pressure_bar = time_indicator.find_child("PressureBar")
		if pressure_bar:
			pressure_bar.value = pressure_ratio
			
			# Update color based on pressure
			var fill_style = pressure_bar.get_theme_stylebox("fill")
			if fill_style is StyleBoxFlat:
				(fill_style as StyleBoxFlat).bg_color = MedicalColors.get_timer_color(time_remaining, total_time)
	else:
		time_indicator.visible = false

# Legacy/compatibility functions
func slide_in_new_chart(chart_data: Dictionary):
	"""Legacy function for chart slide in"""
	animate_chart_in(chart_data)

func slide_out_current_chart():
	"""Legacy function for chart slide out"""
	animate_chart_out()

# Signal handlers

func _on_chart_slide_complete():
	"""Handle chart slide in complete"""
	
	current_state = AnimationState.ON_DESK
	chart_animation_complete.emit()
	chart_slide_in_complete.emit()
	
	# Auto-highlight critical information if high urgency
	if current_chart_urgency > 0.7:
		var highlight_timer = Timer.new()
		highlight_timer.wait_time = 0.5
		highlight_timer.one_shot = true
		highlight_timer.timeout.connect(func():
			highlight_critical_information("all_critical")
			highlight_timer.queue_free()
		)
		add_child(highlight_timer)
		highlight_timer.start()
	
	# Process next animation if queued
	process_animation_queue()

func _on_chart_slide_out_complete():
	"""Handle chart slide out complete"""
	
	current_state = AnimationState.IDLE
	chart_slide_out_complete.emit()
	
	# Clean up active chart
	if active_chart:
		active_chart.queue_free()
		active_chart = null
	
	# Process next animation
	process_animation_queue()

func _on_critical_info_blink():
	"""Handle critical information blink"""
	
	# Additional critical alert effects can go here
	pass

func process_animation_queue():
	"""Process queued animations"""
	
	if animation_queue.is_empty() or current_state != AnimationState.IDLE:
		return
	
	var next_animation = animation_queue.pop_front()
	
	match next_animation.type:
		"slide_in":
			animate_chart_in(
				next_animation.data,
				next_animation.urgency,
				next_animation.wear
			)
		
		"highlight":
			highlight_critical_information(
				next_animation.info_type,
				next_animation.get("section", "")
			)

# Public interface

func queue_chart_animation(patient_data: Dictionary, urgency_level: float = 0.0, wear_level: float = 0.0):
	"""Queue a chart animation"""
	
	if current_state == AnimationState.IDLE:
		animate_chart_in(patient_data, urgency_level, wear_level)
	else:
		animation_queue.append({
			"type": "slide_in",
			"data": patient_data,
			"urgency": urgency_level,
			"wear": wear_level
		})

func force_highlight_critical():
	"""Force highlight of critical information"""
	
	if current_state == AnimationState.ON_DESK:
		highlight_critical_information("all_critical")

func clear_current_chart():
	"""Clear current chart from desk"""
	
	if current_state in [AnimationState.ON_DESK, AnimationState.HIGHLIGHTING]:
		animate_chart_out()

func is_animation_active() -> bool:
	"""Check if any animation is currently active"""
	
	return current_state != AnimationState.IDLE

func get_current_urgency_level() -> float:
	"""Get current chart urgency level"""
	
	return current_chart_urgency

func set_animation_speed(speed_multiplier: float):
	"""Set animation speed (1.0 = normal, 2.0 = double speed)"""
	
	speed_multiplier = clampf(speed_multiplier, 0.1, 3.0)
	
	slide_in_duration = 0.8 / speed_multiplier
	highlight_duration = 1.5 / speed_multiplier
	slide_out_duration = 0.6 / speed_multiplier
	critical_blink_duration = 2.0 / speed_multiplier
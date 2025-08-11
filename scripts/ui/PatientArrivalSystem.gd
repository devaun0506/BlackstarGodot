class_name PatientArrivalSystem
extends Node

## Patient Arrival Animation System for Blackstar
##
## Handles the complete patient arrival experience including chart sliding,
## urgency cues, paper sound effects, and priority highlighting.

signal arrival_sequence_started(patient_data: Dictionary)
signal arrival_sequence_completed()
signal urgency_alert_triggered(urgency_level: float)

# Animation components
@onready var chart_animation: ChartAnimationSystem
@onready var urgency_overlay: Control
@onready var paper_sound_player: AudioStreamPlayer
@onready var alarm_sound_player: AudioStreamPlayer

# UI elements for arrival sequence
@onready var chart_container: Control
@onready var urgency_indicators: Array[Control] = []
@onready var priority_highlights: Array[Control] = []

# Arrival configuration
@export var base_arrival_duration: float = 2.5
@export var urgency_threshold_warning: float = 0.6
@export var urgency_threshold_critical: float = 0.8

# Current arrival state
var current_patient_data: Dictionary = {}
var current_urgency_level: float = 0.0
var is_arrival_active: bool = false

func _ready() -> void:
	print("PatientArrivalSystem: Initializing patient arrival system")
	setup_arrival_components()

func setup_arrival_components() -> void:
	"""Initialize components for patient arrival animations"""
	
	# Connect to existing chart animation system if available
	if not chart_animation:
		chart_animation = find_child("ChartAnimationSystem", true, false)
		if not chart_animation:
			chart_animation = ChartAnimationSystem.new()
			add_child(chart_animation)
			chart_animation.name = "ChartAnimationSystem"
	
	# Setup audio components
	setup_arrival_audio()
	
	# Setup visual components
	setup_urgency_overlays()
	
	print("PatientArrivalSystem: Components initialized")

func setup_arrival_audio() -> void:
	"""Setup audio components for arrival effects"""
	
	if not paper_sound_player:
		paper_sound_player = AudioStreamPlayer.new()
		paper_sound_player.name = "PaperSoundPlayer"
		add_child(paper_sound_player)
		paper_sound_player.volume_db = -10
	
	if not alarm_sound_player:
		alarm_sound_player = AudioStreamPlayer.new()
		alarm_sound_player.name = "AlarmSoundPlayer"
		add_child(alarm_sound_player)
		alarm_sound_player.volume_db = -8

func setup_urgency_overlays() -> void:
	"""Setup visual urgency indicator overlays"""
	
	if not urgency_overlay:
		urgency_overlay = Control.new()
		urgency_overlay.name = "UrgencyOverlay"
		add_child(urgency_overlay)
		urgency_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func connect_chart_container(container: Control) -> void:
	"""Connect the main chart container for animations"""
	chart_container = container
	
	if chart_animation:
		chart_animation.connect_chart_elements(container, container, container.find_child("VBoxContainer", true, false))

func start_patient_arrival(patient_data: Dictionary) -> void:
	"""Start the complete patient arrival sequence"""
	
	if is_arrival_active:
		print("PatientArrivalSystem: Arrival already in progress, skipping")
		return
	
	is_arrival_active = true
	current_patient_data = patient_data
	current_urgency_level = calculate_patient_urgency(patient_data)
	
	print("PatientArrivalSystem: Starting arrival for patient with urgency %.2f" % current_urgency_level)
	
	arrival_sequence_started.emit(patient_data)
	
	# Execute arrival sequence based on urgency
	execute_arrival_sequence()

func execute_arrival_sequence() -> void:
	"""Execute the complete arrival sequence"""
	
	# Step 1: Pre-arrival preparation
	prepare_arrival_environment()
	
	# Step 2: Chart sliding animation with sound
	await animate_chart_arrival()
	
	# Step 3: Urgency-specific effects
	await apply_urgency_effects()
	
	# Step 4: Priority highlighting
	await highlight_priority_information()
	
	# Step 5: Settle and complete
	await settle_chart()
	
	# Complete arrival sequence
	complete_arrival_sequence()

func prepare_arrival_environment() -> void:
	"""Prepare the environment for patient arrival"""
	
	# Clear any existing urgency indicators
	clear_urgency_indicators()
	
	# Set atmosphere based on urgency
	if current_urgency_level >= urgency_threshold_critical:
		# Critical patient preparation
		trigger_critical_environment()
	elif current_urgency_level >= urgency_threshold_warning:
		# Urgent patient preparation  
		trigger_urgent_environment()

func animate_chart_arrival() -> Awaitable:
	"""Animate the chart sliding onto the desk"""
	
	# Play paper slide sound
	play_paper_sound("slide")
	
	# Start chart slide animation
	if chart_animation:
		chart_animation.slide_in_new_chart(current_patient_data)
		await chart_animation.chart_slide_in_complete
	else:
		# Fallback simple animation
		await animate_simple_chart_arrival()

func animate_simple_chart_arrival() -> Awaitable:
	"""Simple fallback chart arrival animation"""
	
	if not chart_container:
		await get_tree().create_timer(base_arrival_duration).timeout
		return
	
	# Store original position
	var original_pos = chart_container.position
	var viewport_width = get_viewport().size.x
	
	# Start from right side
	chart_container.position.x = viewport_width
	chart_container.modulate.a = 0.8
	
	# Animate sliding in
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.parallel().tween_property(chart_container, "position:x", original_pos.x, base_arrival_duration)
	tween.parallel().tween_property(chart_container, "modulate:a", 1.0, base_arrival_duration * 0.6)
	
	# Add settling bounce
	tween.tween_property(chart_container, "position:x", original_pos.x - 5, 0.1)
	tween.tween_property(chart_container, "position:x", original_pos.x, 0.1)
	
	await tween.finished

func apply_urgency_effects() -> Awaitable:
	"""Apply urgency-specific visual and audio effects"""
	
	if current_urgency_level >= urgency_threshold_critical:
		await apply_critical_effects()
	elif current_urgency_level >= urgency_threshold_warning:
		await apply_urgent_effects()
	else:
		await apply_routine_effects()

func apply_critical_effects() -> Awaitable:
	"""Apply effects for critical urgency patients"""
	
	print("PatientArrivalSystem: Applying critical urgency effects")
	
	urgency_alert_triggered.emit(current_urgency_level)
	
	# Play alarm sound
	play_alarm_sound("critical")
	
	# Red pulsing overlay
	await create_urgency_pulse(MedicalColors.URGENT_RED, 1.0, 3)
	
	# Chart animation for critical alert
	if chart_animation:
		chart_animation.animate_critical_alert()

func apply_urgent_effects() -> Awaitable:
	"""Apply effects for urgent patients"""
	
	print("PatientArrivalSystem: Applying urgent effects")
	
	urgency_alert_triggered.emit(current_urgency_level)
	
	# Orange/yellow pulsing
	await create_urgency_pulse(MedicalColors.URGENT_ORANGE, 0.7, 2)
	
	# Quick paper rustle
	play_paper_sound("rustle")

func apply_routine_effects() -> Awaitable:
	"""Apply effects for routine patients"""
	
	print("PatientArrivalSystem: Applying routine effects")
	
	# Subtle paper settling sound
	play_paper_sound("settle")
	
	# Brief pause for natural pacing
	await get_tree().create_timer(0.3).timeout

func create_urgency_pulse(color: Color, intensity: float, pulse_count: int) -> Awaitable:
	"""Create urgency pulsing overlay effect"""
	
	if not urgency_overlay:
		return
	
	# Create pulsing overlay
	var pulse_rect = ColorRect.new()
	pulse_rect.color = Color(color.r, color.g, color.b, 0.0)
	urgency_overlay.add_child(pulse_rect)
	pulse_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Pulse animation
	var pulse_tween = create_tween()
	pulse_tween.set_loops(pulse_count)
	
	var max_alpha = intensity * 0.3
	
	pulse_tween.tween_property(pulse_rect, "color:a", max_alpha, 0.3)
	pulse_tween.tween_property(pulse_rect, "color:a", 0.0, 0.3)
	
	await pulse_tween.finished
	
	pulse_rect.queue_free()

func highlight_priority_information() -> Awaitable:
	"""Highlight critical patient information"""
	
	var priority_elements = identify_priority_elements()
	
	if priority_elements.is_empty():
		await get_tree().create_timer(0.1).timeout
		return
	
	print("PatientArrivalSystem: Highlighting %d priority elements" % priority_elements.size())
	
	# Use chart animation system if available
	if chart_animation:
		chart_animation.highlight_priority_information(priority_elements)
		await chart_animation.priority_highlight_complete
	else:
		# Fallback highlighting
		await highlight_elements_simple(priority_elements)

func identify_priority_elements() -> Array[String]:
	"""Identify which patient information elements should be highlighted"""
	
	var priority_elements: Array[String] = []
	
	# Check vitals for critical values
	if current_patient_data.has("vitals"):
		var vitals = current_patient_data.vitals
		
		# High heart rate
		if vitals.has("HR"):
			var hr = parse_vital_value(str(vitals.HR))
			if hr > 120:
				priority_elements.append("HR")
		
		# Low oxygen saturation
		if vitals.has("O2Sat"):
			var o2_sat = parse_vital_value(str(vitals.O2Sat))
			if o2_sat < 95:
				priority_elements.append("O2Sat")
		
		# High temperature
		if vitals.has("Temp"):
			var temp_str = str(vitals.Temp)
			if "°C" in temp_str:
				var temp = parse_vital_value(temp_str)
				if temp > 38.5:  # High fever
					priority_elements.append("Temp")
	
	# Check for urgent keywords in presentation
	var presentation = current_patient_data.get("presentation", "").to_lower()
	var urgent_keywords = ["chest pain", "shortness of breath", "unconscious", "bleeding"]
	
	for keyword in urgent_keywords:
		if keyword in presentation:
			priority_elements.append("presentation")
			break
	
	return priority_elements

func highlight_elements_simple(element_paths: Array[String]) -> Awaitable:
	"""Simple fallback element highlighting"""
	
	# Create highlight effects for each element
	for element_path in element_paths:
		create_element_highlight(element_path)
	
	await get_tree().create_timer(0.8).timeout

func create_element_highlight(element_path: String) -> void:
	"""Create highlight effect for a specific element"""
	
	# This would find and highlight actual UI elements
	# For now, just create a visual effect
	
	var highlight = ColorRect.new()
	highlight.color = Color(MedicalColors.URGENT_YELLOW.r, MedicalColors.URGENT_YELLOW.g, 
							MedicalColors.URGENT_YELLOW.b, 0.0)
	
	if urgency_overlay:
		urgency_overlay.add_child(highlight)
		highlight.size = Vector2(200, 30)
		highlight.position = Vector2(randf_range(50, 300), randf_range(100, 400))
		
		# Animate highlight
		var tween = create_tween()
		tween.tween_property(highlight, "color:a", 0.4, 0.2)
		tween.tween_delay(0.4)
		tween.tween_property(highlight, "color:a", 0.0, 0.2)
		tween.tween_callback(highlight.queue_free)

func settle_chart() -> Awaitable:
	"""Final chart settling animation"""
	
	# Play subtle paper settle sound
	play_paper_sound("settle")
	
	# Subtle chart settling movement
	if chart_container:
		var settle_tween = create_tween()
		settle_tween.set_ease(Tween.EASE_OUT)
		settle_tween.set_trans(Tween.TRANS_BOUNCE)
		
		var original_pos = chart_container.position
		settle_tween.tween_property(chart_container, "position:y", original_pos.y + 2, 0.2)
		settle_tween.tween_property(chart_container, "position:y", original_pos.y, 0.3)
		
		await settle_tween.finished
	else:
		await get_tree().create_timer(0.5).timeout

func complete_arrival_sequence() -> void:
	"""Complete the patient arrival sequence"""
	
	is_arrival_active = false
	
	print("PatientArrivalSystem: Arrival sequence completed")
	arrival_sequence_completed.emit()

# Audio effect methods
func play_paper_sound(sound_type: String) -> void:
	"""Play paper-related sound effects"""
	
	if not paper_sound_player:
		return
	
	# Adjust sound properties based on type
	match sound_type:
		"slide":
			paper_sound_player.pitch_scale = 1.0
			paper_sound_player.volume_db = -10
		"rustle":
			paper_sound_player.pitch_scale = 1.2
			paper_sound_player.volume_db = -15
		"settle":
			paper_sound_player.pitch_scale = 0.8
			paper_sound_player.volume_db = -18
	
	# Play sound (would use actual audio file)
	paper_sound_player.play()
	print("PatientArrivalSystem: Playing paper sound - %s" % sound_type)

func play_alarm_sound(alarm_type: String) -> void:
	"""Play medical alarm sound"""
	
	if not alarm_sound_player:
		return
	
	match alarm_type:
		"critical":
			alarm_sound_player.pitch_scale = 1.0
			alarm_sound_player.volume_db = -8
		"urgent":
			alarm_sound_player.pitch_scale = 0.9
			alarm_sound_player.volume_db = -12
	
	alarm_sound_player.play()
	print("PatientArrivalSystem: Playing alarm sound - %s" % alarm_type)

# Environment effect methods
func trigger_critical_environment() -> void:
	"""Trigger critical patient environment effects"""
	
	# This would trigger:
	# - Red lighting tints
	# - Faster equipment beeping
	# - More urgent background activity
	print("PatientArrivalSystem: Critical environment triggered")

func trigger_urgent_environment() -> void:
	"""Trigger urgent patient environment effects"""
	
	# This would trigger:
	# - Yellow/orange lighting tints
	# - Elevated equipment activity
	# - Increased background sounds
	print("PatientArrivalSystem: Urgent environment triggered")

# Utility methods
func calculate_patient_urgency(patient_data: Dictionary) -> float:
	"""Calculate patient urgency level (0.0 = routine, 1.0 = critical)"""
	
	var urgency = 0.0
	
	# Check vital signs
	if patient_data.has("vitals"):
		var vitals = patient_data.vitals
		
		# Heart rate
		if vitals.has("HR"):
			var hr = parse_vital_value(str(vitals.HR))
			if hr > 120:
				urgency += 0.3
			elif hr > 100:
				urgency += 0.1
		
		# Oxygen saturation
		if vitals.has("O2Sat"):
			var o2_sat = parse_vital_value(str(vitals.O2Sat))
			if o2_sat < 90:
				urgency += 0.4
			elif o2_sat < 95:
				urgency += 0.2
		
		# Temperature
		if vitals.has("Temp"):
			var temp = parse_vital_value(str(vitals.Temp))
			if temp > 39.0:  # High fever
				urgency += 0.2
	
	# Check presentation for urgent keywords
	var presentation = patient_data.get("presentation", "").to_lower()
	var urgent_keywords = ["chest pain", "shortness of breath", "unconscious", "trauma", "bleeding", "severe"]
	
	for keyword in urgent_keywords:
		if keyword in presentation:
			urgency += 0.2
			break
	
	return clamp(urgency, 0.0, 1.0)

func parse_vital_value(vital_string: String) -> float:
	"""Parse numeric value from vital sign string"""
	var regex = RegEx.new()
	regex.compile(r"\d+\.?\d*")
	var result = regex.search(vital_string)
	if result:
		return result.get_string().to_float()
	return 0.0

func clear_urgency_indicators() -> void:
	"""Clear all active urgency indicators"""
	
	if urgency_overlay:
		for child in urgency_overlay.get_children():
			child.queue_free()

# Public interface
func get_current_urgency_level() -> float:
	"""Get the current patient's urgency level"""
	return current_urgency_level

func is_arrival_in_progress() -> bool:
	"""Check if arrival sequence is currently active"""
	return is_arrival_active

func skip_arrival_sequence() -> void:
	"""Skip the current arrival sequence (for testing/debugging)"""
	if is_arrival_active:
		print("PatientArrivalSystem: Skipping arrival sequence")
		complete_arrival_sequence()
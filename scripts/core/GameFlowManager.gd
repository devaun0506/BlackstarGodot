extends Node
## Game Flow Manager for Blackstar
##
## Orchestrates the complete game experience including scene transitions,
## medical atmosphere, and proper pacing for emergency department simulation.

signal scene_transition_started(scene_type: String)
signal scene_transition_completed(scene_type: String)
signal atmosphere_changed(atmosphere_type: String)

# Scene states
enum GameFlowState {
	SHIFT_START,      # Brief intro with goals/time
	PATIENT_ARRIVAL,  # Chart slides in with urgency cues
	ASSESSMENT,       # Main question/answer phase
	FEEDBACK,         # Immediate response to answer
	BETWEEN_PATIENTS, # Brief breather/story moment
	SHIFT_END         # Wrap up and results
}

# Current game state
var current_state: GameFlowState = GameFlowState.SHIFT_START
var state_timer: float = 0.0
var state_duration: float = 0.0

# Scene components
@onready var chart_animation: ChartAnimationSystem
@onready var story_manager: StorySystem
@onready var atmosphere_controller: AtmosphereController

# Flow configuration
@export var shift_start_duration: float = 4.0
@export var patient_arrival_duration: float = 2.5
@export var feedback_duration: float = 6.0
@export var between_patients_duration: float = 2.0

# Medical context
var current_urgency_level: float = 0.0
var coffee_momentum: float = 0.0
var atmosphere_intensity: float = 0.0

func _ready() -> void:
	print("GameFlowManager: Initializing game flow system")
	setup_scene_components()
	connect_signals()

func setup_scene_components() -> void:
	"""Initialize game flow scene components"""
	
	# Create chart animation system if not present
	if not chart_animation:
		chart_animation = ChartAnimationSystem.new()
		add_child(chart_animation)
		chart_animation.name = "ChartAnimationSystem"
		print("GameFlowManager: Created ChartAnimationSystem")
	
	# Story manager will be created later
	# Atmosphere controller will be created later

func connect_signals() -> void:
	"""Connect to relevant game system signals"""
	
	# Connect to ShiftManager signals
	if ShiftManager:
		if ShiftManager.has_signal("shift_started"):
			if not ShiftManager.shift_started.is_connected(_on_shift_started):
				ShiftManager.shift_started.connect(_on_shift_started)
		
		if ShiftManager.has_signal("patient_completed"):
			if not ShiftManager.patient_completed.is_connected(_on_patient_loaded):
				ShiftManager.patient_completed.connect(_on_patient_loaded)
		
		if ShiftManager.has_signal("shift_ended"):
			if not ShiftManager.shift_ended.is_connected(_on_shift_ended):
				ShiftManager.shift_ended.connect(_on_shift_ended)
	
	# Connect chart animation signals
	if chart_animation:
		chart_animation.chart_slide_in_complete.connect(_on_chart_slide_in_complete)
		chart_animation.chart_slide_out_complete.connect(_on_chart_slide_out_complete)

func _process(delta: float) -> void:
	"""Update game flow state timing"""
	
	if state_duration > 0:
		state_timer += delta
		
		# Handle automatic state transitions
		if state_timer >= state_duration:
			_advance_to_next_state()

func start_shift_sequence() -> void:
	"""Begin the shift start sequence"""
	print("GameFlowManager: Starting shift sequence")
	
	transition_to_state(GameFlowState.SHIFT_START)
	
	# Show shift introduction
	display_shift_introduction()

func transition_to_state(new_state: GameFlowState) -> void:
	"""Transition to a new game flow state"""
	
	var old_state = current_state
	current_state = new_state
	state_timer = 0.0
	
	# Set state duration based on state type
	match new_state:
		GameFlowState.SHIFT_START:
			state_duration = shift_start_duration
		GameFlowState.PATIENT_ARRIVAL:
			state_duration = patient_arrival_duration
		GameFlowState.ASSESSMENT:
			state_duration = 0.0  # Player controlled timing
		GameFlowState.FEEDBACK:
			state_duration = feedback_duration
		GameFlowState.BETWEEN_PATIENTS:
			state_duration = between_patients_duration
		GameFlowState.SHIFT_END:
			state_duration = 0.0  # Manual control
	
	print("GameFlowManager: Transitioned from %s to %s" % [
		GameFlowState.keys()[old_state], 
		GameFlowState.keys()[new_state]
	])
	
	scene_transition_started.emit(GameFlowState.keys()[new_state])
	
	# Execute state-specific logic
	_execute_state_logic(new_state)

func _execute_state_logic(state: GameFlowState) -> void:
	"""Execute logic specific to each game flow state"""
	
	match state:
		GameFlowState.SHIFT_START:
			_execute_shift_start_logic()
		GameFlowState.PATIENT_ARRIVAL:
			_execute_patient_arrival_logic()
		GameFlowState.ASSESSMENT:
			_execute_assessment_logic()
		GameFlowState.FEEDBACK:
			_execute_feedback_logic()
		GameFlowState.BETWEEN_PATIENTS:
			_execute_between_patients_logic()
		GameFlowState.SHIFT_END:
			_execute_shift_end_logic()

func _execute_shift_start_logic() -> void:
	"""Execute shift start sequence logic"""
	print("GameFlowManager: Executing shift start sequence")
	
	# Update atmosphere for shift beginning
	update_medical_atmosphere("shift_start", 0.2)
	
	# TODO: Display shift goals, time/date, story snippet

func _execute_patient_arrival_logic() -> void:
	"""Execute patient arrival sequence logic"""
	print("GameFlowManager: Executing patient arrival sequence")
	
	if not ShiftManager:
		print("GameFlowManager: ShiftManager not available for patient arrival")
		return
	
	var patient_data = ShiftManager.get_current_patient()
	if patient_data.is_empty():
		print("GameFlowManager: No patient data for arrival sequence")
		return
	
	# Calculate urgency level from patient data
	current_urgency_level = calculate_patient_urgency(patient_data)
	
	# Update atmosphere based on patient urgency
	var atmosphere_type = "routine"
	if current_urgency_level > 0.8:
		atmosphere_type = "critical"
	elif current_urgency_level > 0.5:
		atmosphere_type = "urgent"
	
	update_medical_atmosphere(atmosphere_type, current_urgency_level)
	
	# Animate chart sliding in
	if chart_animation:
		chart_animation.slide_in_new_chart(patient_data)
		
		# Add urgency effects if needed
		if current_urgency_level > 0.7:
			chart_animation.animate_critical_alert()

func _execute_assessment_logic() -> void:
	"""Execute assessment phase logic"""
	print("GameFlowManager: Executing assessment phase")
	
	# Assessment phase is player-controlled timing
	# Just ensure UI is ready for interaction
	
	# Update coffee momentum (decreases during assessment)
	coffee_momentum = max(0.0, coffee_momentum - 0.1)

func _execute_feedback_logic() -> void:
	"""Execute feedback sequence logic"""
	print("GameFlowManager: Executing feedback sequence")
	
	# TODO: Show patient outcome animation
	# TODO: Display explanation if needed
	# TODO: Update score display with animation

func _execute_between_patients_logic() -> void:
	"""Execute between patients sequence logic"""
	print("GameFlowManager: Executing between patients sequence")
	
	# Increase coffee momentum (brief break)
	coffee_momentum = min(1.0, coffee_momentum + 0.15)
	
	# Update atmosphere to calmer state
	update_medical_atmosphere("between_patients", 0.3)
	
	# TODO: Show story moments every few patients
	# TODO: Display coffee cup animation

func _execute_shift_end_logic() -> void:
	"""Execute shift end sequence logic"""
	print("GameFlowManager: Executing shift end sequence")
	
	# Update atmosphere for shift completion
	update_medical_atmosphere("shift_end", 0.1)

func _advance_to_next_state() -> void:
	"""Automatically advance to the next appropriate state"""
	
	match current_state:
		GameFlowState.SHIFT_START:
			# After shift start, wait for first patient
			if ShiftManager and ShiftManager.current_shift_active:
				# ShiftManager will trigger patient arrival
				pass
		GameFlowState.PATIENT_ARRIVAL:
			transition_to_state(GameFlowState.ASSESSMENT)
		GameFlowState.FEEDBACK:
			transition_to_state(GameFlowState.BETWEEN_PATIENTS)
		GameFlowState.BETWEEN_PATIENTS:
			# Between patients automatically loads next patient
			if ShiftManager and ShiftManager.current_shift_active:
				ShiftManager.load_next_patient()

func display_shift_introduction() -> void:
	"""Display shift start information"""
	
	if not ShiftManager:
		return
	
	var shift_info = {
		"time": "11:47 PM",
		"date": "October 15th",
		"goals": "Maintain >75% accuracy, 10 patients",
		"story_snippet": "The emergency department hums with quiet efficiency..."
	}
	
	print("=== SHIFT START ===")
	print("Time: %s - %s" % [shift_info.time, shift_info.date])
	print("Goals: %s" % shift_info.goals)
	print("Story: %s" % shift_info.story_snippet)
	print("==================")

func calculate_patient_urgency(patient_data: Dictionary) -> float:
	"""Calculate urgency level from patient data (0.0 = routine, 1.0 = critical)"""
	
	var urgency = 0.0
	
	# Check vital signs if available
	if patient_data.has("vitals"):
		var vitals = patient_data.vitals
		
		# High heart rate increases urgency
		if vitals.has("HR"):
			var hr = parse_vital_value(vitals.HR)
			if hr > 120:
				urgency += 0.3
			elif hr > 100:
				urgency += 0.1
		
		# Low oxygen saturation increases urgency
		if vitals.has("O2Sat"):
			var o2_sat = parse_vital_value(vitals.O2Sat)
			if o2_sat < 90:
				urgency += 0.4
			elif o2_sat < 95:
				urgency += 0.2
	
	# Check for emergency keywords in presentation
	var presentation = patient_data.get("presentation", "").to_lower()
	var urgent_keywords = ["chest pain", "shortness of breath", "unconscious", "trauma", "bleeding"]
	
	for keyword in urgent_keywords:
		if keyword in presentation:
			urgency += 0.2
			break
	
	# Check question type for inherent urgency
	var question = patient_data.get("question", "").to_lower()
	if "emergency" in question or "immediate" in question or "urgent" in question:
		urgency += 0.1
	
	return clamp(urgency, 0.0, 1.0)

func parse_vital_value(vital_string: String) -> float:
	"""Parse numeric value from vital sign string"""
	var regex = RegEx.new()
	regex.compile(r"\d+\.?\d*")
	var result = regex.search(vital_string)
	if result:
		return result.get_string().to_float()
	return 0.0

func update_medical_atmosphere(atmosphere_type: String, intensity: float) -> void:
	"""Update the medical atmosphere of the scene"""
	
	atmosphere_intensity = intensity
	print("GameFlowManager: Setting atmosphere to %s (intensity: %.2f)" % [atmosphere_type, intensity])
	
	atmosphere_changed.emit(atmosphere_type)
	
	# TODO: Implement actual atmosphere changes
	# - Lighting adjustments
	# - Ambient sound changes  
	# - Equipment monitor beeping
	# - Background activity

func get_coffee_momentum() -> float:
	"""Get current coffee momentum level (0.0 to 1.0)"""
	return coffee_momentum

func get_current_urgency() -> float:
	"""Get current patient urgency level"""
	return current_urgency_level

func handle_answer_submitted(is_correct: bool) -> void:
	"""Handle when player submits an answer"""
	print("GameFlowManager: Answer submitted (correct: %s)" % is_correct)
	
	# Transition from assessment to feedback
	if current_state == GameFlowState.ASSESSMENT:
		transition_to_state(GameFlowState.FEEDBACK)
	
	# Update coffee momentum based on performance
	if is_correct:
		coffee_momentum = min(1.0, coffee_momentum + 0.05)
	else:
		coffee_momentum = max(0.0, coffee_momentum - 0.1)

# Signal callbacks
func _on_shift_started() -> void:
	"""Handle shift started signal"""
	print("GameFlowManager: Received shift started signal")
	start_shift_sequence()

func _on_patient_loaded() -> void:
	"""Handle patient loaded signal"""
	print("GameFlowManager: Received patient loaded signal")
	
	if current_state == GameFlowState.SHIFT_START or current_state == GameFlowState.BETWEEN_PATIENTS:
		transition_to_state(GameFlowState.PATIENT_ARRIVAL)

func _on_shift_ended() -> void:
	"""Handle shift ended signal"""
	print("GameFlowManager: Received shift ended signal")
	transition_to_state(GameFlowState.SHIFT_END)

func _on_chart_slide_in_complete() -> void:
	"""Handle chart slide in animation completion"""
	print("GameFlowManager: Chart slide in complete")
	
	if current_state == GameFlowState.PATIENT_ARRIVAL:
		# Wait a moment then transition to assessment
		await get_tree().create_timer(0.3).timeout
		transition_to_state(GameFlowState.ASSESSMENT)

func _on_chart_slide_out_complete() -> void:
	"""Handle chart slide out animation completion"""
	print("GameFlowManager: Chart slide out complete")
	
	scene_transition_completed.emit("chart_slide_out")

# Public interface for external systems
func request_state_transition(new_state_name: String) -> bool:
	"""Request transition to a specific state (for external systems)"""
	
	# Convert string to enum
	for i in range(GameFlowState.size()):
		if GameFlowState.keys()[i] == new_state_name.to_upper():
			transition_to_state(i as GameFlowState)
			return true
	
	print("GameFlowManager: Invalid state requested: %s" % new_state_name)
	return false

func get_current_state_name() -> String:
	"""Get current state as string"""
	return GameFlowState.keys()[current_state]

func is_in_assessment_phase() -> bool:
	"""Check if currently in assessment phase"""
	return current_state == GameFlowState.ASSESSMENT

func skip_current_state() -> void:
	"""Skip current timed state (for debugging/testing)"""
	if state_duration > 0:
		state_timer = state_duration
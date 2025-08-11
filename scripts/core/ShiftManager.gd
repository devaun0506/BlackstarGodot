extends Node
## Manages the flow of medical shifts in Blackstar
##
## The ShiftManager handles the overall game state, patient progression,
## timing, and scoring throughout a medical shift.

signal shift_started
signal shift_ended
signal patient_completed
signal score_updated

# Shift settings
@export var shift_duration: float = 480.0  # 8 minutes in seconds
@export var patients_per_shift: int = 10

# Current shift state
var current_shift_active: bool = false
var current_patient_index: int = 0
var patients_treated: int = 0
var correct_diagnoses: int = 0
var current_patient_data: Dictionary = {}
var shift_start_time: float
var shift_time_remaining: float

# Patient queue
var patient_queue: Array[Dictionary] = []

func _ready() -> void:
	# Connect to other autoload signals with error handling
	call_deferred("_connect_autoload_signals")

func _connect_autoload_signals() -> void:
	"""Connect to other autoload signals after all autoloads are ready"""
	if PatientLoader and PatientLoader.has_signal("patient_loaded"):
		if not PatientLoader.patient_loaded.is_connected(_on_patient_loaded):
			PatientLoader.patient_loaded.connect(_on_patient_loaded)
			print("ShiftManager: Connected to PatientLoader.patient_loaded signal")
	else:
		push_warning("ShiftManager: PatientLoader or patient_loaded signal not available")
	
	if TimerSystem and TimerSystem.has_signal("time_updated"):
		if not TimerSystem.time_updated.is_connected(_on_time_updated):
			TimerSystem.time_updated.connect(_on_time_updated)
			print("ShiftManager: Connected to TimerSystem.time_updated signal")
	else:
		push_warning("ShiftManager: TimerSystem or time_updated signal not available")
	
	if TimerSystem and TimerSystem.has_signal("time_expired"):
		if not TimerSystem.time_expired.is_connected(_on_shift_time_expired):
			TimerSystem.time_expired.connect(_on_shift_time_expired)
			print("ShiftManager: Connected to TimerSystem.time_expired signal")
	else:
		push_warning("ShiftManager: TimerSystem or time_expired signal not available")

func start_new_shift() -> void:
	"""Initialize and start a new medical shift"""
	print("Starting new shift...")
	
	# Reset shift data
	current_shift_active = true
	current_patient_index = -1  # Start at -1 so first load_next_patient goes to 0
	patients_treated = 0
	correct_diagnoses = 0
	shift_start_time = Time.get_ticks_msec() / 1000.0
	shift_time_remaining = shift_duration
	
	# Load patient queue
	if PatientLoader:
		patient_queue = PatientLoader.load_patient_queue(patients_per_shift)
	else:
		print("ShiftManager: PatientLoader not available")
		return
	
	# Start the timer
	if TimerSystem:
		TimerSystem.start_shift_timer(shift_duration)
	else:
		print("ShiftManager: TimerSystem not available")
		return
	
	# Emit shift started first, then load patient after scene is ready
	shift_started.emit()
	
	# Wait for scenes to connect before loading first patient
	await get_tree().create_timer(0.1).timeout
	load_next_patient()

func load_next_patient() -> void:
	"""Load the next patient in the queue"""
	# Advance to next patient
	current_patient_index += 1
	
	# Check if we have more patients and time remaining
	if current_patient_index >= patient_queue.size() or patients_treated >= patients_per_shift or shift_time_remaining <= 0:
		end_shift()
		return
	
	current_patient_data = patient_queue[current_patient_index]
	print("Loading patient %d: %s" % [current_patient_index + 1, current_patient_data.get("name", "Unknown")])
	
	# Notify systems that new patient is ready
	patient_completed.emit()

func submit_diagnosis(selected_answer: String) -> bool:
	"""Process a submitted diagnosis and return if correct"""
	if not current_shift_active:
		return false
	
	var correct_answer = _get_correct_answer_from_patient_data()
	var is_correct = selected_answer == correct_answer
	
	if is_correct:
		correct_diagnoses += 1
		print("Correct diagnosis!")
	else:
		print("Incorrect diagnosis. Correct answer was: ", correct_answer)
	
	# Update statistics
	patients_treated += 1
	score_updated.emit()
	
	return is_correct

func end_shift() -> void:
	"""End the current shift and calculate results"""
	if not current_shift_active:
		return
	
	print("Ending shift...")
	current_shift_active = false
	
	# Stop timer
	if TimerSystem and TimerSystem.has_method("stop_timer"):
		TimerSystem.stop_timer()
	else:
		push_warning("ShiftManager: TimerSystem not available for stop_timer")
	
	# Calculate final statistics
	var accuracy = 0.0
	if patients_treated > 0:
		accuracy = (float(correct_diagnoses) / float(patients_treated)) * 100.0
	
	print("Shift complete! Patients treated: %d, Correct: %d, Accuracy: %.1f%%" % [patients_treated, correct_diagnoses, accuracy])
	
	shift_ended.emit()

func get_current_patient() -> Dictionary:
	"""Get the current patient data"""
	return current_patient_data

func get_shift_statistics() -> Dictionary:
	"""Get current shift statistics"""
	var accuracy = 0.0
	if patients_treated > 0:
		accuracy = (float(correct_diagnoses) / float(patients_treated)) * 100.0
	
	return {
		"patients_treated": patients_treated,
		"correct_diagnoses": correct_diagnoses,
		"accuracy": accuracy,
		"time_remaining": shift_time_remaining,
		"shift_active": current_shift_active
	}

func pause_shift() -> void:
	"""Pause the current shift"""
	if current_shift_active:
		if TimerSystem and TimerSystem.has_method("pause_timer"):
			TimerSystem.pause_timer()
		else:
			push_warning("ShiftManager: TimerSystem not available for pause_timer")

func resume_shift() -> void:
	"""Resume a paused shift"""
	if current_shift_active:
		if TimerSystem and TimerSystem.has_method("resume_timer"):
			TimerSystem.resume_timer()
		else:
			push_warning("ShiftManager: TimerSystem not available for resume_timer")

# Signal callbacks
func _on_patient_loaded(patient_data: Dictionary) -> void:
	"""Handle patient data being loaded"""
	current_patient_data = patient_data

func _on_time_updated(time_remaining: float) -> void:
	"""Handle timer updates"""
	shift_time_remaining = time_remaining

func _on_shift_time_expired() -> void:
	"""Handle shift timer expiration"""
	print("Shift time expired!")
	end_shift()

func _get_correct_answer_from_patient_data() -> String:
	"""Get the correct answer from patient data, handling both old and new formats"""
	# Handle new format with choices
	if current_patient_data.has("choices"):
		var choices = current_patient_data.get("choices", [])
		for choice in choices:
			if choice.has("correct") and choice.get("correct", false):
				return choice.get("id", "")
	
	# Handle old format with correct_answer field
	return current_patient_data.get("correct_answer", "")
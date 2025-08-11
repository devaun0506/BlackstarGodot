extends Control
## Enhanced Game Scene Controller for Blackstar
##
## Orchestrates the complete medical emergency department experience with
## proper scene transitions, medical atmosphere, and immersive story integration.

@onready var patient_info = %PatientInfo
@onready var question_area = %QuestionArea
@onready var timer_label = %Timer
@onready var answer_buttons = %AnswerButtons
@onready var next_button = %NextButton

@onready var answer_a = %AnswerA
@onready var answer_b = %AnswerB
@onready var answer_c = %AnswerC
@onready var answer_d = %AnswerD
@onready var answer_e = %AnswerE

# Enhanced game systems
var question_controller: Node
var game_flow_manager: GameFlowManager
var atmosphere_controller: AtmosphereController
var patient_arrival_system: PatientArrivalSystem
var assessment_phase_ui: AssessmentPhaseUI
var between_patients_ui: BetweenPatientsUI
var shift_intro_ui: ShiftIntroUI
var story_system: StorySystem

# New pixel art UI systems
var pixel_environment: PixelArtEnvironment
var chart_animation_system: ChartAnimationSystem  
var character_portraits: PixelArtCharacters
var medical_equipment_ui: MedicalEquipmentUI

# UI state
var buttons_enabled: bool = true
var current_game_phase: String = "initializing"

func _ready() -> void:
	print("GameScene: Loading enhanced medical emergency department interface")
	
	# Initialize core systems
	initialize_game_systems()
	
	# Initialize pixel art UI systems
	initialize_pixel_art_systems()
	
	# Wait for autoloads to be ready
	await get_tree().process_frame
	
	# Connect to autoloaded signals with error handling
	connect_autoload_signals()
	
	# Connect enhanced system signals
	connect_enhanced_system_signals()
	
	# Connect pixel art system signals
	connect_pixel_art_signals()
	
	# Connect traditional UI elements
	connect_traditional_ui()
	
	# Validate essential UI elements
	_validate_ui_elements()
	
	# Initialize game flow
	initialize_game_flow()

func initialize_game_systems() -> void:
	"""Initialize all enhanced game systems"""
	
	# Create question controller instance
	question_controller = preload("res://scripts/systems/QuestionController.gd").new()
	add_child(question_controller)
	
	# Create game flow manager
	game_flow_manager = preload("res://scripts/core/GameFlowManager.gd").new()
	add_child(game_flow_manager)
	game_flow_manager.name = "GameFlowManager"
	
	# Create atmosphere controller
	atmosphere_controller = preload("res://scripts/systems/AtmosphereController.gd").new()
	add_child(atmosphere_controller)
	atmosphere_controller.name = "AtmosphereController"
	
	# Create patient arrival system
	patient_arrival_system = preload("res://scripts/ui/PatientArrivalSystem.gd").new()
	add_child(patient_arrival_system)
	patient_arrival_system.name = "PatientArrivalSystem"
	
	# Create story system
	story_system = preload("res://scripts/systems/StorySystem.gd").new()
	add_child(story_system)
	story_system.name = "StorySystem"
	
	# Create UI overlays
	create_ui_overlays()
	
	print("GameScene: Enhanced game systems initialized")

func initialize_pixel_art_systems() -> void:
	"""Initialize pixel art UI systems for immersive medical atmosphere"""
	
	print("GameScene: Initializing pixel art medical interface systems")
	
	# Create pixel art hospital environment
	pixel_environment = PixelArtEnvironment.new()
	pixel_environment.name = "PixelEnvironment"
	pixel_environment.size = get_viewport().size
	add_child(pixel_environment)
	# Move environment to back
	move_child(pixel_environment, 0)
	
	# Create chart animation system
	chart_animation_system = ChartAnimationSystem.new()
	chart_animation_system.name = "ChartAnimationSystem"
	chart_animation_system.size = get_viewport().size
	add_child(chart_animation_system)
	
	# Create character portrait system
	character_portraits = PixelArtCharacters.new()
	character_portraits.name = "CharacterPortraits"
	character_portraits.size = get_viewport().size
	add_child(character_portraits)
	
	# Create medical equipment UI
	medical_equipment_ui = MedicalEquipmentUI.new()
	medical_equipment_ui.name = "MedicalEquipmentUI"
	medical_equipment_ui.size = get_viewport().size
	add_child(medical_equipment_ui)
	# Move equipment UI to front
	move_child(medical_equipment_ui, get_child_count() - 1)
	
	print("GameScene: Pixel art systems initialized")

func create_ui_overlays() -> void:
	"""Create overlay UI systems"""
	
	# Shift introduction overlay
	shift_intro_ui = preload("res://scripts/ui/ShiftIntroUI.gd").new()
	add_child(shift_intro_ui)
	shift_intro_ui.name = "ShiftIntroUI"
	
	# Between patients overlay
	between_patients_ui = preload("res://scripts/ui/BetweenPatientsUI.gd").new()
	add_child(between_patients_ui)
	between_patients_ui.name = "BetweenPatientsUI"
	
	print("GameScene: UI overlays created")

func connect_autoload_signals() -> void:
	"""Connect to autoload system signals"""
	
	if ShiftManager:
		if ShiftManager.has_signal("patient_completed"):
			if not ShiftManager.patient_completed.is_connected(_on_patient_completed):
				ShiftManager.patient_completed.connect(_on_patient_completed)
				print("GameScene: Connected to ShiftManager.patient_completed signal")
		else:
			push_warning("GameScene: ShiftManager.patient_completed signal not available")
		
		if ShiftManager.has_signal("shift_ended"):
			if not ShiftManager.shift_ended.is_connected(_on_shift_ended):
				ShiftManager.shift_ended.connect(_on_shift_ended)
				print("GameScene: Connected to ShiftManager.shift_ended signal")
		else:
			push_warning("GameScene: ShiftManager.shift_ended signal not available")
		
		if ShiftManager.has_signal("score_updated"):
			if not ShiftManager.score_updated.is_connected(_on_score_updated):
				ShiftManager.score_updated.connect(_on_score_updated)
				print("GameScene: Connected to ShiftManager.score_updated signal")
		else:
			push_warning("GameScene: ShiftManager.score_updated signal not available")
	else:
		push_warning("GameScene: ShiftManager autoload not available")
	
	if TimerSystem:
		if TimerSystem.has_signal("time_updated"):
			if not TimerSystem.time_updated.is_connected(_on_time_updated):
				TimerSystem.time_updated.connect(_on_time_updated)
				print("GameScene: Connected to TimerSystem.time_updated signal")
		else:
			push_warning("GameScene: TimerSystem.time_updated signal not available")
	else:
		push_warning("GameScene: TimerSystem autoload not available")

func connect_enhanced_system_signals() -> void:
	"""Connect to enhanced game system signals"""
	
	# Game flow manager signals
	if game_flow_manager:
		game_flow_manager.scene_transition_started.connect(_on_scene_transition_started)
		game_flow_manager.scene_transition_completed.connect(_on_scene_transition_completed)
		game_flow_manager.atmosphere_changed.connect(_on_atmosphere_changed)
	
	# Patient arrival system signals
	if patient_arrival_system:
		patient_arrival_system.arrival_sequence_completed.connect(_on_arrival_sequence_completed)
		patient_arrival_system.urgency_alert_triggered.connect(_on_urgency_alert)
		
		# Connect patient arrival to chart container
		if patient_info and patient_info.get_parent():
			patient_arrival_system.connect_chart_container(patient_info.get_parent())
	
	# Between patients UI signals
	if between_patients_ui:
		between_patients_ui.between_patients_completed.connect(_on_between_patients_completed)
		between_patients_ui.story_moment_triggered.connect(_on_story_moment)
	
	# Shift intro UI signals
	if shift_intro_ui:
		shift_intro_ui.intro_completed.connect(_on_shift_intro_completed)
	
	# Story system signals
	if story_system:
		story_system.character_interaction_started.connect(_on_character_interaction)
		story_system.relationship_changed.connect(_on_relationship_changed)
	
	print("GameScene: Enhanced system signals connected")

func connect_pixel_art_signals() -> void:
	"""Connect pixel art UI system signals"""
	
	# Chart animation system signals
	if chart_animation_system:
		chart_animation_system.chart_animation_complete.connect(_on_chart_animation_complete)
		chart_animation_system.critical_information_highlighted.connect(_on_critical_info_highlighted)
		chart_animation_system.chart_interaction_started.connect(_on_chart_interaction)
	
	# Character portrait signals
	if character_portraits:
		character_portraits.character_emotion_changed.connect(_on_character_emotion_changed)
		character_portraits.character_dialogue_triggered.connect(_on_character_dialogue)
	
	# Medical equipment UI signals
	if medical_equipment_ui:
		medical_equipment_ui.timer_warning_triggered.connect(_on_timer_warning)
		medical_equipment_ui.answer_choice_selected.connect(_on_equipment_answer_selected)
		medical_equipment_ui.equipment_malfunction.connect(_on_equipment_malfunction)
	
	# Pixel environment signals
	if pixel_environment:
		pixel_environment.environment_loaded.connect(_on_environment_loaded)
		pixel_environment.lighting_changed.connect(_on_lighting_changed)
		pixel_environment.desk_interaction.connect(_on_desk_interaction)
	
	print("GameScene: Pixel art system signals connected")

func connect_traditional_ui() -> void:
	"""Connect traditional UI elements"""
	
	# Connect question controller signals
	if question_controller:
		question_controller.answer_selected.connect(_on_answer_selected)
		question_controller.question_completed.connect(_on_question_completed)
	
	# Connect button signals with validation
	_connect_answer_buttons()
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
		next_button.disabled = true
	else:
		push_error("GameScene: Next button not found - check scene structure")

func initialize_game_flow() -> void:
	"""Initialize the complete game flow experience"""
	
	current_game_phase = "ready"
	print("GameScene: Enhanced medical emergency department interface ready")

func _connect_answer_buttons() -> void:
	"""Connect answer button signals"""
	if answer_a:
		answer_a.pressed.connect(func(): _on_answer_button_pressed("A"))
	if answer_b:
		answer_b.pressed.connect(func(): _on_answer_button_pressed("B"))
	if answer_c:
		answer_c.pressed.connect(func(): _on_answer_button_pressed("C"))
	if answer_d:
		answer_d.pressed.connect(func(): _on_answer_button_pressed("D"))
	if answer_e:
		answer_e.pressed.connect(func(): _on_answer_button_pressed("E"))

func _validate_ui_elements() -> void:
	"""Validate that essential UI elements are present"""
	var missing_elements = []
	
	if not patient_info:
		missing_elements.append("PatientInfo")
	if not question_area:
		missing_elements.append("QuestionArea")
	if not timer_label:
		missing_elements.append("Timer")
	if not answer_buttons:
		missing_elements.append("AnswerButtons")
	if not next_button:
		missing_elements.append("NextButton")
	
	var answer_buttons_list = [answer_a, answer_b, answer_c, answer_d, answer_e]
	var button_names = ["AnswerA", "AnswerB", "AnswerC", "AnswerD", "AnswerE"]
	for i in range(answer_buttons_list.size()):
		if not answer_buttons_list[i]:
			missing_elements.append(button_names[i])
	
	if missing_elements.size() > 0:
		push_error("GameScene: Missing UI elements: " + str(missing_elements))
		print("GameScene: Game may not function correctly without these UI elements")
	else:
		print("GameScene: All UI elements validated successfully")

func _on_patient_completed() -> void:
	"""Handle new patient being loaded with enhanced experience"""
	if not ShiftManager:
		print("GameScene: ShiftManager not available")
		return
	
	var patient_data = ShiftManager.get_current_patient()
	if patient_data.is_empty():
		print("GameScene: No patient data available")
		return
	
	var patient_name = patient_data.get("name", "Unknown")
	print("GameScene: Processing patient arrival - %s" % patient_name)
	
	# Trigger patient arrival sequence through game flow manager
	if game_flow_manager:
		# This will handle the complete arrival experience
		pass  # Game flow manager handles this via its own signal connections
	
	# Load question data for assessment phase
	if question_controller:
		question_controller.load_question(patient_data)
	
	# Start patient arrival animation sequence
	if patient_arrival_system:
		patient_arrival_system.start_patient_arrival(patient_data)
	else:
		# Fallback to traditional UI update
		_update_patient_info()
		_update_question_display()
	
	# Update pixel art UI systems for immersive experience
	update_pixel_ui_for_patient(patient_data)

func _update_patient_info() -> void:
	"""Update patient information display"""
	if not patient_info or not question_controller:
		return
	
	var formatted_info = question_controller.get_formatted_patient_info()
	patient_info.text = formatted_info

func _update_question_display() -> void:
	"""Update question text display"""
	if not question_area or not question_controller:
		return
	
	var question_text = question_controller.get_current_question_text()
	question_area.text = "[b]Question:[/b]\n" + question_text

func _update_answer_buttons() -> void:
	"""Update answer button text"""
	if not question_controller:
		return
	
	var answers = question_controller.get_formatted_answers()
	var answer_buttons_list = [answer_a, answer_b, answer_c, answer_d, answer_e]
	
	for i in range(min(answers.size(), answer_buttons_list.size())):
		if answer_buttons_list[i]:
			answer_buttons_list[i].text = str(answers[i])
			answer_buttons_list[i].visible = true
	
	# Hide unused buttons
	for i in range(answers.size(), answer_buttons_list.size()):
		if answer_buttons_list[i]:
			answer_buttons_list[i].visible = false

func _reset_button_states() -> void:
	"""Reset answer button states"""
	buttons_enabled = true
	var answer_buttons_list = [answer_a, answer_b, answer_c, answer_d, answer_e]
	
	for button in answer_buttons_list:
		if button:
			button.disabled = false
			button.modulate = Color.WHITE
	
	if next_button:
		next_button.disabled = true

func _on_answer_button_pressed(answer_key: String) -> void:
	"""Handle answer button press with enhanced game flow"""
	if not buttons_enabled or not question_controller:
		return
	
	print("GameScene: Answer button pressed - %s" % answer_key)
	
	# Select the answer
	question_controller.select_answer(answer_key)
	
	# Highlight selected button
	_highlight_selected_answer(answer_key)
	
	# Submit the answer immediately
	var is_correct = question_controller.submit_answer()
	
	# Inform ShiftManager about the diagnosis
	if ShiftManager and ShiftManager.current_shift_active:
		ShiftManager.submit_diagnosis(answer_key)
	
	# Notify game flow manager about answer submission
	if game_flow_manager:
		game_flow_manager.handle_answer_submitted(is_correct)
	
	_on_question_completed(is_correct)

func _highlight_selected_answer(answer_key: String) -> void:
	"""Highlight the selected answer button"""
	var answer_buttons_list = [answer_a, answer_b, answer_c, answer_d, answer_e]
	var keys = ["A", "B", "C", "D", "E"]
	
	for i in range(keys.size()):
		if answer_buttons_list[i]:
			if keys[i] == answer_key:
				answer_buttons_list[i].modulate = Color.YELLOW
			else:
				answer_buttons_list[i].modulate = Color.GRAY

func _on_answer_selected(answer_key: String) -> void:
	"""Handle answer selection"""
	print("Answer selected: %s" % answer_key)

func _on_question_completed(is_correct: bool) -> void:
	"""Handle question completion"""
	print("Question completed. Correct: %s" % is_correct)
	
	# Disable answer buttons
	buttons_enabled = false
	var answer_buttons_list = [answer_a, answer_b, answer_c, answer_d, answer_e]
	for button in answer_buttons_list:
		if button:
			button.disabled = true
	
	# Show correct answer
	_show_correct_answer(is_correct)
	
	# Enable next button
	if next_button:
		next_button.disabled = false
		next_button.grab_focus()

func _show_correct_answer(player_was_correct: bool) -> void:
	"""Highlight the correct answer"""
	if not question_controller:
		return
	
	var correct_answer = question_controller.get_correct_answer()
	var answer_buttons_list = [answer_a, answer_b, answer_c, answer_d, answer_e]
	var keys = ["A", "B", "C", "D", "E"]
	
	for i in range(keys.size()):
		if answer_buttons_list[i] and keys[i] == correct_answer:
			answer_buttons_list[i].modulate = Color.GREEN

func _on_next_pressed() -> void:
	"""Handle next button press"""
	print("Next patient requested")
	
	# Load the next patient through ShiftManager
	if ShiftManager and ShiftManager.current_shift_active:
		ShiftManager.load_next_patient()
	
	if next_button:
		next_button.disabled = true

func _on_time_updated(time_remaining: float) -> void:
	"""Handle timer updates"""
	if timer_label and TimerSystem:
		timer_label.text = "Time: %s" % TimerSystem.format_time(time_remaining)
		
		# Change color based on time remaining
		var warning_level = TimerSystem.get_time_warning_level()
		match warning_level:
			"safe":
				timer_label.modulate = Color.WHITE
			"warning":
				timer_label.modulate = Color.YELLOW
			"critical":
				timer_label.modulate = Color.ORANGE
			"urgent":
				timer_label.modulate = Color.RED

func _on_score_updated() -> void:
	"""Handle score updates"""
	if ShiftManager:
		var stats = ShiftManager.get_shift_statistics()
		print("Score updated - Patients: %d, Correct: %d, Accuracy: %.1f%%" % [
			stats.patients_treated, 
			stats.correct_diagnoses, 
			stats.accuracy
		])

func _on_shift_ended() -> void:
	"""Handle shift end"""
	print("Shift ended in game scene")
	
	# Disable all interactions
	buttons_enabled = false
	var answer_buttons_list = [answer_a, answer_b, answer_c, answer_d, answer_e]
	for button in answer_buttons_list:
		if button:
			button.disabled = true
	if next_button:
		next_button.disabled = true

func handle_pause() -> void:
	"""Handle pause input (ESC key)"""
	if ShiftManager and ShiftManager.has("current_shift_active") and ShiftManager.current_shift_active:
		# TODO: Implement pause menu
		print("Pause requested (not implemented)")
	elif not ShiftManager:
		push_warning("GameScene: ShiftManager not available for pause handling")
	
func _input(event: InputEvent) -> void:
	"""Handle game scene input"""
	if not buttons_enabled:
		return
	
	# Handle keyboard shortcuts
	if event is InputEventKey and event.pressed:
		var key_event = event as InputEventKey
		match key_event.keycode:
			KEY_1:
				if answer_a and answer_a.visible:
					_on_answer_button_pressed("A")
			KEY_2:
				if answer_b and answer_b.visible:
					_on_answer_button_pressed("B")
			KEY_3:
				if answer_c and answer_c.visible:
					_on_answer_button_pressed("C")
			KEY_4:
				if answer_d and answer_d.visible:
					_on_answer_button_pressed("D")
			KEY_5:
				if answer_e and answer_e.visible:
					_on_answer_button_pressed("E")
			KEY_SPACE:
				# Spacebar shows summary/explanation if available
				if question_controller and question_controller.is_question_answered():
					var explanation = question_controller.get_explanation()
					print("Explanation: %s" % explanation)
					# TODO: Show explanation in UI dialog
			KEY_ENTER:
				# Enter advances to next patient if answer is completed
				if next_button and not next_button.disabled:
					_on_next_pressed()

# Enhanced system signal handlers
func _on_scene_transition_started(scene_type: String) -> void:
	"""Handle scene transition start"""
	print("GameScene: Scene transition started - %s" % scene_type)
	current_game_phase = scene_type.to_lower()

func _on_scene_transition_completed(scene_type: String) -> void:
	"""Handle scene transition completion"""
	print("GameScene: Scene transition completed - %s" % scene_type)

func _on_atmosphere_changed(atmosphere_type: String) -> void:
	"""Handle atmosphere change"""
	print("GameScene: Atmosphere changed to %s" % atmosphere_type)

func _on_arrival_sequence_completed() -> void:
	"""Handle patient arrival sequence completion"""
	print("GameScene: Patient arrival sequence completed")
	
	# Update UI with patient information after arrival animation
	_update_patient_info()
	_update_question_display()
	_update_answer_buttons()
	_reset_button_states()

func _on_urgency_alert(urgency_level: float) -> void:
	"""Handle urgency alert from patient arrival"""
	print("GameScene: Urgency alert triggered - level %.2f" % urgency_level)

func _on_between_patients_completed() -> void:
	"""Handle between patients sequence completion"""
	print("GameScene: Between patients sequence completed")

func _on_story_moment(story_data: Dictionary) -> void:
	"""Handle story moment trigger"""
	print("GameScene: Story moment - %s" % story_data.get("title", "Unknown"))

func _on_shift_intro_completed() -> void:
	"""Handle shift introduction completion"""
	print("GameScene: Shift introduction completed, starting patient flow")

func _on_character_interaction(character_name: String) -> void:
	"""Handle character interaction start"""
	print("GameScene: Character interaction with %s" % character_name)

func _on_relationship_changed(character_name: String, relationship_level: int) -> void:
	"""Handle character relationship change"""
	print("GameScene: Relationship with %s changed to %d" % [character_name, relationship_level])


func should_trigger_between_patients() -> bool:
	"""Determine if we should show between patients sequence"""
	
	# Show between patients every few patients or for story moments
	if not ShiftManager:
		return false
	
	var stats = ShiftManager.get_shift_statistics()
	var patients_treated = stats.get("patients_treated", 0)
	
	# Show every 2-3 patients, or when we have story content
	return patients_treated > 0 and (patients_treated % 2 == 0 or has_pending_story_content())

func has_pending_story_content() -> bool:
	"""Check if there's pending story content to show"""
	
	if not story_system:
		return false
	
	# Check if we have story beats available
	var patients_seen = 0
	if ShiftManager:
		var stats = ShiftManager.get_shift_statistics()
		patients_seen = stats.get("patients_treated", 0)
	
	# Story beats every 3 patients
	return patients_seen > 0 and patients_seen % 3 == 0

# Enhanced shift start
func start_new_shift() -> void:
	"""Start a new shift with enhanced intro sequence"""
	
	if shift_intro_ui:
		var shift_data = shift_intro_ui.get_default_shift_data()
		shift_intro_ui.show_shift_intro(shift_data)
	
	# Start the shift through normal flow
	if ShiftManager:
		ShiftManager.start_new_shift()

# Public interface for external systems
func get_current_game_phase() -> String:
	"""Get current game phase"""
	return current_game_phase

func is_assessment_active() -> bool:
	"""Check if assessment phase is currently active"""
	return current_game_phase == "assessment" and buttons_enabled

# Pixel Art UI Signal Handlers

func _on_chart_animation_complete() -> void:
	"""Handle chart animation completion"""
	print("GameScene: Chart animation completed")
	
	# Update medical equipment UI with chart data if available
	if medical_equipment_ui and question_controller:
		var answers = question_controller.get_formatted_answers()
		if answers.size() > 0:
			medical_equipment_ui.update_answer_choices(answers)

func _on_critical_info_highlighted(info_type: String) -> void:
	"""Handle critical information highlighting"""
	print("GameScene: Critical information highlighted: %s" % info_type)
	
	# Show appropriate character reaction
	if character_portraits:
		match info_type:
			"vital_signs":
				character_portraits.show_character_dialogue(PixelArtCharacters.CharacterType.SENIOR_RESIDENT, "Those vitals look concerning.")
			"lab_results":
				character_portraits.show_character_dialogue(PixelArtCharacters.CharacterType.NIGHT_NURSE, "Lab results are back.")
			"all_critical":
				character_portraits.show_character_dialogue(PixelArtCharacters.CharacterType.ATTENDING, "Review the critical findings carefully.")

func _on_chart_interaction(interaction_type: String) -> void:
	"""Handle chart interaction events"""
	print("GameScene: Chart interaction: %s" % interaction_type)
	
	match interaction_type:
		"chart_slide_in":
			# Show active character
			if character_portraits:
				var character_type = get_appropriate_character_for_urgency()
				character_portraits.show_character(character_type)

func _on_character_emotion_changed(character: String, emotion: String) -> void:
	"""Handle character emotion changes"""
	print("GameScene: %s emotion changed to %s" % [character, emotion])

func _on_character_dialogue(character: String, dialogue_text: String) -> void:
	"""Handle character dialogue"""
	print("GameScene: %s says: %s" % [character, dialogue_text])

func _on_timer_warning(warning_level: String) -> void:
	"""Handle timer warning from medical equipment"""
	print("GameScene: Timer warning: %s" % warning_level)
	
	# Update environment lighting based on time pressure
	if pixel_environment:
		match warning_level:
			"critical", "urgent":
				pixel_environment.set_lighting_state("emergency")
			"warning":
				pixel_environment.set_lighting_state("dim")
			_:
				pixel_environment.set_lighting_state("normal")
	
	# Update character stress levels
	if character_portraits:
		var stress_level = 0.5
		match warning_level:
			"urgent":
				stress_level = 1.0
			"critical":
				stress_level = 0.8
			"warning":
				stress_level = 0.6
		
		# Update current character stress
		var current_char = get_appropriate_character_for_urgency()
		character_portraits.set_character_stress_level(current_char, stress_level)

func _on_equipment_answer_selected(choice_id: String) -> void:
	"""Handle answer selection from medical equipment UI"""
	print("GameScene: Equipment answer selected: %s" % choice_id)
	
	# Also trigger traditional answer selection
	_on_answer_button_pressed(choice_id)

func _on_equipment_malfunction() -> void:
	"""Handle medical equipment malfunction"""
	print("GameScene: Equipment malfunction detected")
	
	# Show character dialogue
	if character_portraits:
		character_portraits.show_character_dialogue(
			PixelArtCharacters.CharacterType.NIGHT_NURSE, 
			"Equipment's acting up again."
		)

func _on_environment_loaded() -> void:
	"""Handle pixel environment loaded"""
	print("GameScene: Pixel art environment loaded")
	
	# Set initial atmosphere based on shift time
	if pixel_environment:
		pixel_environment.set_atmosphere_intensity(0.3)  # Start calm
		pixel_environment.set_lighting_state("normal")

func _on_lighting_changed(lighting_state: String) -> void:
	"""Handle lighting state changes"""
	print("GameScene: Lighting changed to: %s" % lighting_state)

func _on_desk_interaction(interaction_type: String) -> void:
	"""Handle desk interaction events"""
	print("GameScene: Desk interaction: %s" % interaction_type)

# Helper functions for pixel art systems

func get_appropriate_character_for_urgency() -> PixelArtCharacters.CharacterType:
	"""Get appropriate character based on current patient urgency"""
	
	if not chart_animation_system:
		return PixelArtCharacters.CharacterType.SENIOR_RESIDENT
	
	var urgency = chart_animation_system.get_current_urgency_level()
	
	if urgency > 0.8:
		return PixelArtCharacters.CharacterType.ATTENDING
	elif urgency > 0.5:
		return PixelArtCharacters.CharacterType.SENIOR_RESIDENT
	elif urgency > 0.3:
		return PixelArtCharacters.CharacterType.NIGHT_NURSE
	else:
		return PixelArtCharacters.CharacterType.MEDICAL_STUDENT

func update_pixel_ui_for_patient(patient_data: Dictionary) -> void:
	"""Update all pixel art UI systems for new patient"""
	
	# Calculate urgency level from patient data
	var urgency_level = calculate_patient_urgency(patient_data)
	
	# Update chart animation system
	if chart_animation_system:
		chart_animation_system.queue_chart_animation(patient_data, urgency_level)
	
	# Update character for situation
	if character_portraits:
		var character_type = get_appropriate_character_for_urgency()
		character_portraits.show_character(character_type)
		
		# Set appropriate emotion based on urgency
		var emotion = PixelArtCharacters.EmotionalState.NEUTRAL
		if urgency_level > 0.7:
			emotion = PixelArtCharacters.EmotionalState.CONCERNED
		elif urgency_level > 0.5:
			emotion = PixelArtCharacters.EmotionalState.FOCUSED
		elif urgency_level < 0.3:
			emotion = PixelArtCharacters.EmotionalState.ENCOURAGING
		
		character_portraits.set_character_emotion(character_type, emotion)
	
	# Update medical equipment UI
	if medical_equipment_ui and question_controller:
		# Update timer if available
		if TimerSystem:
			var time_remaining = TimerSystem.get_time_remaining()
			var total_time = TimerSystem.get_total_time()
			medical_equipment_ui.update_timer_display(time_remaining, total_time)

func calculate_patient_urgency(patient_data: Dictionary) -> float:
	"""Calculate patient urgency level from patient data"""
	
	var urgency = 0.0
	
	# Check vital signs for urgency indicators
	if patient_data.has("vitals"):
		var vitals = patient_data.vitals
		
		# High heart rate
		if vitals.has("HR"):
			var hr_str = str(vitals.HR)
			var hr = hr_str.to_int()
			if hr > 120:
				urgency += 0.3
			elif hr > 100:
				urgency += 0.2
		
		# Blood pressure
		if vitals.has("BP"):
			var bp_str = str(vitals.BP)
			if "18" in bp_str or "19" in bp_str or "20" in bp_str:
				urgency += 0.4
		
		# Temperature
		if vitals.has("Temp"):
			var temp_str = str(vitals.Temp)
			if "103" in temp_str or "104" in temp_str or "39" in temp_str or "40" in temp_str:
				urgency += 0.3
		
		# Oxygen saturation
		if vitals.has("O2Sat"):
			var o2_str = str(vitals.O2Sat)
			if o2_str.begins_with("8") or (o2_str.begins_with("9") and o2_str.to_int() < 95):
				urgency += 0.4
	
	# Check chief complaint for urgent keywords
	var presentation = patient_data.get("presentation", "")
	var urgent_keywords = ["chest pain", "difficulty breathing", "unconscious", "trauma", "bleeding", "seizure"]
	for keyword in urgent_keywords:
		if keyword in presentation.to_lower():
			urgency += 0.3
			break
	
	# Cap urgency at 1.0
	return clampf(urgency, 0.0, 1.0)

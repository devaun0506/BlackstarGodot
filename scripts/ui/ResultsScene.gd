extends Control
## Results scene controller for Blackstar
##
## Displays shift completion results, statistics, and performance feedback.

signal restart_requested
signal menu_requested

@onready var results_text = %ResultsText
@onready var restart_button = %RestartButton
@onready var menu_button = %MenuButton

func _ready() -> void:
	print("Results scene loaded")
	
	# Validate UI elements
	_validate_ui_elements()
	
	# Connect button signals
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	else:
		push_error("ResultsScene: Restart button not found")
	
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
	else:
		push_error("ResultsScene: Menu button not found")
	
	# Display results
	_display_results()
	
	# Focus restart button by default
	if restart_button:
		restart_button.grab_focus()

func _validate_ui_elements() -> void:
	"""Validate that essential UI elements are present"""
	var missing_elements = []
	
	if not results_text:
		missing_elements.append("ResultsText")
	if not restart_button:
		missing_elements.append("RestartButton")
	if not menu_button:
		missing_elements.append("MenuButton")
	
	if missing_elements.size() > 0:
		push_error("ResultsScene: Missing critical UI elements: " + str(missing_elements))
		print("ResultsScene: Results display may not function correctly")
	else:
		print("ResultsScene: UI elements validated successfully")

func _display_results() -> void:
	"""Display the shift results"""
	if not results_text:
		push_error("ResultsScene: results_text not found")
		return
	
	if not ShiftManager or not ShiftManager.has_method("get_shift_statistics"):
		push_error("ResultsScene: ShiftManager not available or missing get_shift_statistics method")
		results_text.text = "[center][b]SHIFT COMPLETE[/b][/center]\n\n[color=red]Error: Unable to load shift statistics[/color]"
		return
	
	var stats = ShiftManager.get_shift_statistics()
	var results_content = _format_results(stats)
	
	results_text.text = results_content

func _format_results(stats: Dictionary) -> String:
	"""Format the results into a readable display"""
	var content = "[center][b]SHIFT COMPLETE[/b][/center]\n\n"
	
	# Basic statistics
	content += "[b]Performance Summary:[/b]\n"
	content += "Patients Treated: %d\n" % stats.get("patients_treated", 0)
	content += "Correct Diagnoses: %d\n" % stats.get("correct_diagnoses", 0)
	content += "Accuracy: %.1f%%\n\n" % stats.get("accuracy", 0.0)
	
	# Performance rating
	var accuracy = stats.get("accuracy", 0.0)
	var rating = _get_performance_rating(accuracy)
	content += "[b]Performance Rating:[/b]\n"
	content += "%s\n\n" % rating
	
	# Time information
	if TimerSystem and TimerSystem.has_method("get_formatted_elapsed_time"):
		var elapsed_time = TimerSystem.get_formatted_elapsed_time()
		content += "[b]Time Information:[/b]\n"
		content += "Time Used: %s\n" % elapsed_time
		if stats.get("time_remaining", 0.0) > 0 and TimerSystem.has_method("get_formatted_time_remaining"):
			content += "Time Remaining: %s\n" % TimerSystem.get_formatted_time_remaining()
		content += "\n"
	else:
		content += "[b]Time Information:[/b] [color=red]Not Available[/color]\n\n"
	
	# Detailed feedback
	content += _get_detailed_feedback(stats)
	
	return content

func _get_performance_rating(accuracy: float) -> String:
	"""Get performance rating based on accuracy"""
	if accuracy >= 90.0:
		return "[color=green]Excellent - Expert Level Diagnosis[/color]"
	elif accuracy >= 80.0:
		return "[color=lightgreen]Very Good - Strong Clinical Skills[/color]"
	elif accuracy >= 70.0:
		return "[color=yellow]Good - Competent Performance[/color]"
	elif accuracy >= 60.0:
		return "[color=orange]Fair - Needs Improvement[/color]"
	else:
		return "[color=red]Poor - Additional Training Required[/color]"

func _get_detailed_feedback(stats: Dictionary) -> String:
	"""Get detailed performance feedback"""
	var feedback = "[b]Clinical Feedback:[/b]\n"
	
	var accuracy = stats.get("accuracy", 0.0)
	var patients_treated = stats.get("patients_treated", 0)
	
	if patients_treated == 0:
		feedback += "No patients were treated during this shift.\n"
		feedback += "Consider reviewing the case materials and trying again.\n"
		return feedback
	
	# Accuracy-based feedback
	if accuracy >= 90.0:
		feedback += "Outstanding diagnostic accuracy! You demonstrate excellent clinical reasoning and pattern recognition skills.\n"
		feedback += "Your performance indicates strong medical knowledge and decision-making abilities.\n"
	elif accuracy >= 80.0:
		feedback += "Very strong diagnostic skills with room for minor improvement.\n"
		feedback += "Continue practicing to achieve expert-level consistency.\n"
	elif accuracy >= 70.0:
		feedback += "Solid clinical performance with good diagnostic reasoning.\n"
		feedback += "Focus on reviewing missed cases to improve accuracy.\n"
	elif accuracy >= 60.0:
		feedback += "Acceptable performance, but improvement is needed for clinical competency.\n"
		feedback += "Review diagnostic criteria and differential diagnosis techniques.\n"
	else:
		feedback += "Significant improvement needed in diagnostic accuracy.\n"
		feedback += "Consider additional study of clinical presentation patterns and diagnostic methods.\n"
	
	# Volume-based feedback
	if patients_treated < 5:
		feedback += "\nConsider practicing with more cases to build experience and confidence.\n"
	elif patients_treated >= 10:
		feedback += "\nExcellent case volume demonstrates good time management skills.\n"
	
	# Recommendations
	feedback += "\n[b]Recommendations:[/b]\n"
	if accuracy < 80.0:
		feedback += "• Review differential diagnosis techniques\n"
		feedback += "• Study clinical presentation patterns\n"
		feedback += "• Practice with similar cases\n"
	if accuracy < 60.0:
		feedback += "• Consider reviewing fundamental medical knowledge\n"
		feedback += "• Seek additional training resources\n"
	
	return feedback

func _on_restart_pressed() -> void:
	"""Handle restart button press"""
	print("Restart requested from results")
	restart_requested.emit()

func _on_menu_pressed() -> void:
	"""Handle menu button press"""
	print("Return to menu requested")
	menu_requested.emit()

func _input(event: InputEvent) -> void:
	"""Handle results scene input"""
	if event.is_action_pressed("ui_accept"):
		# Enter restarts by default
		if restart_button and restart_button.has_focus():
			_on_restart_pressed()
		elif menu_button and menu_button.has_focus():
			_on_menu_pressed()
	elif event.is_action_pressed("ui_cancel"):
		# ESC goes to menu
		_on_menu_pressed()
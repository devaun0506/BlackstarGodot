extends Node
## Controls question and answer logic for medical cases in Blackstar
##
## The QuestionController manages the presentation of patient cases,
## answer selection, validation, and feedback for the Q&A gameplay.

signal answer_selected(answer_key: String)
signal question_completed(is_correct: bool)
signal feedback_shown(explanation: String)

# Current question state
var current_question_data: Dictionary = {}
var selected_answer: String = ""
var question_answered: bool = false
var show_explanation: bool = true

# Answer tracking
var answer_history: Array[Dictionary] = []

func _ready() -> void:
	print("QuestionController ready")

func load_question(patient_data: Dictionary) -> void:
	"""Load a new question from patient data"""
	current_question_data = patient_data.duplicate(true)
	selected_answer = ""
	question_answered = false
	
	var patient_name = _extract_patient_name(patient_data)
	print("Loaded question for patient: %s" % patient_name)

func select_answer(answer_key: String) -> void:
	"""Select an answer option"""
	if question_answered:
		print("Question already answered")
		return
	
	if not _is_valid_answer_key(answer_key):
		print("Invalid answer key: %s" % answer_key)
		return
	
	selected_answer = answer_key
	print("Selected answer: %s" % answer_key)
	answer_selected.emit(answer_key)

func submit_answer() -> bool:
	"""Submit the selected answer and check if correct"""
	if selected_answer.is_empty():
		print("No answer selected")
		return false
	
	if question_answered:
		print("Question already answered")
		return false
	
	var correct_answer = get_correct_answer()
	var is_correct = selected_answer == correct_answer
	
	# Record answer in history
	var answer_record = {
		"patient_name": _get_patient_name_for_record(),
		"question": current_question_data.get("question", ""),
		"selected_answer": selected_answer,
		"correct_answer": correct_answer,
		"is_correct": is_correct,
		"timestamp": Time.get_ticks_msec()
	}
	answer_history.append(answer_record)
	
	question_answered = true
	
	print("Answer submitted: %s (Correct: %s)" % [selected_answer, correct_answer])
	question_completed.emit(is_correct)
	
	# Show explanation if enabled
	if show_explanation:
		var explanation = current_question_data.get("explanation", "No explanation available.")
		show_feedback(explanation, is_correct)
	
	return is_correct

func show_feedback(explanation: String, is_correct: bool) -> void:
	"""Display feedback and explanation to the player"""
	print("Feedback - Correct: %s, Explanation: %s" % [is_correct, explanation])
	feedback_shown.emit(explanation)

func get_current_question_text() -> String:
	"""Get the current question text"""
	return current_question_data.get("question", "No question available")

func get_current_answers() -> Array:
	"""Get the current answer options"""
	# Handle new format with choices
	if current_question_data.has("choices"):
		return current_question_data.get("choices", [])
	# Handle old format with answers
	return current_question_data.get("answers", [])

func get_current_patient_info() -> Dictionary:
	"""Get current patient information for display"""
	var patient_info = {}
	
	# Handle new JSON format with vignette structure
	if current_question_data.has("vignette"):
		var vignette = current_question_data.get("vignette", {})
		patient_info["demographics"] = vignette.get("demographics", "")
		patient_info["presentation"] = vignette.get("presentation", "")
		patient_info["history"] = vignette.get("history", "")
		patient_info["physicalExam"] = vignette.get("physicalExam", "")
		patient_info["vital_signs"] = vignette.get("vitals", {})
		patient_info["labs"] = vignette.get("labs", {})
		patient_info["specialty"] = current_question_data.get("specialty", "")
		patient_info["topic"] = current_question_data.get("topic", "")
	else:
		# Handle old format
		var keys_to_include = ["name", "age", "gender", "chief_complaint", "vital_signs", "history"]
		for key in keys_to_include:
			if current_question_data.has(key):
				patient_info[key] = current_question_data[key]
	
	return patient_info

func get_formatted_patient_info() -> String:
	"""Get formatted patient information as rich text"""
	var info = get_current_patient_info()
	var formatted_text = ""
	
	# Handle new format
	if info.has("demographics"):
		# Specialty and topic
		if info.has("specialty"):
			formatted_text += "[b]Specialty:[/b] %s\n" % info.specialty
		if info.has("topic"):
			formatted_text += "[b]Topic:[/b] %s\n\n" % info.topic
		
		# Patient demographics and presentation
		formatted_text += "[b]Patient:[/b] %s %s\n\n" % [info.get("demographics", ""), info.get("presentation", "")]
		
		# History
		if info.has("history") and info.history != "":
			formatted_text += "[b]History:[/b]\n%s\n\n" % info.history
		
		# Physical exam
		if info.has("physicalExam") and info.physicalExam != "":
			formatted_text += "[b]Physical Exam:[/b]\n%s\n\n" % info.physicalExam
		
		# Vital signs
		if info.has("vital_signs") and info.vital_signs is Dictionary:
			formatted_text += "[b]Vital Signs:[/b]\n"
			var vitals = info.vital_signs
			for key in vitals:
				formatted_text += "%s: %s\n" % [key, vitals[key]]
			formatted_text += "\n"
		
		# Labs
		if info.has("labs") and info.labs is Dictionary and info.labs.has("formatted"):
			formatted_text += "[b]Labs & Diagnostics:[/b]\n%s\n" % info.labs.formatted
	else:
		# Handle old format
		# Patient demographics
		if info.has("name"):
			formatted_text += "[b]Patient:[/b] %s" % info.name
		if info.has("age"):
			formatted_text += ", Age %s" % info.age
		if info.has("gender"):
			formatted_text += " (%s)" % info.gender
		formatted_text += "\n\n"
		
		# Chief complaint
		if info.has("chief_complaint"):
			formatted_text += "[b]Chief Complaint:[/b]\n%s\n\n" % info.chief_complaint
		
		# Vital signs
		if info.has("vital_signs") and info.vital_signs is Dictionary:
			formatted_text += "[b]Vital Signs:[/b]\n"
			var vitals = info.vital_signs
			if vitals.has("blood_pressure"):
				formatted_text += "BP: %s\n" % vitals.blood_pressure
			if vitals.has("heart_rate"):
				formatted_text += "HR: %s bpm\n" % vitals.heart_rate
			if vitals.has("respiratory_rate"):
				formatted_text += "RR: %s/min\n" % vitals.respiratory_rate
			if vitals.has("temperature"):
				formatted_text += "Temp: %s°F\n" % vitals.temperature
			formatted_text += "\n"
		
		# History
		if info.has("history"):
			formatted_text += "[b]History:[/b]\n%s\n" % info.history
	
	return formatted_text

func get_formatted_answers() -> Array[String]:
	"""Get formatted answer options"""
	var answers = get_current_answers()
	var formatted_answers: Array[String] = []
	
	for answer in answers:
		# Handle new format with choice objects
		if answer is Dictionary and answer.has("id") and answer.has("text"):
			formatted_answers.append("%s) %s" % [answer.id, answer.text])
		else:
			# Handle old format with string answers
			formatted_answers.append(str(answer))
	
	return formatted_answers

func get_selected_answer() -> String:
	"""Get the currently selected answer"""
	return selected_answer

func is_question_answered() -> bool:
	"""Check if the current question has been answered"""
	return question_answered

func get_correct_answer() -> String:
	"""Get the correct answer for the current question"""
	# Handle new format with choices
	if current_question_data.has("choices"):
		var choices = current_question_data.get("choices", [])
		for choice in choices:
			if choice.has("correct") and choice.get("correct", false):
				return choice.get("id", "")
	
	# Handle old format with correct_answer field
	return current_question_data.get("correct_answer", "")

func get_explanation() -> String:
	"""Get the explanation for the current question"""
	# Handle new format with explanation object
	if current_question_data.has("explanation") and current_question_data.explanation is Dictionary:
		var explanation = current_question_data.get("explanation", {})
		var text = ""
		if explanation.has("correct"):
			text += explanation.correct
		if explanation.has("concepts") and explanation.concepts != "":
			text += "\n\nKey Concepts: " + explanation.concepts
		return text if text != "" else "No explanation available."
	
	# Handle old format with explanation string or missing
	return current_question_data.get("explanation", "No explanation available.")

func clear_current_question() -> void:
	"""Clear the current question data"""
	current_question_data.clear()
	selected_answer = ""
	question_answered = false

func get_answer_history() -> Array[Dictionary]:
	"""Get the complete answer history"""
	return answer_history.duplicate()

func get_accuracy_percentage() -> float:
	"""Calculate accuracy percentage from answer history"""
	if answer_history.is_empty():
		return 0.0
	
	var correct_count = 0
	for record in answer_history:
		if record.get("is_correct", false):
			correct_count += 1
	
	return (float(correct_count) / float(answer_history.size())) * 100.0

func reset_answer_history() -> void:
	"""Clear the answer history"""
	answer_history.clear()

func _is_valid_answer_key(key: String) -> bool:
	"""Validate if an answer key is valid"""
	return key in ["A", "B", "C", "D", "E"]

func _extract_answer_key(answer_text: String) -> String:
	"""Extract answer key from full answer text (e.g., 'A) Answer text' -> 'A')"""
	if answer_text.length() >= 2 and answer_text[1] == ')':
		return answer_text[0].to_upper()
	return ""

func toggle_explanation_display(enabled: bool) -> void:
	"""Enable or disable automatic explanation display"""
	show_explanation = enabled

func _get_patient_name_for_record() -> String:
	"""Get patient name for answer history record"""
	# Handle new format
	if current_question_data.has("vignette"):
		var vignette = current_question_data.get("vignette", {})
		var demographics = vignette.get("demographics", "Unknown Patient")
		return demographics
	
	# Handle old format
	return current_question_data.get("name", "Unknown Patient")

func _extract_patient_name(data: Dictionary) -> String:
	"""Extract patient name from standardized format"""
	var vignette = data.get("vignette", {})
	var demographics = vignette.get("demographics", "")
	# Extract name from demographics like "A 52-year-old man" -> "52-year-old man"
	if demographics.begins_with("A "):
		return demographics.right(-2)
	elif demographics.begins_with("An "):
		return demographics.right(-3)
	else:
		return data.get("id", "Unknown Patient")

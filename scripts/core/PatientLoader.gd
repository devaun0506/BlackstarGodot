extends Node
## Loads and manages patient case data for Blackstar
##
## The PatientLoader handles loading patient information from JSON files,
## randomizing case selection, and providing patient data to other systems.

signal patient_loaded(patient_data: Dictionary)
signal patient_queue_loaded(queue: Array)

# File paths
const PATIENT_DATA_PATH = "res://data/questions/"
const STORY_DATA_PATH = "res://data/story/"

# Available patient case files
var available_cases: Array[String] = []
var loaded_patients: Array[Dictionary] = []

func _ready() -> void:
	# Scan for available patient case files
	_scan_patient_files()
	print("PatientLoader ready. Found %d patient cases." % available_cases.size())

func _scan_patient_files() -> void:
	"""Scan the data directory for patient case files"""
	var dir = DirAccess.open(PATIENT_DATA_PATH)
	if dir == null:
		push_error("PatientLoader: Could not open patient data directory: " + PATIENT_DATA_PATH)
		return
	
	available_cases.clear()
	var files = dir.get_files()
	
	for file_name in files:
		if file_name.ends_with(".json") and not file_name.begins_with("."):
			available_cases.append(file_name)
			print("Found patient case file: ", file_name)

func load_patient_queue(count: int = 10) -> Array[Dictionary]:
	"""Load a randomized queue of patient cases"""
	var patient_queue: Array[Dictionary] = []
	
	# If we don't have enough cases, create sample cases
	if available_cases.size() == 0:
		push_warning("PatientLoader: No patient case files found. Creating sample cases...")
		return _create_sample_patient_queue(count)
	
	# Shuffle available cases
	var shuffled_cases = available_cases.duplicate()
	shuffled_cases.shuffle()
	
	# Load the requested number of cases (with repetition if needed)
	for i in range(count):
		var case_index = i % shuffled_cases.size()
		var case_file = shuffled_cases[case_index]
		var patient_data = load_patient_case(case_file)
		
		if not patient_data.is_empty():
			patient_queue.append(patient_data)
	
	print("Loaded patient queue with %d cases" % patient_queue.size())
	patient_queue_loaded.emit(patient_queue)
	return patient_queue

func load_patient_case(filename: String) -> Dictionary:
	"""Load a specific patient case from a JSON file"""
	var file_path = PATIENT_DATA_PATH + filename
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		push_error("PatientLoader: Could not open patient case file: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("PatientLoader: Error parsing JSON in file: " + filename)
		return {}
	
	var raw_data = json.data
	var patient_data = {}
	
	# Handle different data formats
	if raw_data is Array:
		# Array format - pick a random case from the array
		if raw_data.size() > 0:
			patient_data = raw_data[randi() % raw_data.size()]
		else:
			push_error("PatientLoader: Empty array in file: " + filename)
			return {}
	else:
		# Single case format
		patient_data = raw_data
	
	# Validate required fields
	if not _validate_patient_data(patient_data):
		push_error("PatientLoader: Invalid patient data in file: " + filename)
		return {}
	
	var patient_name = _extract_patient_name(patient_data)
	print("Loaded patient case: ", patient_name)
	patient_loaded.emit(patient_data)
	return patient_data

func _validate_patient_data(data: Dictionary) -> bool:
	"""Validate that patient data has required fields"""
	# Check for NBME standard format
	var nbme_required = ["id", "specialty", "topic", "difficulty", "vignette", "question", "choices", "explanation", "metadata"]
	var has_nbme_format = true
	
	for field in nbme_required:
		if not data.has(field):
			has_nbme_format = false
			break
	
	if has_nbme_format:
		# Validate NBME format
		var vignette = data.get("vignette", {})
		var required_vignette_fields = ["demographics", "presentation", "vitals"]
		for field in required_vignette_fields:
			if not vignette.has(field):
				push_error("PatientLoader: Missing vignette field: " + field)
				return false
		
		# Validate choices structure
		var choices = data.get("choices", [])
		if not choices is Array or choices.size() < 4:
			push_error("PatientLoader: Invalid choices array in NBME format")
			return false
		
		var correct_count = 0
		for choice in choices:
			if not choice is Dictionary:
				push_error("PatientLoader: Invalid choice structure")
				return false
			if not choice.has("id") or not choice.has("text") or not choice.has("correct"):
				push_error("PatientLoader: Choice missing required fields")
				return false
			if choice.get("correct", false):
				correct_count += 1
		
		if correct_count != 1:
			push_error("PatientLoader: Invalid number of correct answers: " + str(correct_count))
			return false
		
		return true
	
	# Check for legacy format (for backwards compatibility)
	var legacy_required = ["name", "age", "chief_complaint", "question", "answers", "correct_answer"]
	var has_legacy_format = true
	
	for field in legacy_required:
		if not data.has(field):
			has_legacy_format = false
			break
	
	if has_legacy_format:
		push_warning("PatientLoader: Using legacy format - consider upgrading to NBME standard format")
		# Validate legacy format
		if not data.answers is Array or data.answers.size() < 2:
			push_error("PatientLoader: Invalid answers array in legacy format")
			return false
		
		var valid_answers = ["A", "B", "C", "D", "E"]
		if data.correct_answer not in valid_answers:
			push_error("PatientLoader: Invalid correct_answer: " + str(data.correct_answer))
			return false
		
		return true
	
	# Validation failed
	push_error("PatientLoader: Patient data validation failed - missing required fields for both NBME and legacy formats")
	return false

func _create_sample_patient_queue(count: int) -> Array[Dictionary]:
	"""Create sample patient cases for testing"""
	var sample_patients: Array[Dictionary] = []
	
	var sample_cases = [
		{
			"name": "John Smith",
			"age": 45,
			"gender": "Male",
			"chief_complaint": "Chest pain and shortness of breath",
			"vital_signs": {
				"blood_pressure": "180/110",
				"heart_rate": 95,
				"respiratory_rate": 22,
				"temperature": 98.6
			},
			"history": "Patient reports sudden onset of crushing chest pain radiating to left arm. History of hypertension.",
			"question": "Based on the patient's presentation, what is the most likely diagnosis?",
			"answers": [
				"A) Myocardial infarction",
				"B) Panic attack", 
				"C) Gastroesophageal reflux",
				"D) Muscle strain"
			],
			"correct_answer": "A",
			"explanation": "The combination of crushing chest pain, radiation to arm, and hypertension history suggests MI."
		},
		{
			"name": "Sarah Johnson",
			"age": 28,
			"gender": "Female",
			"chief_complaint": "Severe abdominal pain",
			"vital_signs": {
				"blood_pressure": "110/70",
				"heart_rate": 105,
				"respiratory_rate": 20,
				"temperature": 101.2
			},
			"history": "Sharp right lower quadrant pain for 12 hours. Nausea and vomiting. No appetite.",
			"question": "What is the most likely diagnosis?",
			"answers": [
				"A) Gastroenteritis",
				"B) Appendicitis",
				"C) Ovarian cyst",
				"D) Food poisoning"
			],
			"correct_answer": "B",
			"explanation": "Classic presentation of appendicitis with RLQ pain, fever, and GI symptoms."
		}
	]
	
	# Repeat sample cases to fill the queue
	for i in range(count):
		var case_index = i % sample_cases.size()
		sample_patients.append(sample_cases[case_index].duplicate(true))
	
	print("Created %d sample patient cases" % sample_patients.size())
	return sample_patients

func get_random_patient_case() -> Dictionary:
	"""Get a random patient case"""
	if available_cases.size() == 0:
		return _create_sample_patient_queue(1)[0]
	
	var random_case = available_cases[randi() % available_cases.size()]
	return load_patient_case(random_case)

func reload_patient_files() -> void:
	"""Rescan and reload available patient files"""
	_scan_patient_files()

func get_available_case_count() -> int:
	"""Get the number of available patient cases"""
	return available_cases.size()

func _extract_patient_name(data: Dictionary) -> String:
	"""Extract patient name from patient data"""
	# Check for legacy format name field first
	if data.has("name"):
		return data.get("name", "Unknown Patient")
	
	# For NBME format, use id and demographics
	var vignette = data.get("vignette", {})
	var demographics = vignette.get("demographics", "")
	# Extract description from demographics like "A 52-year-old man" -> "52-year-old man"
	if demographics.begins_with("A "):
		return demographics.right(-2)
	elif demographics.begins_with("An "):
		return demographics.right(-3)
	else:
		return data.get("id", "Unknown Patient")


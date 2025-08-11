extends Node
class_name CaseValidator
## Validates patient case JSON data against the standardized schema

const SCHEMA_PATH = "res://data/schema/patient_case_schema.json"

static func validate_case(case_data: Dictionary) -> Array[String]:
	"""Validate a single patient case and return array of errors"""
	var errors: Array[String] = []
	
	# Required top-level fields
	var required_fields = ["id", "specialty", "topic", "difficulty", "vignette", "question", "choices", "explanation", "metadata"]
	for field in required_fields:
		if not case_data.has(field):
			errors.append("Missing required field: " + field)
	
	# Validate difficulty range
	var difficulty = case_data.get("difficulty", 0)
	if difficulty < 1 or difficulty > 5:
		errors.append("Difficulty must be between 1 and 5, got: " + str(difficulty))
	
	# Validate specialty
	var valid_specialties = ["Internal Medicine", "Surgery", "Pediatrics", "OB/GYN", "Psychiatry", "Emergency Medicine", "Radiology", "Pathology"]
	var specialty = case_data.get("specialty", "")
	if specialty not in valid_specialties:
		errors.append("Invalid specialty: " + specialty)
	
	# Validate vignette
	var vignette = case_data.get("vignette", {})
	if vignette.is_empty():
		errors.append("Vignette is missing or empty")
	else:
		errors.append_array(_validate_vignette(vignette))
	
	# Validate choices
	var choices = case_data.get("choices", [])
	if choices.is_empty():
		errors.append("Choices array is missing or empty")
	else:
		errors.append_array(_validate_choices(choices))
	
	# Validate explanation
	var explanation = case_data.get("explanation", {})
	if explanation.is_empty():
		errors.append("Explanation is missing or empty")
	else:
		errors.append_array(_validate_explanation(explanation))
	
	# Validate metadata
	var metadata = case_data.get("metadata", {})
	if metadata.is_empty():
		errors.append("Metadata is missing or empty")
	else:
		errors.append_array(_validate_metadata(metadata))
	
	return errors

static func _validate_vignette(vignette: Dictionary) -> Array[String]:
	"""Validate vignette structure"""
	var errors: Array[String] = []
	
	# Required vignette fields
	var required_fields = ["demographics", "presentation", "vitals"]
	for field in required_fields:
		if not vignette.has(field):
			errors.append("Vignette missing required field: " + field)
	
	# Validate demographics format
	var demographics = vignette.get("demographics", "")
	if not demographics.begins_with("A ") and not demographics.begins_with("An "):
		errors.append("Demographics should start with 'A' or 'An': " + demographics)
	
	# Validate vital signs
	var vitals = vignette.get("vitals", {})
	if vitals.is_empty():
		errors.append("Vitals are missing")
	else:
		var required_vitals = ["BP", "HR", "RR", "Temp"]
		for vital in required_vitals:
			if not vitals.has(vital):
				errors.append("Missing vital sign: " + vital)
	
	return errors

static func _validate_choices(choices: Array) -> Array[String]:
	"""Validate choices array"""
	var errors: Array[String] = []
	
	if choices.size() < 4 or choices.size() > 5:
		errors.append("Choices array must have 4-5 items, got: " + str(choices.size()))
	
	var correct_count = 0
	var used_ids: Array[String] = []
	
	for i in range(choices.size()):
		var choice = choices[i]
		
		# Validate choice structure
		if not choice.has("id") or not choice.has("text") or not choice.has("correct"):
			errors.append("Choice " + str(i) + " missing required fields (id, text, correct)")
			continue
		
		var choice_id = choice.get("id", "")
		var choice_text = choice.get("text", "")
		var is_correct = choice.get("correct", false)
		
		# Validate choice ID
		if choice_id not in ["A", "B", "C", "D", "E"]:
			errors.append("Invalid choice ID: " + choice_id + " (must be A-E)")
		
		if choice_id in used_ids:
			errors.append("Duplicate choice ID: " + choice_id)
		else:
			used_ids.append(choice_id)
		
		# Validate choice text
		if choice_text.length() < 3:
			errors.append("Choice text too short for " + choice_id + ": " + choice_text)
		
		# Count correct answers
		if is_correct:
			correct_count += 1
	
	# Must have exactly one correct answer
	if correct_count != 1:
		errors.append("Must have exactly 1 correct answer, found: " + str(correct_count))
	
	return errors

static func _validate_explanation(explanation: Dictionary) -> Array[String]:
	"""Validate explanation structure"""
	var errors: Array[String] = []
	
	var required_fields = ["correct", "concepts"]
	for field in required_fields:
		if not explanation.has(field):
			errors.append("Explanation missing required field: " + field)
	
	# Validate explanation text length
	var correct_explanation = explanation.get("correct", "")
	if correct_explanation.length() < 20:
		errors.append("Correct explanation too short (minimum 20 characters)")
	
	var concepts = explanation.get("concepts", "")
	if concepts.length() < 10:
		errors.append("Concepts explanation too short (minimum 10 characters)")
	
	return errors

static func _validate_metadata(metadata: Dictionary) -> Array[String]:
	"""Validate metadata structure"""
	var errors: Array[String] = []
	
	var required_fields = ["high_yield", "tested_frequency"]
	for field in required_fields:
		if not metadata.has(field):
			errors.append("Metadata missing required field: " + field)
	
	# Validate tested_frequency
	var frequency = metadata.get("tested_frequency", "")
	var valid_frequencies = ["very_high", "high", "medium", "low"]
	if frequency not in valid_frequencies:
		errors.append("Invalid tested_frequency: " + frequency)
	
	# Validate high_yield
	var high_yield = metadata.get("high_yield")
	if not (high_yield is bool):
		errors.append("high_yield must be boolean, got: " + str(high_yield))
	
	return errors

static func validate_case_file(file_path: String) -> Dictionary:
	"""Validate an entire case file and return validation results"""
	var results = {
		"valid": true,
		"errors": [],
		"case_count": 0,
		"case_errors": {}
	}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		results["valid"] = false
		results["errors"].append("Could not open file: " + file_path)
		return results
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		results["valid"] = false
		results["errors"].append("Invalid JSON syntax in file: " + file_path)
		return results
	
	var data = json.data
	
	# Handle array format (multiple cases)
	if data is Array:
		results["case_count"] = data.size()
		for i in range(data.size()):
			var case_data = data[i]
			var case_errors = validate_case(case_data)
			if case_errors.size() > 0:
				results["valid"] = false
				results["case_errors"][str(i)] = case_errors
	
	# Handle single case format
	elif data is Dictionary:
		results["case_count"] = 1
		var case_errors = validate_case(data)
		if case_errors.size() > 0:
			results["valid"] = false
			results["case_errors"]["0"] = case_errors
	
	else:
		results["valid"] = false
		results["errors"].append("Unknown data format in file: " + file_path)
	
	return results

static func validate_all_case_files(directory_path: String) -> Dictionary:
	"""Validate all case files in a directory"""
	var overall_results = {
		"valid": true,
		"file_count": 0,
		"total_cases": 0,
		"file_results": {}
	}
	
	var dir = DirAccess.open(directory_path)
	if dir == null:
		overall_results["valid"] = false
		overall_results["errors"] = ["Could not open directory: " + directory_path]
		return overall_results
	
	var files = dir.get_files()
	
	for file_name in files:
		if file_name.ends_with(".json") and not file_name.begins_with("."):
			var file_path = directory_path + "/" + file_name
			var file_results = validate_case_file(file_path)
			
			overall_results["file_count"] += 1
			overall_results["total_cases"] += file_results["case_count"]
			overall_results["file_results"][file_name] = file_results
			
			if not file_results["valid"]:
				overall_results["valid"] = false
	return overall_results
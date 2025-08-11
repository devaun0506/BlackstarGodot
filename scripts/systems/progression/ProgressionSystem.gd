class_name ProgressionSystem extends Node

# Progression system manages 3 difficulty levels and adaptive learning
# Tracks performance, unlocks content, and adjusts to player skill

signal difficulty_unlocked(new_difficulty: DifficultyLevel)
signal specialty_unlocked(specialty: String)
signal performance_milestone_reached(milestone: String)
signal adaptive_adjustment_made(adjustment_type: String, value: float)

# Three main difficulty levels
enum DifficultyLevel {
	INTERN,        # Level 1: 45 seconds, clear diagnoses
	RESIDENT,      # Level 2: 35 seconds, some complexity
	ATTENDING      # Level 3: 25 seconds, complex cases
}

# Medical specialties to unlock
enum Specialty {
	INTERNAL_MEDICINE,
	EMERGENCY_MEDICINE,
	SURGERY,
	PEDIATRICS,
	CARDIOLOGY,
	NEUROLOGY,
	PSYCHIATRY,
	RADIOLOGY
}

# Performance tracking
var current_difficulty: DifficultyLevel = DifficultyLevel.INTERN
var unlocked_difficulties: Array[DifficultyLevel] = [DifficultyLevel.INTERN]
var unlocked_specialties: Array[String] = ["Internal Medicine"]

# Progression requirements
var shifts_completed: int = 0
var total_questions_answered: int = 0
var overall_accuracy: float = 0.0
var current_streak: int = 0
var best_streak: int = 0

# Specialty-specific tracking
var specialty_performance: Dictionary = {}
var specialty_unlock_progress: Dictionary = {}

# Adaptive algorithm data
var adaptive_weights: Dictionary = {
	"topic_weights": {},      # Topics that need more practice
	"last_seen": {},          # When topics were last practiced
	"error_frequency": {},    # How often topics are missed
	"difficulty_scaling": 1.0 # Overall difficulty multiplier
}

# Unlock requirements
var unlock_requirements: Dictionary = {
	DifficultyLevel.RESIDENT: {
		"shifts_completed": 5,
		"accuracy_threshold": 0.70,
		"min_questions": 50
	},
	DifficultyLevel.ATTENDING: {
		"shifts_completed": 12,
		"accuracy_threshold": 0.75,
		"min_questions": 150,
		"streak_requirement": 10
	}
}

# Specialty unlock requirements
var specialty_requirements: Dictionary = {
	"Emergency Medicine": {"shifts": 3, "accuracy": 0.65},
	"Surgery": {"shifts": 6, "accuracy": 0.72, "difficulty": DifficultyLevel.RESIDENT},
	"Pediatrics": {"shifts": 4, "accuracy": 0.70},
	"Cardiology": {"shifts": 8, "accuracy": 0.75, "specialty_mastery": "Internal Medicine"},
	"Neurology": {"shifts": 7, "accuracy": 0.73},
	"Psychiatry": {"shifts": 5, "accuracy": 0.68},
	"Radiology": {"shifts": 10, "accuracy": 0.80, "difficulty": DifficultyLevel.ATTENDING}
}

# Performance milestones
var milestones: Dictionary = {
	"first_shift": {"shifts": 1, "reward": "Basic ER knowledge"},
	"steady_progress": {"shifts": 5, "accuracy": 0.65, "reward": "Resident level unlocked"},
	"competent_physician": {"shifts": 10, "accuracy": 0.70, "reward": "Advanced cases"},
	"expert_diagnostician": {"shifts": 15, "accuracy": 0.80, "reward": "Attending level"},
	"master_clinician": {"accuracy": 0.85, "streak": 20, "reward": "All specialties"}
}

func _ready() -> void:
	_initialize_specialty_tracking()
	_initialize_adaptive_weights()

func _initialize_specialty_tracking() -> void:
	"""Initialize performance tracking for all specialties"""
	var specialties = ["Internal Medicine", "Emergency Medicine", "Surgery", 
					   "Pediatrics", "Cardiology", "Neurology", "Psychiatry", "Radiology"]
	
	for specialty in specialties:
		specialty_performance[specialty] = {
			"questions_seen": 0,
			"correct_answers": 0,
			"accuracy": 0.0,
			"last_practiced": 0,
			"weak_topics": [],
			"mastery_level": 0.0
		}
		
		specialty_unlock_progress[specialty] = {
			"requirements_met": 0,
			"total_requirements": _count_specialty_requirements(specialty)
		}

func _initialize_adaptive_weights() -> void:
	"""Initialize adaptive learning system"""
	# Standard medical topics with base priority
	var base_topics = [
		"Myocardial Infarction", "Pneumonia", "Diabetes", "Hypertension",
		"Stroke", "Sepsis", "Appendicitis", "Kidney Disease", "Heart Failure",
		"Asthma", "COPD", "UTI", "Depression", "Anxiety", "Fractures"
	]
	
	for topic in base_topics:
		adaptive_weights.topic_weights[topic] = 1.0
		adaptive_weights.last_seen[topic] = 0
		adaptive_weights.error_frequency[topic] = 0.0

func complete_shift(shift_data: Dictionary) -> void:
	"""Process completion of a shift and update progression"""
	shifts_completed += 1
	
	# Update performance metrics
	if shift_data.has("questions_answered"):
		total_questions_answered += shift_data.questions_answered
	
	if shift_data.has("accuracy"):
		_update_overall_accuracy(shift_data.accuracy)
	
	if shift_data.has("streak"):
		current_streak = shift_data.streak
		best_streak = max(best_streak, current_streak)
	
	# Update specialty performance
	if shift_data.has("specialty_performance"):
		_update_specialty_performance(shift_data.specialty_performance)
	
	# Update adaptive weights based on performance
	if shift_data.has("question_results"):
		_update_adaptive_weights(shift_data.question_results)
	
	# Check for unlocks
	_check_difficulty_unlocks()
	_check_specialty_unlocks()
	_check_milestone_achievements()
	
	# Adjust adaptive difficulty
	_adjust_adaptive_difficulty(shift_data)

func _update_overall_accuracy(shift_accuracy: float) -> void:
	"""Update running average of accuracy"""
	if total_questions_answered > 0:
		var weight = float(shifts_completed - 1) / shifts_completed
		overall_accuracy = overall_accuracy * weight + shift_accuracy * (1.0 - weight)
	else:
		overall_accuracy = shift_accuracy

func _update_specialty_performance(specialty_data: Dictionary) -> void:
	"""Update performance tracking for specific specialties"""
	for specialty in specialty_data:
		if specialty_performance.has(specialty):
			var perf = specialty_performance[specialty]
			var data = specialty_data[specialty]
			
			perf.questions_seen += data.get("questions", 0)
			perf.correct_answers += data.get("correct", 0)
			
			if perf.questions_seen > 0:
				perf.accuracy = float(perf.correct_answers) / perf.questions_seen
			
			perf.last_practiced = Time.get_ticks_msec()
			
			# Update weak topics
			if data.has("missed_topics"):
				for topic in data.missed_topics:
					if not perf.weak_topics.has(topic):
						perf.weak_topics.append(topic)
			
			# Calculate mastery level (0.0 to 1.0)
			perf.mastery_level = _calculate_mastery_level(perf)

func _calculate_mastery_level(performance_data: Dictionary) -> float:
	"""Calculate mastery level based on questions seen, accuracy, and recency"""
	var questions_factor = min(1.0, performance_data.questions_seen / 50.0)  # Cap at 50 questions
	var accuracy_factor = performance_data.accuracy
	var recency_factor = 1.0  # Could add time decay here
	
	return questions_factor * accuracy_factor * recency_factor

func _update_adaptive_weights(question_results: Array):
	"""Update adaptive algorithm weights based on recent performance"""
	for result in question_results:
		var topic = result.get("topic", "unknown")
		var correct = result.get("correct", false)
		
		if adaptive_weights.topic_weights.has(topic):
			# Update last seen timestamp
			adaptive_weights.last_seen[topic] = Time.get_ticks_msec()
			
			# Update error frequency
			if not correct:
				adaptive_weights.error_frequency[topic] += 0.1
				adaptive_weights.topic_weights[topic] *= 1.5  # Increase weight for missed topics
			else:
				# Reduce weight slightly for correct answers
				adaptive_weights.topic_weights[topic] *= 0.95
				# Decay error frequency
				adaptive_weights.error_frequency[topic] *= 0.9
			
			# Keep weights within reasonable bounds
			adaptive_weights.topic_weights[topic] = clamp(adaptive_weights.topic_weights[topic], 0.1, 5.0)
			adaptive_weights.error_frequency[topic] = clamp(adaptive_weights.error_frequency[topic], 0.0, 2.0)

func _adjust_adaptive_difficulty(shift_data: Dictionary):
	"""Adjust overall difficulty scaling based on performance"""
	var target_accuracy = 0.75
	var current_accuracy = shift_data.get("accuracy", overall_accuracy)
	var accuracy_diff = current_accuracy - target_accuracy
	
	# Adjust difficulty scaling
	if accuracy_diff > 0.1:
		# Too easy, increase difficulty
		adaptive_weights.difficulty_scaling *= 1.05
		adaptive_adjustment_made.emit("increase_difficulty", adaptive_weights.difficulty_scaling)
	elif accuracy_diff < -0.15:
		# Too hard, decrease difficulty
		adaptive_weights.difficulty_scaling *= 0.95
		adaptive_adjustment_made.emit("decrease_difficulty", adaptive_weights.difficulty_scaling)
	
	# Keep scaling within bounds
	adaptive_weights.difficulty_scaling = clamp(adaptive_weights.difficulty_scaling, 0.5, 2.0)

func _check_difficulty_unlocks():
	"""Check if player has met requirements for higher difficulty levels"""
	# Check for Resident level unlock
	if not unlocked_difficulties.has(DifficultyLevel.RESIDENT):
		var req = unlock_requirements[DifficultyLevel.RESIDENT]
		if (shifts_completed >= req.shifts_completed and 
			overall_accuracy >= req.accuracy_threshold and
			total_questions_answered >= req.min_questions):
			
			unlocked_difficulties.append(DifficultyLevel.RESIDENT)
			difficulty_unlocked.emit(DifficultyLevel.RESIDENT)
	
	# Check for Attending level unlock
	if (unlocked_difficulties.has(DifficultyLevel.RESIDENT) and 
		not unlocked_difficulties.has(DifficultyLevel.ATTENDING)):
		
		var req = unlock_requirements[DifficultyLevel.ATTENDING]
		if (shifts_completed >= req.shifts_completed and
			overall_accuracy >= req.accuracy_threshold and
			total_questions_answered >= req.min_questions and
			best_streak >= req.streak_requirement):
			
			unlocked_difficulties.append(DifficultyLevel.ATTENDING)
			difficulty_unlocked.emit(DifficultyLevel.ATTENDING)

func _check_specialty_unlocks():
	"""Check if player has unlocked new medical specialties"""
	for specialty in specialty_requirements:
		if unlocked_specialties.has(specialty):
			continue
		
		var req = specialty_requirements[specialty]
		var unlocked = true
		
		# Check basic requirements
		if req.has("shifts") and shifts_completed < req.shifts:
			unlocked = false
		
		if req.has("accuracy") and overall_accuracy < req.accuracy:
			unlocked = false
		
		# Check difficulty requirement
		if req.has("difficulty") and not unlocked_difficulties.has(req.difficulty):
			unlocked = false
		
		# Check specialty mastery requirement
		if req.has("specialty_mastery"):
			var mastery_specialty = req.specialty_mastery
			if (not specialty_performance.has(mastery_specialty) or 
				specialty_performance[mastery_specialty].mastery_level < 0.8):
				unlocked = false
		
		if unlocked:
			unlocked_specialties.append(specialty)
			specialty_unlocked.emit(specialty)

func _check_milestone_achievements():
	"""Check if player has reached any performance milestones"""
	for milestone_id in milestones:
		var milestone = milestones[milestone_id]
		if milestone.has("achieved"):
			continue  # Already achieved
		
		var achieved = true
		
		# Check milestone requirements
		if milestone.has("shifts") and shifts_completed < milestone.shifts:
			achieved = false
		
		if milestone.has("accuracy") and overall_accuracy < milestone.accuracy:
			achieved = false
		
		if milestone.has("streak") and best_streak < milestone.streak:
			achieved = false
		
		if achieved:
			milestone.achieved = true
			performance_milestone_reached.emit(milestone_id)

func _count_specialty_requirements(specialty: String) -> int:
	"""Count total requirements for specialty unlock"""
	if not specialty_requirements.has(specialty):
		return 0
	
	var req = specialty_requirements[specialty]
	var count = 0
	
	if req.has("shifts"): count += 1
	if req.has("accuracy"): count += 1
	if req.has("difficulty"): count += 1
	if req.has("specialty_mastery"): count += 1
	
	return count

func get_next_question_priority(available_topics: Array) -> Dictionary:
	"""Calculate priority scores for available topics using adaptive algorithm"""
	var priority_scores = {}
	var current_time = Time.get_ticks_msec()
	
	for topic in available_topics:
		var base_priority = 1.0
		var error_multiplier = 1.0
		var recency_multiplier = 1.0
		var specialty_multiplier = 1.0
		
		# Error frequency multiplier
		if adaptive_weights.error_frequency.has(topic):
			error_multiplier = 1.0 + adaptive_weights.error_frequency[topic]
		
		# Recency multiplier (topics not seen recently get higher priority)
		if adaptive_weights.last_seen.has(topic):
			var time_since_seen = current_time - adaptive_weights.last_seen[topic]
			var hours_since_seen = time_since_seen / (1000.0 * 60.0 * 60.0)  # Convert to hours
			recency_multiplier = min(2.0, 1.0 + hours_since_seen / 24.0)  # Increase over 24 hours
		
		# Specialty weakness multiplier
		var topic_specialty = _get_topic_specialty(topic)
		if (specialty_performance.has(topic_specialty) and
			specialty_performance[topic_specialty].weak_topics.has(topic)):
			specialty_multiplier = 1.5
		
		# High yield bonus (could be loaded from question metadata)
		var high_yield_bonus = 1.0
		
		# Calculate final priority
		priority_scores[topic] = (base_priority * error_multiplier * 
								 recency_multiplier * specialty_multiplier * 
								 high_yield_bonus * adaptive_weights.difficulty_scaling)
	
	return priority_scores

func _get_topic_specialty(topic: String) -> String:
	"""Map a topic to its primary specialty"""
	# This could be loaded from a data file, but for now we'll use simple mapping
	var topic_specialty_map = {
		"Myocardial Infarction": "Cardiology",
		"Pneumonia": "Internal Medicine",
		"Diabetes": "Internal Medicine",
		"Stroke": "Neurology",
		"Appendicitis": "Surgery",
		"Fractures": "Surgery"
	}
	
	return topic_specialty_map.get(topic, "Internal Medicine")

func get_time_limit_for_difficulty() -> float:
	"""Get time limit in seconds for current difficulty level"""
	match current_difficulty:
		DifficultyLevel.INTERN:
			return 45.0
		DifficultyLevel.RESIDENT:
			return 35.0
		DifficultyLevel.ATTENDING:
			return 25.0
	return 45.0

func get_difficulty_name(difficulty: DifficultyLevel) -> String:
	"""Get human-readable name for difficulty level"""
	match difficulty:
		DifficultyLevel.INTERN:
			return "Intern"
		DifficultyLevel.RESIDENT:
			return "Resident"
		DifficultyLevel.ATTENDING:
			return "Attending"
	return "Unknown"

func set_current_difficulty(new_difficulty: DifficultyLevel):
	"""Set the current difficulty level"""
	if unlocked_difficulties.has(new_difficulty):
		current_difficulty = new_difficulty

func get_progression_summary() -> Dictionary:
	"""Get complete progression summary for UI display"""
	return {
		"current_difficulty": get_difficulty_name(current_difficulty),
		"unlocked_difficulties": unlocked_difficulties.size(),
		"unlocked_specialties": unlocked_specialties.size(),
		"shifts_completed": shifts_completed,
		"overall_accuracy": overall_accuracy,
		"best_streak": best_streak,
		"total_questions": total_questions_answered,
		"next_unlock": _get_next_unlock_info()
	}

func _get_next_unlock_info() -> Dictionary:
	"""Get information about the next unlock"""
	# Check for next difficulty unlock
	if not unlocked_difficulties.has(DifficultyLevel.RESIDENT):
		var req = unlock_requirements[DifficultyLevel.RESIDENT]
		return {
			"type": "difficulty",
			"name": "Resident Level",
			"progress": {
				"shifts": float(shifts_completed) / req.shifts_completed,
				"accuracy": overall_accuracy / req.accuracy_threshold,
				"questions": float(total_questions_answered) / req.min_questions
			}
		}
	elif not unlocked_difficulties.has(DifficultyLevel.ATTENDING):
		var req = unlock_requirements[DifficultyLevel.ATTENDING]
		return {
			"type": "difficulty", 
			"name": "Attending Level",
			"progress": {
				"shifts": float(shifts_completed) / req.shifts_completed,
				"accuracy": overall_accuracy / req.accuracy_threshold,
				"questions": float(total_questions_answered) / req.min_questions,
				"streak": float(best_streak) / req.streak_requirement
			}
		}
	
	# Check for specialty unlocks
	for specialty in specialty_requirements:
		if not unlocked_specialties.has(specialty):
			return {
				"type": "specialty",
				"name": specialty,
				"progress": _calculate_specialty_unlock_progress(specialty)
			}
	
	return {"type": "none", "name": "All content unlocked!"}

func _calculate_specialty_unlock_progress(specialty: String) -> Dictionary:
	"""Calculate progress towards specialty unlock"""
	var req = specialty_requirements[specialty]
	var progress = {}
	
	if req.has("shifts"):
		progress["shifts"] = float(shifts_completed) / req.shifts
	
	if req.has("accuracy"):
		progress["accuracy"] = overall_accuracy / req.accuracy
	
	return progress

func get_save_data() -> Dictionary:
	"""Get progression data for saving"""
	return {
		"current_difficulty": current_difficulty,
		"unlocked_difficulties": unlocked_difficulties,
		"unlocked_specialties": unlocked_specialties,
		"shifts_completed": shifts_completed,
		"total_questions_answered": total_questions_answered,
		"overall_accuracy": overall_accuracy,
		"current_streak": current_streak,
		"best_streak": best_streak,
		"specialty_performance": specialty_performance,
		"adaptive_weights": adaptive_weights,
		"milestones": milestones
	}

func load_save_data(save_data: Dictionary):
	"""Load progression data from save"""
	if save_data.has("current_difficulty"):
		current_difficulty = save_data.current_difficulty
	
	if save_data.has("unlocked_difficulties"):
		unlocked_difficulties = save_data.unlocked_difficulties
	
	if save_data.has("unlocked_specialties"):
		unlocked_specialties = save_data.unlocked_specialties
	
	if save_data.has("shifts_completed"):
		shifts_completed = save_data.shifts_completed
	
	if save_data.has("total_questions_answered"):
		total_questions_answered = save_data.total_questions_answered
	
	if save_data.has("overall_accuracy"):
		overall_accuracy = save_data.overall_accuracy
	
	if save_data.has("current_streak"):
		current_streak = save_data.current_streak
	
	if save_data.has("best_streak"):
		best_streak = save_data.best_streak
	
	if save_data.has("specialty_performance"):
		specialty_performance = save_data.specialty_performance
	
	if save_data.has("adaptive_weights"):
		adaptive_weights = save_data.adaptive_weights
	
	if save_data.has("milestones"):
		milestones = save_data.milestones
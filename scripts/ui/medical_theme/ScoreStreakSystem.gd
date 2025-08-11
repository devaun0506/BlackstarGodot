class_name ScoreStreakSystem
extends Node

# Score and streak tracking system for Blackstar
# Provides performance feedback with medical-themed presentation

signal score_updated(new_score: int, score_change: int)
signal streak_updated(new_streak: int, streak_change: int)
signal accuracy_updated(new_accuracy: float)
signal performance_milestone(milestone_type: String, value: int)

# Performance tracking
var total_score: int = 0
var current_streak: int = 0
var longest_streak: int = 0
var questions_answered: int = 0
var correct_answers: int = 0
var current_accuracy: float = 0.0

# Scoring configuration
@export var base_correct_points: int = 100
@export var time_bonus_multiplier: float = 0.5
@export var streak_bonus_multiplier: float = 0.1
@export var difficulty_multiplier: Dictionary = {1: 1.0, 2: 1.5, 3: 2.0}

# Performance categories (for medical context)
var performance_categories: Dictionary = {
	"excellent": {"threshold": 0.95, "color": MedicalColors.SUCCESS_GREEN, "title": "Attending Level"},
	"very_good": {"threshold": 0.90, "color": MedicalColors.MONITOR_GREEN, "title": "Senior Resident Level"},
	"good": {"threshold": 0.80, "color": MedicalColors.WARNING_AMBER, "title": "Resident Level"},
	"fair": {"threshold": 0.70, "color": MedicalColors.URGENT_ORANGE, "title": "Intern Level"},
	"needs_improvement": {"threshold": 0.0, "color": MedicalColors.ERROR_RED, "title": "Medical Student Level"}
}

# UI References
@onready var score_display: Label
@onready var streak_display: Label
@onready var accuracy_display: Label
@onready var performance_display: Label
@onready var milestone_popup: Control

func _ready():
	update_all_displays()

func answer_question(correct: bool, time_remaining: float, max_time: float, difficulty: int = 1):
	"""Process a question answer and update all metrics"""
	
	questions_answered += 1
	
	if correct:
		correct_answers += 1
		current_streak += 1
		longest_streak = max(longest_streak, current_streak)
		
		# Calculate score
		var points_earned = calculate_points(time_remaining, max_time, difficulty)
		total_score += points_earned
		
		# Emit updates
		score_updated.emit(total_score, points_earned)
		streak_updated.emit(current_streak, 1)
		
		# Check for milestones
		check_milestones()
		
	else:
		# Incorrect answer breaks streak
		var old_streak = current_streak
		current_streak = 0
		streak_updated.emit(current_streak, -old_streak)
	
	# Update accuracy
	current_accuracy = float(correct_answers) / float(questions_answered)
	accuracy_updated.emit(current_accuracy)
	
	# Update all displays
	update_all_displays()

func calculate_points(time_remaining: float, max_time: float, difficulty: int) -> int:
	"""Calculate points earned for a correct answer"""
	
	var base_points = base_correct_points
	
	# Apply difficulty multiplier
	if difficulty_multiplier.has(difficulty):
		base_points = int(base_points * difficulty_multiplier[difficulty])
	
	# Time bonus (faster answers get more points)
	var time_bonus = int((time_remaining / max_time) * base_points * time_bonus_multiplier)
	
	# Streak bonus
	var streak_bonus = int(current_streak * base_points * streak_bonus_multiplier)
	
	return base_points + time_bonus + streak_bonus

func get_performance_category() -> Dictionary:
	"""Get current performance category based on accuracy"""
	
	for category in ["excellent", "very_good", "good", "fair", "needs_improvement"]:
		if current_accuracy >= performance_categories[category]["threshold"]:
			return performance_categories[category]
	
	return performance_categories["needs_improvement"]

func update_all_displays():
	"""Update all connected display elements"""
	
	if score_display:
		score_display.text = "Score: %s" % format_score(total_score)
		MedicalFont.apply_font_config(score_display, MedicalFont.get_score_font_config())
	
	if streak_display:
		streak_display.text = "Streak: %d" % current_streak
		
		# Color based on streak length
		var streak_color = get_streak_color(current_streak)
		streak_display.add_theme_color_override("font_color", streak_color)
		MedicalFont.apply_font_config(streak_display, MedicalFont.get_score_font_config())
	
	if accuracy_display:
		accuracy_display.text = "Accuracy: %d%%" % int(current_accuracy * 100)
		
		# Color based on performance category
		var perf_category = get_performance_category()
		accuracy_display.add_theme_color_override("font_color", perf_category["color"])
		MedicalFont.apply_font_config(accuracy_display, MedicalFont.get_score_font_config())
	
	if performance_display:
		var perf_category = get_performance_category()
		performance_display.text = perf_category["title"]
		performance_display.add_theme_color_override("font_color", perf_category["color"])
		MedicalFont.apply_font_config(performance_display, MedicalFont.get_label_font_config())

func format_score(score: int) -> String:
	"""Format score with appropriate separators"""
	if score >= 1000000:
		return "%.1fM" % (score / 1000000.0)
	elif score >= 1000:
		return "%.1fK" % (score / 1000.0)
	else:
		return str(score)

func get_streak_color(streak: int) -> Color:
	"""Get color for streak display based on streak length"""
	if streak >= 20:
		return MedicalColors.SUCCESS_GREEN
	elif streak >= 10:
		return MedicalColors.MONITOR_GREEN
	elif streak >= 5:
		return MedicalColors.WARNING_AMBER
	elif streak >= 2:
		return MedicalColors.TEXT_LIGHT
	else:
		return MedicalColors.TEXT_MUTED

func check_milestones():
	"""Check for performance milestones and achievements"""
	
	# Streak milestones
	if current_streak > 0 and current_streak % 5 == 0:
		performance_milestone.emit("streak", current_streak)
		show_milestone_popup("Streak Milestone!", "%d Correct in a Row!" % current_streak, 
							MedicalColors.SUCCESS_GREEN)
	
	# Score milestones
	var score_milestones = [1000, 5000, 10000, 25000, 50000, 100000]
	for milestone in score_milestones:
		if total_score >= milestone and total_score - calculate_points(0, 45, 1) < milestone:
			performance_milestone.emit("score", milestone)
			show_milestone_popup("Score Milestone!", "%s Points Reached!" % format_score(milestone), 
								MedicalColors.MONITOR_GREEN)
			break
	
	# Accuracy milestones (only after sufficient questions)
	if questions_answered >= 20:
		var accuracy_percent = int(current_accuracy * 100)
		var milestones = [70, 80, 90, 95]
		
		for milestone in milestones:
			if accuracy_percent >= milestone:
				var previous_accuracy = float(correct_answers - 1) / float(questions_answered - 1)
				if int(previous_accuracy * 100) < milestone:
					performance_milestone.emit("accuracy", milestone)
					show_milestone_popup("Accuracy Milestone!", "%d%% Accuracy Achieved!" % milestone, 
										get_performance_category()["color"])
				break

func show_milestone_popup(title: String, description: String, color: Color):
	"""Show milestone achievement popup"""
	
	if milestone_popup:
		# Animate popup appearance
		milestone_popup.modulate = Color(color.r, color.g, color.b, 0.0)
		milestone_popup.visible = true
		
		# Find or create popup elements
		var title_label = milestone_popup.find_child("Title", true, false) as Label
		var desc_label = milestone_popup.find_child("Description", true, false) as Label
		
		if title_label:
			title_label.text = title
			title_label.add_theme_color_override("font_color", color)
		
		if desc_label:
			desc_label.text = description
		
		# Animate popup
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BOUNCE)
		
		# Fade in and scale up
		tween.parallel().tween_property(milestone_popup, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(milestone_popup, "scale", Vector2.ONE, 0.3)
		
		# Hold for 2 seconds
		tween.tween_delay(2.0)
		
		# Fade out
		tween.parallel().tween_property(milestone_popup, "modulate:a", 0.0, 0.5)
		tween.parallel().tween_property(milestone_popup, "scale", Vector2.ZERO, 0.5)
		
		# Hide when done
		tween.tween_callback(func(): milestone_popup.visible = false)

func get_session_summary() -> Dictionary:
	"""Get summary of current session performance"""
	
	var performance_category = get_performance_category()
	
	return {
		"total_score": total_score,
		"questions_answered": questions_answered,
		"correct_answers": correct_answers,
		"accuracy": current_accuracy,
		"current_streak": current_streak,
		"longest_streak": longest_streak,
		"performance_level": performance_category["title"],
		"performance_color": performance_category["color"]
	}

func get_medical_performance_feedback() -> String:
	"""Get medical-context performance feedback"""
	
	var accuracy_percent = int(current_accuracy * 100)
	
	if accuracy_percent >= 95:
		return "Outstanding clinical judgment! You're performing at attending level."
	elif accuracy_percent >= 90:
		return "Excellent diagnostic skills. You're ready for senior resident responsibilities."
	elif accuracy_percent >= 80:
		return "Good clinical reasoning. Continue developing your decision-making skills."
	elif accuracy_percent >= 70:
		return "Adequate performance. Focus on reviewing missed topics and pattern recognition."
	elif accuracy_percent >= 60:
		return "Needs improvement. Consider reviewing fundamental concepts and practice more cases."
	else:
		return "Significant improvement needed. Review basic medical knowledge and seek additional study resources."

func get_streak_encouragement() -> String:
	"""Get encouraging messages based on streak performance"""
	
	if current_streak >= 20:
		return "Incredible streak! Your clinical decision-making is exceptional."
	elif current_streak >= 15:
		return "Outstanding consistency! You're in the zone."
	elif current_streak >= 10:
		return "Great streak! You're showing excellent clinical judgment."
	elif current_streak >= 5:
		return "Good momentum! Keep up the focused decision-making."
	elif current_streak >= 2:
		return "Building confidence! Stay focused on the next case."
	else:
		return "Every expert was once a beginner. Learn from each case and improve."

func reset_session():
	"""Reset all session statistics"""
	total_score = 0
	current_streak = 0
	questions_answered = 0
	correct_answers = 0
	current_accuracy = 0.0
	
	update_all_displays()

func connect_display_elements(score_label: Label, streak_label: Label, accuracy_label: Label, 
							  performance_label: Label = null, popup: Control = null):
	"""Connect UI elements for automatic updates"""
	score_display = score_label
	streak_display = streak_label
	accuracy_display = accuracy_label
	performance_display = performance_label
	milestone_popup = popup
	
	update_all_displays()

# Animation effects for score changes
func animate_score_change(points_earned: int):
	"""Animate score increase with floating text effect"""
	
	if score_display and points_earned > 0:
		# Create floating text effect
		var floating_text = Label.new()
		floating_text.text = "+%d" % points_earned
		floating_text.add_theme_color_override("font_color", MedicalColors.SUCCESS_GREEN)
		MedicalFont.apply_font_config(floating_text, MedicalFont.get_score_font_config())
		
		# Add to scene temporarily
		score_display.get_parent().add_child(floating_text)
		floating_text.position = score_display.position + Vector2(0, -20)
		
		# Animate upward movement and fade
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		
		tween.parallel().tween_property(floating_text, "position:y", 
										floating_text.position.y - 40, 1.0)
		tween.parallel().tween_property(floating_text, "modulate:a", 0.0, 1.0)
		
		tween.tween_callback(floating_text.queue_free)

func animate_streak_break():
	"""Animate streak breaking with visual feedback"""
	
	if streak_display:
		# Flash red briefly
		var original_color = streak_display.get_theme_color("font_color")
		
		var tween = create_tween()
		tween.tween_property(streak_display, "modulate", Color.RED, 0.1)
		tween.tween_property(streak_display, "modulate", Color.WHITE, 0.1)
		tween.tween_property(streak_display, "modulate", Color.RED, 0.1)
		tween.tween_property(streak_display, "modulate", Color.WHITE, 0.1)
class_name MedicalFont
extends RefCounted

# Medical Typography System for Blackstar
# Optimized for medical documentation readability within pixel art constraints

# Font size constants for different UI elements
const CHART_HEADER_SIZE = 16
const CHART_BODY_SIZE = 14
const CHART_SMALL_SIZE = 12
const UI_BUTTON_SIZE = 14
const UI_LABEL_SIZE = 12
const TIMER_SIZE = 18
const SCORE_SIZE = 16
const QUESTION_SIZE = 15
const CHOICE_SIZE = 14

# Font weight simulation through styling
const BOLD_OUTLINE = 1.0
const NORMAL_OUTLINE = 0.5
const LIGHT_OUTLINE = 0.2

# Character spacing for readability
const NORMAL_SPACING = 0
const TIGHT_SPACING = -1
const LOOSE_SPACING = 1

# Line height multipliers for different text types
const CHART_LINE_HEIGHT = 1.3  # Medical charts need good readability
const UI_LINE_HEIGHT = 1.2     # Standard UI text
const COMPACT_LINE_HEIGHT = 1.1  # For space-constrained areas

# Font configurations for different contexts
static func get_chart_font_config() -> Dictionary:
	"""Font configuration for patient chart text"""
	return {
		"size": CHART_BODY_SIZE,
		"outline_size": NORMAL_OUTLINE,
		"outline_color": MedicalColors.TEXT_DARK,
		"font_color": MedicalColors.TEXT_DARK,
		"spacing": NORMAL_SPACING,
		"line_height": CHART_LINE_HEIGHT
	}

static func get_chart_header_font_config() -> Dictionary:
	"""Font configuration for chart headers and vital signs"""
	return {
		"size": CHART_HEADER_SIZE,
		"outline_size": BOLD_OUTLINE,
		"outline_color": MedicalColors.MEDICAL_GREEN_DARK,
		"font_color": MedicalColors.MEDICAL_GREEN_DARK,
		"spacing": LOOSE_SPACING,
		"line_height": UI_LINE_HEIGHT
	}

static func get_vital_signs_font_config() -> Dictionary:
	"""Font configuration for vital signs - needs high readability"""
	return {
		"size": CHART_BODY_SIZE,
		"outline_size": BOLD_OUTLINE,
		"outline_color": MedicalColors.URGENT_RED,
		"font_color": MedicalColors.TEXT_DARK,
		"spacing": NORMAL_SPACING,
		"line_height": UI_LINE_HEIGHT
	}

static func get_question_font_config() -> Dictionary:
	"""Font configuration for question text"""
	return {
		"size": QUESTION_SIZE,
		"outline_size": NORMAL_OUTLINE,
		"outline_color": MedicalColors.TEXT_DARK,
		"font_color": MedicalColors.TEXT_DARK,
		"spacing": NORMAL_SPACING,
		"line_height": CHART_LINE_HEIGHT
	}

static func get_choice_font_config() -> Dictionary:
	"""Font configuration for answer choices"""
	return {
		"size": CHOICE_SIZE,
		"outline_size": NORMAL_OUTLINE,
		"outline_color": MedicalColors.TEXT_DARK,
		"font_color": MedicalColors.TEXT_DARK,
		"spacing": NORMAL_SPACING,
		"line_height": UI_LINE_HEIGHT
	}

static func get_timer_font_config(urgency_level: float = 0.0) -> Dictionary:
	"""Font configuration for timer display with urgency coloring"""
	var color = MedicalColors.get_timer_color(urgency_level, 1.0)
	return {
		"size": TIMER_SIZE,
		"outline_size": BOLD_OUTLINE,
		"outline_color": color,
		"font_color": color,
		"spacing": TIGHT_SPACING,
		"line_height": UI_LINE_HEIGHT
	}

static func get_score_font_config() -> Dictionary:
	"""Font configuration for score and streak display"""
	return {
		"size": SCORE_SIZE,
		"outline_size": NORMAL_OUTLINE,
		"outline_color": MedicalColors.MONITOR_GREEN,
		"font_color": MedicalColors.MONITOR_GREEN,
		"spacing": NORMAL_SPACING,
		"line_height": UI_LINE_HEIGHT
	}

static func get_button_font_config() -> Dictionary:
	"""Font configuration for UI buttons"""
	return {
		"size": UI_BUTTON_SIZE,
		"outline_size": NORMAL_OUTLINE,
		"outline_color": MedicalColors.TEXT_LIGHT,
		"font_color": MedicalColors.TEXT_LIGHT,
		"spacing": NORMAL_SPACING,
		"line_height": UI_LINE_HEIGHT
	}

static func get_label_font_config() -> Dictionary:
	"""Font configuration for UI labels and secondary text"""
	return {
		"size": UI_LABEL_SIZE,
		"outline_size": LIGHT_OUTLINE,
		"outline_color": MedicalColors.TEXT_MUTED,
		"font_color": MedicalColors.TEXT_MUTED,
		"spacing": NORMAL_SPACING,
		"line_height": UI_LINE_HEIGHT
	}

# Utility function to apply font configuration to Label or Button nodes
static func apply_font_config(node: Control, config: Dictionary) -> void:
	"""Apply font configuration to a Label or Button node"""
	if node == null:
		return
	
	# Verify node type supports font theming
	if not (node is Label or node is Button):
		push_error("MedicalFont: apply_font_config() only supports Label and Button nodes, got: " + str(node.get_class()))
		return
	
	# Apply font size
	if config.has("size"):
		node.add_theme_font_size_override("font_size", config.size)
	
	# Apply font color
	if config.has("font_color"):
		node.add_theme_color_override("font_color", config.font_color)
	
	# Apply outline
	if config.has("outline_size") and config.has("outline_color"):
		node.add_theme_constant_override("outline_size", int(config.outline_size))
		node.add_theme_color_override("font_outline_color", config.outline_color)

# Create medical document-style text formatting
static func format_patient_demographics(text: String) -> String:
	"""Format patient demographics in standard medical format"""
	return "[b]PATIENT:[/b] " + text

static func format_vital_signs(vitals: Dictionary) -> String:
	"""Format vital signs in standard medical chart format"""
	var formatted = "[b]VITAL SIGNS:[/b]\n"
	if vitals.has("BP"):
		formatted += "BP: " + str(vitals.BP) + "\n"
	if vitals.has("HR"):
		formatted += "HR: " + str(vitals.HR) + "\n"
	if vitals.has("RR"):
		formatted += "RR: " + str(vitals.RR) + "\n"
	if vitals.has("Temp"):
		formatted += "Temp: " + str(vitals.Temp) + "\n"
	if vitals.has("O2Sat"):
		formatted += "O2Sat: " + str(vitals.O2Sat)
	return formatted

static func format_chart_section(title: String, content: String) -> String:
	"""Format a chart section with consistent medical styling"""
	return "[b]" + title.to_upper() + ":[/b]\n" + content

static func highlight_abnormal_values(text: String, abnormal_terms: Array = []) -> String:
	"""Highlight abnormal values in medical text"""
	var highlighted = text
	for term in abnormal_terms:
		highlighted = highlighted.replace(term, "[color=#D94545]" + term + "[/color]")
	return highlighted
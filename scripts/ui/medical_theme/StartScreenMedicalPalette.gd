class_name StartScreenMedicalPalette
extends RefCounted

# Blackstar Start Screen Medical Color Palette
# 32-color constraint optimized for hospital emergency department aesthetic
# Designed for pixel art medical environment with authentic details

# Core Hospital Environment Colors (8 colors)
const HOSPITAL_GREEN_DARK = Color(0.29, 0.42, 0.30)      # #4A6B4D - Main hospital walls
const HOSPITAL_GREEN_MAIN = Color(0.35, 0.48, 0.36)      # #5A7B5D - Primary UI elements
const STERILE_BLUE_MAIN = Color(0.42, 0.48, 0.54)        # #6B7B8A - Medical equipment
const STERILE_BLUE_LIGHT = Color(0.48, 0.54, 0.60)       # #7B8B9A - Highlight elements
const URGENT_RED_MAIN = Color(0.54, 0.29, 0.29)          # #8A4A4A - Emergency alerts
const URGENT_RED_LIGHT = Color(0.60, 0.35, 0.35)         # #9A5A5A - Urgent warnings
const COFFEE_BROWN_DARK = Color(0.29, 0.23, 0.16)        # #4A3A2A - Coffee stains/wear
const COFFEE_BROWN_LIGHT = Color(0.35, 0.29, 0.23)       # #5A4A3A - Light wear marks

# Paper and Documentation Colors (6 colors)
const PAPER_WHITE_CLEAN = Color(0.94, 0.94, 0.91)        # #F0F0E8 - Clean clipboards
const PAPER_WHITE_WORN = Color(0.91, 0.91, 0.88)         # #E8E8E0 - Worn paperwork
const CHART_BEIGE_LIGHT = Color(0.96, 0.93, 0.86)        # #F5EEDC - Medical chart paper
const CHART_BEIGE_STAINED = Color(0.89, 0.85, 0.78)      # #E3D8C7 - Coffee-stained charts
const TEXT_BLACK_MAIN = Color(0.13, 0.13, 0.13)          # #212121 - Primary text
const TEXT_GRAY_MUTED = Color(0.45, 0.45, 0.45)          # #737373 - Secondary text

# Medical Equipment Colors (8 colors)
const EQUIPMENT_SILVER = Color(0.67, 0.70, 0.71)         # #ABB3B5 - Stethoscopes, equipment
const EQUIPMENT_SILVER_DARK = Color(0.55, 0.58, 0.59)    # #8C9497 - Equipment shadows
const MONITOR_GREEN_BRIGHT = Color(0.20, 0.85, 0.30)     # #33D94D - Active monitors
const MONITOR_GREEN_DIM = Color(0.15, 0.65, 0.23)        # #26A53A - Idle monitors
const WARNING_AMBER = Color(0.85, 0.65, 0.15)            # #D9A626 - Warning indicators
const WARNING_ORANGE = Color(0.85, 0.45, 0.15)           # #D97326 - Alert indicators
const IV_TUBE_CLEAR = Color(0.88, 0.92, 0.95)            # #E1EBF2 - Medical tubing
const METAL_CHROME = Color(0.80, 0.82, 0.84)             # #CCD1D6 - Metal fixtures

# Environmental Atmosphere Colors (6 colors)
const FLUORESCENT_HARSH = Color(0.98, 0.98, 0.96)        # #FAFAF5 - Harsh lighting
const SHADOW_DEEP_BLUE = Color(0.08, 0.12, 0.16)         # #141F28 - Deep shadows
const NIGHT_SHIFT_BLUE = Color(0.12, 0.16, 0.22)         # #1F2938 - Night atmosphere
const FATIGUE_PURPLE = Color(0.18, 0.15, 0.22)           # #2E2638 - Tired undertones
const STRESS_RED_TINT = Color(0.25, 0.12, 0.12)          # #401F1F - High-stress atmosphere
const CALM_GREEN_TINT = Color(0.12, 0.20, 0.15)          # #1F3326 - Calm periods

# UI Feedback Colors (4 colors)
const SUCCESS_FEEDBACK = Color(0.25, 0.75, 0.45)         # #40BF73 - Correct answers
const ERROR_FEEDBACK = Color(0.80, 0.25, 0.25)           # #CC4040 - Wrong answers
const INFO_HIGHLIGHT = Color(0.25, 0.55, 0.80)           # #408CCC - Information
const NEUTRAL_GRAY = Color(0.60, 0.62, 0.64)             # #999FA3 - Neutral elements

# Pixel Art Specific Palette Constraints
const TOTAL_COLORS = 32
const PALETTE_NAME = "Blackstar Medical Emergency"

# Organized color arrays for easy access
static var hospital_environment_colors: Array[Color] = [
	HOSPITAL_GREEN_DARK, HOSPITAL_GREEN_MAIN, STERILE_BLUE_MAIN, STERILE_BLUE_LIGHT,
	URGENT_RED_MAIN, URGENT_RED_LIGHT, COFFEE_BROWN_DARK, COFFEE_BROWN_LIGHT
]

static var paper_documentation_colors: Array[Color] = [
	PAPER_WHITE_CLEAN, PAPER_WHITE_WORN, CHART_BEIGE_LIGHT, 
	CHART_BEIGE_STAINED, TEXT_BLACK_MAIN, TEXT_GRAY_MUTED
]

static var medical_equipment_colors: Array[Color] = [
	EQUIPMENT_SILVER, EQUIPMENT_SILVER_DARK, MONITOR_GREEN_BRIGHT, MONITOR_GREEN_DIM,
	WARNING_AMBER, WARNING_ORANGE, IV_TUBE_CLEAR, METAL_CHROME
]

static var atmosphere_colors: Array[Color] = [
	FLUORESCENT_HARSH, SHADOW_DEEP_BLUE, NIGHT_SHIFT_BLUE, 
	FATIGUE_PURPLE, STRESS_RED_TINT, CALM_GREEN_TINT
]

static var feedback_colors: Array[Color] = [
	SUCCESS_FEEDBACK, ERROR_FEEDBACK, INFO_HIGHLIGHT, NEUTRAL_GRAY
]

static var complete_palette: Array[Color] = []

static func _static_init():
	"""Initialize the complete color palette"""
	complete_palette.clear()
	complete_palette.append_array(hospital_environment_colors)
	complete_palette.append_array(paper_documentation_colors)
	complete_palette.append_array(medical_equipment_colors)
	complete_palette.append_array(atmosphere_colors)
	complete_palette.append_array(feedback_colors)

# Color utility functions for start screen design

static func get_color_by_index(index: int) -> Color:
	"""Get color by palette index (0-31)"""
	if complete_palette.is_empty():
		_static_init()
	
	if index >= 0 and index < complete_palette.size():
		return complete_palette[index]
	return Color.MAGENTA  # Error color

static func get_color_by_name(color_name: String) -> Color:
	"""Get color by descriptive name"""
	match color_name.to_lower():
		# Hospital environment
		"hospital_wall", "wall_green":
			return HOSPITAL_GREEN_DARK
		"ui_primary", "main_green":
			return HOSPITAL_GREEN_MAIN
		"equipment_main", "medical_blue":
			return STERILE_BLUE_MAIN
		"equipment_highlight":
			return STERILE_BLUE_LIGHT
		"emergency", "urgent_main":
			return URGENT_RED_MAIN
		"urgent_light":
			return URGENT_RED_LIGHT
		"coffee_stain", "wear_dark":
			return COFFEE_BROWN_DARK
		"wear_light":
			return COFFEE_BROWN_LIGHT
		
		# Paper and documentation
		"clipboard", "paper_clean":
			return PAPER_WHITE_CLEAN
		"paper_worn":
			return PAPER_WHITE_WORN
		"chart_paper":
			return CHART_BEIGE_LIGHT
		"chart_stained":
			return CHART_BEIGE_STAINED
		"text_main", "black_text":
			return TEXT_BLACK_MAIN
		"text_secondary", "gray_text":
			return TEXT_GRAY_MUTED
		
		# Medical equipment
		"stethoscope", "equipment_silver":
			return EQUIPMENT_SILVER
		"equipment_shadow":
			return EQUIPMENT_SILVER_DARK
		"monitor_active", "heart_monitor":
			return MONITOR_GREEN_BRIGHT
		"monitor_idle":
			return MONITOR_GREEN_DIM
		"warning", "caution_amber":
			return WARNING_AMBER
		"alert", "warning_orange":
			return WARNING_ORANGE
		"iv_tubing", "medical_clear":
			return IV_TUBE_CLEAR
		"metal_fixture":
			return METAL_CHROME
		
		# Atmosphere
		"fluorescent", "harsh_light":
			return FLUORESCENT_HARSH
		"deep_shadow":
			return SHADOW_DEEP_BLUE
		"night_shift":
			return NIGHT_SHIFT_BLUE
		"fatigue", "tired_purple":
			return FATIGUE_PURPLE
		"stress", "high_stress":
			return STRESS_RED_TINT
		"calm", "peaceful_green":
			return CALM_GREEN_TINT
		
		# Feedback
		"correct", "success":
			return SUCCESS_FEEDBACK
		"wrong", "error":
			return ERROR_FEEDBACK
		"info", "information":
			return INFO_HIGHLIGHT
		"neutral":
			return NEUTRAL_GRAY
		
		_:
			push_warning("Color name '%s' not found in StartScreenMedicalPalette" % color_name)
			return Color.MAGENTA

static func get_clipboard_button_colors() -> Dictionary:
	"""Get color set for medical clipboard-style buttons"""
	return {
		"background": PAPER_WHITE_CLEAN,
		"background_worn": PAPER_WHITE_WORN,
		"border": EQUIPMENT_SILVER_DARK,
		"text": TEXT_BLACK_MAIN,
		"text_secondary": TEXT_GRAY_MUTED,
		"hover_tint": STERILE_BLUE_LIGHT,
		"press_tint": HOSPITAL_GREEN_MAIN,
		"coffee_stain": COFFEE_BROWN_LIGHT
	}

static func get_id_badge_colors() -> Dictionary:
	"""Get color set for hospital ID badge aesthetic"""
	return {
		"background": PAPER_WHITE_CLEAN,
		"border": URGENT_RED_MAIN,
		"clip_metal": METAL_CHROME,
		"text": TEXT_BLACK_MAIN,
		"photo_tint": STERILE_BLUE_MAIN,
		"wear_marks": COFFEE_BROWN_DARK
	}

static func get_medical_equipment_colors() -> Dictionary:
	"""Get color set for medical equipment styling"""
	return {
		"main_body": EQUIPMENT_SILVER,
		"shadow": EQUIPMENT_SILVER_DARK,
		"screen_active": MONITOR_GREEN_BRIGHT,
		"screen_idle": MONITOR_GREEN_DIM,
		"warning_light": WARNING_AMBER,
		"alert_light": WARNING_ORANGE,
		"cables": SHADOW_DEEP_BLUE,
		"chrome_details": METAL_CHROME
	}

static func get_coffee_cup_colors() -> Dictionary:
	"""Get color set for coffee cup environmental detail"""
	return {
		"cup_white": PAPER_WHITE_WORN,
		"coffee_liquid": COFFEE_BROWN_DARK,
		"steam_light": FLUORESCENT_HARSH,
		"handle": EQUIPMENT_SILVER,
		"stain_ring": COFFEE_BROWN_LIGHT,
		"reflection": IV_TUBE_CLEAR
	}

static func get_fluorescent_lighting_colors() -> Dictionary:
	"""Get color set for fluorescent lighting effects"""
	return {
		"main_light": FLUORESCENT_HARSH,
		"flicker_dim": PAPER_WHITE_CLEAN,
		"shadow_cast": SHADOW_DEEP_BLUE,
		"night_mode": NIGHT_SHIFT_BLUE,
		"fatigue_tint": FATIGUE_PURPLE,
		"stress_overlay": STRESS_RED_TINT
	}

static func get_triage_area_colors() -> Dictionary:
	"""Get color set for emergency triage area background"""
	return {
		"wall_main": HOSPITAL_GREEN_DARK,
		"wall_highlight": HOSPITAL_GREEN_MAIN,
		"floor_tile": STERILE_BLUE_MAIN,
		"floor_grout": SHADOW_DEEP_BLUE,
		"signage": URGENT_RED_MAIN,
		"signage_text": PAPER_WHITE_CLEAN,
		"wear_marks": COFFEE_BROWN_DARK,
		"equipment_area": EQUIPMENT_SILVER
	}

static func apply_wear_effect(base_color: Color, wear_level: float = 0.1) -> Color:
	"""Apply authentic wear effect to colors"""
	wear_level = clampf(wear_level, 0.0, 0.5)
	var wear_color = COFFEE_BROWN_LIGHT
	return base_color.lerp(wear_color, wear_level)

static func apply_coffee_stain(base_color: Color, stain_intensity: float = 0.05) -> Color:
	"""Apply coffee stain effect to paper/surface colors"""
	stain_intensity = clampf(stain_intensity, 0.0, 0.3)
	return base_color.lerp(COFFEE_BROWN_DARK, stain_intensity)

static func get_urgency_tint(urgency_level: float) -> Color:
	"""Get color tint based on medical urgency (0.0 = calm, 1.0 = critical)"""
	urgency_level = clampf(urgency_level, 0.0, 1.0)
	
	if urgency_level >= 0.8:
		return URGENT_RED_MAIN
	elif urgency_level >= 0.6:
		return WARNING_ORANGE
	elif urgency_level >= 0.4:
		return WARNING_AMBER
	elif urgency_level >= 0.2:
		return INFO_HIGHLIGHT
	else:
		return CALM_GREEN_TINT

static func get_time_of_day_overlay(hour_24: int) -> Color:
	"""Get atmospheric overlay color based on time of day"""
	
	match hour_24:
		0, 1, 2, 3, 4, 5:  # Deep night shift
			return NIGHT_SHIFT_BLUE
		6, 7:  # Early morning fatigue
			return FATIGUE_PURPLE
		8, 9, 10, 11, 12, 13, 14, 15:  # Day shift
			return Color.TRANSPARENT  # No overlay during day
		16, 17, 18:  # Evening
			return STRESS_RED_TINT.lerp(Color.TRANSPARENT, 0.7)
		19, 20, 21:  # Evening stress
			return STRESS_RED_TINT.lerp(Color.TRANSPARENT, 0.5)
		22, 23:  # Late night preparation
			return NIGHT_SHIFT_BLUE.lerp(Color.TRANSPARENT, 0.3)
		_:
			return Color.TRANSPARENT

static func validate_palette_size() -> bool:
	"""Validate that the palette meets the 32-color constraint"""
	if complete_palette.is_empty():
		_static_init()
	
	return complete_palette.size() == TOTAL_COLORS

static func get_palette_summary() -> Dictionary:
	"""Get summary information about the color palette"""
	if complete_palette.is_empty():
		_static_init()
	
	return {
		"name": PALETTE_NAME,
		"total_colors": complete_palette.size(),
		"meets_constraint": validate_palette_size(),
		"categories": {
			"hospital_environment": hospital_environment_colors.size(),
			"paper_documentation": paper_documentation_colors.size(),
			"medical_equipment": medical_equipment_colors.size(),
			"atmosphere": atmosphere_colors.size(),
			"ui_feedback": feedback_colors.size()
		}
	}
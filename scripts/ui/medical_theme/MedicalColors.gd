class_name MedicalColors
extends RefCounted

# Medical-themed color palette for Blackstar
# Balances clinical precision with human warmth

# Primary Medical Colors
const MEDICAL_GREEN = Color(0.19, 0.31, 0.28)  # #314F47 - Primary UI background
const MEDICAL_GREEN_LIGHT = Color(0.23, 0.38, 0.34)  # Hover states
const MEDICAL_GREEN_DARK = Color(0.15, 0.25, 0.22)  # Pressed states

const STERILE_BLUE = Color(0.29, 0.42, 0.49)  # #4A6B7C - Secondary elements
const STERILE_BLUE_LIGHT = Color(0.35, 0.48, 0.55)  # Information highlights
const STERILE_BLUE_DARK = Color(0.23, 0.36, 0.43)  # Borders and outlines

# Urgency Colors
const URGENT_RED = Color(0.85, 0.27, 0.27)  # #D94545 - Critical alerts, timer warnings
const URGENT_RED_LIGHT = Color(0.92, 0.45, 0.45)  # Hover over urgent elements
const URGENT_ORANGE = Color(0.85, 0.55, 0.27)  # Medium priority
const URGENT_YELLOW = Color(0.85, 0.78, 0.27)  # Low priority alerts

# Paper and Documentation Colors
const CHART_PAPER = Color(0.98, 0.96, 0.91)  # #FAF5E8 - Patient chart backgrounds
const CHART_PAPER_STAINED = Color(0.94, 0.90, 0.82)  # Coffee stains and wear
const TEXT_DARK = Color(0.15, 0.15, 0.15)  # Primary text on light backgrounds
const TEXT_LIGHT = Color(0.95, 0.95, 0.95)  # Text on dark backgrounds
const TEXT_MUTED = Color(0.55, 0.55, 0.55)  # Secondary information

# Equipment and Interface Colors
const EQUIPMENT_GRAY = Color(0.55, 0.60, 0.61)  # #8B9A9C - Medical equipment
const EQUIPMENT_GRAY_DARK = Color(0.45, 0.50, 0.51)  # Shadows and depth
const MONITOR_GREEN = Color(0.20, 0.80, 0.20)  # Heart rate monitors, success states
const MONITOR_AMBER = Color(1.0, 0.75, 0.0)  # Warning states on medical equipment

# Atmosphere Colors
const FLUORESCENT_WHITE = Color(0.96, 0.96, 0.94)  # Harsh hospital lighting
const SHADOW_BLUE = Color(0.12, 0.18, 0.22)  # Deep shadows, night shift atmosphere
const COFFEE_BROWN = Color(0.40, 0.26, 0.13)  # Coffee stains, human touches
const WEAR_GRAY = Color(0.75, 0.75, 0.70)  # Worn surfaces, age

# Success and Feedback Colors
const SUCCESS_GREEN = Color(0.27, 0.67, 0.46)  # Correct answers, good outcomes
const WARNING_AMBER = Color(0.85, 0.65, 0.13)  # Caution states
const ERROR_RED = Color(0.80, 0.25, 0.25)  # Wrong answers, critical errors
const INFO_BLUE = Color(0.25, 0.55, 0.80)  # Informational elements

# Transparency variants for overlays and effects
const OVERLAY_DARK = Color(0.0, 0.0, 0.0, 0.6)  # Modal backgrounds
const OVERLAY_LIGHT = Color(1.0, 1.0, 1.0, 0.8)  # Light overlays
const GLASS_EFFECT = Color(1.0, 1.0, 1.0, 0.1)  # Subtle glass effects

# Enhanced Medical Color Hierarchy System
# Proper urgency levels for medical decision-making

# Critical Priority Colors (Life-threatening)
const CRITICAL_RED = Color(0.95, 0.15, 0.15)  # Immediate intervention required
const CRITICAL_RED_PULSE = Color(1.0, 0.3, 0.3)  # Pulsing effect for critical alerts

# High Priority Colors (Urgent but stable)
const HIGH_ORANGE = Color(0.95, 0.65, 0.15)  # Urgent attention needed
const HIGH_YELLOW = Color(0.95, 0.85, 0.15)  # Elevated concern

# Medium Priority Colors (Stable but monitoring)
const MEDIUM_AMBER = Color(0.85, 0.75, 0.25)  # Routine monitoring
const MEDIUM_BLUE = Color(0.25, 0.65, 0.85)  # Stable condition

# Low Priority Colors (Routine care)
const LOW_GREEN = Color(0.25, 0.75, 0.45)  # Normal/stable
const LOW_GRAY = Color(0.65, 0.7, 0.72)  # Non-critical

# Medical Context Colors
const MEDICATION_PURPLE = Color(0.6, 0.3, 0.8)  # Medication-related
const DIAGNOSTIC_CYAN = Color(0.2, 0.8, 0.8)  # Diagnostic results
const PROCEDURE_MAGENTA = Color(0.8, 0.2, 0.6)  # Procedures/interventions

# Pixel Art Atmosphere Colors
const NIGHT_SHIFT_BLUE = Color(0.08, 0.12, 0.18)  # 3 AM atmosphere
const TIRED_PURPLE = Color(0.15, 0.12, 0.18)  # Fatigue undertones
const STRESS_RED_TINT = Color(0.22, 0.08, 0.08)  # High-stress undertones
const CALM_GREEN_TINT = Color(0.08, 0.15, 0.12)  # Calm periods

# Environmental Storytelling Colors
const OLD_EQUIPMENT_BEIGE = Color(0.85, 0.82, 0.75)  # Worn medical equipment
const FRESH_LINEN_WHITE = Color(0.98, 0.97, 0.96)  # Clean medical linens
const BLOOD_STAIN_BROWN = Color(0.35, 0.15, 0.12)  # Realistic medical stains
const SALINE_CLEAR = Color(0.92, 0.96, 0.98)  # Medical fluids
const ANTISEPTIC_BLUE = Color(0.88, 0.92, 0.98)  # Cleaning solution tint

# Character Expression Colors
const EXHAUSTED_GRAY = Color(0.7, 0.7, 0.75)  # Fatigue around eyes
const FOCUSED_BRIGHT = Color(1.1, 1.1, 1.1)  # Alert/focused highlight
const STRESSED_FLUSH = Color(0.9, 0.7, 0.7)  # Stress flush on skin
const COMPASSION_WARM = Color(0.95, 0.88, 0.82)  # Warm, caring expression

# Helper functions for dynamic color adjustments
static func get_urgency_color(urgency_level: float) -> Color:
	"""Get color based on medical urgency level (0.0 = routine, 1.0 = critical)"""
	urgency_level = clampf(urgency_level, 0.0, 1.0)
	
	if urgency_level >= 0.9:
		return CRITICAL_RED
	elif urgency_level >= 0.7:
		return URGENT_RED
	elif urgency_level >= 0.5:
		return HIGH_ORANGE
	elif urgency_level >= 0.3:
		return HIGH_YELLOW
	elif urgency_level >= 0.1:
		return MEDIUM_AMBER
	else:
		return LOW_GREEN

static func get_priority_color(priority_level: String) -> Color:
	"""Get color based on medical priority level"""
	match priority_level.to_lower():
		"critical", "code_red", "stat":
			return CRITICAL_RED
		"urgent", "high":
			return URGENT_RED
		"semi_urgent", "medium_high":
			return HIGH_ORANGE
		"less_urgent", "medium":
			return HIGH_YELLOW
		"routine", "low":
			return LOW_GREEN
		"non_urgent", "stable":
			return MEDIUM_BLUE
		_:
			return LOW_GRAY

static func get_timer_color(time_remaining: float, total_time: float) -> Color:
	"""Get timer color based on remaining time percentage"""
	var percentage = time_remaining / total_time
	
	if percentage > 0.75:
		return LOW_GREEN  # Plenty of time
	elif percentage > 0.5:
		return MONITOR_GREEN  # Good time
	elif percentage > 0.25:
		return HIGH_YELLOW  # Getting tight
	elif percentage > 0.1:
		return HIGH_ORANGE  # Running out
	else:
		return CRITICAL_RED  # Critical time

static func get_vital_sign_color(vital_type: String, value: String, is_abnormal: bool) -> Color:
	"""Get color for vital signs based on medical significance"""
	
	if not is_abnormal:
		return LOW_GREEN
	
	match vital_type.to_lower():
		"hr", "heart_rate":
			# Heart rate abnormalities can be critical
			var hr_val = value.to_int()
			if hr_val > 150 or hr_val < 40:
				return CRITICAL_RED
			elif hr_val > 120 or hr_val < 50:
				return URGENT_RED
			else:
				return HIGH_ORANGE
		
		"bp", "blood_pressure":
			# Blood pressure - hypertensive crisis is critical
			if "20" in value or "19" in value or "18" in value:
				return CRITICAL_RED  # Severe hypertension
			else:
				return HIGH_ORANGE
		
		"temp", "temperature":
			# Temperature - high fever is urgent
			if "104" in value or "40" in value or "41" in value:
				return CRITICAL_RED
			elif "103" in value or "39" in value:
				return URGENT_RED
			else:
				return HIGH_YELLOW
		
		"o2sat", "spo2":
			# Oxygen saturation - hypoxemia is critical
			if "%" in value:
				var spo2_val = value.replace("%", "").strip_edges().to_int()
				if spo2_val < 85:
					return CRITICAL_RED
				elif spo2_val < 90:
					return URGENT_RED
				else:
					return HIGH_ORANGE
		
		"rr", "respiratory_rate":
			# Respiratory rate abnormalities
			var rr_val = value.to_int()
			if rr_val > 35 or rr_val < 8:
				return CRITICAL_RED
			elif rr_val > 25 or rr_val < 10:
				return URGENT_RED
			else:
				return HIGH_ORANGE
		
		_:
			return HIGH_ORANGE  # Default for abnormal vitals

static func get_emotional_state_color(emotion: String) -> Color:
	"""Get color tint for character emotional states"""
	
	match emotion.to_lower():
		"exhausted", "tired":
			return EXHAUSTED_GRAY
		
		"focused", "alert", "sharp":
			return FOCUSED_BRIGHT
		
		"stressed", "overwhelmed", "panicked":
			return STRESSED_FLUSH
		
		"compassionate", "caring", "warm":
			return COMPASSION_WARM
		
		"concerned", "worried":
			return HIGH_YELLOW.lerp(STRESSED_FLUSH, 0.3)
		
		"frustrated", "angry":
			return URGENT_RED.lerp(STRESSED_FLUSH, 0.5)
		
		"relieved", "satisfied":
			return LOW_GREEN.lerp(COMPASSION_WARM, 0.4)
		
		"encouraging", "supportive":
			return MEDIUM_BLUE.lerp(COMPASSION_WARM, 0.3)
		
		_:
			return Color.WHITE

static func get_atmosphere_color(time_of_shift: String, stress_level: float) -> Color:
	"""Get atmospheric color overlay based on shift time and stress"""
	
	var base_color: Color
	
	match time_of_shift.to_lower():
		"night", "overnight", "graveyard":
			base_color = NIGHT_SHIFT_BLUE
		
		"early_morning", "dawn":
			base_color = TIRED_PURPLE
		
		"day", "afternoon":
			base_color = FLUORESCENT_WHITE
		
		"evening", "dusk":
			base_color = SHADOW_BLUE
		
		_:
			base_color = FLUORESCENT_WHITE
	
	# Blend with stress level
	if stress_level > 0.7:
		base_color = base_color.lerp(STRESS_RED_TINT, stress_level * 0.3)
	elif stress_level < 0.3:
		base_color = base_color.lerp(CALM_GREEN_TINT, (1.0 - stress_level) * 0.2)
	
	return base_color

static func add_wear_effect(base_color: Color, wear_amount: float = 0.1) -> Color:
	"""Add subtle wear/aging effect to a color"""
	wear_amount = clampf(wear_amount, 0.0, 1.0)
	return base_color.lerp(WEAR_GRAY, wear_amount)

static func add_coffee_stain(base_color: Color, stain_intensity: float = 0.05) -> Color:
	"""Add coffee stain effect to paper/chart colors"""
	stain_intensity = clampf(stain_intensity, 0.0, 0.5)
	return base_color.lerp(COFFEE_BROWN, stain_intensity)

static func get_pulsing_urgency_color(urgency_level: float, pulse_phase: float) -> Color:
	"""Get pulsing color for urgent alerts"""
	
	var base_color = get_urgency_color(urgency_level)
	
	if urgency_level >= 0.8:
		# Critical items pulse between base and bright
		var pulse_bright = CRITICAL_RED_PULSE
		var pulse_amount = (sin(pulse_phase) + 1.0) / 2.0  # 0 to 1
		return base_color.lerp(pulse_bright, pulse_amount * 0.4)
	
	return base_color

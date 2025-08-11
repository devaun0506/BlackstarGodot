class_name StartScreenPixelArtSpecs
extends RefCounted

# Pixel Art Asset Specifications for Blackstar Start Screen
# Hospital Emergency Department Aesthetic with Authentic Medical Details
# Optimized for medical student audience - educational yet appealing

# Base Resolution and Scaling
const BASE_RESOLUTION = Vector2i(1920, 1080)  # Target 1080p
const PIXEL_SCALE = 4  # 4x pixel scaling for crisp pixel art
const UI_SCALE = 2     # 2x scaling for UI elements

# Asset Dimensions (in pixels before scaling)
const BACKGROUND_SIZE = Vector2i(480, 270)  # Will scale to 1920x1080
const BUTTON_SIZE = Vector2i(80, 20)        # Standard button
const LARGE_BUTTON_SIZE = Vector2i(120, 28) # Start button
const ICON_SIZE = Vector2i(16, 16)          # Small icons
const LARGE_ICON_SIZE = Vector2i(32, 32)    # Featured elements

# Color Depth and Style Guide
const COLOR_DEPTH = 32                      # Matches StartScreenMedicalPalette
const PIXEL_STYLE = "MEDICAL_REALISM"       # Realistic medical environment
const SHADING_STYLE = "MULTI_DIRECTIONAL"  # Complex lighting from fluorescents

# Hospital Environment Assets
enum HospitalAssetType {
	TRIAGE_BACKGROUND,
	RECEPTION_DESK,
	MEDICAL_EQUIPMENT,
	COFFEE_STATION,
	FLUORESCENT_FIXTURE,
	HOSPITAL_SIGNAGE,
	WORN_SURFACES,
	ENVIRONMENTAL_DETAILS
}

# Medical Equipment Asset Specifications
static var medical_equipment_specs = {
	"heart_monitor": {
		"size": Vector2i(48, 32),
		"colors": ["equipment_silver", "equipment_shadow", "monitor_active", "text_main"],
		"animation_frames": 4,
		"details": [
			"LCD screen with heart rhythm",
			"Control buttons and knobs",
			"Cable connections",
			"Power indicator LED"
		]
	},
	
	"stethoscope": {
		"size": Vector2i(24, 32),
		"colors": ["equipment_silver", "equipment_shadow", "medical_blue"],
		"hanging": true,
		"details": [
			"Chest piece with accurate proportions",
			"Flexible tubing curves",
			"Earpiece detail",
			"Realistic material shading"
		]
	},
	
	"clipboard_stack": {
		"size": Vector2i(32, 24),
		"colors": ["paper_clean", "paper_worn", "chart_stained", "text_main", "coffee_stain"],
		"layers": 3,
		"details": [
			"Multiple clipboards at angles",
			"Coffee ring stains on top clipboard",
			"Pen attached by chain",
			"Slightly curled corner papers"
		]
	},
	
	"iv_stand": {
		"size": Vector2i(16, 64),
		"colors": ["metal_chrome", "equipment_shadow", "iv_tubing", "medical_clear"],
		"animation_frames": 2,
		"details": [
			"Adjustable height mechanism",
			"IV bag with fluid level",
			"Tubing with drip chamber",
			"Wheeled base with realistic proportions"
		]
	}
}

# Background Element Specifications
static var background_specs = {
	"emergency_triage_area": {
		"size": BACKGROUND_SIZE,
		"layers": [
			{
				"name": "back_wall",
				"colors": ["hospital_wall", "wear_dark", "fluorescent"],
				"elements": ["wall_mounted_charts", "emergency_procedures_poster", "clock"]
			},
			{
				"name": "floor_tiles", 
				"colors": ["medical_blue", "deep_shadow", "wear_light"],
				"pattern": "hospital_tile_pattern",
				"wear_areas": ["high_traffic_paths", "equipment_marks"]
			},
			{
				"name": "reception_counter",
				"colors": ["equipment_silver", "paper_clean", "coffee_stain"],
				"elements": ["computer_terminal", "phone", "coffee_cup", "paperwork_stack"]
			},
			{
				"name": "lighting_fixtures",
				"colors": ["fluorescent", "flicker_dim", "equipment_silver"],
				"animation": "fluorescent_flicker_pattern",
				"cast_shadows": true
			}
		]
	},
	
	"coffee_station_detail": {
		"size": Vector2i(64, 48),
		"colors": ["equipment_silver", "coffee_liquid", "paper_worn", "steam_light"],
		"animation_frames": 6,
		"details": [
			"Coffee maker with glass carafe",
			"Steam animation from hot coffee",
			"Used coffee cups with rings",
			"Sugar packets and stirrers",
			"Coffee stains on counter surface"
		]
	}
}

# UI Component Asset Specifications
static var ui_component_specs = {
	"clipboard_button": {
		"base_size": BUTTON_SIZE,
		"large_size": LARGE_BUTTON_SIZE,
		"colors": ["clipboard", "equipment_shadow", "text_main", "coffee_stain"],
		"states": ["normal", "hover", "pressed", "disabled"],
		"design_elements": [
			"Metal clip at top with realistic shading",
			"Paper texture with slight yellowing",
			"Handwritten-style text areas",
			"Coffee ring in corner (subtle)",
			"Slightly rounded paper corners",
			"Shadow cast by metal clip"
		],
		"hover_effect": "slight_lift_with_shadow",
		"press_effect": "compress_and_darken"
	},
	
	"id_badge_button": {
		"size": Vector2i(64, 40),
		"colors": ["paper_clean", "urgent_main", "metal_chrome", "text_main"],
		"elements": [
			"Hospital ID card with photo placeholder",
			"Red lanyard/clip system", 
			"Hospital logo area",
			"Name and department text areas",
			"Barcode or magnetic stripe",
			"Realistic plastic card sheen"
		],
		"animation": "gentle_sway_when_hovered",
		"interaction": "flip_to_show_back"
	},
	
	"medical_equipment_ui": {
		"monitor_style_panel": {
			"size": Vector2i(120, 80),
			"colors": ["equipment_main", "monitor_active", "text_light"],
			"elements": [
				"Medical monitor bezel",
				"Control buttons along bottom",
				"Screen with medical readout",
				"Power and status LEDs",
				"Realistic cable connections"
			]
		},
		
		"equipment_cart_style": {
			"size": Vector2i(96, 120),
			"colors": ["equipment_silver", "equipment_shadow", "medical_blue"],
			"elements": [
				"Rolling medical cart structure",
				"Multiple shelf levels",
				"Medical equipment on shelves",
				"Electrical outlets and connections",
				"Realistic wheel and caster details"
			]
		}
	}
}

# Animation Specifications
static var animation_specs = {
	"fluorescent_flicker": {
		"frames": 12,
		"duration": 2.5,
		"pattern": "irregular_medical_grade_flicker",
		"colors": ["fluorescent", "flicker_dim", "night_shift"],
		"affects": ["lighting_overlay", "shadow_positions", "equipment_visibility"]
	},
	
	"coffee_steam": {
		"frames": 8,
		"duration": 4.0,
		"pattern": "rising_dissipating_steam",
		"colors": ["steam_light", "fluorescent"],
		"opacity_fade": true
	},
	
	"monitor_heartbeat": {
		"frames": 6,
		"duration": 1.0,
		"pattern": "realistic_ecg_trace",
		"colors": ["monitor_active", "monitor_idle"],
		"repeating": true
	},
	
	"environmental_idle": {
		"clipboard_pages_flutter": {
			"frames": 4,
			"duration": 8.0,
			"trigger": "ambient_air_movement"
		},
		"equipment_status_blinks": {
			"frames": 2,
			"duration": 3.0,
			"colors": ["warning", "alert"]
		}
	}
}

# Texture and Surface Detail Specifications
static var surface_detail_specs = {
	"paper_texture": {
		"base_color": "paper_clean",
		"detail_colors": ["paper_worn", "chart_stained"],
		"patterns": [
			"subtle_fiber_texture",
			"worn_edge_details", 
			"coffee_ring_marks",
			"ink_bleed_areas"
		]
	},
	
	"metal_equipment_finish": {
		"base_color": "equipment_silver",
		"detail_colors": ["metal_chrome", "equipment_shadow"],
		"patterns": [
			"brushed_metal_lines",
			"reflection_highlights",
			"wear_marks_from_use",
			"fingerprint_smudges"
		]
	},
	
	"hospital_floor_tiles": {
		"base_color": "medical_blue",
		"detail_colors": ["deep_shadow", "wear_light", "fluorescent"],
		"patterns": [
			"grout_lines_with_slight_discoloration",
			"scuff_marks_in_high_traffic_areas",
			"floor_wax_reflection_highlights",
			"equipment_wheel_marks"
		]
	}
}

# Environmental Storytelling Elements
static var storytelling_elements = {
	"shift_change_details": {
		"coffee_cups": "Multiple cups showing 12+ hour shift",
		"paperwork_pile": "Growing stack of patient charts",
		"personal_items": "Staff belongings showing long shift",
		"equipment_wear": "Signs of heavy usage"
	},
	
	"medical_accuracy": {
		"proper_equipment_placement": "Equipment positioned as in real ED",
		"authentic_signage": "Real medical terminology and warnings",
		"accurate_proportions": "Equipment sized correctly relative to environment",
		"workflow_logic": "Layout supports actual medical workflow"
	},
	
	"human_touches": {
		"coffee_rings": "Evidence of caffeine-dependent staff",
		"worn_edges": "Frequently handled items show use",
		"personal_notes": "Handwritten reminders and notes",
		"comfort_items": "Small personal touches in sterile environment"
	}
}

# Helper Functions for Asset Generation

static func get_asset_spec(asset_type: String, asset_name: String) -> Dictionary:
	"""Get specifications for a specific asset"""
	match asset_type:
		"medical_equipment":
			return medical_equipment_specs.get(asset_name, {})
		"background":
			return background_specs.get(asset_name, {})
		"ui_component":
			return ui_component_specs.get(asset_name, {})
		"animation":
			return animation_specs.get(asset_name, {})
		"surface_detail":
			return surface_detail_specs.get(asset_name, {})
		_:
			push_warning("Unknown asset type: %s" % asset_type)
			return {}

static func get_color_palette_for_asset(asset_spec: Dictionary) -> Array[Color]:
	"""Convert color names in asset spec to actual colors"""
	var colors: Array[Color] = []
	
	if asset_spec.has("colors"):
		for color_name in asset_spec.colors:
			colors.append(StartScreenMedicalPalette.get_color_by_name(color_name))
	
	return colors

static func calculate_scaled_size(original_size: Vector2i, scale_factor: int = PIXEL_SCALE) -> Vector2i:
	"""Calculate final size after pixel scaling"""
	return original_size * scale_factor

static func get_animation_frame_count(animation_name: String) -> int:
	"""Get total frames needed for an animation"""
	if animation_specs.has(animation_name):
		return animation_specs[animation_name].get("frames", 1)
	return 1

static func validate_asset_colors(asset_spec: Dictionary) -> bool:
	"""Validate that all colors in asset spec exist in palette"""
	if not asset_spec.has("colors"):
		return true
	
	for color_name in asset_spec.colors:
		var color = StartScreenMedicalPalette.get_color_by_name(color_name)
		if color == Color.MAGENTA:  # Error color from palette
			push_warning("Invalid color name in asset spec: %s" % color_name)
			return false
	
	return true

static func get_layered_background_spec(background_name: String) -> Array[Dictionary]:
	"""Get layered rendering specification for complex backgrounds"""
	var bg_spec = background_specs.get(background_name, {})
	
	if bg_spec.has("layers"):
		return bg_spec.layers
	
	return []

static func get_medical_accuracy_guidelines() -> Dictionary:
	"""Get guidelines for maintaining medical accuracy in assets"""
	return {
		"equipment_proportions": "Medical equipment should be proportioned accurately to real-world counterparts",
		"color_coding": "Use standard medical color coding (red for urgent, green for normal, etc.)",
		"terminology": "All visible text should use correct medical terminology",
		"workflow_layout": "Equipment and furniture placement should reflect real ED workflow",
		"safety_standards": "Visual elements should reflect real hospital safety standards"
	}

static func get_pixel_art_best_practices() -> Dictionary:
	"""Get best practices for medical-themed pixel art"""
	return {
		"color_consistency": "Use only colors from the 32-color StartScreenMedicalPalette",
		"lighting_direction": "Maintain consistent lighting from fluorescent sources above",
		"detail_hierarchy": "Most detail on interactive elements, less on background",
		"readability": "Ensure all medical text and displays remain readable",
		"authenticity": "Balance pixel art style with medical realism",
		"accessibility": "Ensure sufficient contrast for medical information display"
	}

# Asset Generation Templates
static func get_clipboard_button_template() -> Dictionary:
	"""Get template for generating clipboard-style buttons"""
	return {
		"base": {
			"background_color": "clipboard",
			"border_style": "metal_clip_at_top",
			"corner_style": "slightly_rounded",
			"surface_texture": "paper_texture"
		},
		"details": {
			"clip_shadow": "equipment_shadow",
			"paper_aging": "chart_stained", 
			"coffee_marks": "coffee_stain",
			"text_style": "medical_handwriting"
		},
		"states": {
			"normal": {"elevation": 0, "brightness": 1.0},
			"hover": {"elevation": 2, "brightness": 1.1},
			"pressed": {"elevation": -1, "brightness": 0.9},
			"disabled": {"saturation": 0.5, "brightness": 0.8}
		}
	}

static func get_medical_monitor_template() -> Dictionary:
	"""Get template for medical monitor-style UI elements"""
	return {
		"frame": {
			"material": "medical_equipment_plastic",
			"color": "equipment_silver",
			"bezel_style": "slightly_raised_border",
			"corner_radius": 2  # pixels
		},
		"screen": {
			"background": "monitor_idle",
			"active_color": "monitor_active",
			"text_color": "fluorescent",
			"scan_line_effect": true
		},
		"controls": {
			"button_style": "recessed_medical_buttons",
			"led_indicators": ["warning", "alert", "success"],
			"connection_ports": "realistic_medical_connectors"
		}
	}
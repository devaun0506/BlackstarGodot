class_name StartScreenUIComponents
extends RefCounted

# Start Screen Medical UI Components for Blackstar
# Authentic hospital aesthetic with medical student appeal
# Clipboard buttons, ID badge elements, and medical equipment styling

# UI Component Types for Start Screen
enum StartScreenButtonType {
	START_BUTTON,      # Primary "Start Shift" button
	SETTINGS_BUTTON,   # Medical clipboard style settings
	QUIT_BUTTON,       # Equipment power-off style
	FEEDBACK_BUTTON,   # ID badge style feedback
	INFO_BUTTON        # Medical chart style information
}

# Create the main start screen buttons with medical theming
static func create_start_shift_button(text: String = "START SHIFT") -> Button:
	"""Create the main start button styled as an emergency button"""
	
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = StartScreenPixelArtSpecs.calculate_scaled_size(
		StartScreenPixelArtSpecs.LARGE_BUTTON_SIZE
	)
	
	# Apply emergency/urgent button styling
	apply_emergency_button_theme(button)
	
	# Add pulsing animation for urgency
	setup_emergency_button_animation(button)
	
	return button

static func create_clipboard_settings_button(text: String = "SETTINGS") -> Button:
	"""Create settings button styled as a medical clipboard"""
	
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = StartScreenPixelArtSpecs.calculate_scaled_size(
		StartScreenPixelArtSpecs.BUTTON_SIZE
	)
	
	# Apply clipboard styling
	apply_clipboard_button_theme(button)
	
	# Add paper flutter effect
	setup_clipboard_hover_effects(button)
	
	return button

static func create_equipment_quit_button(text: String = "END SHIFT") -> Button:
	"""Create quit button styled as medical equipment power button"""
	
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = StartScreenPixelArtSpecs.calculate_scaled_size(
		StartScreenPixelArtSpecs.BUTTON_SIZE
	)
	
	# Apply equipment power button styling
	apply_equipment_button_theme(button)
	
	# Add power-down effect
	setup_power_button_effects(button)
	
	return button

static func create_id_badge_feedback_button(text: String = "FEEDBACK") -> Button:
	"""Create feedback button styled as a hospital ID badge"""
	
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = StartScreenPixelArtSpecs.calculate_scaled_size(
		Vector2i(64, 40)  # ID badge proportions
	)
	
	# Apply ID badge styling
	apply_id_badge_button_theme(button)
	
	# Add swaying animation
	setup_id_badge_animation(button)
	
	return button

# Theme Application Functions

static func apply_emergency_button_theme(button: Button):
	"""Apply emergency button theme with urgent red styling"""
	
	var colors = StartScreenMedicalPalette.get_medical_equipment_colors()
	
	# Create styles for different states
	var normal_style = create_emergency_button_style(
		colors.alert_light,
		StartScreenMedicalPalette.URGENT_RED_MAIN,
		false
	)
	
	var hover_style = create_emergency_button_style(
		StartScreenMedicalPalette.URGENT_RED_LIGHT,
		StartScreenMedicalPalette.URGENT_RED_MAIN,
		true  # Glowing effect
	)
	
	var pressed_style = create_emergency_button_style(
		StartScreenMedicalPalette.URGENT_RED_MAIN,
		StartScreenMedicalPalette.ERROR_FEEDBACK,
		false
	)
	
	# Apply styles
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Font styling for emergency button
	button.add_theme_color_override("font_color", StartScreenMedicalPalette.PAPER_WHITE_CLEAN)
	button.add_theme_font_size_override("font_size", 14)

static func apply_clipboard_button_theme(button: Button):
	"""Apply clipboard paper theme with authentic wear"""
	
	var colors = StartScreenMedicalPalette.get_clipboard_button_colors()
	
	# Create paper-like styles
	var normal_style = create_clipboard_style(
		colors.background,
		colors.border,
		false
	)
	
	var hover_style = create_clipboard_style(
		colors.hover_tint,
		StartScreenMedicalPalette.HOSPITAL_GREEN_MAIN,
		true  # Slight lift effect
	)
	
	var pressed_style = create_clipboard_style(
		colors.press_tint,
		StartScreenMedicalPalette.HOSPITAL_GREEN_DARK,
		false
	)
	
	# Apply styles
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Add coffee stain detail as background
	add_clipboard_wear_effects(button)
	
	# Font styling for clipboard text
	button.add_theme_color_override("font_color", colors.text)
	button.add_theme_font_size_override("font_size", 10)

static func apply_equipment_button_theme(button: Button):
	"""Apply medical equipment theme with metal finish"""
	
	var colors = StartScreenMedicalPalette.get_medical_equipment_colors()
	
	var normal_style = create_equipment_style(
		colors.main_body,
		colors.shadow,
		false
	)
	
	var hover_style = create_equipment_style(
		StartScreenMedicalPalette.STERILE_BLUE_LIGHT,
		colors.shadow,
		true
	)
	
	var pressed_style = create_equipment_style(
		StartScreenMedicalPalette.STERILE_BLUE_MAIN,
		StartScreenMedicalPalette.SHADOW_DEEP_BLUE,
		false
	)
	
	# Apply styles
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Equipment-style font
	button.add_theme_color_override("font_color", StartScreenMedicalPalette.TEXT_BLACK_MAIN)
	button.add_theme_font_size_override("font_size", 9)

static func apply_id_badge_button_theme(button: Button):
	"""Apply hospital ID badge theme with lanyard"""
	
	var colors = StartScreenMedicalPalette.get_id_badge_colors()
	
	var normal_style = create_id_badge_style(
		colors.background,
		colors.border,
		false
	)
	
	var hover_style = create_id_badge_style(
		colors.background,
		StartScreenMedicalPalette.INFO_HIGHLIGHT,
		true  # Sway animation trigger
	)
	
	var pressed_style = create_id_badge_style(
		StartScreenMedicalPalette.PAPER_WHITE_WORN,
		colors.border,
		false
	)
	
	# Apply styles
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Badge text styling
	button.add_theme_color_override("font_color", colors.text)
	button.add_theme_font_size_override("font_size", 8)

# Style Creation Helper Functions

static func create_emergency_button_style(bg_color: Color, border_color: Color, glowing: bool) -> StyleBoxFlat:
	"""Create StyleBoxFlat for emergency button"""
	
	var style = StyleBoxFlat.new()
	
	style.bg_color = bg_color
	style.border_width_left = style.border_width_top = 3
	style.border_width_right = style.border_width_bottom = 3
	style.border_color = border_color
	
	# Rounded corners for modern medical equipment
	style.corner_radius_top_left = style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 6
	
	# Generous padding for emergency button
	style.content_margin_left = style.content_margin_right = 16
	style.content_margin_top = style.content_margin_bottom = 12
	
	# Add glow effect for hover state
	if glowing:
		style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.4)
		style.shadow_size = 8
		style.shadow_offset = Vector2.ZERO
	
	return style

static func create_clipboard_style(bg_color: Color, border_color: Color, elevated: bool) -> StyleBoxFlat:
	"""Create StyleBoxFlat for clipboard button"""
	
	var style = StyleBoxFlat.new()
	
	style.bg_color = bg_color
	style.border_width_left = style.border_width_top = 2
	style.border_width_right = style.border_width_bottom = 2
	style.border_color = border_color
	
	# Slight rounded corners for paper
	style.corner_radius_top_left = style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 3
	
	# Clipboard-like padding
	style.content_margin_left = style.content_margin_right = 12
	style.content_margin_top = style.content_margin_bottom = 8
	
	# Elevation effect for hover
	if elevated:
		style.shadow_color = Color(0, 0, 0, 0.2)
		style.shadow_size = 4
		style.shadow_offset = Vector2(2, 3)
	
	return style

static func create_equipment_style(bg_color: Color, shadow_color: Color, active: bool) -> StyleBoxFlat:
	"""Create StyleBoxFlat for medical equipment button"""
	
	var style = StyleBoxFlat.new()
	
	style.bg_color = bg_color
	style.border_width_left = style.border_width_top = 1
	style.border_width_right = style.border_width_bottom = 2  # Bottom/right heavier for depth
	style.border_color = shadow_color
	
	# Equipment-style corners
	style.corner_radius_top_left = style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
	
	# Compact equipment padding
	style.content_margin_left = style.content_margin_right = 10
	style.content_margin_top = style.content_margin_bottom = 6
	
	# Active state highlight
	if active:
		style.border_color = StartScreenMedicalPalette.INFO_HIGHLIGHT
		style.border_width_left = style.border_width_top = 2
	
	return style

static func create_id_badge_style(bg_color: Color, border_color: Color, swaying: bool) -> StyleBoxFlat:
	"""Create StyleBoxFlat for ID badge button"""
	
	var style = StyleBoxFlat.new()
	
	style.bg_color = bg_color
	style.border_width_left = style.border_width_top = 2
	style.border_width_right = style.border_width_bottom = 2
	style.border_color = border_color
	
	# ID card corners (slightly rounded)
	style.corner_radius_top_left = style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 2
	
	# Badge-like padding
	style.content_margin_left = style.content_margin_right = 8
	style.content_margin_top = style.content_margin_bottom = 6
	
	# Subtle shadow for plastic card effect
	style.shadow_color = Color(0, 0, 0, 0.1)
	style.shadow_size = 2
	style.shadow_offset = Vector2(1, 1)
	
	return style

# Animation and Effect Functions

static func setup_emergency_button_animation(button: Button):
	"""Setup pulsing animation for emergency button urgency"""
	
	var tween: Tween
	
	button.ready.connect(func():
		tween = button.create_tween()
		tween.set_loops()
		
		# Subtle pulse between normal and bright
		var pulse_sequence = tween.tween_method(
			func(pulse_value: float):
				var pulse_color = StartScreenMedicalPalette.URGENT_RED_MAIN.lerp(
					StartScreenMedicalPalette.URGENT_RED_LIGHT,
					pulse_value
				)
				button.modulate = pulse_color,
			0.0, 1.0, 1.5
		)
		pulse_sequence.set_trans(Tween.TRANS_SINE)
		pulse_sequence.set_ease(Tween.EASE_IN_OUT)
		
		tween.tween_method(
			func(pulse_value: float):
				var pulse_color = StartScreenMedicalPalette.URGENT_RED_LIGHT.lerp(
					StartScreenMedicalPalette.URGENT_RED_MAIN,
					pulse_value
				)
				button.modulate = pulse_color,
			0.0, 1.0, 1.5
		)
	)

static func setup_clipboard_hover_effects(button: Button):
	"""Setup paper flutter effect for clipboard buttons"""
	
	button.mouse_entered.connect(func():
		var hover_tween = button.create_tween()
		hover_tween.parallel().tween_property(button, "rotation", deg_to_rad(1), 0.1)
		hover_tween.parallel().tween_property(button, "position:y", button.position.y - 2, 0.1)
	)
	
	button.mouse_exited.connect(func():
		var unhover_tween = button.create_tween()
		unhover_tween.parallel().tween_property(button, "rotation", 0.0, 0.15)
		unhover_tween.parallel().tween_property(button, "position:y", button.position.y, 0.15)
	)

static func setup_power_button_effects(button: Button):
	"""Setup power equipment effects for quit button"""
	
	button.mouse_entered.connect(func():
		var glow_tween = button.create_tween()
		glow_tween.tween_property(button, "modulate", 
			StartScreenMedicalPalette.WARNING_AMBER, 0.2)
	)
	
	button.mouse_exited.connect(func():
		var dim_tween = button.create_tween()
		dim_tween.tween_property(button, "modulate", Color.WHITE, 0.2)
	)
	
	button.button_down.connect(func():
		var press_tween = button.create_tween()
		press_tween.tween_property(button, "modulate", 
			StartScreenMedicalPalette.ERROR_FEEDBACK, 0.05)
	)

static func setup_id_badge_animation(button: Button):
	"""Setup gentle swaying animation for ID badge"""
	
	var sway_tween: Tween
	
	button.mouse_entered.connect(func():
		if sway_tween:
			sway_tween.kill()
		
		sway_tween = button.create_tween()
		sway_tween.set_loops()
		
		# Gentle sway like hanging on lanyard
		sway_tween.tween_property(button, "rotation", deg_to_rad(2), 1.0)
		sway_tween.tween_property(button, "rotation", deg_to_rad(-2), 2.0)
		sway_tween.tween_property(button, "rotation", deg_to_rad(2), 1.0)
	)
	
	button.mouse_exited.connect(func():
		if sway_tween:
			sway_tween.kill()
		
		var settle_tween = button.create_tween()
		settle_tween.tween_property(button, "rotation", 0.0, 0.5)
	)

# Additional UI Element Functions

static func add_clipboard_wear_effects(button: Button):
	"""Add visual wear effects to clipboard buttons"""
	
	# Create a subtle coffee ring texture overlay
	var coffee_ring = ColorRect.new()
	coffee_ring.color = Color(
		StartScreenMedicalPalette.COFFEE_BROWN_LIGHT.r,
		StartScreenMedicalPalette.COFFEE_BROWN_LIGHT.g,
		StartScreenMedicalPalette.COFFEE_BROWN_LIGHT.b,
		0.1
	)
	coffee_ring.size = Vector2(16, 16)
	coffee_ring.position = Vector2(
		button.custom_minimum_size.x * 0.7,
		button.custom_minimum_size.y * 0.3
	)
	coffee_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	button.add_child(coffee_ring)

static func create_medical_version_label(version_text: String) -> Label:
	"""Create version label with medical chart styling"""
	
	var label = Label.new()
	label.text = version_text
	label.add_theme_color_override("font_color", StartScreenMedicalPalette.TEXT_GRAY_MUTED)
	label.add_theme_font_size_override("font_size", 8)
	
	return label

static func create_hospital_logo_area(size: Vector2i) -> Panel:
	"""Create area for hospital/game logo with medical styling"""
	
	var panel = Panel.new()
	panel.custom_minimum_size = StartScreenPixelArtSpecs.calculate_scaled_size(size)
	
	var style = StyleBoxFlat.new()
	style.bg_color = StartScreenMedicalPalette.PAPER_WHITE_CLEAN
	style.border_width_left = style.border_width_top = 2
	style.border_width_right = style.border_width_bottom = 2
	style.border_color = StartScreenMedicalPalette.HOSPITAL_GREEN_MAIN
	
	style.corner_radius_top_left = style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
	
	panel.add_theme_stylebox_override("panel", style)
	
	return panel

static func create_atmospheric_overlay() -> ColorRect:
	"""Create atmospheric color overlay for time-of-day effects"""
	
	var overlay = ColorRect.new()
	
	# Default to night shift atmosphere
	overlay.color = Color(
		StartScreenMedicalPalette.NIGHT_SHIFT_BLUE.r,
		StartScreenMedicalPalette.NIGHT_SHIFT_BLUE.g,
		StartScreenMedicalPalette.NIGHT_SHIFT_BLUE.b,
		0.15  # Subtle overlay
	)
	
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	return overlay

# Layout Helper Functions

static func create_start_screen_layout() -> Control:
	"""Create the complete start screen layout with medical theming"""
	
	var main_container = Control.new()
	main_container.name = "StartScreenMedicalLayout"
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Background atmospheric overlay
	var atmosphere = create_atmospheric_overlay()
	atmosphere.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_child(atmosphere)
	
	# Center button container
	var center_container = VBoxContainer.new()
	center_container.name = "CenterButtons"
	center_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center_container.add_theme_constant_override("separation", 20)
	
	# Add main buttons
	var start_button = create_start_shift_button()
	var settings_button = create_clipboard_settings_button()
	var feedback_button = create_id_badge_feedback_button()
	var quit_button = create_equipment_quit_button()
	
	center_container.add_child(start_button)
	center_container.add_child(settings_button)
	center_container.add_child(feedback_button)
	center_container.add_child(quit_button)
	
	main_container.add_child(center_container)
	
	# Version label in corner
	var version_label = create_medical_version_label("v0.1 - Medical Student Edition")
	version_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	version_label.position = Vector2(-120, -30)
	main_container.add_child(version_label)
	
	return main_container

static func get_start_screen_design_specifications() -> Dictionary:
	"""Get complete design specifications for the start screen"""
	
	return {
		"color_palette": "StartScreenMedicalPalette (32 colors)",
		"visual_theme": "Hospital Emergency Department",
		"target_audience": "Medical students and healthcare professionals",
		"authenticity_level": "High - realistic medical environment",
		"pixel_art_style": "Medical realism with pixel art aesthetic",
		
		"ui_components": {
			"start_button": "Emergency/urgent red button with pulsing",
			"settings_button": "Medical clipboard with paper texture",
			"feedback_button": "Hospital ID badge with sway animation",
			"quit_button": "Medical equipment power button",
			"version_label": "Medical chart text styling"
		},
		
		"environmental_details": {
			"atmosphere": "Night shift hospital atmosphere",
			"lighting": "Fluorescent lighting with subtle flicker",
			"wear_effects": "Coffee stains, worn edges, authentic use marks",
			"equipment_details": "Realistic medical equipment proportions"
		},
		
		"animations": {
			"emergency_pulse": "Subtle urgency pulsing on start button",
			"paper_flutter": "Clipboard hover effects",
			"id_sway": "Lanyard sway on feedback button",
			"equipment_glow": "Status indicator effects"
		}
	}
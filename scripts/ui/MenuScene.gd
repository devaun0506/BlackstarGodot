extends Control
## Medical-Themed Main Menu for Blackstar Emergency Department Simulator
##
## Provides an immersive hospital start screen with medical aesthetics,
## emergency department atmosphere, and professional medical interface design.

signal start_shift_requested
signal settings_requested
signal feedback_requested
signal quit_requested

# UI element references
@onready var start_shift_button = %StartShiftButton
@onready var settings_button = %SettingsButton
@onready var feedback_button = %FeedbackButton
@onready var quit_button = %QuitButton
@onready var title_label = %TitleLabel
@onready var subtitle_label = %SubtitleLabel
@onready var background_panel = %BackgroundPanel
@onready var medical_overlay = %MedicalOverlay

# Medical atmosphere components
@onready var atmosphere_controller: AtmosphereController
@onready var mobile_responsive_ui: MobileResponsiveUI

# Visual effects
var fluorescent_material: ShaderMaterial
var coffee_stain_textures: Array[Texture2D] = []
var medical_ui_tween: Tween

# Email feedback configuration
const FEEDBACK_EMAIL: String = "devaun0506@gmail.com"
const FEEDBACK_SUBJECT: String = "Blackstar Medical Simulation Feedback"

func _ready() -> void:
	print("MenuScene: Initializing medical-themed start screen")
	
	# Initialize medical atmosphere
	_setup_medical_atmosphere()
	
	# Apply medical color palette and styling
	_apply_medical_styling()
	
	# Setup fluorescent lighting effects
	_setup_fluorescent_lighting()
	
	# Initialize mobile responsiveness
	_setup_mobile_responsive_ui()
	
	# Validate and connect UI elements
	_validate_medical_ui_elements()
	_connect_medical_button_signals()
	
	# Apply coffee-stained paper effects
	_apply_paperwork_textures()
	
	# Setup ED atmosphere
	_initialize_emergency_department_atmosphere()
	
	# Focus management
	_setup_focus_management()
	
	print("MenuScene: Medical start screen initialized successfully")

func _setup_medical_atmosphere() -> void:
	"""Initialize the medical atmosphere controller for ED ambience"""
	if not atmosphere_controller:
		atmosphere_controller = AtmosphereController.new()
		atmosphere_controller.name = "AtmosphereController"
		add_child(atmosphere_controller)
	
	# Set shift start atmosphere for menu
	atmosphere_controller.set_atmosphere(AtmosphereController.AtmosphereType.SHIFT_START, 0.3)
	
	# Create subtle medical moments while in menu
	_schedule_ambient_medical_sounds()

func _apply_medical_styling() -> void:
	"""Apply medical color palette and typography to all UI elements"""
	
	# Apply medical background color
	if background_panel:
		var style = StyleBoxFlat.new()
		style.bg_color = MedicalColors.MEDICAL_GREEN_DARK
		background_panel.add_theme_stylebox_override("panel", style)
	
	# Style the title with medical theme
	if title_label:
		var font_config = MedicalFont.get_chart_header_font_config()
		font_config.size = 24
		font_config.font_color = MedicalColors.FLUORESCENT_WHITE
		font_config.outline_color = MedicalColors.MEDICAL_GREEN
		MedicalFont.apply_font_config(title_label, font_config)
		title_label.text = "BLACKSTAR"
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Style the subtitle with ED context
	if subtitle_label:
		var font_config = MedicalFont.get_label_font_config()
		font_config.font_color = MedicalColors.CHART_PAPER
		MedicalFont.apply_font_config(subtitle_label, font_config)
		subtitle_label.text = "Emergency Department Simulation"
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _setup_fluorescent_lighting() -> void:
	"""Setup fluorescent lighting shader effects"""
	
	# Load fluorescent flicker shader
	var fluorescent_shader = load("res://scripts/shaders/FluorescentFlicker.gdshader")
	if fluorescent_shader:
		fluorescent_material = ShaderMaterial.new()
		fluorescent_material.shader = fluorescent_shader
		
		# Configure fluorescent lighting parameters
		fluorescent_material.set_shader_parameter("flicker_intensity", 0.2)
		fluorescent_material.set_shader_parameter("flicker_speed", 2.5)
		fluorescent_material.set_shader_parameter("base_brightness", 0.92)
		fluorescent_material.set_shader_parameter("fluorescent_tint", 
			Vector3(MedicalColors.FLUORESCENT_WHITE.r, MedicalColors.FLUORESCENT_WHITE.g, MedicalColors.FLUORESCENT_WHITE.b))
		
		# Apply to medical overlay
		if medical_overlay:
			medical_overlay.material = fluorescent_material
	else:
		push_warning("MenuScene: Fluorescent flicker shader not found")

func _setup_mobile_responsive_ui() -> void:
	"""Initialize mobile responsive UI system"""
	if not mobile_responsive_ui:
		mobile_responsive_ui = MobileResponsiveUI.new()
		mobile_responsive_ui.name = "MobileResponsiveUI"
		add_child(mobile_responsive_ui)
		
		# Connect mobile gesture signals
		mobile_responsive_ui.touch_gesture_detected.connect(_on_mobile_gesture_detected)
		mobile_responsive_ui.layout_changed.connect(_on_layout_changed)

func _validate_medical_ui_elements() -> void:
	"""Validate medical-themed UI elements"""
	var missing_elements = []
	var warnings = []
	
	# Critical elements
	if not start_shift_button:
		missing_elements.append("StartShiftButton")
	if not quit_button:
		missing_elements.append("QuitButton")
	if not title_label:
		missing_elements.append("TitleLabel")
	
	# Optional but recommended elements
	if not settings_button:
		warnings.append("SettingsButton")
	if not feedback_button:
		warnings.append("FeedbackButton")
	if not background_panel:
		warnings.append("BackgroundPanel")
	
	if missing_elements.size() > 0:
		push_error("MenuScene: Missing critical medical UI elements: " + str(missing_elements))
	
	if warnings.size() > 0:
		push_warning("MenuScene: Optional medical UI elements missing: " + str(warnings))
	
	if missing_elements.size() == 0:
		print("MenuScene: Medical UI elements validated successfully")

func _connect_medical_button_signals() -> void:
	"""Connect medical-themed button signals with error handling"""
	
	# Start Shift button
	if start_shift_button:
		start_shift_button.pressed.connect(_on_start_shift_pressed)
		_apply_medical_button_style(start_shift_button, "primary")
	else:
		push_error("MenuScene: Start Shift button not found")
	
	# Settings button
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
		_apply_medical_button_style(settings_button, "secondary")
	
	# Feedback button
	if feedback_button:
		feedback_button.pressed.connect(_on_feedback_pressed)
		_apply_medical_button_style(feedback_button, "feedback")
	
	# Quit button
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		_apply_medical_button_style(quit_button, "quit")

func _apply_medical_button_style(button: Button, button_type: String) -> void:
	"""Apply medical styling to buttons based on type"""
	if not button:
		return
	
	var style_normal = StyleBoxFlat.new()
	var style_hover = StyleBoxFlat.new()
	var style_pressed = StyleBoxFlat.new()
	
	# Configure styles based on button type
	match button_type:
		"primary":  # Start Shift
			style_normal.bg_color = MedicalColors.URGENT_RED
			style_hover.bg_color = MedicalColors.URGENT_RED_LIGHT
			style_pressed.bg_color = MedicalColors.URGENT_RED
			button.text = "► START SHIFT"
		
		"secondary":  # Settings
			style_normal.bg_color = MedicalColors.EQUIPMENT_GRAY
			style_hover.bg_color = MedicalColors.EQUIPMENT_GRAY_DARK
			style_pressed.bg_color = MedicalColors.EQUIPMENT_GRAY_DARK
			button.text = "⚙ SETTINGS"
		
		"feedback":  # Feedback
			style_normal.bg_color = MedicalColors.INFO_BLUE
			style_hover.bg_color = MedicalColors.STERILE_BLUE_LIGHT
			style_pressed.bg_color = MedicalColors.STERILE_BLUE_DARK
			button.text = "✉ FEEDBACK"
		
		"quit":  # Quit
			style_normal.bg_color = MedicalColors.SHADOW_BLUE
			style_hover.bg_color = MedicalColors.MEDICAL_GREEN_LIGHT
			style_pressed.bg_color = MedicalColors.MEDICAL_GREEN_DARK
			button.text = "✕ QUIT"
	
	# Apply common styling
	for style in [style_normal, style_hover, style_pressed]:
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = MedicalColors.MEDICAL_GREEN_LIGHT
	
	# Apply styles to button
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	
	# Apply font configuration
	var font_config = MedicalFont.get_button_font_config()
	MedicalFont.apply_font_config(button, font_config)
	
	# Set minimum size for touch targets
	button.custom_minimum_size = Vector2(160, 44)

func _apply_paperwork_textures() -> void:
	"""Apply coffee-stained paperwork texture effects"""
	
	# Create subtle coffee stain overlay effect
	if medical_overlay:
		var coffee_tint = MedicalColors.add_coffee_stain(MedicalColors.CHART_PAPER, 0.02)
		medical_overlay.color = coffee_tint
		medical_overlay.color.a = 0.1  # Very subtle overlay

func _initialize_emergency_department_atmosphere() -> void:
	"""Setup emergency department atmospheric elements"""
	
	# Schedule periodic medical atmosphere moments
	await get_tree().create_timer(3.0).timeout
	_create_menu_medical_moment("shift_prep")
	
	# Setup continuous subtle medical ambience
	_setup_continuous_ambience()

func _setup_focus_management() -> void:
	"""Setup focus management for the medical menu"""
	if start_shift_button:
		start_shift_button.grab_focus()
		
		# Add visual focus indicator
		start_shift_button.focus_entered.connect(_on_focus_entered.bind(start_shift_button))
		start_shift_button.focus_exited.connect(_on_focus_exited.bind(start_shift_button))

func _schedule_ambient_medical_sounds() -> void:
	"""Schedule ambient medical sounds for menu atmosphere"""
	
	# Schedule subtle medical equipment sounds every 8-15 seconds
	var timer = Timer.new()
	timer.name = "AmbientSoundsTimer"
	add_child(timer)
	timer.wait_time = randf_range(8.0, 15.0)
	timer.autostart = true
	timer.timeout.connect(_play_random_ambient_sound)

func _play_random_ambient_sound() -> void:
	"""Play random ambient medical sound for atmosphere"""
	
	var sound_effects = [
		"distant_monitor_beep",
		"soft_page_announcement", 
		"quiet_footsteps",
		"equipment_hum"
	]
	
	var selected_sound = sound_effects[randi() % sound_effects.size()]
	
	if atmosphere_controller:
		atmosphere_controller.create_medical_moment(selected_sound, {})
	
	# Reschedule with random interval
	var timer = get_node("AmbientSoundsTimer") as Timer
	if timer:
		timer.wait_time = randf_range(8.0, 15.0)
		timer.start()

func _setup_continuous_ambience() -> void:
	"""Setup continuous background medical ambience"""
	
	if atmosphere_controller:
		# Create subtle shift preparation atmosphere
		atmosphere_controller.create_medical_moment("shift_change", {"intensity": 0.2})

func _create_menu_medical_moment(moment_type: String) -> void:
	"""Create atmospheric medical moments while in menu"""
	
	match moment_type:
		"shift_prep":
			print("MenuScene: Creating shift preparation atmosphere")
			if atmosphere_controller:
				atmosphere_controller.play_coffee_machine_effect()
				await get_tree().create_timer(2.0).timeout
				atmosphere_controller.play_footstep_sequence(0.3)

# Button signal handlers
func _on_start_shift_pressed() -> void:
	"""Handle start shift button press with medical transition"""
	print("MenuScene: Start shift requested - transitioning to ED")
	
	# Play medical transition sound
	if atmosphere_controller:
		atmosphere_controller.create_medical_moment("shift_change", {"urgency": 0.8})
	
	# Animate button press feedback
	_animate_medical_button_press(start_shift_button)
	
	# Emit signal to start the medical simulation
	start_shift_requested.emit()

func _on_settings_pressed() -> void:
	"""Handle settings button press"""
	print("MenuScene: Settings menu requested")
	_animate_medical_button_press(settings_button)
	settings_requested.emit()

func _on_feedback_pressed() -> void:
	"""Handle feedback button press with email functionality"""
	print("MenuScene: Opening feedback email")
	_animate_medical_button_press(feedback_button)
	
	# Open default email client with pre-filled feedback email
	var email_body = "Please provide your feedback about the Blackstar Emergency Department Simulation:\n\n"
	email_body += "What did you like?\n\n"
	email_body += "What could be improved?\n\n"
	email_body += "Any medical accuracy concerns?\n\n"
	email_body += "Technical issues encountered?\n\n"
	email_body += "Overall experience rating (1-5):\n\n"
	
	var mailto_url = "mailto:" + FEEDBACK_EMAIL + "?subject=" + FEEDBACK_SUBJECT.uri_encode() + "&body=" + email_body.uri_encode()
	OS.shell_open(mailto_url)
	
	feedback_requested.emit()

func _on_quit_pressed() -> void:
	"""Handle quit button press"""
	print("MenuScene: Quit requested")
	_animate_medical_button_press(quit_button)
	quit_requested.emit()

func _animate_medical_button_press(button: Button) -> void:
	"""Animate button press with medical-themed feedback"""
	if not button:
		return
	
	# Create medical button press animation
	if medical_ui_tween:
		medical_ui_tween.kill()
	
	medical_ui_tween = create_tween()
	medical_ui_tween.set_ease(Tween.EASE_OUT)
	medical_ui_tween.set_trans(Tween.TRANS_QUART)
	
	# Scale animation for tactile feedback
	medical_ui_tween.parallel().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	medical_ui_tween.parallel().tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Color flash for visual feedback
	var original_modulate = button.modulate
	var flash_color = MedicalColors.MONITOR_GREEN
	flash_color.a = 0.3
	
	medical_ui_tween.parallel().tween_property(button, "modulate", flash_color, 0.05)
	medical_ui_tween.parallel().tween_property(button, "modulate", original_modulate, 0.05)

func _on_focus_entered(button: Button) -> void:
	"""Handle button focus for accessibility and visual feedback"""
	if not button:
		return
	
	# Add subtle glow effect to focused button
	var glow_color = MedicalColors.MONITOR_GREEN
	glow_color.a = 0.2
	button.modulate = button.modulate.lerp(glow_color, 0.3)

func _on_focus_exited(button: Button) -> void:
	"""Handle button focus exit"""
	if not button:
		return
	
	# Remove glow effect
	button.modulate = Color.WHITE

func _on_mobile_gesture_detected(gesture_type: String, data: Dictionary) -> void:
	"""Handle mobile gesture detection"""
	
	match gesture_type:
		"swipe_up":
			# Swipe up could trigger start shift
			if start_shift_button:
				_on_start_shift_pressed()
		"swipe_right":
			# Swipe right could open settings
			if settings_button:
				_on_settings_pressed()
		"double_tap":
			# Double tap anywhere to start
			if start_shift_button:
				_on_start_shift_pressed()

func _on_layout_changed(new_layout: String) -> void:
	"""Handle responsive layout changes"""
	print("MenuScene: Layout changed to " + new_layout)
	
	# Adjust medical UI elements for different layouts
	match new_layout:
		"mobile":
			_apply_mobile_medical_layout()
		"tablet":
			_apply_tablet_medical_layout()
		"desktop":
			_apply_desktop_medical_layout()

func _apply_mobile_medical_layout() -> void:
	"""Apply mobile-specific medical layout"""
	# Larger buttons for touch
	var buttons = [start_shift_button, settings_button, feedback_button, quit_button]
	for button in buttons:
		if button:
			button.custom_minimum_size = Vector2(200, 54)

func _apply_tablet_medical_layout() -> void:
	"""Apply tablet-specific medical layout"""
	# Medium-sized touch targets
	var buttons = [start_shift_button, settings_button, feedback_button, quit_button]
	for button in buttons:
		if button:
			button.custom_minimum_size = Vector2(180, 48)

func _apply_desktop_medical_layout() -> void:
	"""Apply desktop-specific medical layout"""
	# Standard button sizes
	var buttons = [start_shift_button, settings_button, feedback_button, quit_button]
	for button in buttons:
		if button:
			button.custom_minimum_size = Vector2(160, 44)

func _input(event: InputEvent) -> void:
	"""Handle medical menu input with ED-appropriate controls"""
	if event.is_action_pressed("ui_cancel"):
		# ESC acts as quit in medical menu
		_on_quit_pressed()
	elif event.is_action_pressed("ui_accept"):
		# Enter starts shift if start button is focused
		if start_shift_button and start_shift_button.has_focus():
			_on_start_shift_pressed()
	elif event.is_action_pressed("ui_select"):
		# Space also starts shift
		if start_shift_button and start_shift_button.has_focus():
			_on_start_shift_pressed()

# Performance optimization - cleanup when leaving menu
func _exit_tree() -> void:
	"""Cleanup resources when leaving menu scene"""
	if atmosphere_controller:
		atmosphere_controller.cleanup_audio_timers()
	
	if medical_ui_tween:
		medical_ui_tween.kill()
	
	print("MenuScene: Medical start screen cleanup completed")

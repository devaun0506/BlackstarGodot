class_name MedicalUIComponents
extends RefCounted

# Medical-themed UI components factory for Blackstar
# Creates consistent UI elements with hospital aesthetic

# Button types
enum ButtonType {
	PRIMARY,      # Main action buttons
	SECONDARY,    # Secondary actions
	CHOICE,       # Answer choice buttons
	URGENT,       # Emergency/urgent actions
	SUCCESS,      # Positive feedback
	WARNING,      # Warning actions
	MINIMAL       # Subtle actions
}

# Progress bar types
enum ProgressBarType {
	TIMER,        # Countdown timer
	HEALTH,       # Patient health/vitals
	COFFEE,       # Momentum meter
	LOADING,      # Loading progress
	ACCURACY      # Performance accuracy
}

static func create_medical_button(text: String, button_type: ButtonType = ButtonType.PRIMARY, 
								  size: Vector2 = Vector2(120, 36)) -> Button:
	"""Create a medical-themed button with appropriate styling"""
	
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	
	# Apply medical theme styling
	apply_button_theme(button, button_type)
	
	# Add hover effects
	setup_button_hover_effects(button, button_type)
	
	return button

static func apply_button_theme(button: Button, button_type: ButtonType):
	"""Apply theme styling to button based on type"""
	
	var normal_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var disabled_style = StyleBoxFlat.new()
	
	# Configure styles based on button type
	match button_type:
		ButtonType.PRIMARY:
			setup_primary_button_style(normal_style, hover_style, pressed_style, disabled_style)
		ButtonType.SECONDARY:
			setup_secondary_button_style(normal_style, hover_style, pressed_style, disabled_style)
		ButtonType.CHOICE:
			setup_choice_button_style(normal_style, hover_style, pressed_style, disabled_style)
		ButtonType.URGENT:
			setup_urgent_button_style(normal_style, hover_style, pressed_style, disabled_style)
		ButtonType.SUCCESS:
			setup_success_button_style(normal_style, hover_style, pressed_style, disabled_style)
		ButtonType.WARNING:
			setup_warning_button_style(normal_style, hover_style, pressed_style, disabled_style)
		ButtonType.MINIMAL:
			setup_minimal_button_style(normal_style, hover_style, pressed_style, disabled_style)
	
	# Apply styles to button
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)
	
	# Apply font styling
	apply_button_font_styling(button, button_type)

static func setup_primary_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, 
									   pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	"""Setup primary button styling"""
	
	# Normal state
	normal.bg_color = MedicalColors.MEDICAL_GREEN
	normal.border_width_left = normal.border_width_top = normal.border_width_right = normal.border_width_bottom = 2
	normal.border_color = MedicalColors.MEDICAL_GREEN_DARK
	normal.corner_radius_top_left = normal.corner_radius_top_right = 4
	normal.corner_radius_bottom_left = normal.corner_radius_bottom_right = 4
	normal.content_margin_left = normal.content_margin_right = 12
	normal.content_margin_top = normal.content_margin_bottom = 8
	
	# Hover state
	hover.bg_color = MedicalColors.MEDICAL_GREEN_LIGHT
	hover.border_width_left = hover.border_width_top = hover.border_width_right = hover.border_width_bottom = 2
	hover.border_color = MedicalColors.MEDICAL_GREEN
	hover.corner_radius_top_left = hover.corner_radius_top_right = 4
	hover.corner_radius_bottom_left = hover.corner_radius_bottom_right = 4
	hover.content_margin_left = hover.content_margin_right = 12
	hover.content_margin_top = hover.content_margin_bottom = 8
	
	# Pressed state
	pressed.bg_color = MedicalColors.MEDICAL_GREEN_DARK
	pressed.border_width_left = pressed.border_width_top = pressed.border_width_right = pressed.border_width_bottom = 2
	pressed.border_color = MedicalColors.SHADOW_BLUE
	pressed.corner_radius_top_left = pressed.corner_radius_top_right = 4
	pressed.corner_radius_bottom_left = pressed.corner_radius_bottom_right = 4
	pressed.content_margin_left = pressed.content_margin_right = 12
	pressed.content_margin_top = pressed.content_margin_bottom = 8
	
	# Disabled state
	disabled.bg_color = MedicalColors.EQUIPMENT_GRAY
	disabled.border_width_left = disabled.border_width_top = disabled.border_width_right = disabled.border_width_bottom = 1
	disabled.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	disabled.corner_radius_top_left = disabled.corner_radius_top_right = 4
	disabled.corner_radius_bottom_left = disabled.corner_radius_bottom_right = 4
	disabled.content_margin_left = disabled.content_margin_right = 12
	disabled.content_margin_top = disabled.content_margin_bottom = 8

static func setup_choice_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, 
									  pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	"""Setup answer choice button styling"""
	
	# Normal state - clean chart paper look
	normal.bg_color = MedicalColors.CHART_PAPER
	normal.border_width_left = normal.border_width_top = normal.border_width_right = normal.border_width_bottom = 1
	normal.border_color = MedicalColors.TEXT_MUTED
	normal.corner_radius_top_left = normal.corner_radius_top_right = 2
	normal.corner_radius_bottom_left = normal.corner_radius_bottom_right = 2
	normal.content_margin_left = normal.content_margin_right = 16
	normal.content_margin_top = normal.content_margin_bottom = 12
	
	# Hover state
	hover.bg_color = MedicalColors.STERILE_BLUE_LIGHT
	hover.border_width_left = hover.border_width_top = hover.border_width_right = hover.border_width_bottom = 2
	hover.border_color = MedicalColors.STERILE_BLUE
	hover.corner_radius_top_left = hover.corner_radius_top_right = 2
	hover.corner_radius_bottom_left = hover.corner_radius_bottom_right = 2
	hover.content_margin_left = hover.content_margin_right = 16
	hover.content_margin_top = hover.content_margin_bottom = 12
	
	# Pressed state - selection highlight
	pressed.bg_color = MedicalColors.SUCCESS_GREEN
	pressed.border_width_left = pressed.border_width_top = pressed.border_width_right = pressed.border_width_bottom = 2
	pressed.border_color = MedicalColors.MONITOR_GREEN
	pressed.corner_radius_top_left = pressed.corner_radius_top_right = 2
	pressed.corner_radius_bottom_left = pressed.corner_radius_bottom_right = 2
	pressed.content_margin_left = pressed.content_margin_right = 16
	pressed.content_margin_top = pressed.content_margin_bottom = 12
	
	# Disabled state
	disabled.bg_color = MedicalColors.CHART_PAPER_STAINED
	disabled.border_width_left = disabled.border_width_top = disabled.border_width_right = disabled.border_width_bottom = 1
	disabled.border_color = MedicalColors.WEAR_GRAY
	disabled.corner_radius_top_left = disabled.corner_radius_top_right = 2
	disabled.corner_radius_bottom_left = disabled.corner_radius_bottom_right = 2
	disabled.content_margin_left = disabled.content_margin_right = 16
	disabled.content_margin_top = disabled.content_margin_bottom = 12

static func setup_urgent_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, 
									  pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	"""Setup urgent/emergency button styling"""
	
	# Normal state - urgent red
	normal.bg_color = MedicalColors.URGENT_RED
	normal.border_width_left = normal.border_width_top = normal.border_width_right = normal.border_width_bottom = 2
	normal.border_color = MedicalColors.ERROR_RED
	normal.corner_radius_top_left = normal.corner_radius_top_right = 4
	normal.corner_radius_bottom_left = normal.corner_radius_bottom_right = 4
	normal.content_margin_left = normal.content_margin_right = 12
	normal.content_margin_top = normal.content_margin_bottom = 8
	
	# Hover state
	hover.bg_color = MedicalColors.URGENT_RED_LIGHT
	hover.border_width_left = hover.border_width_top = hover.border_width_right = hover.border_width_bottom = 2
	hover.border_color = MedicalColors.URGENT_RED
	hover.corner_radius_top_left = hover.corner_radius_top_right = 4
	hover.corner_radius_bottom_left = hover.corner_radius_bottom_right = 4
	hover.content_margin_left = hover.content_margin_right = 12
	hover.content_margin_top = hover.content_margin_bottom = 8
	
	# Pressed state
	pressed.bg_color = MedicalColors.ERROR_RED
	pressed.border_width_left = pressed.border_width_top = pressed.border_width_right = pressed.border_width_bottom = 2
	pressed.border_color = MedicalColors.SHADOW_BLUE
	pressed.corner_radius_top_left = pressed.corner_radius_top_right = 4
	pressed.corner_radius_bottom_left = pressed.corner_radius_bottom_right = 4
	pressed.content_margin_left = pressed.content_margin_right = 12
	pressed.content_margin_top = pressed.content_margin_bottom = 8
	
	# Disabled state
	disabled.bg_color = MedicalColors.EQUIPMENT_GRAY
	disabled.border_width_left = disabled.border_width_top = disabled.border_width_right = disabled.border_width_bottom = 1
	disabled.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	disabled.corner_radius_top_left = disabled.corner_radius_top_right = 4
	disabled.corner_radius_bottom_left = disabled.corner_radius_bottom_right = 4
	disabled.content_margin_left = disabled.content_margin_right = 12
	disabled.content_margin_top = disabled.content_margin_bottom = 8

static func setup_secondary_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, 
										 pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	"""Setup secondary button styling"""
	
	# Normal state - sterile blue
	normal.bg_color = MedicalColors.STERILE_BLUE
	normal.border_width_left = normal.border_width_top = normal.border_width_right = normal.border_width_bottom = 2
	normal.border_color = MedicalColors.STERILE_BLUE_DARK
	normal.corner_radius_top_left = normal.corner_radius_top_right = 4
	normal.corner_radius_bottom_left = normal.corner_radius_bottom_right = 4
	normal.content_margin_left = normal.content_margin_right = 12
	normal.content_margin_top = normal.content_margin_bottom = 8
	
	# Hover state
	hover.bg_color = MedicalColors.STERILE_BLUE_LIGHT
	hover.border_width_left = hover.border_width_top = hover.border_width_right = hover.border_width_bottom = 2
	hover.border_color = MedicalColors.STERILE_BLUE
	hover.corner_radius_top_left = hover.corner_radius_top_right = 4
	hover.corner_radius_bottom_left = hover.corner_radius_bottom_right = 4
	hover.content_margin_left = hover.content_margin_right = 12
	hover.content_margin_top = hover.content_margin_bottom = 8
	
	# Pressed state
	pressed.bg_color = MedicalColors.STERILE_BLUE_DARK
	pressed.border_width_left = pressed.border_width_top = pressed.border_width_right = pressed.border_width_bottom = 2
	pressed.border_color = MedicalColors.SHADOW_BLUE
	pressed.corner_radius_top_left = pressed.corner_radius_top_right = 4
	pressed.corner_radius_bottom_left = pressed.corner_radius_bottom_right = 4
	pressed.content_margin_left = pressed.content_margin_right = 12
	pressed.content_margin_top = pressed.content_margin_bottom = 8
	
	# Disabled state
	disabled.bg_color = MedicalColors.EQUIPMENT_GRAY
	disabled.border_width_left = disabled.border_width_top = disabled.border_width_right = disabled.border_width_bottom = 1
	disabled.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	disabled.corner_radius_top_left = disabled.corner_radius_top_right = 4
	disabled.corner_radius_bottom_left = disabled.corner_radius_bottom_right = 4
	disabled.content_margin_left = disabled.content_margin_right = 12
	disabled.content_margin_top = disabled.content_margin_bottom = 8

static func setup_success_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, 
									   pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	"""Setup success/positive button styling"""
	
	# Use monitor green for success actions
	normal.bg_color = MedicalColors.MONITOR_GREEN
	hover.bg_color = MedicalColors.SUCCESS_GREEN
	pressed.bg_color = Color(MedicalColors.MONITOR_GREEN.r * 0.8, MedicalColors.MONITOR_GREEN.g * 0.8, MedicalColors.MONITOR_GREEN.b * 0.8)
	disabled.bg_color = MedicalColors.EQUIPMENT_GRAY
	
	# Apply consistent styling
	for style in [normal, hover, pressed, disabled]:
		style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
		style.corner_radius_top_left = style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
		style.content_margin_left = style.content_margin_right = 12
		style.content_margin_top = style.content_margin_bottom = 8

static func setup_warning_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, 
									   pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	"""Setup warning button styling"""
	
	normal.bg_color = MedicalColors.WARNING_AMBER
	hover.bg_color = MedicalColors.URGENT_ORANGE
	pressed.bg_color = Color(MedicalColors.WARNING_AMBER.r * 0.8, MedicalColors.WARNING_AMBER.g * 0.8, MedicalColors.WARNING_AMBER.b * 0.8)
	disabled.bg_color = MedicalColors.EQUIPMENT_GRAY
	
	# Apply consistent styling
	for style in [normal, hover, pressed, disabled]:
		style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
		style.corner_radius_top_left = style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
		style.content_margin_left = style.content_margin_right = 12
		style.content_margin_top = style.content_margin_bottom = 8

static func setup_minimal_button_style(normal: StyleBoxFlat, hover: StyleBoxFlat, 
									   pressed: StyleBoxFlat, disabled: StyleBoxFlat):
	"""Setup minimal/subtle button styling"""
	
	# Minimal buttons are mostly transparent with subtle borders
	normal.bg_color = Color.TRANSPARENT
	normal.border_width_left = normal.border_width_top = normal.border_width_right = normal.border_width_bottom = 1
	normal.border_color = MedicalColors.TEXT_MUTED
	
	hover.bg_color = Color(MedicalColors.MEDICAL_GREEN.r, MedicalColors.MEDICAL_GREEN.g, MedicalColors.MEDICAL_GREEN.b, 0.1)
	hover.border_width_left = hover.border_width_top = hover.border_width_right = hover.border_width_bottom = 1
	hover.border_color = MedicalColors.MEDICAL_GREEN
	
	pressed.bg_color = Color(MedicalColors.MEDICAL_GREEN.r, MedicalColors.MEDICAL_GREEN.g, MedicalColors.MEDICAL_GREEN.b, 0.2)
	pressed.border_width_left = pressed.border_width_top = pressed.border_width_right = pressed.border_width_bottom = 1
	pressed.border_color = MedicalColors.MEDICAL_GREEN_DARK
	
	disabled.bg_color = Color.TRANSPARENT
	disabled.border_width_left = disabled.border_width_top = disabled.border_width_right = disabled.border_width_bottom = 1
	disabled.border_color = MedicalColors.WEAR_GRAY
	
	# Apply consistent content margins
	for style in [normal, hover, pressed, disabled]:
		style.corner_radius_top_left = style.corner_radius_top_right = 2
		style.corner_radius_bottom_left = style.corner_radius_bottom_right = 2
		style.content_margin_left = style.content_margin_right = 8
		style.content_margin_top = style.content_margin_bottom = 6

static func apply_button_font_styling(button: Button, button_type: ButtonType):
	"""Apply font styling based on button type"""
	
	var font_config: Dictionary
	
	match button_type:
		ButtonType.CHOICE:
			font_config = MedicalFont.get_choice_font_config()
		ButtonType.URGENT:
			font_config = MedicalFont.get_button_font_config()
			button.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
		ButtonType.MINIMAL:
			font_config = MedicalFont.get_label_font_config()
		_:
			font_config = MedicalFont.get_button_font_config()
	
	# Apply font configuration
	MedicalFont.apply_font_config(button, font_config)
	
	# Set button alignment based on type
	if button_type == ButtonType.CHOICE:
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER

static func setup_button_hover_effects(button: Button, button_type: ButtonType):
	"""Setup hover and interaction effects for buttons"""
	
	button.mouse_entered.connect(_on_button_hover.bind(button, button_type))
	button.mouse_exited.connect(_on_button_unhover.bind(button, button_type))
	button.button_down.connect(_on_button_press.bind(button, button_type))
	button.button_up.connect(_on_button_release.bind(button, button_type))

static func _on_button_hover(button: Button, button_type: ButtonType):
	"""Handle button hover effect"""
	
	if button_type == ButtonType.URGENT:
		# Add subtle glow for urgent buttons
		var tween = button.create_tween()
		tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.1), 0.1)

static func _on_button_unhover(button: Button, button_type: ButtonType):
	"""Handle button unhover effect"""
	
	var tween = button.create_tween()
	tween.tween_property(button, "modulate", Color.WHITE, 0.1)

static func _on_button_press(button: Button, button_type: ButtonType):
	"""Handle button press effect"""
	
	# Slight scale down for tactile feedback
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)

static func _on_button_release(button: Button, button_type: ButtonType):
	"""Handle button release effect"""
	
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.05)

static func create_medical_progress_bar(progress_type: ProgressBarType = ProgressBarType.TIMER, 
									   size: Vector2 = Vector2(200, 12)) -> ProgressBar:
	"""Create a medical-themed progress bar"""
	
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = size
	progress_bar.show_percentage = false
	
	# Apply medical theme styling
	apply_progress_bar_theme(progress_bar, progress_type)
	
	return progress_bar

static func apply_progress_bar_theme(progress_bar: ProgressBar, progress_type: ProgressBarType):
	"""Apply theme styling to progress bar based on type"""
	
	var bg_style = StyleBoxFlat.new()
	var fill_style = StyleBoxFlat.new()
	
	# Background styling (consistent across types)
	bg_style.bg_color = MedicalColors.SHADOW_BLUE
	bg_style.border_width_left = bg_style.border_width_top = bg_style.border_width_right = bg_style.border_width_bottom = 1
	bg_style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	bg_style.corner_radius_top_left = bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_left = bg_style.corner_radius_bottom_right = 2
	
	# Fill styling based on type
	match progress_type:
		ProgressBarType.TIMER:
			fill_style.bg_color = MedicalColors.MONITOR_GREEN  # Will be changed based on time
		ProgressBarType.HEALTH:
			fill_style.bg_color = MedicalColors.MONITOR_GREEN
		ProgressBarType.COFFEE:
			fill_style.bg_color = MedicalColors.COFFEE_BROWN
		ProgressBarType.LOADING:
			fill_style.bg_color = MedicalColors.STERILE_BLUE
		ProgressBarType.ACCURACY:
			fill_style.bg_color = MedicalColors.SUCCESS_GREEN
	
	fill_style.corner_radius_top_left = fill_style.corner_radius_top_right = 1
	fill_style.corner_radius_bottom_left = fill_style.corner_radius_bottom_right = 1
	
	# Apply styles
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

static func create_medical_label(text: String, label_type: String = "normal") -> Label:
	"""Create a medical-themed label with appropriate styling"""
	
	var label = Label.new()
	label.text = text
	
	var font_config: Dictionary
	
	match label_type:
		"header":
			font_config = MedicalFont.get_chart_header_font_config()
		"chart":
			font_config = MedicalFont.get_chart_font_config()
		"vital":
			font_config = MedicalFont.get_vital_signs_font_config()
		"question":
			font_config = MedicalFont.get_question_font_config()
		"score":
			font_config = MedicalFont.get_score_font_config()
		_:
			font_config = MedicalFont.get_label_font_config()
	
	MedicalFont.apply_font_config(label, font_config)
	
	return label

static func create_medical_panel(panel_type: String = "normal", size: Vector2 = Vector2.ZERO) -> Panel:
	"""Create a medical-themed panel with appropriate styling"""
	
	var panel = Panel.new()
	
	if size != Vector2.ZERO:
		panel.custom_minimum_size = size
	
	var style = StyleBoxFlat.new()
	
	match panel_type:
		"chart":
			style.bg_color = MedicalColors.CHART_PAPER
			style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
			style.border_color = MedicalColors.EQUIPMENT_GRAY
			style.corner_radius_top_left = style.corner_radius_top_right = 6
			style.corner_radius_bottom_left = style.corner_radius_bottom_right = 6
			style.shadow_color = Color(0, 0, 0, 0.1)
			style.shadow_size = 4
			style.shadow_offset = Vector2(2, 2)
		
		"equipment":
			style.bg_color = MedicalColors.EQUIPMENT_GRAY
			style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
			style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
			style.corner_radius_top_left = style.corner_radius_top_right = 4
			style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
		
		"urgent":
			style.bg_color = Color(MedicalColors.URGENT_RED.r, MedicalColors.URGENT_RED.g, MedicalColors.URGENT_RED.b, 0.1)
			style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
			style.border_color = MedicalColors.URGENT_RED
			style.corner_radius_top_left = style.corner_radius_top_right = 4
			style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
		
		_:  # normal
			style.bg_color = MedicalColors.MEDICAL_GREEN
			style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
			style.border_color = MedicalColors.MEDICAL_GREEN_DARK
			style.corner_radius_top_left = style.corner_radius_top_right = 4
			style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
	
	panel.add_theme_stylebox_override("panel", style)
	
	return panel

static func create_choice_button_set(choices: Array[Dictionary]) -> VBoxContainer:
	"""Create a set of choice buttons for questions"""
	
	var container = VBoxContainer.new()
	container.name = "ChoicesContainer"
	
	for i in range(choices.size()):
		var choice = choices[i]
		var button = create_medical_button(
			"[%s] %s" % [choice.get("id", char(65 + i)), choice.get("text", "")],
			ButtonType.CHOICE,
			Vector2(600, 40)
		)
		
		button.name = "Choice" + choice.get("id", char(65 + i))
		container.add_child(button)
	
	return container

static func create_timer_display(initial_time: float = 45.0) -> Control:
	"""Create a complete timer display with progress bar"""
	
	var container = VBoxContainer.new()
	container.name = "TimerDisplay"
	
	# Timer label
	var timer_label = create_medical_label("00:00", "score")
	timer_label.name = "TimerLabel"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(timer_label)
	
	# Progress bar
	var progress_bar = create_medical_progress_bar(ProgressBarType.TIMER, Vector2(150, 8))
	progress_bar.name = "TimerProgress"
	progress_bar.max_value = initial_time
	progress_bar.value = initial_time
	container.add_child(progress_bar)
	
	return container

static func create_score_display() -> Control:
	"""Create a complete score and streak display"""
	
	var container = HBoxContainer.new()
	container.name = "ScoreDisplay"
	
	# Score label
	var score_label = create_medical_label("Score: 0", "score")
	score_label.name = "ScoreLabel"
	container.add_child(score_label)
	
	# Separator
	var separator = VSeparator.new()
	container.add_child(separator)
	
	# Streak label
	var streak_label = create_medical_label("Streak: 0", "score")
	streak_label.name = "StreakLabel"
	container.add_child(streak_label)
	
	# Separator
	var separator2 = VSeparator.new()
	container.add_child(separator2)
	
	# Accuracy label
	var accuracy_label = create_medical_label("Accuracy: 0%", "score")
	accuracy_label.name = "AccuracyLabel"
	container.add_child(accuracy_label)
	
	return container
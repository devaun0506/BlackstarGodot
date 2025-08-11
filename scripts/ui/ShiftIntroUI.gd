class_name ShiftIntroUI
extends Control

## Shift Introduction UI for Blackstar
##
## Displays the shift start sequence with time/date, story snippet,
## and shift goals in an immersive medical context.

signal intro_completed()
signal intro_skipped()

# UI Components
@onready var background_overlay: ColorRect
@onready var intro_panel: Panel
@onready var time_date_label: Label
@onready var story_snippet_label: RichTextLabel
@onready var goals_label: RichTextLabel
@onready var progress_bar: ProgressBar
@onready var skip_button: Button

# Animation components
var intro_tween: Tween
var typewriter_tween: Tween

# Intro configuration
@export var intro_duration: float = 4.0
@export var typewriter_speed: float = 30.0  # characters per second
@export var auto_advance: bool = true

# Intro data
var shift_data: Dictionary = {}

func _ready() -> void:
	setup_ui_components()
	setup_styling()
	hide()  # Start hidden

func setup_ui_components() -> void:
	"""Create and arrange intro UI components"""
	
	# Create background overlay
	if not background_overlay:
		background_overlay = ColorRect.new()
		background_overlay.name = "BackgroundOverlay"
		add_child(background_overlay)
		background_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background_overlay.color = Color(MedicalColors.SHADOW_BLUE.r, MedicalColors.SHADOW_BLUE.g, 
										MedicalColors.SHADOW_BLUE.b, 0.9)
		background_overlay.z_index = -1
	
	# Create main intro panel
	if not intro_panel:
		intro_panel = Panel.new()
		intro_panel.name = "IntroPanel"
		add_child(intro_panel)
		intro_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
		intro_panel.size = Vector2(600, 400)
		intro_panel.position = Vector2(50, -200)  # Offset from center
	
	# Create content layout
	var vbox = VBoxContainer.new()
	vbox.name = "ContentLayout"
	intro_panel.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	
	# Time and date display
	if not time_date_label:
		time_date_label = Label.new()
		time_date_label.name = "TimeDateLabel"
		vbox.add_child(time_date_label)
		time_date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		time_date_label.add_theme_font_size_override("font_size", 28)
		time_date_label.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	
	# Story snippet
	if not story_snippet_label:
		story_snippet_label = RichTextLabel.new()
		story_snippet_label.name = "StorySnippetLabel"
		vbox.add_child(story_snippet_label)
		story_snippet_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		story_snippet_label.fit_content = true
		story_snippet_label.add_theme_color_override("default_color", MedicalColors.TEXT_LIGHT)
		story_snippet_label.add_theme_font_size_override("normal_font_size", 16)
	
	# Goals display
	if not goals_label:
		goals_label = RichTextLabel.new()
		goals_label.name = "GoalsLabel"
		vbox.add_child(goals_label)
		goals_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		goals_label.fit_content = true
		goals_label.add_theme_color_override("default_color", MedicalColors.MONITOR_GREEN)
		goals_label.add_theme_font_size_override("normal_font_size", 14)
	
	# Progress bar
	if not progress_bar:
		progress_bar = ProgressBar.new()
		progress_bar.name = "ProgressBar"
		vbox.add_child(progress_bar)
		progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		progress_bar.custom_minimum_size.y = 8
		progress_bar.value = 0
		progress_bar.max_value = 100
	
	# Skip button
	if not skip_button:
		skip_button = Button.new()
		skip_button.name = "SkipButton"
		add_child(skip_button)
		skip_button.text = "Press SPACE to continue"
		skip_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		skip_button.position.x -= 200
		skip_button.position.y -= 50
		skip_button.pressed.connect(_on_skip_pressed)

func setup_styling() -> void:
	"""Apply medical theme styling to components"""
	
	# Style the intro panel
	if intro_panel:
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = MedicalColors.MEDICAL_GREEN
		panel_style.border_width_left = 2
		panel_style.border_width_right = 2
		panel_style.border_width_top = 2
		panel_style.border_width_bottom = 2
		panel_style.border_color = MedicalColors.STERILE_BLUE_LIGHT
		panel_style.corner_radius_top_left = 8
		panel_style.corner_radius_top_right = 8
		panel_style.corner_radius_bottom_left = 8
		panel_style.corner_radius_bottom_right = 8
		
		intro_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Style the progress bar
	if progress_bar:
		var progress_style = StyleBoxFlat.new()
		progress_style.bg_color = MedicalColors.EQUIPMENT_GRAY_DARK
		progress_bar.add_theme_stylebox_override("background", progress_style)
		
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = MedicalColors.MONITOR_GREEN
		progress_bar.add_theme_stylebox_override("fill", fill_style)

func show_shift_intro(shift_info: Dictionary) -> void:
	"""Display the shift introduction sequence"""
	
	shift_data = shift_info
	print("ShiftIntroUI: Showing shift introduction")
	
	# Prepare content
	setup_intro_content()
	
	# Show the UI
	show()
	modulate.a = 0.0
	
	# Animate intro appearance
	animate_intro_sequence()

func setup_intro_content() -> void:
	"""Setup the content for the shift introduction"""
	
	# Set time and date
	var time_str = shift_data.get("time", "11:47 PM")
	var date_str = shift_data.get("date", "October 15th, 2024")
	if time_date_label:
		time_date_label.text = "%s - %s" % [time_str, date_str]
	
	# Set story snippet (will be typewritten)
	var story = shift_data.get("story_snippet", 
		"The emergency department hums with quiet efficiency. The fluorescent lights cast their familiar glow over the workstation as you settle in for another night shift. Charts await your attention, each one representing a person seeking help in their moment of need.")
	
	if story_snippet_label:
		story_snippet_label.text = ""  # Start empty for typewriter effect
	
	# Set shift goals
	var goals = shift_data.get("goals", {
		"target_accuracy": 75,
		"patient_count": 10,
		"special_conditions": []
	})
	
	if goals_label:
		var goals_text = "[b]Shift Objectives:[/b]\n"
		goals_text += "• Maintain ≥%d%% diagnostic accuracy\n" % goals.target_accuracy
		goals_text += "• Treat %d patients efficiently\n" % goals.patient_count
		
		if goals.has("special_conditions") and goals.special_conditions.size() > 0:
			goals_text += "• Special focus: %s" % ", ".join(goals.special_conditions)
		
		goals_label.text = goals_text

func animate_intro_sequence() -> void:
	"""Animate the complete intro sequence"""
	
	if intro_tween:
		intro_tween.kill()
	
	intro_tween = create_tween()
	intro_tween.set_parallel(true)
	
	# Fade in the whole UI
	intro_tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Slide in the intro panel from left
	if intro_panel:
		var start_pos = intro_panel.position
		intro_panel.position.x = -intro_panel.size.x
		intro_tween.tween_property(intro_panel, "position:x", start_pos.x, 0.8)
		intro_tween.tween_method(_apply_panel_settle, 0.0, 1.0, 0.3).tween_delay(0.8)
	
	# Animate progress bar if auto-advance is enabled
	if auto_advance and progress_bar:
		intro_tween.tween_property(progress_bar, "value", 100, intro_duration).tween_delay(1.0)
	
	# Start typewriter effect for story after panel settles
	intro_tween.tween_callback(start_typewriter_effect).tween_delay(1.2)
	
	# Auto-complete intro if enabled
	if auto_advance:
		intro_tween.tween_callback(_complete_intro).tween_delay(intro_duration)

func _apply_panel_settle(progress: float) -> void:
	"""Apply subtle settling bounce to intro panel"""
	if intro_panel:
		var bounce_offset = sin(progress * PI) * 5.0
		intro_panel.position.x += bounce_offset

func start_typewriter_effect() -> void:
	"""Start typewriter effect for story snippet"""
	
	if not story_snippet_label:
		return
	
	var story_text = shift_data.get("story_snippet", "")
	if story_text.is_empty():
		return
	
	# Clear current text
	story_snippet_label.text = ""
	
	if typewriter_tween:
		typewriter_tween.kill()
	
	typewriter_tween = create_tween()
	
	# Calculate duration based on text length and speed
	var typewriter_duration = story_text.length() / typewriter_speed
	
	# Animate character by character
	typewriter_tween.tween_method(_update_typewriter_text, 0, story_text.length(), typewriter_duration)

func _update_typewriter_text(char_count: int) -> void:
	"""Update text during typewriter animation"""
	
	if story_snippet_label:
		var full_text = shift_data.get("story_snippet", "")
		var current_text = full_text.substr(0, char_count)
		story_snippet_label.text = current_text
		
		# Add cursor effect
		if char_count < full_text.length():
			story_snippet_label.text += "[color=white]|[/color]"

func _complete_intro() -> void:
	"""Complete the intro sequence"""
	
	print("ShiftIntroUI: Completing intro sequence")
	
	# Ensure final text is complete
	if story_snippet_label:
		story_snippet_label.text = shift_data.get("story_snippet", "")
	
	# Animate out
	animate_intro_exit()

func animate_intro_exit() -> void:
	"""Animate the intro UI exiting"""
	
	var exit_tween = create_tween()
	exit_tween.set_parallel(true)
	
	# Slide panel out to right
	if intro_panel:
		var target_x = get_viewport().size.x
		exit_tween.tween_property(intro_panel, "position:x", target_x, 0.6)
	
	# Fade out
	exit_tween.tween_property(self, "modulate:a", 0.0, 0.8)
	
	# Complete
	exit_tween.tween_callback(_on_intro_exit_complete)

func _on_intro_exit_complete() -> void:
	"""Handle intro exit completion"""
	hide()
	intro_completed.emit()

func _on_skip_pressed() -> void:
	"""Handle skip button press"""
	print("ShiftIntroUI: Intro skipped by user")
	
	# Stop all animations
	if intro_tween:
		intro_tween.kill()
	if typewriter_tween:
		typewriter_tween.kill()
	
	# Complete immediately
	animate_intro_exit()
	intro_skipped.emit()

func _input(event: InputEvent) -> void:
	"""Handle input for intro sequence"""
	
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE, KEY_ENTER, KEY_ESCAPE:
				_on_skip_pressed()

# Public interface
func set_intro_duration(duration: float) -> void:
	"""Set intro duration"""
	intro_duration = duration

func set_typewriter_speed(speed: float) -> void:
	"""Set typewriter effect speed"""
	typewriter_speed = speed

func set_auto_advance(enabled: bool) -> void:
	"""Enable or disable auto-advance"""
	auto_advance = enabled
	if progress_bar:
		progress_bar.visible = enabled

func get_default_shift_data() -> Dictionary:
	"""Get default shift data for testing"""
	return {
		"time": "11:47 PM",
		"date": "October 15th, 2024",
		"story_snippet": "The emergency department settles into the rhythm of night shift. The soft hum of medical equipment creates a backdrop of clinical precision, while the coffee machine gurgles its promise of sustained alertness. Charts await your attention—each one a story, a challenge, a life in your hands.",
		"goals": {
			"target_accuracy": 75,
			"patient_count": 10,
			"special_conditions": ["Focus on cardiovascular cases"]
		}
	}

# Utility methods
func create_medical_ambiance() -> void:
	"""Add subtle medical ambiance effects"""
	
	# This would add subtle animations like:
	# - Flickering fluorescent lights
	# - Distant equipment sounds
	# - Occasional footsteps
	pass
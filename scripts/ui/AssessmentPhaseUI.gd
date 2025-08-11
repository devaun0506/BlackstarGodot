class_name AssessmentPhaseUI
extends Control

## Assessment Phase UI for Blackstar  
##
## Enhanced patient assessment interface with chart/summary toggle,
## medical equipment context, and immersive clinical environment.

signal chart_view_toggled(is_summary: bool)
signal assessment_completed(selected_answer: String)
signal spacebar_help_requested()

# UI Components
@onready var main_layout: HSplitContainer
@onready var chart_panel: Panel
@onready var controls_panel: Panel

# Chart display components
@onready var full_chart_view: ScrollContainer
@onready var summary_chart_view: Panel
@onready var chart_content: RichTextLabel
@onready var summary_content: RichTextLabel

# Medical equipment context
@onready var equipment_panel: Panel
@onready var monitor_display: TextureRect
@onready var vital_signs_monitor: RichTextLabel
@onready var equipment_status: VBoxContainer

# Assessment controls
@onready var question_area: RichTextLabel
@onready var answer_buttons: VBoxContainer
@onready var timer_display: Label
@onready var help_panel: Panel

# View state
var is_summary_view: bool = false
var current_patient_data: Dictionary = {}
var assessment_active: bool = false

# Equipment simulation
var heart_rate_timer: Timer
var equipment_update_timer: Timer
var current_heart_rate: int = 72
var equipment_status_data: Dictionary = {}

func _ready() -> void:
	print("AssessmentPhaseUI: Initializing assessment interface")
	setup_ui_layout()
	setup_medical_equipment()
	setup_interactions()

func setup_ui_layout() -> void:
	"""Setup the main UI layout structure"""
	
	# Create main horizontal split
	if not main_layout:
		main_layout = HSplitContainer.new()
		main_layout.name = "MainLayout"
		add_child(main_layout)
		main_layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		main_layout.split_offset = 500
	
	setup_chart_panel()
	setup_controls_panel()
	setup_equipment_context()

func setup_chart_panel() -> void:
	"""Setup the patient chart display panel"""
	
	if not chart_panel:
		chart_panel = Panel.new()
		chart_panel.name = "ChartPanel"
		main_layout.add_child(chart_panel)
		
		# Apply medical styling
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = MedicalColors.CHART_PAPER
		panel_style.border_width_left = 2
		panel_style.border_width_right = 2
		panel_style.border_width_top = 2
		panel_style.border_width_bottom = 2
		panel_style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
		chart_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Create chart layout
	var chart_vbox = VBoxContainer.new()
	chart_vbox.name = "ChartVBox"
	chart_panel.add_child(chart_vbox)
	chart_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	chart_vbox.add_theme_constant_override("separation", 10)
	
	# Chart header with toggle button
	var header_hbox = HBoxContainer.new()
	chart_vbox.add_child(header_hbox)
	
	var chart_title = Label.new()
	chart_title.text = "Patient Chart"
	chart_title.add_theme_font_size_override("font_size", 18)
	chart_title.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
	header_hbox.add_child(chart_title)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)
	
	var toggle_button = Button.new()
	toggle_button.text = "Summary View (SPACE)"
	toggle_button.pressed.connect(_on_chart_toggle_pressed)
	header_hbox.add_child(toggle_button)
	
	# Full chart view (scrollable)
	setup_full_chart_view(chart_vbox)
	
	# Summary chart view (condensed)
	setup_summary_chart_view(chart_vbox)

func setup_full_chart_view(parent: Control) -> void:
	"""Setup the full patient chart view"""
	
	full_chart_view = ScrollContainer.new()
	full_chart_view.name = "FullChartView"
	parent.add_child(full_chart_view)
	full_chart_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	chart_content = RichTextLabel.new()
	chart_content.name = "ChartContent"
	full_chart_view.add_child(chart_content)
	chart_content.fit_content = true
	chart_content.add_theme_color_override("default_color", MedicalColors.TEXT_DARK)
	chart_content.add_theme_font_size_override("normal_font_size", 14)

func setup_summary_chart_view(parent: Control) -> void:
	"""Setup the condensed summary chart view"""
	
	summary_chart_view = Panel.new()
	summary_chart_view.name = "SummaryChartView"
	parent.add_child(summary_chart_view)
	summary_chart_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_chart_view.visible = false
	
	# Summary panel styling
	var summary_style = StyleBoxFlat.new()
	summary_style.bg_color = Color(MedicalColors.CHART_PAPER.r, MedicalColors.CHART_PAPER.g, 
								   MedicalColors.CHART_PAPER.b, 0.9)
	summary_style.border_width_left = 1
	summary_style.border_width_right = 1  
	summary_style.border_width_top = 1
	summary_style.border_width_bottom = 1
	summary_style.border_color = MedicalColors.STERILE_BLUE
	summary_chart_view.add_theme_stylebox_override("panel", summary_style)
	
	summary_content = RichTextLabel.new()
	summary_content.name = "SummaryContent"
	summary_chart_view.add_child(summary_content)
	summary_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	summary_content.fit_content = true
	summary_content.add_theme_color_override("default_color", MedicalColors.TEXT_DARK)
	summary_content.add_theme_font_size_override("normal_font_size", 16)

func setup_controls_panel() -> void:
	"""Setup the assessment controls panel"""
	
	if not controls_panel:
		controls_panel = Panel.new()
		controls_panel.name = "ControlsPanel"
		main_layout.add_child(controls_panel)
		controls_panel.custom_minimum_size.x = 400
		
		# Controls panel styling
		var controls_style = StyleBoxFlat.new()
		controls_style.bg_color = MedicalColors.MEDICAL_GREEN
		controls_style.border_width_left = 2
		controls_style.border_width_right = 2
		controls_style.border_width_top = 2
		controls_style.border_width_bottom = 2
		controls_style.border_color = MedicalColors.STERILE_BLUE_DARK
		controls_panel.add_theme_stylebox_override("panel", controls_style)
	
	# Create controls layout
	var controls_vbox = VBoxContainer.new()
	controls_vbox.name = "ControlsVBox"
	controls_panel.add_child(controls_vbox)
	controls_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	controls_vbox.add_theme_constant_override("separation", 15)
	
	setup_timer_and_status(controls_vbox)
	setup_question_area(controls_vbox)
	setup_answer_buttons(controls_vbox)
	setup_help_panel(controls_vbox)

func setup_timer_and_status(parent: Control) -> void:
	"""Setup timer and status display"""
	
	var status_hbox = HBoxContainer.new()
	parent.add_child(status_hbox)
	
	timer_display = Label.new()
	timer_display.name = "TimerDisplay"
	timer_display.text = "Time: --:--"
	timer_display.add_theme_font_size_override("font_size", 16)
	timer_display.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	status_hbox.add_child(timer_display)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_hbox.add_child(spacer)
	
	# Coffee momentum indicator
	var coffee_label = Label.new()
	coffee_label.text = "☕ Energy"
	coffee_label.add_theme_color_override("font_color", MedicalColors.COFFEE_BROWN)
	status_hbox.add_child(coffee_label)

func setup_question_area(parent: Control) -> void:
	"""Setup the question display area"""
	
	question_area = RichTextLabel.new()
	question_area.name = "QuestionArea"
	parent.add_child(question_area)
	question_area.custom_minimum_size.y = 120
	question_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	question_area.fit_content = true
	question_area.add_theme_color_override("default_color", MedicalColors.TEXT_LIGHT)
	question_area.add_theme_font_size_override("normal_font_size", 15)

func setup_answer_buttons(parent: Control) -> void:
	"""Setup answer button container"""
	
	answer_buttons = VBoxContainer.new()
	answer_buttons.name = "AnswerButtons"
	parent.add_child(answer_buttons)
	answer_buttons.size_flags_vertical = Control.SIZE_EXPAND_FILL
	answer_buttons.add_theme_constant_override("separation", 8)
	
	# Create answer buttons A-E
	for i in range(5):
		var button = Button.new()
		var letter = String.chr(65 + i)  # A, B, C, D, E
		button.name = "Answer%s" % letter
		button.text = "%s) Answer choice" % letter
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_answer_selected.bind(letter))
		answer_buttons.add_child(button)
		
		# Style the buttons
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = MedicalColors.STERILE_BLUE
		button_style.border_width_left = 1
		button_style.border_width_right = 1
		button_style.border_width_top = 1
		button_style.border_width_bottom = 1
		button_style.border_color = MedicalColors.STERILE_BLUE_DARK
		button.add_theme_stylebox_override("normal", button_style)

func setup_help_panel(parent: Control) -> void:
	"""Setup help and shortcut information panel"""
	
	help_panel = Panel.new()
	help_panel.name = "HelpPanel"
	parent.add_child(help_panel)
	help_panel.custom_minimum_size.y = 80
	
	var help_style = StyleBoxFlat.new()
	help_style.bg_color = Color(MedicalColors.EQUIPMENT_GRAY.r, MedicalColors.EQUIPMENT_GRAY.g, 
								MedicalColors.EQUIPMENT_GRAY.b, 0.3)
	help_panel.add_theme_stylebox_override("panel", help_style)
	
	var help_label = RichTextLabel.new()
	help_label.name = "HelpLabel"
	help_panel.add_child(help_label)
	help_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	help_label.fit_content = true
	help_label.add_theme_color_override("default_color", MedicalColors.TEXT_LIGHT)
	help_label.add_theme_font_size_override("normal_font_size", 12)
	help_label.text = "[b]Shortcuts:[/b]\n[color=#88CCFF]SPACE[/color] - Toggle Summary View\n[color=#88CCFF]1-5[/color] - Select Answer\n[color=#88CCFF]ENTER[/color] - Confirm Selection"

func setup_equipment_context() -> void:
	"""Setup medical equipment context display"""
	
	# Add equipment panel to chart area
	if chart_panel:
		equipment_panel = Panel.new()
		equipment_panel.name = "EquipmentPanel"
		chart_panel.add_child(equipment_panel)
		equipment_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		equipment_panel.size = Vector2(150, 100)
		equipment_panel.position.x -= 160
		equipment_panel.position.y = 10
		
		# Equipment styling
		var equipment_style = StyleBoxFlat.new()
		equipment_style.bg_color = MedicalColors.EQUIPMENT_GRAY
		equipment_style.border_width_left = 1
		equipment_style.border_width_right = 1
		equipment_style.border_width_top = 1
		equipment_style.border_width_bottom = 1
		equipment_style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
		equipment_panel.add_theme_stylebox_override("panel", equipment_style)
	
	setup_vital_signs_monitor()
	setup_equipment_timers()

func setup_vital_signs_monitor() -> void:
	"""Setup the vital signs monitoring display"""
	
	if not equipment_panel:
		return
	
	var monitor_vbox = VBoxContainer.new()
	monitor_vbox.name = "MonitorVBox"
	equipment_panel.add_child(monitor_vbox)
	monitor_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	monitor_vbox.add_theme_constant_override("separation", 5)
	
	# Monitor display texture
	monitor_display = TextureRect.new()
	monitor_display.name = "MonitorDisplay"
	monitor_vbox.add_child(monitor_display)
	monitor_display.custom_minimum_size = Vector2(140, 60)
	monitor_display.texture = PlaceholderAssets.create_medical_monitor_texture()
	
	# Vital signs text
	vital_signs_monitor = RichTextLabel.new()
	vital_signs_monitor.name = "VitalSignsMonitor"
	monitor_vbox.add_child(vital_signs_monitor)
	vital_signs_monitor.custom_minimum_size.y = 30
	vital_signs_monitor.fit_content = true
	vital_signs_monitor.add_theme_color_override("default_color", MedicalColors.MONITOR_GREEN)
	vital_signs_monitor.add_theme_font_size_override("normal_font_size", 10)

func setup_equipment_timers() -> void:
	"""Setup timers for equipment simulation"""
	
	# Heart rate simulation timer
	heart_rate_timer = Timer.new()
	heart_rate_timer.name = "HeartRateTimer"
	add_child(heart_rate_timer)
	heart_rate_timer.wait_time = 60.0 / 72.0  # 72 BPM
	heart_rate_timer.autostart = false
	heart_rate_timer.timeout.connect(_on_heart_rate_beat)
	
	# Equipment status update timer
	equipment_update_timer = Timer.new()
	equipment_update_timer.name = "EquipmentUpdateTimer"
	add_child(equipment_update_timer)
	equipment_update_timer.wait_time = 2.0
	equipment_update_timer.autostart = false
	equipment_update_timer.timeout.connect(_on_equipment_update)

func setup_interactions() -> void:
	"""Setup UI interactions and shortcuts"""
	# Input handling is in _input method
	pass

func load_patient_data(patient_data: Dictionary) -> void:
	"""Load patient data into the assessment interface"""
	
	current_patient_data = patient_data
	print("AssessmentPhaseUI: Loading patient data")
	
	# Update chart content
	update_full_chart_content()
	update_summary_chart_content()
	
	# Update question and answers
	update_question_display()
	update_answer_buttons()
	
	# Update medical equipment simulation
	update_equipment_simulation()
	
	# Start assessment
	start_assessment_phase()

func update_full_chart_content() -> void:
	"""Update the full chart view with complete patient information"""
	
	if not chart_content:
		return
	
	var content = "[b][color=#2A4F47]PATIENT CHART - EMERGENCY DEPARTMENT[/color][/b]\n\n"
	
	# Demographics
	content += "[b]DEMOGRAPHICS[/b]\n"
	content += "Name: %s\n" % current_patient_data.get("name", "Patient")
	content += "Age/Gender: %s\n" % current_patient_data.get("demographics", "Unknown")
	content += "\n"
	
	# Chief Complaint / Presentation
	content += "[b]CHIEF COMPLAINT[/b]\n"
	content += "%s\n\n" % current_patient_data.get("presentation", "No complaint documented")
	
	# History
	if current_patient_data.has("history"):
		content += "[b]HISTORY OF PRESENT ILLNESS[/b]\n"
		content += "%s\n\n" % current_patient_data.history
	
	# Physical Exam
	if current_patient_data.has("physicalExam"):
		content += "[b]PHYSICAL EXAMINATION[/b]\n"
		content += "%s\n\n" % current_patient_data.physicalExam
	
	# Vital Signs
	if current_patient_data.has("vitals"):
		content += "[b]VITAL SIGNS[/b]\n"
		var vitals = current_patient_data.vitals
		for key in vitals.keys():
			var color = get_vital_sign_color(key, str(vitals[key]))
			content += "[color=%s]%s: %s[/color]\n" % [color, key, vitals[key]]
		content += "\n"
	
	# Lab Results
	if current_patient_data.has("labs"):
		content += "[b]LABORATORY RESULTS[/b]\n"
		content += "%s\n\n" % current_patient_data.labs.get("formatted", "No labs available")
	
	chart_content.text = content

func update_summary_chart_content() -> void:
	"""Update the summary view with key information only"""
	
	if not summary_content:
		return
	
	var content = "[b][color=#2A4F47]PATIENT SUMMARY[/color][/b]\n\n"
	
	# Key demographics and presentation
	content += "[b]Patient:[/b] %s\n" % current_patient_data.get("demographics", "Unknown")
	content += "[b]Chief Complaint:[/b]\n%s\n\n" % current_patient_data.get("presentation", "No complaint")
	
	# Critical vital signs only
	if current_patient_data.has("vitals"):
		content += "[b]KEY VITALS[/b]\n"
		var vitals = current_patient_data.vitals
		var critical_vitals = ["HR", "BP", "O2Sat", "Temp"]
		
		for vital in critical_vitals:
			if vitals.has(vital):
				var color = get_vital_sign_color(vital, str(vitals[vital]))
				content += "[color=%s]%s: %s[/color]\n" % [color, vital, vitals[vital]]
		content += "\n"
	
	# Key physical findings (abbreviated)
	if current_patient_data.has("physicalExam"):
		var exam = str(current_patient_data.physicalExam)
		var short_exam = exam.substr(0, min(200, exam.length()))
		if exam.length() > 200:
			short_exam += "..."
		content += "[b]Key Findings:[/b] %s\n" % short_exam
	
	summary_content.text = content

func get_vital_sign_color(vital_name: String, vital_value: String) -> String:
	"""Get color code for vital sign based on normal ranges"""
	
	var value = parse_vital_value(vital_value)
	
	match vital_name:
		"HR":
			if value > 120 or value < 50:
				return "#D94545"  # Red for abnormal HR
			elif value > 100 or value < 60:
				return "#D97A45"  # Orange for borderline
			else:
				return "#47AA64"  # Green for normal
		"O2Sat":
			if value < 90:
				return "#D94545"  # Red for critical O2
			elif value < 95:
				return "#D97A45"  # Orange for low O2
			else:
				return "#47AA64"  # Green for normal
		"Temp":
			if value > 38.5 or value < 35.0:
				return "#D94545"  # Red for fever/hypothermia
			elif value > 37.5 or value < 36.0:
				return "#D97A45"  # Orange for borderline
			else:
				return "#47AA64"  # Green for normal
		_:
			return "#F5F5F5"  # Default white

func parse_vital_value(vital_string: String) -> float:
	"""Parse numeric value from vital sign string"""
	var regex = RegEx.new()
	regex.compile(r"\d+\.?\d*")
	var result = regex.search(vital_string)
	if result:
		return result.get_string().to_float()
	return 0.0

func update_question_display() -> void:
	"""Update the question area with current patient question"""
	
	if not question_area:
		return
	
	var question_text = "[b]CLINICAL DECISION[/b]\n\n"
	question_text += current_patient_data.get("question", "What is the most appropriate next step?")
	
	question_area.text = question_text

func update_answer_buttons() -> void:
	"""Update answer buttons with current choices"""
	
	if not answer_buttons:
		return
	
	var choices = current_patient_data.get("choices", [])
	var button_children = answer_buttons.get_children()
	
	for i in range(min(choices.size(), button_children.size())):
		var button = button_children[i]
		var choice = choices[i]
		
		if button and choice.has("text"):
			var letter = String.chr(65 + i)
			button.text = "%s) %s" % [letter, choice.text]
			button.visible = true
	
	# Hide unused buttons
	for i in range(choices.size(), button_children.size()):
		if button_children[i]:
			button_children[i].visible = false

func update_equipment_simulation() -> void:
	"""Update medical equipment simulation based on patient data"""
	
	# Extract heart rate from vitals for simulation
	if current_patient_data.has("vitals") and current_patient_data.vitals.has("HR"):
		var hr_string = str(current_patient_data.vitals.HR)
		current_heart_rate = int(parse_vital_value(hr_string))
		
		# Update heart rate timer
		if heart_rate_timer and current_heart_rate > 0:
			heart_rate_timer.wait_time = 60.0 / current_heart_rate
	
	# Update vital signs display
	update_vital_signs_display()

func update_vital_signs_display() -> void:
	"""Update the vital signs monitor display"""
	
	if not vital_signs_monitor:
		return
	
	var display_text = "[b]MONITOR[/b]\n"
	
	if current_patient_data.has("vitals"):
		var vitals = current_patient_data.vitals
		if vitals.has("HR"):
			display_text += "HR: %s\n" % vitals.HR
		if vitals.has("O2Sat"):
			display_text += "SpO2: %s\n" % vitals.O2Sat
	
	vital_signs_monitor.text = display_text

func start_assessment_phase() -> void:
	"""Start the assessment phase"""
	
	assessment_active = true
	
	# Start equipment simulation
	if heart_rate_timer:
		heart_rate_timer.start()
	if equipment_update_timer:
		equipment_update_timer.start()
	
	print("AssessmentPhaseUI: Assessment phase started")

# Event handlers
func _on_chart_toggle_pressed() -> void:
	"""Handle chart view toggle button"""
	toggle_chart_view()

func toggle_chart_view() -> void:
	"""Toggle between full chart and summary view"""
	
	is_summary_view = !is_summary_view
	
	if full_chart_view:
		full_chart_view.visible = !is_summary_view
	if summary_chart_view:
		summary_chart_view.visible = is_summary_view
	
	# Update toggle button text
	var toggle_button = find_child("*", true, false)
	if toggle_button and toggle_button.has_method("set_text"):
		if is_summary_view:
			toggle_button.text = "Full Chart (SPACE)"
		else:
			toggle_button.text = "Summary View (SPACE)"
	
	chart_view_toggled.emit(is_summary_view)
	print("AssessmentPhaseUI: Toggled to %s view" % ("summary" if is_summary_view else "full"))

func _on_answer_selected(letter: String) -> void:
	"""Handle answer button selection"""
	
	if not assessment_active:
		return
	
	print("AssessmentPhaseUI: Answer %s selected" % letter)
	
	# Highlight selected button
	highlight_selected_answer(letter)
	
	# Complete assessment
	assessment_completed.emit(letter)

func highlight_selected_answer(selected_letter: String) -> void:
	"""Highlight the selected answer button"""
	
	if not answer_buttons:
		return
	
	for button in answer_buttons.get_children():
		if button.name.ends_with(selected_letter):
			button.modulate = Color(1.2, 1.2, 0.8)  # Highlight selected
		else:
			button.modulate = Color(0.7, 0.7, 0.7)  # Dim others

func _on_heart_rate_beat() -> void:
	"""Simulate heart rate monitor beat"""
	
	# Create subtle visual pulse effect on monitor
	if monitor_display:
		var tween = create_tween()
		tween.tween_property(monitor_display, "modulate", Color(1.2, 1.2, 1.2), 0.1)
		tween.tween_property(monitor_display, "modulate", Color.WHITE, 0.1)

func _on_equipment_update() -> void:
	"""Update equipment display periodically"""
	
	# Add slight variations to make equipment feel alive
	if vital_signs_monitor and current_patient_data.has("vitals"):
		var hr_variation = randi_range(-2, 2)
		var display_hr = current_heart_rate + hr_variation
		
		# Update display with variation
		update_vital_signs_display()

# Input handling
func _input(event: InputEvent) -> void:
	"""Handle assessment phase input"""
	
	if not visible or not assessment_active:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				toggle_chart_view()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
				var answer_index = event.keycode - KEY_1
				var answer_letter = String.chr(65 + answer_index)
				_on_answer_selected(answer_letter)
			KEY_F1:
				spacebar_help_requested.emit()

# Public interface
func set_assessment_active(active: bool) -> void:
	"""Set assessment phase active state"""
	assessment_active = active

func get_is_summary_view() -> bool:
	"""Check if currently in summary view"""
	return is_summary_view

func cleanup_assessment() -> void:
	"""Clean up assessment phase resources"""
	
	assessment_active = false
	
	if heart_rate_timer:
		heart_rate_timer.stop()
	if equipment_update_timer:
		equipment_update_timer.stop()
	
	print("AssessmentPhaseUI: Assessment phase cleaned up")
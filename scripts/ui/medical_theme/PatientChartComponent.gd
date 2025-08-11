class_name PatientChartComponent
extends Panel

# Patient chart UI component with medical styling and coffee stains
# Handles display of patient information in authentic medical format

signal chart_loaded(chart_data: Dictionary)
signal section_expanded(section_name: String)
signal vital_signs_highlighted()

# Chart sections
@onready var patient_header: Label
@onready var demographics_section: VBoxContainer
@onready var vital_signs_section: VBoxContainer
@onready var history_section: VBoxContainer
@onready var physical_exam_section: VBoxContainer
@onready var labs_section: VBoxContainer

# Chart effects
@onready var coffee_stains: Node2D
@onready var wear_effects: Node2D
@onready var highlight_overlay: ColorRect

# Current chart data
var current_chart_data: Dictionary = {}
var is_summary_mode: bool = false

func _ready():
	setup_chart_styling()
	create_chart_sections()
	add_authenticity_effects()

func setup_chart_styling():
	"""Apply medical chart styling to the panel"""
	
	# Create chart paper background with medical styling
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.CHART_PAPER
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
	style.border_color = MedicalColors.EQUIPMENT_GRAY
	style.corner_radius_top_left = style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size = 6
	style.shadow_offset = Vector2(3, 3)
	
	add_theme_stylebox_override("panel", style)

func create_chart_sections():
	"""Create the main chart sections"""
	
	var main_container = VBoxContainer.new()
	main_container.name = "ChartContent"
	add_child(main_container)
	
	# Set margins for authentic chart appearance
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.offset_left = 20
	main_container.offset_top = 16
	main_container.offset_right = -20
	main_container.offset_bottom = -16
	
	# Hospital header
	create_hospital_header(main_container)
	
	# Patient demographics
	demographics_section = create_chart_section(main_container, "PATIENT INFORMATION")
	
	# Vital signs
	vital_signs_section = create_chart_section(main_container, "VITAL SIGNS")
	
	# History of Present Illness
	history_section = create_chart_section(main_container, "HISTORY OF PRESENT ILLNESS")
	
	# Physical Examination
	physical_exam_section = create_chart_section(main_container, "PHYSICAL EXAMINATION")
	
	# Laboratory Results
	labs_section = create_chart_section(main_container, "LABORATORY RESULTS")

func create_hospital_header(parent: VBoxContainer):
	"""Create authentic hospital header"""
	
	var header_container = VBoxContainer.new()
	parent.add_child(header_container)
	
	# Hospital name
	var hospital_label = MedicalUIComponents.create_medical_label("BLACKSTAR GENERAL HOSPITAL", "header")
	hospital_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hospital_label.add_theme_color_override("font_color", MedicalColors.MEDICAL_GREEN_DARK)
	header_container.add_child(hospital_label)
	
	# Emergency Department
	var dept_label = MedicalUIComponents.create_medical_label("Emergency Department", "normal")
	dept_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dept_label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
	header_container.add_child(dept_label)
	
	# Separator
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", MedicalColors.EQUIPMENT_GRAY)
	header_container.add_child(separator)
	
	# Add some space
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 12
	header_container.add_child(spacer)

func create_chart_section(parent: VBoxContainer, title: String) -> VBoxContainer:
	"""Create a chart section with collapsible header"""
	
	var section_container = VBoxContainer.new()
	section_container.name = title.replace(" ", "")
	parent.add_child(section_container)
	
	# Section header
	var header_button = Button.new()
	header_button.text = title
	header_button.flat = true
	header_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	MedicalFont.apply_font_config(header_button, MedicalFont.get_chart_header_font_config())
	header_button.add_theme_color_override("font_color", MedicalColors.MEDICAL_GREEN_DARK)
	section_container.add_child(header_button)
	
	# Connect header for expansion/collapse
	header_button.pressed.connect(_on_section_header_pressed.bind(title))
	
	# Content container
	var content_container = VBoxContainer.new()
	content_container.name = "Content"
	section_container.add_child(content_container)
	
	# Section separator
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", MedicalColors.TEXT_MUTED)
	section_container.add_child(separator)
	
	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 8
	section_container.add_child(spacer)
	
	return content_container

func load_chart_data(chart_data: Dictionary):
	"""Load patient data into the chart"""
	
	current_chart_data = chart_data
	
	# Load demographics
	if chart_data.has("demographics"):
		load_demographics(chart_data.demographics)
	
	# Load vital signs
	if chart_data.has("vitals"):
		load_vital_signs(chart_data.vitals)
	
	# Load history
	if chart_data.has("history") or chart_data.has("presentation"):
		var history_text = chart_data.get("history", chart_data.get("presentation", ""))
		load_history(history_text)
	
	# Load physical exam
	if chart_data.has("physical_exam") or chart_data.has("physicalExam"):
		var exam_text = chart_data.get("physical_exam", chart_data.get("physicalExam", ""))
		load_physical_exam(exam_text)
	
	# Load labs
	if chart_data.has("labs"):
		load_laboratory_results(chart_data.labs)
	
	chart_loaded.emit(chart_data)

func load_demographics(demographics_data):
	"""Load patient demographics section"""
	
	if not demographics_section:
		return
	
	# Clear existing content
	for child in demographics_section.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var demographics_text: String
	if demographics_data is String:
		demographics_text = demographics_data
	elif demographics_data is Dictionary:
		demographics_text = format_demographics_dict(demographics_data)
	else:
		demographics_text = str(demographics_data)
	
	var demographics_label = MedicalUIComponents.create_medical_label(demographics_text, "chart")
	demographics_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	demographics_section.add_child(demographics_label)

func format_demographics_dict(demo_dict: Dictionary) -> String:
	"""Format demographics dictionary into medical chart format"""
	
	var formatted = ""
	
	if demo_dict.has("name"):
		formatted += "Name: " + str(demo_dict.name) + "\n"
	if demo_dict.has("age"):
		formatted += "Age: " + str(demo_dict.age) + "\n"
	if demo_dict.has("gender") or demo_dict.has("sex"):
		var gender = demo_dict.get("gender", demo_dict.get("sex", ""))
		formatted += "Sex: " + str(gender) + "\n"
	if demo_dict.has("mrn"):
		formatted += "MRN: " + str(demo_dict.mrn) + "\n"
	if demo_dict.has("dob"):
		formatted += "DOB: " + str(demo_dict.dob) + "\n"
	
	return formatted.strip_edges()

func load_vital_signs(vitals_data):
	"""Load vital signs with highlighting for abnormal values"""
	
	if not vital_signs_section:
		return
	
	# Clear existing content
	for child in vital_signs_section.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	# Create vital signs grid
	var vitals_grid = GridContainer.new()
	vitals_grid.columns = 2
	vitals_section.add_child(vitals_grid)
	
	var vital_order = ["BP", "HR", "RR", "Temp", "O2Sat", "Pain"]
	var vital_names = {
		"BP": "Blood Pressure:",
		"HR": "Heart Rate:",
		"RR": "Respiratory Rate:",
		"Temp": "Temperature:",
		"O2Sat": "Oxygen Saturation:",
		"Pain": "Pain Score:"
	}
	
	for vital_key in vital_order:
		if vitals_data.has(vital_key):
			# Label
			var label = MedicalUIComponents.create_medical_label(vital_names[vital_key], "chart")
			vitals_grid.add_child(label)
			
			# Value
			var value_label = MedicalUIComponents.create_medical_label(str(vitals_data[vital_key]), "vital")
			
			# Highlight abnormal values
			if is_abnormal_vital(vital_key, vitals_data[vital_key]):
				value_label.add_theme_color_override("font_color", MedicalColors.URGENT_RED)
				# Add slight background highlight
				var highlight_style = StyleBoxFlat.new()
				highlight_style.bg_color = Color(MedicalColors.URGENT_RED.r, MedicalColors.URGENT_RED.g, MedicalColors.URGENT_RED.b, 0.1)
				highlight_style.corner_radius_top_left = highlight_style.corner_radius_top_right = 2
				highlight_style.corner_radius_bottom_left = highlight_style.corner_radius_bottom_right = 2
				value_label.add_theme_stylebox_override("normal", highlight_style)
			
			vitals_grid.add_child(value_label)

func is_abnormal_vital(vital_type: String, value: String) -> bool:
	"""Check if a vital sign value is abnormal"""
	
	match vital_type:
		"BP":
			# Simple check for high BP (would be more sophisticated in practice)
			return "1" in value and ("16" in value or "17" in value or "18" in value or "19" in value or "20" in value)
		"HR":
			var hr_val = value.to_int()
			return hr_val > 100 or hr_val < 60
		"RR":
			var rr_val = value.to_int()
			return rr_val > 20 or rr_val < 12
		"Temp":
			return "38" in value or "39" in value or "40" in value or "101" in value or "102" in value or "103" in value
		"O2Sat":
			return "%" in value and (value.begins_with("8") or value.begins_with("9") and value.to_int() < 95)
		_:
			return false

func load_history(history_text: String):
	"""Load history of present illness"""
	
	if not history_section:
		return
	
	# Clear existing content
	for child in history_section.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var history_label = MedicalUIComponents.create_medical_label(history_text, "chart")
	history_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	history_section.add_child(history_label)

func load_physical_exam(exam_text: String):
	"""Load physical examination findings"""
	
	if not physical_exam_section:
		return
	
	# Clear existing content
	for child in physical_exam_section.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var exam_label = MedicalUIComponents.create_medical_label(exam_text, "chart")
	exam_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	physical_exam_section.add_child(exam_label)

func load_laboratory_results(labs_data):
	"""Load laboratory results"""
	
	if not labs_section:
		return
	
	# Clear existing content
	for child in labs_section.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var labs_text: String
	if labs_data is String:
		labs_text = labs_data
	elif labs_data is Dictionary:
		labs_text = format_labs_dict(labs_data)
	else:
		labs_text = str(labs_data)
	
	var labs_label = MedicalUIComponents.create_medical_label(labs_text, "chart")
	labs_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labs_section.add_child(labs_label)

func format_labs_dict(labs_dict: Dictionary) -> String:
	"""Format laboratory results dictionary"""
	
	var formatted = ""
	
	# Common lab ordering
	var lab_order = ["WBC", "Hgb", "Hct", "Plt", "Na", "K", "Cl", "CO2", "BUN", "Cr", "Glucose", "Troponin", "CK-MB", "BNP"]
	
	for lab in lab_order:
		if labs_dict.has(lab):
			formatted += lab + ": " + str(labs_dict[lab]) + "\n"
	
	# Add any remaining labs not in the standard order
	for lab in labs_dict.keys():
		if not lab in lab_order:
			formatted += lab + ": " + str(labs_dict[lab]) + "\n"
	
	return formatted.strip_edges()

func add_authenticity_effects():
	"""Add coffee stains and wear effects for authenticity"""
	
	# Create coffee stains overlay
	coffee_stains = Node2D.new()
	coffee_stains.name = "CoffeeStains"
	add_child(coffee_stains)
	
	# Add a few coffee stains
	add_coffee_stain(Vector2(size.x - 80, 60), 0.3)
	add_coffee_stain(Vector2(40, size.y - 100), 0.2)
	add_coffee_stain(Vector2(size.x / 2, size.y / 3), 0.15)
	
	# Create wear effects
	wear_effects = Node2D.new()
	wear_effects.name = "WearEffects"
	add_child(wear_effects)
	
	# Add bent corner effect
	add_bent_corner()

func add_coffee_stain(position: Vector2, intensity: float):
	"""Add a coffee stain at specified position"""
	
	var stain = ColorRect.new()
	stain.color = MedicalColors.add_coffee_stain(MedicalColors.CHART_PAPER, intensity)
	stain.size = Vector2(20 + randf() * 15, 20 + randf() * 15)
	stain.position = position
	
	# Make it circular by setting corner radius
	var style = StyleBoxFlat.new()
	style.bg_color = stain.color
	style.corner_radius_top_left = style.corner_radius_top_right = int(stain.size.x / 2)
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = int(stain.size.x / 2)
	stain.add_theme_stylebox_override("panel", style)
	
	coffee_stains.add_child(stain)

func add_bent_corner():
	"""Add bent corner effect to chart"""
	
	var corner = Polygon2D.new()
	var corner_size = 12
	corner.polygon = PackedVector2Array([
		Vector2(size.x - corner_size, 0),
		Vector2(size.x, 0),
		Vector2(size.x, corner_size)
	])
	corner.color = MedicalColors.EQUIPMENT_GRAY
	wear_effects.add_child(corner)

func toggle_summary_mode():
	"""Toggle between full chart and summary view"""
	
	is_summary_mode = !is_summary_mode
	
	# In summary mode, hide less critical sections
	if is_summary_mode:
		if physical_exam_section.get_parent():
			physical_exam_section.get_parent().visible = false
		if labs_section.get_parent():
			labs_section.get_parent().visible = false
	else:
		# Show all sections
		for section in [demographics_section, vital_signs_section, history_section, physical_exam_section, labs_section]:
			if section and section.get_parent():
				section.get_parent().visible = true

func highlight_priority_information():
	"""Highlight critical information for quick review"""
	
	vital_signs_highlighted.emit()
	
	# Create highlight animation for vital signs
	if vital_signs_section:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		
		# Add temporary highlight background
		var highlight = ColorRect.new()
		highlight.color = Color(MedicalColors.URGENT_YELLOW.r, MedicalColors.URGENT_YELLOW.g, MedicalColors.URGENT_YELLOW.b, 0.0)
		vital_signs_section.add_child(highlight)
		vital_signs_section.move_child(highlight, 0)  # Move to back
		
		highlight.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		# Animate highlight
		tween.tween_property(highlight, "color:a", 0.3, 0.2)
		tween.tween_delay(0.6)
		tween.tween_property(highlight, "color:a", 0.0, 0.4)
		tween.tween_callback(highlight.queue_free)

func _on_section_header_pressed(section_name: String):
	"""Handle section header pressed for expand/collapse"""
	section_expanded.emit(section_name)
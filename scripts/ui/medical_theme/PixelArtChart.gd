class_name PixelArtChart
extends Control

# Pixel art patient chart system for Blackstar
# Creates authentic medical charts that slide across desk with realistic details

signal chart_slide_complete()
signal chart_section_highlighted(section: String)
signal critical_info_blink()

# Chart visual elements
@onready var chart_paper: Panel
@onready var chart_content: VBoxContainer
@onready var coffee_stains: Node2D
@onready var paper_clips: Node2D
@onready var highlight_overlay: ColorRect

# Animation components
var slide_tween: Tween
var highlight_tween: Tween
var current_slide_state: String = "off_screen"  # off_screen, sliding_in, on_desk, sliding_out

# Chart data
var patient_data: Dictionary = {}
var chart_urgency_level: float = 0.0  # 0.0 routine to 1.0 critical
var chart_wear_level: float = 0.0  # 0.0 new to 1.0 heavily used

# Visual styling
var chart_base_size: Vector2 = Vector2(320, 240)
var slide_start_position: Vector2
var slide_end_position: Vector2

func _ready():
	setup_chart_structure()
	setup_slide_positions()

func setup_chart_structure():
	"""Create the basic chart structure with pixel art styling"""
	
	# Set initial size and position
	size = chart_base_size
	position = Vector2(-chart_base_size.x, 0)  # Start off screen
	
	# Main chart paper background
	chart_paper = Panel.new()
	chart_paper.name = "ChartPaper"
	chart_paper.size = chart_base_size
	chart_paper.position = Vector2.ZERO
	add_child(chart_paper)
	
	# Apply chart paper styling
	apply_chart_paper_styling()
	
	# Content container for medical information
	chart_content = VBoxContainer.new()
	chart_content.name = "ChartContent"
	chart_content.position = Vector2(15, 12)
	chart_content.size = Vector2(chart_base_size.x - 30, chart_base_size.y - 24)
	chart_paper.add_child(chart_content)
	
	# Coffee stains and authenticity effects
	coffee_stains = Node2D.new()
	coffee_stains.name = "CoffeeStains"
	chart_paper.add_child(coffee_stains)
	
	# Paper clips and attachments
	paper_clips = Node2D.new()
	paper_clips.name = "PaperClips"
	chart_paper.add_child(paper_clips)
	
	# Highlight overlay for critical information
	highlight_overlay = ColorRect.new()
	highlight_overlay.name = "HighlightOverlay"
	highlight_overlay.size = chart_base_size
	highlight_overlay.position = Vector2.ZERO
	highlight_overlay.color = Color.TRANSPARENT
	highlight_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chart_paper.add_child(highlight_overlay)

func apply_chart_paper_styling():
	"""Apply authentic medical chart paper styling"""
	
	var style = StyleBoxFlat.new()
	
	# Base paper color with aging based on wear level
	var base_color = MedicalColors.CHART_PAPER
	if chart_wear_level > 0.1:
		base_color = MedicalColors.add_wear_effect(base_color, chart_wear_level * 0.2)
	
	style.bg_color = base_color
	
	# Paper borders
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = MedicalColors.TEXT_MUTED
	
	# Slight corner rounding for paper authenticity
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	
	# Drop shadow for depth
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 4
	style.shadow_offset = Vector2(3, 3)
	
	chart_paper.add_theme_stylebox_override("panel", style)

func setup_slide_positions():
	"""Setup positions for chart sliding animation"""
	
	# Start position (off screen left)
	slide_start_position = Vector2(-chart_base_size.x - 20, get_parent().size.y * 0.55)
	
	# End position (on desk)
	slide_end_position = Vector2(get_parent().size.x * 0.25, get_parent().size.y * 0.55)

func load_patient_chart(patient_info: Dictionary, urgency: float = 0.0, wear: float = 0.0):
	"""Load patient information into the chart with visual styling"""
	
	patient_data = patient_info
	chart_urgency_level = clampf(urgency, 0.0, 1.0)
	chart_wear_level = clampf(wear, 0.0, 1.0)
	
	# Clear existing content
	for child in chart_content.get_children():
		child.queue_free()
	
	# Wait for children to be removed
	await get_tree().process_frame
	
	# Create chart header
	create_chart_header()
	
	# Add patient demographics
	add_patient_demographics()
	
	# Add vital signs with urgency highlighting
	add_vital_signs()
	
	# Add chief complaint
	add_chief_complaint()
	
	# Add history and physical exam
	add_history_and_physical()
	
	# Add laboratory results
	add_laboratory_results()
	
	# Apply authenticity effects
	add_coffee_stains()
	add_paper_clips()
	add_wear_marks()
	
	# Apply urgency styling
	apply_urgency_styling()

func create_chart_header():
	"""Create the hospital header on the chart"""
	
	var header_container = VBoxContainer.new()
	header_container.name = "Header"
	chart_content.add_child(header_container)
	
	# Hospital name
	var hospital_label = create_pixel_chart_label("BLACKSTAR GENERAL HOSPITAL", "header")
	hospital_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hospital_label.add_theme_color_override("font_color", MedicalColors.MEDICAL_GREEN_DARK)
	header_container.add_child(hospital_label)
	
	# Emergency Department
	var dept_label = create_pixel_chart_label("EMERGENCY DEPARTMENT", "sub_header")
	dept_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dept_label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
	header_container.add_child(dept_label)
	
	# Date/Time stamp
	var datetime_label = create_pixel_chart_label(get_current_datetime(), "small")
	datetime_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	datetime_label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
	header_container.add_child(datetime_label)
	
	# Separator line
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", MedicalColors.EQUIPMENT_GRAY_DARK)
	header_container.add_child(separator)
	
	# Spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 8
	header_container.add_child(spacer)

func add_patient_demographics():
	"""Add patient demographics section"""
	
	var demo_section = create_chart_section("PATIENT INFORMATION")
	chart_content.add_child(demo_section)
	
	# Patient name
	if patient_data.has("name"):
		var name_label = create_pixel_chart_label("Name: " + str(patient_data.name), "normal")
		demo_section.add_child(name_label)
	
	# Age and gender
	var age_gender = ""
	if patient_data.has("age"):
		age_gender += "Age: " + str(patient_data.age)
	if patient_data.has("gender") or patient_data.has("sex"):
		var gender = patient_data.get("gender", patient_data.get("sex", ""))
		if age_gender != "":
			age_gender += "  •  "
		age_gender += "Sex: " + str(gender)
	
	if age_gender != "":
		var age_gender_label = create_pixel_chart_label(age_gender, "normal")
		demo_section.add_child(age_gender_label)
	
	# Medical record number
	if patient_data.has("mrn"):
		var mrn_label = create_pixel_chart_label("MRN: " + str(patient_data.mrn), "small")
		mrn_label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
		demo_section.add_child(mrn_label)

func add_vital_signs():
	"""Add vital signs with urgency highlighting"""
	
	if not patient_data.has("vitals"):
		return
	
	var vitals_section = create_chart_section("VITAL SIGNS")
	chart_content.add_child(vitals_section)
	
	# Create vitals grid
	var vitals_grid = GridContainer.new()
	vitals_grid.columns = 2
	vitals_grid.add_theme_constant_override("h_separation", 20)
	vitals_grid.add_theme_constant_override("v_separation", 4)
	vitals_section.add_child(vitals_grid)
	
	var vitals_data = patient_data.vitals
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
			var label = create_pixel_chart_label(vital_names[vital_key], "vital_label")
			vitals_grid.add_child(label)
			
			# Value with urgency coloring
			var value_label = create_pixel_chart_label(str(vitals_data[vital_key]), "vital_value")
			
			# Apply urgency coloring for abnormal vitals
			if is_abnormal_vital(vital_key, vitals_data[vital_key]):
				value_label.add_theme_color_override("font_color", MedicalColors.URGENT_RED)
				# Add background highlight for critical vitals
				add_vital_highlight_background(value_label)
			else:
				value_label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
			
			vitals_grid.add_child(value_label)

func is_abnormal_vital(vital_type: String, value: String) -> bool:
	"""Check if a vital sign is abnormal and should be highlighted"""
	
	match vital_type:
		"BP":
			# Check for hypertensive values
			if value.contains("/"):
				var bp_parts = value.split("/")
				if bp_parts.size() == 2:
					var systolic = bp_parts[0].to_int()
					var diastolic = bp_parts[1].to_int()
					return systolic > 140 or diastolic > 90 or systolic < 90
			return false
		
		"HR":
			var hr_val = value.to_int()
			return hr_val > 100 or hr_val < 60
		
		"RR":
			var rr_val = value.to_int()
			return rr_val > 20 or rr_val < 12
		
		"Temp":
			# Check for fever (F or C)
			if "°F" in value or "F" in value:
				var temp_val = value.replace("°F", "").replace("F", "").strip_edges().to_float()
				return temp_val > 100.4 or temp_val < 96.0
			elif "°C" in value or "C" in value:
				var temp_val = value.replace("°C", "").replace("C", "").strip_edges().to_float()
				return temp_val > 38.0 or temp_val < 35.5
			return false
		
		"O2Sat":
			if "%" in value:
				var spo2_val = value.replace("%", "").strip_edges().to_int()
				return spo2_val < 95
			return false
		
		"Pain":
			var pain_val = value.split("/")[0].to_int()
			return pain_val > 7
		
		_:
			return false

func add_vital_highlight_background(label: Label):
	"""Add highlighted background for abnormal vital signs"""
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(MedicalColors.URGENT_RED.r, MedicalColors.URGENT_RED.g, MedicalColors.URGENT_RED.b, 0.1)
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.URGENT_RED
	style.corner_radius_top_left = style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 2
	style.content_margin_left = style.content_margin_right = 4
	style.content_margin_top = style.content_margin_bottom = 2
	
	label.add_theme_stylebox_override("normal", style)

func add_chief_complaint():
	"""Add chief complaint section"""
	
	if patient_data.has("chief_complaint") or patient_data.has("presentation"):
		var complaint = patient_data.get("chief_complaint", patient_data.get("presentation", ""))
		
		var complaint_section = create_chart_section("CHIEF COMPLAINT")
		chart_content.add_child(complaint_section)
		
		var complaint_label = create_pixel_chart_label(str(complaint), "normal")
		complaint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		complaint_section.add_child(complaint_label)

func add_history_and_physical():
	"""Add history of present illness and physical exam"""
	
	# History of Present Illness
	if patient_data.has("history") or patient_data.has("hpi"):
		var history = patient_data.get("history", patient_data.get("hpi", ""))
		
		var hpi_section = create_chart_section("HISTORY OF PRESENT ILLNESS")
		chart_content.add_child(hpi_section)
		
		var hpi_label = create_pixel_chart_label(str(history), "normal")
		hpi_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hpi_section.add_child(hpi_label)
	
	# Physical Examination
	if patient_data.has("physical_exam") or patient_data.has("physicalExam"):
		var exam = patient_data.get("physical_exam", patient_data.get("physicalExam", ""))
		
		var exam_section = create_chart_section("PHYSICAL EXAMINATION")
		chart_content.add_child(exam_section)
		
		var exam_label = create_pixel_chart_label(str(exam), "normal")
		exam_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		exam_section.add_child(exam_label)

func add_laboratory_results():
	"""Add laboratory results if present"""
	
	if not patient_data.has("labs"):
		return
	
	var labs_section = create_chart_section("LABORATORY RESULTS")
	chart_content.add_child(labs_section)
	
	var labs_data = patient_data.labs
	
	if labs_data is String:
		# Simple string format
		var labs_label = create_pixel_chart_label(str(labs_data), "normal")
		labs_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		labs_section.add_child(labs_label)
	elif labs_data is Dictionary:
		# Structured lab data
		add_structured_lab_results(labs_section, labs_data)

func add_structured_lab_results(parent: VBoxContainer, labs_dict: Dictionary):
	"""Add structured laboratory results"""
	
	# Create lab grid for organized display
	var labs_grid = GridContainer.new()
	labs_grid.columns = 3
	labs_grid.add_theme_constant_override("h_separation", 15)
	labs_grid.add_theme_constant_override("v_separation", 3)
	parent.add_child(labs_grid)
	
	# Common lab order for medical authenticity
	var lab_order = ["WBC", "Hgb", "Hct", "Plt", "Na", "K", "Cl", "CO2", "BUN", "Cr", "Glucose", "Troponin", "BNP"]
	
	for lab in lab_order:
		if labs_dict.has(lab):
			add_lab_result(labs_grid, lab, labs_dict[lab])
	
	# Add any remaining labs not in standard order
	for lab in labs_dict.keys():
		if not lab in lab_order:
			add_lab_result(labs_grid, lab, labs_dict[lab])

func add_lab_result(grid: GridContainer, lab_name: String, lab_value):
	"""Add individual lab result to grid"""
	
	# Lab name
	var name_label = create_pixel_chart_label(lab_name + ":", "vital_label")
	grid.add_child(name_label)
	
	# Lab value
	var value_label = create_pixel_chart_label(str(lab_value), "vital_value")
	
	# Check for abnormal lab values (simplified)
	if is_abnormal_lab_value(lab_name, str(lab_value)):
		value_label.add_theme_color_override("font_color", MedicalColors.URGENT_RED)
		add_vital_highlight_background(value_label)
	
	grid.add_child(value_label)
	
	# Unit/Reference (simplified)
	var unit_label = create_pixel_chart_label(get_lab_reference(lab_name), "small")
	unit_label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
	grid.add_child(unit_label)

func is_abnormal_lab_value(lab_name: String, value_str: String) -> bool:
	"""Check if lab value is abnormal (simplified logic)"""
	
	var value = value_str.to_float()
	
	match lab_name:
		"WBC":
			return value > 11.0 or value < 4.0
		"Hgb":
			return value < 12.0 or value > 16.0
		"Na":
			return value < 135 or value > 145
		"K":
			return value < 3.5 or value > 5.0
		"Cr":
			return value > 1.5
		"Glucose":
			return value > 200 or value < 70
		"Troponin":
			return value > 0.04
		_:
			return false

func get_lab_reference(lab_name: String) -> String:
	"""Get reference range for lab values"""
	
	match lab_name:
		"WBC":
			return "(4-11)"
		"Hgb":
			return "g/dL"
		"Na":
			return "mEq/L"
		"K":
			return "mEq/L"
		"Cr":
			return "mg/dL"
		"Glucose":
			return "mg/dL"
		"Troponin":
			return "ng/mL"
		_:
			return ""

func create_chart_section(title: String) -> VBoxContainer:
	"""Create a chart section with medical styling"""
	
	var section = VBoxContainer.new()
	section.name = title.replace(" ", "")
	
	# Section header
	var header_label = create_pixel_chart_label(title, "section_header")
	header_label.add_theme_color_override("font_color", MedicalColors.MEDICAL_GREEN_DARK)
	section.add_child(header_label)
	
	# Underline
	var underline = HSeparator.new()
	underline.add_theme_color_override("separator", MedicalColors.MEDICAL_GREEN_DARK)
	section.add_child(underline)
	
	# Spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 4
	section.add_child(spacer)
	
	return section

func create_pixel_chart_label(text: String, label_type: String) -> Label:
	"""Create label with appropriate medical chart typography"""
	
	var label = Label.new()
	label.text = text
	
	# Apply different typography based on type
	match label_type:
		"header":
			label.add_theme_font_size_override("font_size", 14)
			label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
		
		"sub_header":
			label.add_theme_font_size_override("font_size", 10)
			label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
		
		"section_header":
			label.add_theme_font_size_override("font_size", 11)
			label.add_theme_color_override("font_color", MedicalColors.MEDICAL_GREEN_DARK)
		
		"vital_label":
			label.add_theme_font_size_override("font_size", 9)
			label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
		
		"vital_value":
			label.add_theme_font_size_override("font_size", 9)
			label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
		
		"small":
			label.add_theme_font_size_override("font_size", 8)
			label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
		
		"normal":
			label.add_theme_font_size_override("font_size", 9)
			label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
	
	return label

func get_current_datetime() -> String:
	"""Get current date/time for chart timestamp"""
	var datetime = Time.get_datetime_dict_from_system()
	return "%02d/%02d/%d  %02d:%02d" % [
		datetime.month, datetime.day, datetime.year,
		datetime.hour, datetime.minute
	]

func add_coffee_stains():
	"""Add authentic coffee stains to chart"""
	
	# Clear existing stains
	for child in coffee_stains.get_children():
		child.queue_free()
	
	# Add stains based on wear level
	var num_stains = int(chart_wear_level * 4) + (1 if randf() < 0.6 else 0)
	
	for i in range(num_stains):
		var stain = create_coffee_stain()
		coffee_stains.add_child(stain)

func create_coffee_stain() -> Control:
	"""Create individual coffee stain"""
	
	var stain_size = Vector2(15 + randf() * 20, 15 + randf() * 20)
	var stain_pos = Vector2(
		randf() * (chart_base_size.x - stain_size.x),
		randf() * (chart_base_size.y - stain_size.y)
	)
	
	var stain = Panel.new()
	stain.size = stain_size
	stain.position = stain_pos
	
	# Create coffee ring style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(MedicalColors.COFFEE_BROWN.r, MedicalColors.COFFEE_BROWN.g, MedicalColors.COFFEE_BROWN.b, 0.15 + randf() * 0.1)
	style.corner_radius_top_left = style.corner_radius_top_right = int(stain_size.x / 2)
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = int(stain_size.x / 2)
	
	# Occasionally add ring effect
	if randf() < 0.4:
		style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
		style.border_color = Color(MedicalColors.COFFEE_BROWN.r, MedicalColors.COFFEE_BROWN.g, MedicalColors.COFFEE_BROWN.b, 0.3)
		style.bg_color = Color.TRANSPARENT
	
	stain.add_theme_stylebox_override("panel", style)
	
	return stain

func add_paper_clips():
	"""Add paper clips and attachments"""
	
	# Clear existing clips
	for child in paper_clips.get_children():
		child.queue_free()
	
	# Add clips based on urgency and wear
	if chart_urgency_level > 0.6 or chart_wear_level > 0.3:
		# High urgency or well-used charts get clips
		add_paper_clip(Vector2(10, 10), MedicalColors.URGENT_RED)  # Urgent flag
	
	if randf() < 0.4:
		# Sometimes add standard clip
		add_paper_clip(Vector2(chart_base_size.x - 20, 15), MedicalColors.EQUIPMENT_GRAY)

func add_paper_clip(pos: Vector2, clip_color: Color):
	"""Add individual paper clip"""
	
	var clip = ColorRect.new()
	clip.size = Vector2(8, 12)
	clip.position = pos
	clip.color = clip_color
	
	# Simple paper clip shape
	var style = StyleBoxFlat.new()
	style.bg_color = clip_color
	style.corner_radius_top_left = style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 2
	
	clip.add_theme_stylebox_override("panel", style)
	paper_clips.add_child(clip)

func add_wear_marks():
	"""Add wear marks based on chart wear level"""
	
	if chart_wear_level < 0.2:
		return  # New charts don't have wear marks
	
	# Add corner bends
	add_corner_bend()
	
	# Add crease lines
	if chart_wear_level > 0.5:
		add_crease_lines()

func add_corner_bend():
	"""Add bent corner effect"""
	
	var corner_size = 8 + chart_wear_level * 4
	var corner = Polygon2D.new()
	corner.polygon = PackedVector2Array([
		Vector2(chart_base_size.x - corner_size, 0),
		Vector2(chart_base_size.x, 0),
		Vector2(chart_base_size.x, corner_size)
	])
	corner.color = MedicalColors.EQUIPMENT_GRAY
	chart_paper.add_child(corner)

func add_crease_lines():
	"""Add crease lines from folding"""
	
	var crease = ColorRect.new()
	crease.size = Vector2(chart_base_size.x * 0.6, 1)
	crease.position = Vector2(chart_base_size.x * 0.2, chart_base_size.y * 0.4)
	crease.color = Color(MedicalColors.TEXT_MUTED.r, MedicalColors.TEXT_MUTED.g, MedicalColors.TEXT_MUTED.b, 0.3)
	crease.rotation = 0.1  # Slight angle
	chart_paper.add_child(crease)

func apply_urgency_styling():
	"""Apply visual styling based on urgency level"""
	
	if chart_urgency_level > 0.8:
		# Critical urgency - red border
		var current_style = chart_paper.get_theme_stylebox("panel") as StyleBoxFlat
		if current_style:
			current_style.border_color = MedicalColors.URGENT_RED
			current_style.border_width_left = current_style.border_width_top = current_style.border_width_right = current_style.border_width_bottom = 3
	elif chart_urgency_level > 0.5:
		# High urgency - orange border
		var current_style = chart_paper.get_theme_stylebox("panel") as StyleBoxFlat
		if current_style:
			current_style.border_color = MedicalColors.URGENT_ORANGE
			current_style.border_width_left = current_style.border_width_top = current_style.border_width_right = current_style.border_width_bottom = 2

# Animation functions

func slide_in_from_left(duration: float = 0.8):
	"""Animate chart sliding in from left side"""
	
	if current_slide_state != "off_screen":
		return
	
	current_slide_state = "sliding_in"
	position = slide_start_position
	
	# Create slide animation
	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.set_trans(Tween.TRANS_BACK)
	
	slide_tween.tween_property(self, "position", slide_end_position, duration)
	slide_tween.tween_callback(func(): 
		current_slide_state = "on_desk"
		chart_slide_complete.emit()
	)

func slide_out_to_right(duration: float = 0.6):
	"""Animate chart sliding out to right side"""
	
	if current_slide_state != "on_desk":
		return
	
	current_slide_state = "sliding_out"
	
	var exit_position = Vector2(get_parent().size.x + 20, position.y)
	
	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_IN)
	slide_tween.set_trans(Tween.TRANS_CUBIC)
	
	slide_tween.tween_property(self, "position", exit_position, duration)
	slide_tween.tween_callback(func(): 
		current_slide_state = "off_screen"
		visible = false
	)

func highlight_critical_information():
	"""Highlight critical information with pulsing effect"""
	
	highlight_overlay.color = Color(MedicalColors.URGENT_YELLOW.r, MedicalColors.URGENT_YELLOW.g, MedicalColors.URGENT_YELLOW.b, 0.0)
	highlight_overlay.visible = true
	
	highlight_tween = create_tween()
	highlight_tween.set_loops(3)
	
	# Pulse effect
	highlight_tween.tween_property(highlight_overlay, "color:a", 0.2, 0.3)
	highlight_tween.tween_property(highlight_overlay, "color:a", 0.0, 0.3)
	
	highlight_tween.tween_callback(func(): 
		highlight_overlay.visible = false
		critical_info_blink.emit()
	)

func highlight_section(section_name: String):
	"""Highlight a specific section of the chart"""
	
	var section_node = chart_content.find_child(section_name.replace(" ", ""), false)
	if section_node:
		var section_highlight = ColorRect.new()
		section_highlight.size = section_node.size + Vector2(10, 6)
		section_highlight.position = section_node.position - Vector2(5, 3)
		section_highlight.color = Color(MedicalColors.URGENT_YELLOW.r, MedicalColors.URGENT_YELLOW.g, MedicalColors.URGENT_YELLOW.b, 0.0)
		chart_paper.add_child(section_highlight)
		chart_paper.move_child(section_highlight, 1)  # Behind content
		
		# Animate highlight
		var section_tween = create_tween()
		section_tween.tween_property(section_highlight, "color:a", 0.3, 0.2)
		section_tween.tween_delay(1.0)
		section_tween.tween_property(section_highlight, "color:a", 0.0, 0.4)
		section_tween.tween_callback(section_highlight.queue_free)
		
		chart_section_highlighted.emit(section_name)

func shake_chart(intensity: float = 5.0):
	"""Shake chart for urgency emphasis"""
	
	var original_position = position
	var shake_tween = create_tween()
	
	for i in range(8):
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(self, "position", original_position + shake_offset, 0.05)
	
	shake_tween.tween_property(self, "position", original_position, 0.1)

# Public interface

func is_chart_on_desk() -> bool:
	"""Check if chart is currently on desk"""
	return current_slide_state == "on_desk"

func get_urgency_level() -> float:
	"""Get chart urgency level"""
	return chart_urgency_level

func get_wear_level() -> float:
	"""Get chart wear level"""
	return chart_wear_level

func reset_chart():
	"""Reset chart to initial state"""
	current_slide_state = "off_screen"
	position = slide_start_position
	visible = true
	if slide_tween:
		slide_tween.kill()
	if highlight_tween:
		highlight_tween.kill()
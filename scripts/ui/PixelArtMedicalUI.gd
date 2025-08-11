extends Control
class_name PixelArtMedicalUI

## Pixel Art Medical UI System for Blackstar
## Creates authentic hospital atmosphere with pixel art aesthetics

signal patient_chart_clicked
signal answer_selected(choice: String)
signal chart_toggle_requested

# Medical color palette
const MEDICAL_COLORS = {
	"hospital_green": Color(0.4, 0.6, 0.45),
	"sterile_blue": Color(0.6, 0.7, 0.85),
	"urgent_red": Color(0.85, 0.3, 0.3),
	"warning_orange": Color(0.9, 0.6, 0.2),
	"coffee_brown": Color(0.4, 0.3, 0.2),
	"paper_white": Color(0.95, 0.94, 0.92),
	"fluorescent_flicker": Color(0.9, 0.95, 1.0)
}

# UI Components
@onready var desk_background: ColorRect = $DeskBackground
@onready var patient_chart: Panel = $PatientChart
@onready var chart_paper: RichTextLabel = $PatientChart/ChartPaper
@onready var answer_clipboard: VBoxContainer = $AnswerClipboard
@onready var timer_display: Label = $MedicalTimer
@onready var coffee_meter: ProgressBar = $CoffeeMeter
@onready var character_portrait: TextureRect = $CharacterPortrait
@onready var fluorescent_light: ColorRect = $FluorescentOverlay

# Animation and effects
var chart_slide_tween: Tween
var coffee_fill_tween: Tween
var fluorescent_flicker_timer: Timer
var current_patient_data: Dictionary = {}
var chart_summary_mode: bool = false

func _ready() -> void:
	setup_medical_environment()
	setup_patient_chart()
	setup_answer_clipboard()
	setup_timer_display()
	setup_coffee_meter()
	setup_fluorescent_lighting()
	connect_signals()

func setup_medical_environment() -> void:
	"""Create the emergency department desk environment"""
	# Desk background with medical equipment clutter
	desk_background.color = MEDICAL_COLORS.hospital_green
	desk_background.material = create_desk_material()
	
	# Add coffee stains and wear marks
	add_environmental_details()

func create_desk_material() -> ShaderMaterial:
	"""Create shader material for desk with coffee stains and wear"""
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	
	uniform float coffee_stain_intensity : hint_range(0.0, 1.0) = 0.3;
	uniform float wear_factor : hint_range(0.0, 1.0) = 0.4;
	
	void fragment() {
		vec2 grid = floor(UV * 64.0) / 64.0;
		float noise = sin(grid.x * 43758.5453 + grid.y * 12.9898) * 0.5 + 0.5;
		
		vec3 base_color = vec3(0.4, 0.6, 0.45);
		vec3 coffee_color = vec3(0.4, 0.3, 0.2);
		vec3 wear_color = vec3(0.35, 0.55, 0.4);
		
		float coffee_mask = step(0.7, noise) * coffee_stain_intensity;
		float wear_mask = step(0.6, noise) * wear_factor;
		
		vec3 final_color = mix(base_color, coffee_color, coffee_mask);
		final_color = mix(final_color, wear_color, wear_mask);
		
		COLOR = vec4(final_color, 1.0);
	}
	"""
	material.shader = shader
	return material

func setup_patient_chart() -> void:
	"""Setup the patient chart with medical styling"""
	patient_chart.modulate = MEDICAL_COLORS.paper_white
	patient_chart.position = Vector2(-400, 100)  # Start off-screen
	
	# Chart paper styling
	chart_paper.add_theme_color_override("default_color", Color.BLACK)
	chart_paper.add_theme_color_override("font_shadow_color", Color(0.9, 0.9, 0.9))
	chart_paper.bbcode_enabled = true
	
	# Add chart border and coffee rings
	var chart_border = NinePatchRect.new()
	chart_border.texture = create_chart_texture()
	patient_chart.add_child(chart_border)

func create_chart_texture() -> ImageTexture:
	"""Create pixel art texture for medical chart"""
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	
	# Chart background
	for y in range(64):
		for x in range(64):
			var color = Color.WHITE
			
			# Add grid lines for medical chart
			if x % 8 == 0 or y % 8 == 0:
				color = Color(0.9, 0.9, 0.95)
			
			# Add coffee ring stains
			var center1 = Vector2(15, 45)
			var center2 = Vector2(48, 20)
			var dist1 = Vector2(x, y).distance_to(center1)
			var dist2 = Vector2(x, y).distance_to(center2)
			
			if dist1 > 8 and dist1 < 12:
				color = Color(0.85, 0.8, 0.75)  # Coffee ring
			if dist2 > 6 and dist2 < 9:
				color = Color(0.88, 0.83, 0.78)  # Smaller coffee ring
			
			image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func setup_answer_clipboard() -> void:
	"""Setup medical clipboard for answer choices"""
	for i in range(5):
		var choice_button = Button.new()
		choice_button.text = "%s) Loading..." % char(65 + i)  # A, B, C, D, E
		choice_button.add_theme_color_override("font_color", Color.BLACK)
		choice_button.add_theme_color_override("font_color_hover", MEDICAL_COLORS.urgent_red)
		choice_button.custom_minimum_size = Vector2(400, 40)
		
		# Medical button styling
		var style = StyleBoxFlat.new()
		style.bg_color = MEDICAL_COLORS.paper_white
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = MEDICAL_COLORS.hospital_green
		choice_button.add_theme_stylebox_override("normal", style)
		
		choice_button.pressed.connect(_on_answer_selected.bind(char(65 + i)))
		answer_clipboard.add_child(choice_button)

func setup_timer_display() -> void:
	"""Setup medical equipment style timer"""
	timer_display.add_theme_color_override("font_color", MEDICAL_COLORS.sterile_blue)
	timer_display.add_theme_font_size_override("font_size", 24)
	timer_display.text = "07:35"
	
	# Medical equipment border
	var timer_bg = NinePatchRect.new()
	timer_bg.texture = create_medical_display_texture()
	timer_display.add_child(timer_bg)
	timer_bg.position = Vector2(-10, -5)
	timer_bg.size = timer_display.size + Vector2(20, 10)

func create_medical_display_texture() -> ImageTexture:
	"""Create medical equipment display texture"""
	var image = Image.create(32, 16, false, Image.FORMAT_RGBA8)
	
	for y in range(16):
		for x in range(32):
			var color = Color(0.1, 0.1, 0.12)  # Dark medical display
			
			# Display border
			if x == 0 or x == 31 or y == 0 or y == 15:
				color = Color(0.3, 0.3, 0.35)
			
			# Inner glow
			if x > 2 and x < 29 and y > 2 and y < 13:
				color = Color(0.15, 0.15, 0.18)
			
			image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func setup_coffee_meter() -> void:
	"""Setup coffee cup momentum meter"""
	coffee_meter.value = 50
	coffee_meter.max_value = 100
	
	# Coffee cup styling
	var coffee_style = StyleBoxFlat.new()
	coffee_style.bg_color = MEDICAL_COLORS.coffee_brown
	coffee_meter.add_theme_stylebox_override("fill", coffee_style)

func setup_fluorescent_lighting() -> void:
	"""Setup flickering fluorescent hospital lighting"""
	fluorescent_light.color = MEDICAL_COLORS.fluorescent_flicker
	fluorescent_light.color.a = 0.1
	fluorescent_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Flicker timer
	fluorescent_flicker_timer = Timer.new()
	fluorescent_flicker_timer.wait_time = randf_range(0.1, 0.5)
	fluorescent_flicker_timer.timeout.connect(_on_fluorescent_flicker)
	add_child(fluorescent_flicker_timer)
	fluorescent_flicker_timer.start()

func _on_fluorescent_flicker() -> void:
	"""Create authentic hospital fluorescent flicker"""
	var flicker_intensity = randf_range(0.05, 0.15)
	fluorescent_light.color.a = flicker_intensity
	
	# Next flicker
	fluorescent_flicker_timer.wait_time = randf_range(0.1, 0.8)
	fluorescent_flicker_timer.start()

func slide_in_patient_chart(patient_data: Dictionary) -> void:
	"""Animate patient chart sliding onto desk"""
	current_patient_data = patient_data
	update_chart_content()
	
	# Slide animation
	if chart_slide_tween:
		chart_slide_tween.kill()
	chart_slide_tween = create_tween()
	chart_slide_tween.tween_property(patient_chart, "position", Vector2(50, 100), 0.8)
	chart_slide_tween.tween_callback(_highlight_critical_info)

func update_chart_content() -> void:
	"""Update chart with patient data and medical formatting"""
	if current_patient_data.is_empty():
		return
	
	var chart_text = ""
	
	# Header with hospital letterhead
	chart_text += "[center][b]BLACKSTAR GENERAL HOSPITAL[/b]\n"
	chart_text += "Emergency Department - Patient Chart[/center]\n\n"
	
	# Patient demographics
	if current_patient_data.has("vignette"):
		var vignette = current_patient_data.vignette
		chart_text += "[b]PATIENT:[/b] %s\n\n" % vignette.get("demographics", "Unknown")
		
		# Chief complaint (highlighted in yellow)
		chart_text += "[b]CHIEF COMPLAINT:[/b]\n"
		chart_text += "[bgcolor=yellow][color=black]%s[/color][/bgcolor]\n\n" % vignette.get("presentation", "")
		
		# History
		chart_text += "[b]HISTORY:[/b]\n%s\n\n" % vignette.get("history", "")
		
		# Physical exam
		chart_text += "[b]EXAMINATION:[/b]\n%s\n\n" % vignette.get("physicalExam", "")
		
		# Vital signs (color coded)
		if vignette.has("vitals"):
			chart_text += "[b]VITAL SIGNS:[/b]\n"
			var vitals = vignette.vitals
			for vital in vitals:
				var color = get_vital_color(vital, vitals[vital])
				chart_text += "[color=%s]%s: %s[/color]\n" % [color.to_html(), vital.to_upper(), vitals[vital]]
	
	chart_paper.text = chart_text

func get_vital_color(vital_name: String, value: String) -> Color:
	"""Get color for vital signs based on abnormal values"""
	# Simplified vital sign color coding
	if "BP" in vital_name and ("140" in value or "90" in value):
		return MEDICAL_COLORS.urgent_red
	elif "HR" in vital_name and ("100" in value or "60" in value):
		return MEDICAL_COLORS.warning_orange
	elif "Temp" in vital_name and ("38" in value or "100" in value):
		return MEDICAL_COLORS.urgent_red
	else:
		return Color.BLACK

func _highlight_critical_info() -> void:
	"""Auto-highlight critical patient information"""
	# Add pulsing effect to urgent information
	var urgent_tween = create_tween()
	urgent_tween.set_loops()
	urgent_tween.tween_property(chart_paper, "modulate:a", 0.8, 0.5)
	urgent_tween.tween_property(chart_paper, "modulate:a", 1.0, 0.5)

func toggle_chart_view() -> void:
	"""Toggle between full chart and summary view"""
	chart_summary_mode = !chart_summary_mode
	update_chart_content()

func update_answer_choices(choices: Array) -> void:
	"""Update answer clipboard with medical choices"""
	for i in range(min(choices.size(), 5)):
		var button = answer_clipboard.get_child(i)
		var choice_data = choices[i]
		var choice_text = ""
		
		if typeof(choice_data) == TYPE_DICTIONARY:
			choice_text = choice_data.get("text", "Missing choice")
		else:
			choice_text = str(choice_data)
		
		button.text = "%s) %s" % [char(65 + i), choice_text]

func update_timer(time_remaining: String) -> void:
	"""Update medical timer display"""
	timer_display.text = time_remaining
	
	# Color code based on urgency
	var time_parts = time_remaining.split(":")
	if time_parts.size() >= 2:
		var minutes = int(time_parts[0])
		if minutes < 1:
			timer_display.add_theme_color_override("font_color", MEDICAL_COLORS.urgent_red)
		elif minutes < 2:
			timer_display.add_theme_color_override("font_color", MEDICAL_COLORS.warning_orange)
		else:
			timer_display.add_theme_color_override("font_color", MEDICAL_COLORS.sterile_blue)

func update_coffee_meter(performance: float) -> void:
	"""Update coffee momentum based on performance"""
	var target_value = clamp(performance * 100, 0, 100)
	
	if coffee_fill_tween:
		coffee_fill_tween.kill()
	coffee_fill_tween = create_tween()
	coffee_fill_tween.tween_property(coffee_meter, "value", target_value, 1.0)

func show_character_portrait(character_type: String) -> void:
	"""Show character portrait for story moments"""
	# This would load actual pixel art portraits
	character_portrait.texture = create_character_texture(character_type)
	character_portrait.visible = true

func create_character_texture(character_type: String) -> ImageTexture:
	"""Create pixel art character portrait"""
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	
	# Simplified character generation
	var base_color = Color.WHITE
	match character_type:
		"senior_resident":
			base_color = Color(0.9, 0.8, 0.7)  # Tired, focused
		"night_nurse": 
			base_color = Color(0.8, 0.9, 0.8)  # Steady, reliable
		"attending":
			base_color = Color(0.85, 0.85, 0.9)  # Experienced, worn
		"medical_student":
			base_color = Color(0.9, 0.9, 0.8)  # Eager, nervous
	
	# Fill with base color (placeholder)
	for y in range(64):
		for x in range(64):
			image.set_pixel(x, y, base_color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func add_environmental_details() -> void:
	"""Add environmental storytelling details"""
	# Coffee cup
	var coffee_cup = ColorRect.new()
	coffee_cup.color = MEDICAL_COLORS.coffee_brown
	coffee_cup.size = Vector2(20, 15)
	coffee_cup.position = Vector2(300, 50)
	add_child(coffee_cup)
	
	# Medical equipment
	var stethoscope = ColorRect.new()
	stethoscope.color = Color.BLACK
	stethoscope.size = Vector2(30, 8)
	stethoscope.position = Vector2(150, 80)
	add_child(stethoscope)

func connect_signals() -> void:
	"""Connect UI signals"""
	patient_chart.gui_input.connect(_on_chart_input)

func _on_chart_input(event: InputEvent) -> void:
	"""Handle chart interactions"""
	if event is InputEventMouseButton and event.pressed:
		patient_chart_clicked.emit()

func _on_answer_selected(choice: String) -> void:
	"""Handle answer selection"""
	answer_selected.emit(choice)

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				chart_toggle_requested.emit()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
				var choice = char(64 + (event.keycode - KEY_0))  # Convert to A-E
				answer_selected.emit(choice)
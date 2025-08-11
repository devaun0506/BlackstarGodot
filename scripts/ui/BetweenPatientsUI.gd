class_name BetweenPatientsUI
extends Control

## Between Patients Flow UI for Blackstar
##
## Provides brief breather moments between patients with coffee momentum meter,
## story beats, character interactions, and emergency department atmosphere.

signal between_patients_completed()
signal story_moment_triggered(story_data: Dictionary)
signal coffee_momentum_updated(momentum_level: float)

# UI Components
@onready var background_overlay: ColorRect
@onready var content_panel: Panel
@onready var coffee_meter: ProgressBar
@onready var coffee_animation: Control
@onready var story_area: RichTextLabel
@onready var character_portrait: TextureRect
@onready var atmosphere_effects: Control

# Animation components
var breath_tween: Tween
var coffee_tween: Tween
var story_tween: Tween

# Between patients state
var current_momentum: float = 0.5
var patients_seen_count: int = 0
var current_story_beat: Dictionary = {}
var is_active: bool = false

# Configuration
@export var base_duration: float = 2.0
@export var story_beat_interval: int = 3  # Show story every N patients
@export var coffee_gain_per_break: float = 0.15
@export var atmosphere_intensity: float = 0.3

func _ready() -> void:
	print("BetweenPatientsUI: Initializing between patients interface")
	setup_ui_components()
	setup_coffee_system()
	hide()  # Start hidden

func setup_ui_components() -> void:
	"""Setup the main UI components"""
	
	# Background overlay
	if not background_overlay:
		background_overlay = ColorRect.new()
		background_overlay.name = "BackgroundOverlay"
		add_child(background_overlay)
		background_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background_overlay.color = Color(MedicalColors.SHADOW_BLUE.r, MedicalColors.SHADOW_BLUE.g,
										MedicalColors.SHADOW_BLUE.b, 0.6)
		background_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Content panel
	if not content_panel:
		content_panel = Panel.new()
		content_panel.name = "ContentPanel"
		add_child(content_panel)
		content_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		content_panel.size = Vector2(500, 300)
		
		# Panel styling
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color(MedicalColors.MEDICAL_GREEN.r, MedicalColors.MEDICAL_GREEN.g,
									MedicalColors.MEDICAL_GREEN.b, 0.95)
		panel_style.border_width_left = 2
		panel_style.border_width_right = 2
		panel_style.border_width_top = 2
		panel_style.border_width_bottom = 2
		panel_style.border_color = MedicalColors.STERILE_BLUE_LIGHT
		panel_style.corner_radius_top_left = 12
		panel_style.corner_radius_top_right = 12
		panel_style.corner_radius_bottom_left = 12
		panel_style.corner_radius_bottom_right = 12
		content_panel.add_theme_stylebox_override("panel", panel_style)
	
	setup_content_layout()

func setup_content_layout() -> void:
	"""Setup the internal content layout"""
	
	var vbox = VBoxContainer.new()
	vbox.name = "ContentVBox"
	content_panel.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	vbox.add_theme_constant_override("separation", 15)
	
	# Header with coffee meter
	setup_header_section(vbox)
	
	# Story/character area
	setup_story_section(vbox)
	
	# Atmosphere effects area
	setup_atmosphere_section(vbox)

func setup_header_section(parent: Control) -> void:
	"""Setup header with coffee momentum meter"""
	
	var header_hbox = HBoxContainer.new()
	parent.add_child(header_hbox)
	header_hbox.add_theme_constant_override("separation", 15)
	
	# Coffee meter section
	var coffee_vbox = VBoxContainer.new()
	header_hbox.add_child(coffee_vbox)
	coffee_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var coffee_label = Label.new()
	coffee_label.text = "☕ Energy Level"
	coffee_label.add_theme_font_size_override("font_size", 14)
	coffee_label.add_theme_color_override("font_color", MedicalColors.COFFEE_BROWN)
	coffee_vbox.add_child(coffee_label)
	
	coffee_meter = ProgressBar.new()
	coffee_meter.name = "CoffeeMeter"
	coffee_vbox.add_child(coffee_meter)
	coffee_meter.min_value = 0.0
	coffee_meter.max_value = 1.0
	coffee_meter.value = current_momentum
	coffee_meter.custom_minimum_size.y = 20
	
	# Style the coffee meter
	var meter_bg = StyleBoxFlat.new()
	meter_bg.bg_color = MedicalColors.EQUIPMENT_GRAY_DARK
	coffee_meter.add_theme_stylebox_override("background", meter_bg)
	
	var meter_fill = StyleBoxFlat.new()
	meter_fill.bg_color = MedicalColors.COFFEE_BROWN
	coffee_meter.add_theme_stylebox_override("fill", meter_fill)
	
	# Coffee animation area
	coffee_animation = Control.new()
	coffee_animation.name = "CoffeeAnimation"
	header_hbox.add_child(coffee_animation)
	coffee_animation.custom_minimum_size = Vector2(80, 60)

func setup_story_section(parent: Control) -> void:
	"""Setup story and character interaction area"""
	
	var story_hbox = HBoxContainer.new()
	parent.add_child(story_hbox)
	story_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	story_hbox.add_theme_constant_override("separation", 15)
	
	# Character portrait
	character_portrait = TextureRect.new()
	character_portrait.name = "CharacterPortrait"
	story_hbox.add_child(character_portrait)
	character_portrait.custom_minimum_size = Vector2(80, 80)
	character_portrait.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	character_portrait.visible = false
	
	# Story text area
	story_area = RichTextLabel.new()
	story_area.name = "StoryArea"
	story_hbox.add_child(story_area)
	story_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	story_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	story_area.fit_content = true
	story_area.add_theme_color_override("default_color", MedicalColors.TEXT_LIGHT)
	story_area.add_theme_font_size_override("normal_font_size", 14)

func setup_atmosphere_section(parent: Control) -> void:
	"""Setup atmosphere effects section"""
	
	atmosphere_effects = Control.new()
	atmosphere_effects.name = "AtmosphereEffects"
	parent.add_child(atmosphere_effects)
	atmosphere_effects.custom_minimum_size.y = 40

func setup_coffee_system() -> void:
	"""Initialize the coffee momentum system"""
	# Coffee system setup is handled in the meter creation
	pass

func show_between_patients(patients_count: int, momentum_level: float = -1.0) -> void:
	"""Show the between patients interface"""
	
	if is_active:
		print("BetweenPatientsUI: Already active, ignoring request")
		return
	
	is_active = true
	patients_seen_count = patients_count
	
	if momentum_level >= 0:
		current_momentum = momentum_level
	
	print("BetweenPatientsUI: Showing between patients (count: %d, momentum: %.2f)" % [patients_count, current_momentum])
	
	# Determine content based on patient count
	determine_between_patients_content()
	
	# Show and animate
	show()
	animate_entrance()

func determine_between_patients_content() -> void:
	"""Determine what content to show based on patient count and momentum"""
	
	var should_show_story = (patients_seen_count % story_beat_interval == 0 and patients_seen_count > 0)
	
	if should_show_story:
		setup_story_content()
	else:
		setup_routine_break_content()
	
	# Update coffee momentum
	update_coffee_momentum()

func setup_story_content() -> void:
	"""Setup story beat content"""
	
	var story_beats = get_story_beats_for_count(patients_seen_count)
	current_story_beat = story_beats
	
	if story_area:
		var story_text = "[b]%s[/b]\n\n" % story_beats.get("title", "A Moment to Breathe")
		story_text += story_beats.get("text", "The emergency department continues its quiet rhythm.")
		
		if story_beats.has("character_dialogue"):
			story_text += "\n\n[i]%s[/i]" % story_beats.character_dialogue
		
		story_area.text = story_text
	
	# Show character portrait if available
	if character_portrait and story_beats.has("character"):
		character_portrait.visible = true
		# Would load actual character portrait texture
	
	story_moment_triggered.emit(story_beats)

func setup_routine_break_content() -> void:
	"""Setup routine break content"""
	
	if story_area:
		var break_messages = [
			"[i]You take a moment to collect your thoughts...[/i]\n\nThe emergency department hums quietly around you. The scent of antiseptic mingles with coffee from the break room.",
			
			"[i]A brief pause in the patient flow...[/i]\n\nYou hear the distant beeping of monitors and the soft conversations of the night staff.",
			
			"[i]Time to refocus...[/i]\n\nThe fluorescent lights cast their familiar glow as you prepare for the next patient.",
			
			"[i]A moment of calm...[/i]\n\nSomeone at the nurses' station laughs quietly at something. The coffee machine gurgles invitingly.",
			
			"[i]The night shift continues...[/i]\n\nCharts rustle as the staff updates patient records. Another ambulance passes by outside."
		]
		
		var message_index = patients_seen_count % break_messages.size()
		story_area.text = break_messages[message_index]
	
	# Hide character portrait for routine breaks
	if character_portrait:
		character_portrait.visible = false

func get_story_beats_for_count(count: int) -> Dictionary:
	"""Get story beat content based on patient count"""
	
	# This would eventually load from external story data
	var story_beats = {
		3: {
			"title": "The Senior Resident",
			"text": "Dr. Sarah Martinez appears at your workstation, coffee in hand.",
			"character_dialogue": "\"How are you settling in? The night shift can be unpredictable, but you're handling it well.\"",
			"character": "senior_resident"
		},
		6: {
			"title": "Nurse Check-in",
			"text": "Nurse Thompson stops by your desk with a clipboard.",
			"character_dialogue": "\"Need anything? Coffee's fresh in the break room, and I grabbed some of those cookies you like.\"",
			"character": "night_nurse"
		},
		9: {
			"title": "The Attending",
			"text": "Dr. Williams reviews your recent cases while making notes.",
			"character_dialogue": "\"Solid diagnostic work tonight. Keep trusting your instincts—they're serving you well.\"",
			"character": "attending"
		},
		12: {
			"title": "Late Night Reflection",
			"text": "The clock shows 2:47 AM. The ED has settled into its deep-night rhythm.",
			"character_dialogue": "You notice patterns in tonight's cases that remind you why you chose emergency medicine.",
			"character": null
		}
	}
	
	return story_beats.get(count, {
		"title": "A Quiet Moment",
		"text": "The emergency department continues its steady pace.",
		"character": null
	})

func update_coffee_momentum() -> void:
	"""Update and animate coffee momentum"""
	
	# Increase momentum during breaks
	var momentum_gain = coffee_gain_per_break
	
	# Bonus gain for story moments (they're more restorative)
	if not current_story_beat.is_empty():
		momentum_gain *= 1.5
	
	var new_momentum = min(1.0, current_momentum + momentum_gain)
	
	# Animate coffee meter change
	if coffee_meter and coffee_tween:
		coffee_tween.kill()
	
	coffee_tween = create_tween()
	coffee_tween.set_ease(Tween.EASE_OUT)
	coffee_tween.set_trans(Tween.TRANS_CUBIC)
	
	if coffee_meter:
		coffee_tween.parallel().tween_property(coffee_meter, "value", new_momentum, 0.8)
	
	# Animate coffee brewing effect
	animate_coffee_brewing()
	
	current_momentum = new_momentum
	coffee_momentum_updated.emit(current_momentum)
	
	print("BetweenPatientsUI: Coffee momentum updated to %.2f" % current_momentum)

func animate_coffee_brewing() -> void:
	"""Animate coffee brewing visual effect"""
	
	if not coffee_animation:
		return
	
	# Create coffee cup sprite
	var coffee_cup = TextureRect.new()
	coffee_cup.name = "CoffeeCup"
	coffee_animation.add_child(coffee_cup)
	coffee_cup.texture = create_coffee_cup_texture()
	coffee_cup.position = Vector2(10, 10)
	coffee_cup.modulate.a = 0.0
	
	# Create steam effect
	var steam_particles = create_steam_particles()
	coffee_animation.add_child(steam_particles)
	
	# Animate coffee cup appearance
	var cup_tween = create_tween()
	cup_tween.set_parallel(true)
	
	cup_tween.tween_property(coffee_cup, "modulate:a", 1.0, 0.5)
	cup_tween.tween_property(coffee_cup, "scale", Vector2(1.1, 1.1), 0.3)
	cup_tween.tween_property(coffee_cup, "scale", Vector2.ONE, 0.2).tween_delay(0.3)
	
	# Clean up after animation
	cup_tween.tween_callback(coffee_cup.queue_free).tween_delay(1.5)

func create_coffee_cup_texture() -> ImageTexture:
	"""Create a simple coffee cup texture"""
	
	var size = Vector2i(48, 48)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	# Simple coffee cup shape
	var cup_color = MedicalColors.COFFEE_BROWN
	var handle_color = Color(0.8, 0.8, 0.8)
	
	# Draw cup body
	for y in range(15, 40):
		for x in range(10, 30):
			image.set_pixel(x, y, cup_color)
	
	# Draw handle
	for x in range(30, 35):
		for y in range(20, 35):
			if x == 30 or x == 34 or y == 20 or y == 34:
				image.set_pixel(x, y, handle_color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func create_steam_particles() -> Control:
	"""Create simple steam effect for coffee"""
	
	var steam_container = Control.new()
	steam_container.name = "SteamContainer"
	steam_container.size = Vector2(60, 60)
	
	# Create a few steam "particles"
	for i in range(3):
		var steam_particle = ColorRect.new()
		steam_particle.color = Color(1.0, 1.0, 1.0, 0.3)
		steam_particle.size = Vector2(4, 8)
		steam_particle.position = Vector2(25 + i * 3, 40)
		steam_container.add_child(steam_particle)
		
		# Animate steam rising
		var steam_tween = create_tween()
		steam_tween.set_loops()
		steam_tween.tween_property(steam_particle, "position:y", steam_particle.position.y - 20, 1.5)
		steam_tween.tween_property(steam_particle, "modulate:a", 0.0, 0.5)
		steam_tween.tween_callback(func(): 
			steam_particle.position.y = 40
			steam_particle.modulate.a = 0.3
		)
	
	return steam_container

func animate_entrance() -> void:
	"""Animate the entrance of the between patients UI"""
	
	if breath_tween:
		breath_tween.kill()
	
	# Start with panel off-screen
	if content_panel:
		content_panel.position.y -= 100
		content_panel.modulate.a = 0.0
	
	breath_tween = create_tween()
	breath_tween.set_parallel(true)
	
	# Fade in background
	breath_tween.tween_property(background_overlay, "color:a", 0.6, 0.4)
	
	# Slide and fade in panel
	if content_panel:
		var target_pos = content_panel.position + Vector2(0, 100)
		breath_tween.tween_property(content_panel, "position", target_pos, 0.6)
		breath_tween.tween_property(content_panel, "modulate:a", 1.0, 0.6)
	
	# Animate story text appearance
	if story_area:
		animate_story_text_appearance()
	
	# Auto-complete after duration
	breath_tween.tween_callback(complete_between_patients).tween_delay(base_duration + 1.0)

func animate_story_text_appearance() -> void:
	"""Animate story text appearing with typewriter effect"""
	
	if not story_area:
		return
	
	var full_text = story_area.text
	story_area.text = ""
	
	if story_tween:
		story_tween.kill()
	
	story_tween = create_tween()
	
	# Typewriter effect
	var char_count = full_text.length()
	var duration = min(1.5, char_count * 0.03)  # Don't make it too slow
	
	story_tween.tween_method(_update_story_text, 0, char_count, duration)
	story_tween.tween_callback(func(): story_area.text = full_text)  # Ensure complete text

var _full_story_text: String = ""

func _update_story_text(char_index: int) -> void:
	"""Update story text during typewriter animation"""
	if story_area and story_area.text.length() > char_index:
		var full_text = _full_story_text
		if full_text.is_empty():
			# Get the full text from initial setup
			full_text = story_area.text
			_full_story_text = full_text
		
		story_area.text = full_text.substr(0, char_index)

func complete_between_patients() -> void:
	"""Complete the between patients sequence"""
	
	if not is_active:
		return
	
	print("BetweenPatientsUI: Completing between patients sequence")
	
	animate_exit()

func animate_exit() -> void:
	"""Animate the exit of between patients UI"""
	
	var exit_tween = create_tween()
	exit_tween.set_parallel(true)
	
	# Fade out background
	exit_tween.tween_property(background_overlay, "color:a", 0.0, 0.4)
	
	# Slide and fade out panel
	if content_panel:
		var target_pos = content_panel.position + Vector2(0, -100)
		exit_tween.tween_property(content_panel, "position", target_pos, 0.4)
		exit_tween.tween_property(content_panel, "modulate:a", 0.0, 0.4)
	
	# Complete
	exit_tween.tween_callback(_on_exit_complete)

func _on_exit_complete() -> void:
	"""Handle exit completion"""
	
	is_active = false
	hide()
	
	# Clean up any temporary elements
	if coffee_animation:
		for child in coffee_animation.get_children():
			child.queue_free()
	
	between_patients_completed.emit()

# Input handling
func _input(event: InputEvent) -> void:
	"""Handle input during between patients sequence"""
	
	if not visible or not is_active:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE, KEY_ENTER, KEY_ESCAPE:
				# Skip/complete sequence early
				complete_between_patients()

# Public interface
func get_current_momentum() -> float:
	"""Get current coffee momentum level"""
	return current_momentum

func set_momentum(momentum: float) -> void:
	"""Set coffee momentum level"""
	current_momentum = clamp(momentum, 0.0, 1.0)
	if coffee_meter:
		coffee_meter.value = current_momentum

func is_sequence_active() -> bool:
	"""Check if between patients sequence is currently active"""
	return is_active

func skip_sequence() -> void:
	"""Skip the current sequence (for testing/debugging)"""
	if is_active:
		complete_between_patients()

func set_base_duration(duration: float) -> void:
	"""Set the base duration for between patients sequence"""
	base_duration = duration

# Utility methods
func create_atmosphere_particle_effect() -> void:
	"""Create subtle particle effects for atmosphere"""
	
	# This would create subtle floating particles representing:
	# - Dust motes in fluorescent light
	# - Steam from coffee
	# - Papers rustling
	pass
class_name PixelArtEnvironment
extends Control

# Pixel art hospital environment system for Blackstar
# Creates immersive emergency department background with authentic details

signal environment_loaded()
signal lighting_changed(lighting_state: String)
signal desk_interaction(interaction_type: String)

# Environment layers
@onready var background_layer: Node2D
@onready var desk_layer: Node2D
@onready var equipment_layer: Node2D
@onready var lighting_layer: Node2D
@onready var atmosphere_layer: Node2D

# Lighting effects
@onready var fluorescent_lights: Array[ColorRect] = []
@onready var flicker_timer: Timer
var lighting_flicker_intensity: float = 0.3
var current_lighting_state: String = "normal"

# Desk elements
var desk_items: Array[Node2D] = []
var coffee_stains: Array[Node2D] = []
var paperwork_stacks: Array[Node2D] = []

# Equipment displays
var monitors: Array[Control] = []
var medical_devices: Array[Control] = []

# Environment state
var time_of_shift: String = "night"  # night, early_morning, dawn
var atmosphere_intensity: float = 0.8  # 0.0 calm to 1.0 chaotic

func _ready():
	setup_environment_layers()
	create_pixel_art_background()
	setup_emergency_desk()
	create_medical_equipment()
	setup_fluorescent_lighting()
	add_atmospheric_details()
	start_ambient_systems()

func setup_environment_layers():
	"""Create layered environment structure for pixel art depth"""
	
	# Background layer (walls, windows)
	background_layer = Node2D.new()
	background_layer.name = "BackgroundLayer"
	add_child(background_layer)
	
	# Desk layer (main work surface)
	desk_layer = Node2D.new()
	desk_layer.name = "DeskLayer"
	add_child(desk_layer)
	
	# Equipment layer (medical devices, computers)
	equipment_layer = Node2D.new()
	equipment_layer.name = "EquipmentLayer"
	add_child(equipment_layer)
	
	# Lighting layer (fluorescent effects, shadows)
	lighting_layer = Node2D.new()
	lighting_layer.name = "LightingLayer"
	add_child(lighting_layer)
	
	# Atmosphere layer (particles, ambience)
	atmosphere_layer = Node2D.new()
	atmosphere_layer.name = "AtmosphereLayer"
	add_child(atmosphere_layer)

func create_pixel_art_background():
	"""Create the main hospital background with pixel art styling"""
	
	# Main background panel
	var background_panel = ColorRect.new()
	background_panel.size = size
	background_panel.color = MedicalColors.SHADOW_BLUE
	background_layer.add_child(background_panel)
	
	# Hospital wall with institutional green
	var wall_panel = create_pixel_wall_panel()
	wall_panel.position = Vector2(0, 0)
	wall_panel.size = Vector2(size.x, size.y * 0.4)
	background_layer.add_child(wall_panel)
	
	# Floor with worn institutional tiles
	var floor_panel = create_pixel_floor_panel()
	floor_panel.position = Vector2(0, size.y * 0.6)
	floor_panel.size = Vector2(size.x, size.y * 0.4)
	background_layer.add_child(floor_panel)
	
	# Add wall details (notices, charts, equipment mounts)
	add_wall_details()

func create_pixel_wall_panel() -> ColorRect:
	"""Create pixel art hospital wall with authentic details"""
	
	var wall = ColorRect.new()
	wall.color = MedicalColors.add_wear_effect(MedicalColors.MEDICAL_GREEN, 0.15)
	
	# Add institutional texture through shader or pattern
	var wall_style = StyleBoxFlat.new()
	wall_style.bg_color = wall.color
	
	# Add subtle gradient for depth
	wall_style.corner_radius_top_left = 0
	wall_style.corner_radius_top_right = 0
	wall_style.corner_radius_bottom_left = 0
	wall_style.corner_radius_bottom_right = 0
	
	# Add wear marks and scuff details
	wall_style.border_width_bottom = 1
	wall_style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	
	wall.add_theme_stylebox_override("panel", wall_style)
	
	return wall

func create_pixel_floor_panel() -> ColorRect:
	"""Create pixel art hospital floor with worn tiles"""
	
	var floor = ColorRect.new()
	floor.color = MedicalColors.EQUIPMENT_GRAY
	
	var floor_style = StyleBoxFlat.new()
	floor_style.bg_color = MedicalColors.add_wear_effect(MedicalColors.EQUIPMENT_GRAY, 0.2)
	
	# Add tile pattern effect
	floor_style.border_width_top = 2
	floor_style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	
	floor.add_theme_stylebox_override("panel", floor_style)
	
	return floor

func add_wall_details():
	"""Add authentic hospital wall details"""
	
	# Medical supply cabinet
	var supply_cabinet = create_pixel_cabinet(Vector2(size.x - 120, 50), Vector2(100, 80))
	background_layer.add_child(supply_cabinet)
	
	# Notice boards with papers
	var notice_board = create_pixel_notice_board(Vector2(50, 40), Vector2(80, 60))
	background_layer.add_child(notice_board)
	
	# Wall-mounted equipment brackets
	add_equipment_mounts()
	
	# Electrical outlets and switches
	add_electrical_fixtures()

func create_pixel_cabinet(pos: Vector2, cabinet_size: Vector2) -> Control:
	"""Create pixel art medical supply cabinet"""
	
	var cabinet = Panel.new()
	cabinet.position = pos
	cabinet.size = cabinet_size
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.CHART_PAPER_STAINED
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 2
	
	# Add shadow for depth
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 3
	style.shadow_offset = Vector2(2, 2)
	
	cabinet.add_theme_stylebox_override("panel", style)
	
	# Add cabinet handles
	var handle = ColorRect.new()
	handle.size = Vector2(6, 16)
	handle.position = Vector2(cabinet_size.x - 15, cabinet_size.y / 2 - 8)
	handle.color = MedicalColors.EQUIPMENT_GRAY_DARK
	cabinet.add_child(handle)
	
	return cabinet

func create_pixel_notice_board(pos: Vector2, board_size: Vector2) -> Control:
	"""Create pixel art notice board with posted papers"""
	
	var board = Panel.new()
	board.position = pos
	board.size = board_size
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.COFFEE_BROWN
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.SHADOW_BLUE
	
	board.add_theme_stylebox_override("panel", style)
	
	# Add pinned papers
	add_pinned_papers(board, board_size)
	
	return board

func add_pinned_papers(board: Panel, board_size: Vector2):
	"""Add small pinned papers to notice board"""
	
	var paper_positions = [
		Vector2(10, 8),
		Vector2(35, 15),
		Vector2(15, 35),
		Vector2(45, 25)
	]
	
	for pos in paper_positions:
		if pos.x + 20 < board_size.x and pos.y + 15 < board_size.y:
			var paper = ColorRect.new()
			paper.size = Vector2(18, 12)
			paper.position = pos
			paper.color = MedicalColors.add_coffee_stain(MedicalColors.CHART_PAPER, randf() * 0.1)
			board.add_child(paper)
			
			# Add thumbtack
			var thumbtack = ColorRect.new()
			thumbtack.size = Vector2(2, 2)
			thumbtack.position = Vector2(pos.x + 9, pos.y + 2)
			thumbtack.color = MedicalColors.URGENT_RED
			board.add_child(thumbtack)

func setup_emergency_desk():
	"""Create the main emergency department desk workspace"""
	
	# Main desk surface
	var desk_surface = create_pixel_desk_surface()
	desk_layer.add_child(desk_surface)
	
	# Desk drawers and storage
	add_desk_storage()
	
	# Computer workstation
	add_computer_workstation()
	
	# Scattered paperwork and supplies
	add_desk_clutter()
	
	# Coffee cup with stains
	add_coffee_elements()

func create_pixel_desk_surface() -> Control:
	"""Create the main desk surface with authentic wear"""
	
	var desk = Panel.new()
	desk.position = Vector2(0, size.y * 0.5)
	desk.size = Vector2(size.x, size.y * 0.35)
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.add_wear_effect(MedicalColors.CHART_PAPER_STAINED, 0.25)
	style.border_width_top = 3
	style.border_width_left = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	
	# Add wood grain effect through color variation
	style.corner_radius_top_left = style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 0
	
	desk.add_theme_stylebox_override("panel", style)
	
	# Add desk edge highlight for 3D effect
	var edge_highlight = ColorRect.new()
	edge_highlight.size = Vector2(desk.size.x, 2)
	edge_highlight.position = Vector2(0, -1)
	edge_highlight.color = Color(MedicalColors.FLUORESCENT_WHITE.r, MedicalColors.FLUORESCENT_WHITE.g, MedicalColors.FLUORESCENT_WHITE.b, 0.6)
	desk.add_child(edge_highlight)
	
	desk_items.append(desk)
	return desk

func add_desk_storage():
	"""Add desk drawers and storage compartments"""
	
	var drawer_width = 80
	var drawer_height = 25
	var drawer_y = size.y * 0.7
	
	# Left drawer unit
	for i in range(3):
		var drawer = create_pixel_drawer(Vector2(20, drawer_y + i * (drawer_height + 2)), Vector2(drawer_width, drawer_height))
		desk_layer.add_child(drawer)
		desk_items.append(drawer)
	
	# Right drawer unit
	for i in range(2):
		var drawer = create_pixel_drawer(Vector2(size.x - drawer_width - 20, drawer_y + i * (drawer_height + 2)), Vector2(drawer_width, drawer_height))
		desk_layer.add_child(drawer)
		desk_items.append(drawer)

func create_pixel_drawer(pos: Vector2, drawer_size: Vector2) -> Control:
	"""Create individual desk drawer with pixel art details"""
	
	var drawer = Panel.new()
	drawer.position = pos
	drawer.size = drawer_size
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.add_wear_effect(MedicalColors.EQUIPMENT_GRAY, 0.1)
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 1
	
	drawer.add_theme_stylebox_override("panel", style)
	
	# Add drawer handle
	var handle = ColorRect.new()
	handle.size = Vector2(16, 4)
	handle.position = Vector2(drawer_size.x - 22, drawer_size.y / 2 - 2)
	handle.color = MedicalColors.EQUIPMENT_GRAY_DARK
	drawer.add_child(handle)
	
	# Add handle highlight
	var handle_highlight = ColorRect.new()
	handle_highlight.size = Vector2(16, 1)
	handle_highlight.position = Vector2(drawer_size.x - 22, drawer_size.y / 2 - 2)
	handle_highlight.color = MedicalColors.FLUORESCENT_WHITE
	drawer.add_child(handle_highlight)
	
	return drawer

func add_computer_workstation():
	"""Add computer monitor and keyboard setup"""
	
	var monitor_pos = Vector2(size.x * 0.3, size.y * 0.15)
	var monitor = create_pixel_monitor(monitor_pos)
	equipment_layer.add_child(monitor)
	
	# Keyboard
	var keyboard_pos = Vector2(size.x * 0.35, size.y * 0.52)
	var keyboard = create_pixel_keyboard(keyboard_pos)
	desk_layer.add_child(keyboard)
	
	# Mouse
	var mouse_pos = Vector2(size.x * 0.55, size.y * 0.55)
	var mouse = create_pixel_mouse(mouse_pos)
	desk_layer.add_child(mouse)

func create_pixel_monitor(pos: Vector2) -> Control:
	"""Create pixel art computer monitor with medical interface"""
	
	var monitor_container = Control.new()
	monitor_container.position = pos
	
	# Monitor bezel
	var bezel = Panel.new()
	bezel.size = Vector2(180, 120)
	bezel.position = Vector2.ZERO
	
	var bezel_style = StyleBoxFlat.new()
	bezel_style.bg_color = MedicalColors.EQUIPMENT_GRAY_DARK
	bezel_style.border_width_left = bezel_style.border_width_top = bezel_style.border_width_right = bezel_style.border_width_bottom = 3
	bezel_style.border_color = MedicalColors.SHADOW_BLUE
	bezel_style.corner_radius_top_left = bezel_style.corner_radius_top_right = 6
	bezel_style.corner_radius_bottom_left = bezel_style.corner_radius_bottom_right = 6
	
	bezel.add_theme_stylebox_override("panel", bezel_style)
	monitor_container.add_child(bezel)
	
	# Screen
	var screen = Panel.new()
	screen.size = Vector2(160, 90)
	screen.position = Vector2(10, 8)
	screen.color = MedicalColors.SHADOW_BLUE
	
	var screen_style = StyleBoxFlat.new()
	screen_style.bg_color = MedicalColors.SHADOW_BLUE
	screen_style.corner_radius_top_left = screen_style.corner_radius_top_right = 2
	screen_style.corner_radius_bottom_left = screen_style.corner_radius_bottom_right = 2
	
	screen.add_theme_stylebox_override("panel", screen_style)
	bezel.add_child(screen)
	
	# Add EMR interface elements on screen
	add_emr_interface(screen)
	
	# Monitor stand
	var stand = ColorRect.new()
	stand.size = Vector2(60, 20)
	stand.position = Vector2(60, 120)
	stand.color = MedicalColors.EQUIPMENT_GRAY
	monitor_container.add_child(stand)
	
	monitors.append(monitor_container)
	return monitor_container

func add_emr_interface(screen: Panel):
	"""Add EMR (Electronic Medical Record) interface to screen"""
	
	# EMR header bar
	var header = ColorRect.new()
	header.size = Vector2(160, 15)
	header.position = Vector2(0, 0)
	header.color = MedicalColors.MEDICAL_GREEN_DARK
	screen.add_child(header)
	
	# EMR title
	var title_label = Label.new()
	title_label.text = "Blackstar EMR"
	title_label.position = Vector2(5, 2)
	title_label.add_theme_font_size_override("font_size", 8)
	title_label.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	header.add_child(title_label)
	
	# Patient list mockup
	var patient_list = VBoxContainer.new()
	patient_list.position = Vector2(5, 20)
	screen.add_child(patient_list)
	
	var patient_names = ["J. Martinez - Chest Pain", "A. Johnson - SOB", "M. Chen - Trauma"]
	for name in patient_names:
		var patient_label = Label.new()
		patient_label.text = name
		patient_label.add_theme_font_size_override("font_size", 6)
		patient_label.add_theme_color_override("font_color", MedicalColors.MONITOR_GREEN)
		patient_list.add_child(patient_label)

func create_pixel_keyboard(pos: Vector2) -> Control:
	"""Create pixel art keyboard"""
	
	var keyboard = Panel.new()
	keyboard.position = pos
	keyboard.size = Vector2(120, 35)
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.EQUIPMENT_GRAY
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 3
	
	keyboard.add_theme_stylebox_override("panel", style)
	
	# Add key highlights
	add_keyboard_keys(keyboard)
	
	return keyboard

func add_keyboard_keys(keyboard: Panel):
	"""Add individual keys to keyboard for detail"""
	
	var key_size = Vector2(8, 6)
	var key_spacing = 2
	var rows = 4
	var cols = 12
	
	for row in range(rows):
		for col in range(cols):
			if randf() > 0.7:  # Only add some keys for pixel art simplicity
				var key = ColorRect.new()
				key.size = key_size
				key.position = Vector2(
					5 + col * (key_size.x + key_spacing),
					3 + row * (key_size.y + key_spacing)
				)
				key.color = MedicalColors.CHART_PAPER_STAINED
				keyboard.add_child(key)

func create_pixel_mouse(pos: Vector2) -> Control:
	"""Create pixel art computer mouse"""
	
	var mouse = Panel.new()
	mouse.position = pos
	mouse.size = Vector2(20, 28)
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.EQUIPMENT_GRAY
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
	
	mouse.add_theme_stylebox_override("panel", style)
	
	# Mouse buttons
	var left_button = ColorRect.new()
	left_button.size = Vector2(8, 12)
	left_button.position = Vector2(2, 2)
	left_button.color = MedicalColors.CHART_PAPER_STAINED
	mouse.add_child(left_button)
	
	var right_button = ColorRect.new()
	right_button.size = Vector2(8, 12)
	right_button.position = Vector2(10, 2)
	right_button.color = MedicalColors.CHART_PAPER_STAINED
	mouse.add_child(right_button)
	
	return mouse

func add_desk_clutter():
	"""Add authentic desk clutter - papers, supplies, personal items"""
	
	# Scattered papers
	add_scattered_papers()
	
	# Medical supplies
	add_medical_supplies()
	
	# Personal items
	add_personal_items()
	
	# Reference books
	add_reference_books()

func add_scattered_papers():
	"""Add scattered medical papers and forms"""
	
	var paper_positions = [
		Vector2(size.x * 0.15, size.y * 0.55),
		Vector2(size.x * 0.65, size.y * 0.58),
		Vector2(size.x * 0.8, size.y * 0.52),
		Vector2(size.x * 0.25, size.y * 0.62)
	]
	
	for i in range(paper_positions.size()):
		var paper = create_pixel_paper(paper_positions[i], i)
		desk_layer.add_child(paper)
		paperwork_stacks.append(paper)

func create_pixel_paper(pos: Vector2, paper_index: int) -> Control:
	"""Create individual pixel art paper with medical content"""
	
	var paper = Panel.new()
	paper.position = pos
	paper.size = Vector2(40 + randf() * 20, 28 + randf() * 15)
	
	var style = StyleBoxFlat.new()
	
	# Vary paper condition
	match paper_index % 3:
		0:  # Fresh paper
			style.bg_color = MedicalColors.CHART_PAPER
		1:  # Coffee stained
			style.bg_color = MedicalColors.add_coffee_stain(MedicalColors.CHART_PAPER, 0.1)
		2:  # Worn paper
			style.bg_color = MedicalColors.add_wear_effect(MedicalColors.CHART_PAPER, 0.15)
	
	style.corner_radius_top_left = style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 1
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.TEXT_MUTED
	
	# Random rotation for authenticity
	paper.rotation = (randf() - 0.5) * 0.3
	
	paper.add_theme_stylebox_override("panel", style)
	
	# Add minimal medical text
	add_paper_text(paper)
	
	return paper

func add_paper_text(paper: Panel):
	"""Add minimal text lines to represent medical forms"""
	
	var text_lines = 3 + randi() % 3
	
	for i in range(text_lines):
		var line = ColorRect.new()
		line.size = Vector2(paper.size.x * 0.8, 1)
		line.position = Vector2(paper.size.x * 0.1, 5 + i * 4)
		line.color = MedicalColors.TEXT_DARK
		paper.add_child(line)

func add_medical_supplies():
	"""Add pixel art medical supplies on desk"""
	
	# Stethoscope
	var stethoscope_pos = Vector2(size.x * 0.7, size.y * 0.48)
	var stethoscope = create_pixel_stethoscope(stethoscope_pos)
	desk_layer.add_child(stethoscope)
	
	# Pen holder with pens
	var pen_holder_pos = Vector2(size.x * 0.45, size.y * 0.45)
	var pen_holder = create_pixel_pen_holder(pen_holder_pos)
	desk_layer.add_child(pen_holder)
	
	# Small medical reference cards
	add_reference_cards()

func create_pixel_stethoscope(pos: Vector2) -> Control:
	"""Create pixel art stethoscope"""
	
	var stethoscope = Control.new()
	stethoscope.position = pos
	
	# Chest piece
	var chest_piece = ColorRect.new()
	chest_piece.size = Vector2(12, 8)
	chest_piece.position = Vector2(0, 0)
	chest_piece.color = MedicalColors.EQUIPMENT_GRAY_DARK
	stethoscope.add_child(chest_piece)
	
	# Tubing - simplified curved line
	var tubing = ColorRect.new()
	tubing.size = Vector2(25, 2)
	tubing.position = Vector2(6, 8)
	tubing.color = MedicalColors.SHADOW_BLUE
	stethoscope.add_child(tubing)
	
	# Earpieces
	var left_earpiece = ColorRect.new()
	left_earpiece.size = Vector2(4, 6)
	left_earpiece.position = Vector2(20, 15)
	left_earpiece.color = MedicalColors.EQUIPMENT_GRAY
	stethoscope.add_child(left_earpiece)
	
	var right_earpiece = ColorRect.new()
	right_earpiece.size = Vector2(4, 6)
	right_earpiece.position = Vector2(30, 15)
	right_earpiece.color = MedicalColors.EQUIPMENT_GRAY
	stethoscope.add_child(right_earpiece)
	
	return stethoscope

func create_pixel_pen_holder(pos: Vector2) -> Control:
	"""Create pixel art pen holder with pens"""
	
	var holder = Panel.new()
	holder.position = pos
	holder.size = Vector2(16, 20)
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.EQUIPMENT_GRAY
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 2
	
	holder.add_theme_stylebox_override("panel", style)
	
	# Add pens
	var pen_colors = [MedicalColors.SHADOW_BLUE, MedicalColors.URGENT_RED, MedicalColors.EQUIPMENT_GRAY_DARK]
	for i in range(3):
		var pen = ColorRect.new()
		pen.size = Vector2(2, 15)
		pen.position = Vector2(3 + i * 4, 2)
		pen.color = pen_colors[i]
		holder.add_child(pen)
	
	return holder

func add_coffee_elements():
	"""Add coffee cup and stains for authenticity"""
	
	# Coffee cup
	var cup_pos = Vector2(size.x * 0.12, size.y * 0.48)
	var coffee_cup = create_pixel_coffee_cup(cup_pos)
	desk_layer.add_child(coffee_cup)
	
	# Coffee stains on desk
	add_desk_coffee_stains()

func create_pixel_coffee_cup(pos: Vector2) -> Control:
	"""Create pixel art coffee cup with steam effect"""
	
	var cup_container = Control.new()
	cup_container.position = pos
	
	# Cup base
	var cup = Panel.new()
	cup.size = Vector2(18, 22)
	cup.position = Vector2(0, 5)
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.CHART_PAPER_STAINED
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 1
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 8
	
	cup.add_theme_stylebox_override("panel", style)
	cup_container.add_child(cup)
	
	# Coffee surface
	var coffee_surface = ColorRect.new()
	coffee_surface.size = Vector2(16, 3)
	coffee_surface.position = Vector2(1, 1)
	coffee_surface.color = MedicalColors.COFFEE_BROWN
	cup.add_child(coffee_surface)
	
	# Handle
	var handle = ColorRect.new()
	handle.size = Vector2(3, 8)
	handle.position = Vector2(18, 10)
	handle.color = MedicalColors.CHART_PAPER_STAINED
	cup_container.add_child(handle)
	
	# Steam effect (animated)
	add_steam_effect(cup_container)
	
	return cup_container

func add_steam_effect(cup_container: Control):
	"""Add animated steam effect to coffee cup"""
	
	for i in range(3):
		var steam = ColorRect.new()
		steam.size = Vector2(2, 8)
		steam.position = Vector2(6 + i * 3, -5)
		steam.color = Color(MedicalColors.FLUORESCENT_WHITE.r, MedicalColors.FLUORESCENT_WHITE.g, MedicalColors.FLUORESCENT_WHITE.b, 0.4)
		cup_container.add_child(steam)
		
		# Animate steam
		animate_steam(steam, i)

func animate_steam(steam: ColorRect, index: int):
	"""Animate individual steam particle"""
	
	var tween = create_tween()
	tween.set_loops()
	
	# Stagger animation start times
	await get_tree().create_timer(index * 0.3).timeout
	
	while true:
		# Rise and fade
		tween.tween_property(steam, "position:y", steam.position.y - 15, 2.0)
		tween.parallel().tween_property(steam, "modulate:a", 0.0, 2.0)
		
		# Reset
		tween.tween_callback(func(): 
			steam.position.y += 15
			steam.modulate.a = 0.4
		)
		
		tween.tween_delay(1.0)

func add_desk_coffee_stains():
	"""Add coffee ring stains on desk surface"""
	
	var stain_positions = [
		Vector2(size.x * 0.2, size.y * 0.55),
		Vector2(size.x * 0.6, size.y * 0.62),
		Vector2(size.x * 0.8, size.y * 0.58)
	]
	
	for pos in stain_positions:
		var stain = create_coffee_ring_stain(pos)
		desk_layer.add_child(stain)
		coffee_stains.append(stain)

func create_coffee_ring_stain(pos: Vector2) -> Control:
	"""Create individual coffee ring stain"""
	
	var stain = ColorRect.new()
	stain.size = Vector2(25 + randf() * 10, 25 + randf() * 10)
	stain.position = pos
	stain.color = Color(MedicalColors.COFFEE_BROWN.r, MedicalColors.COFFEE_BROWN.g, MedicalColors.COFFEE_BROWN.b, 0.2)
	
	# Make it circular
	var style = StyleBoxFlat.new()
	style.bg_color = stain.color
	style.corner_radius_top_left = style.corner_radius_top_right = int(stain.size.x / 2.0)
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = int(stain.size.x / 2.0)
	
	stain.add_theme_stylebox_override("panel", style)
	
	return stain

func setup_fluorescent_lighting():
	"""Setup realistic fluorescent lighting system"""
	
	# Create fluorescent light fixtures
	create_fluorescent_fixtures()
	
	# Setup flicker timer
	flicker_timer = Timer.new()
	flicker_timer.wait_time = 0.1 + randf() * 0.2
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)
	flicker_timer.autostart = true
	add_child(flicker_timer)
	
	# Add overall lighting overlay
	add_lighting_overlay()

func create_fluorescent_fixtures():
	"""Create pixel art fluorescent light fixtures"""
	
	var fixture_width = size.x / 3
	var fixture_height = 8
	
	for i in range(3):
		var fixture = create_fluorescent_fixture(
			Vector2(i * fixture_width + fixture_width * 0.1, 20),
			Vector2(fixture_width * 0.8, fixture_height)
		)
		lighting_layer.add_child(fixture)
		fluorescent_lights.append(fixture)

func create_fluorescent_fixture(pos: Vector2, fixture_size: Vector2) -> Control:
	"""Create individual fluorescent light fixture"""
	
	var fixture_container = Control.new()
	fixture_container.position = pos
	
	# Housing
	var housing = ColorRect.new()
	housing.size = fixture_size
	housing.color = MedicalColors.EQUIPMENT_GRAY_DARK
	fixture_container.add_child(housing)
	
	# Light tubes
	var tube = ColorRect.new()
	tube.size = Vector2(fixture_size.x - 4, fixture_size.y - 2)
	tube.position = Vector2(2, 1)
	tube.color = MedicalColors.FLUORESCENT_WHITE
	fixture_container.add_child(tube)
	
	return fixture_container

func add_lighting_overlay():
	"""Add overall lighting effects to environment"""
	
	# Main lighting overlay
	var lighting_overlay = ColorRect.new()
	lighting_overlay.size = size
	lighting_overlay.color = Color(MedicalColors.FLUORESCENT_WHITE.r, MedicalColors.FLUORESCENT_WHITE.g, MedicalColors.FLUORESCENT_WHITE.b, 0.1)
	lighting_layer.add_child(lighting_overlay)
	
	# Add the fluorescent shader effect
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://scripts/shaders/FluorescentFlicker.gdshader")
	shader_material.set_shader_parameter("flicker_intensity", lighting_flicker_intensity)
	shader_material.set_shader_parameter("flicker_speed", 3.0)
	lighting_overlay.material = shader_material

func _on_flicker_timer_timeout():
	"""Handle fluorescent light flickering"""
	
	if randf() < 0.05:  # 5% chance of flicker
		# Pick random light to flicker
		if fluorescent_lights.size() > 0:
			var light_index = randi() % fluorescent_lights.size()
			var light = fluorescent_lights[light_index]
			
			# Brief flicker
			var tween = create_tween()
			tween.tween_property(light, "modulate:a", 0.3, 0.05)
			tween.tween_property(light, "modulate:a", 1.0, 0.05)
			
			if randf() < 0.3:  # Sometimes double flicker
				tween.tween_delay(0.1)
				tween.tween_property(light, "modulate:a", 0.5, 0.03)
				tween.tween_property(light, "modulate:a", 1.0, 0.03)
	
	# Reset timer with random interval
	flicker_timer.wait_time = 0.1 + randf() * 0.3

func create_medical_equipment():
	"""Create pixel art medical equipment and devices"""
	
	# IV pole
	add_iv_pole()
	
	# Medical cart
	add_medical_cart()
	
	# Vital signs monitor
	add_vital_signs_monitor()
	
	# Defibrillator unit
	add_defibrillator_unit()

func add_iv_pole():
	"""Add pixel art IV pole"""
	
	var pole_pos = Vector2(size.x - 60, size.y * 0.25)
	var pole = create_pixel_iv_pole(pole_pos)
	equipment_layer.add_child(pole)
	medical_devices.append(pole)

func create_pixel_iv_pole(pos: Vector2) -> Control:
	"""Create detailed pixel art IV pole"""
	
	var pole_container = Control.new()
	pole_container.position = pos
	
	# Pole shaft
	var shaft = ColorRect.new()
	shaft.size = Vector2(3, 200)
	shaft.position = Vector2(20, 0)
	shaft.color = MedicalColors.EQUIPMENT_GRAY
	pole_container.add_child(shaft)
	
	# Base with wheels
	var base = ColorRect.new()
	base.size = Vector2(40, 8)
	base.position = Vector2(0, 195)
	base.color = MedicalColors.EQUIPMENT_GRAY_DARK
	pole_container.add_child(base)
	
	# Wheels
	for i in range(4):
		var wheel = ColorRect.new()
		wheel.size = Vector2(6, 6)
		wheel.position = Vector2(2 + i * 9, 200)
		wheel.color = MedicalColors.SHADOW_BLUE
		pole_container.add_child(wheel)
	
	# IV bag hook
	var hook = ColorRect.new()
	hook.size = Vector2(15, 3)
	hook.position = Vector2(15, 10)
	hook.color = MedicalColors.EQUIPMENT_GRAY
	pole_container.add_child(hook)
	
	# IV bag (if present)
	if randf() > 0.5:
		add_iv_bag(pole_container, Vector2(10, 15))
	
	return pole_container

func add_iv_bag(parent: Control, pos: Vector2):
	"""Add IV bag to pole"""
	
	var iv_bag = ColorRect.new()
	iv_bag.size = Vector2(12, 20)
	iv_bag.position = pos
	iv_bag.color = Color(MedicalColors.CHART_PAPER.r, MedicalColors.CHART_PAPER.g, MedicalColors.CHART_PAPER.b, 0.8)
	parent.add_child(iv_bag)
	
	# IV tubing
	var tubing = ColorRect.new()
	tubing.size = Vector2(2, 40)
	tubing.position = Vector2(pos.x + 5, pos.y + 20)
	tubing.color = MedicalColors.STERILE_BLUE_LIGHT
	parent.add_child(tubing)

func add_vital_signs_monitor():
	"""Add pixel art vital signs monitor"""
	
	var monitor_pos = Vector2(size.x - 140, size.y * 0.3)
	var monitor = create_pixel_vital_monitor(monitor_pos)
	equipment_layer.add_child(monitor)
	medical_devices.append(monitor)

func create_pixel_vital_monitor(pos: Vector2) -> Control:
	"""Create detailed vital signs monitor"""
	
	var monitor_container = Control.new()
	monitor_container.position = pos
	
	# Main unit
	var main_unit = Panel.new()
	main_unit.size = Vector2(80, 60)
	main_unit.position = Vector2(0, 0)
	
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.EQUIPMENT_GRAY
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
	style.border_color = MedicalColors.EQUIPMENT_GRAY_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 4
	
	main_unit.add_theme_stylebox_override("panel", style)
	monitor_container.add_child(main_unit)
	
	# Screen
	var screen = ColorRect.new()
	screen.size = Vector2(60, 35)
	screen.position = Vector2(10, 5)
	screen.color = MedicalColors.SHADOW_BLUE
	main_unit.add_child(screen)
	
	# Add vital signs display
	add_vital_display(screen)
	
	# Control buttons
	add_monitor_buttons(main_unit)
	
	# Mobile cart base
	var cart_base = ColorRect.new()
	cart_base.size = Vector2(70, 40)
	cart_base.position = Vector2(5, 60)
	cart_base.color = MedicalColors.EQUIPMENT_GRAY_DARK
	monitor_container.add_child(cart_base)
	
	return monitor_container

func add_vital_display(screen: ColorRect):
	"""Add vital signs display to monitor screen"""
	
	# Heart rate
	var hr_label = Label.new()
	hr_label.text = "HR: 82"
	hr_label.position = Vector2(5, 3)
	hr_label.add_theme_font_size_override("font_size", 8)
	hr_label.add_theme_color_override("font_color", MedicalColors.MONITOR_GREEN)
	screen.add_child(hr_label)
	
	# Blood pressure
	var bp_label = Label.new()
	bp_label.text = "BP: 120/80"
	bp_label.position = Vector2(5, 15)
	bp_label.add_theme_font_size_override("font_size", 8)
	bp_label.add_theme_color_override("font_color", MedicalColors.MONITOR_GREEN)
	screen.add_child(bp_label)
	
	# Oxygen saturation
	var spo2_label = Label.new()
	spo2_label.text = "SpO2: 98%"
	spo2_label.position = Vector2(5, 27)
	spo2_label.add_theme_font_size_override("font_size", 8)
	spo2_label.add_theme_color_override("font_color", MedicalColors.MONITOR_GREEN)
	screen.add_child(spo2_label)
	
	# Simple ECG trace
	add_ecg_trace(screen)

func add_ecg_trace(screen: ColorRect):
	"""Add simple ECG trace animation"""
	
	var trace_line = ColorRect.new()
	trace_line.size = Vector2(45, 1)
	trace_line.position = Vector2(10, 20)
	trace_line.color = MedicalColors.MONITOR_GREEN
	screen.add_child(trace_line)
	
	# Animate trace (simple moving dot)
	var trace_dot = ColorRect.new()
	trace_dot.size = Vector2(2, 2)
	trace_dot.position = Vector2(10, 19)
	trace_dot.color = MedicalColors.MONITOR_GREEN
	screen.add_child(trace_dot)
	
	# Animate the dot moving across
	animate_ecg_trace(trace_dot)

func animate_ecg_trace(dot: ColorRect):
	"""Animate ECG trace dot"""
	
	var tween = create_tween()
	tween.set_loops()
	
	while true:
		tween.tween_property(dot, "position:x", 50, 2.0)
		tween.tween_callback(func(): dot.position.x = 10)
		tween.tween_delay(0.5)

func add_monitor_buttons(main_unit: Panel):
	"""Add control buttons to monitor"""
	
	var button_colors = [MedicalColors.MONITOR_GREEN, MedicalColors.URGENT_RED, MedicalColors.WARNING_AMBER]
	
	for i in range(3):
		var button = ColorRect.new()
		button.size = Vector2(8, 6)
		button.position = Vector2(10 + i * 12, 45)
		button.color = button_colors[i]
		main_unit.add_child(button)

func add_atmospheric_details():
	"""Add atmospheric details for immersion"""
	
	# Dust particles in air
	add_dust_particles()
	
	# Subtle shadows
	add_environmental_shadows()
	
	# Background activity indicators
	add_activity_indicators()

func add_dust_particles():
	"""Add floating dust particles in fluorescent light"""
	
	for i in range(8):
		var particle = create_dust_particle()
		atmosphere_layer.add_child(particle)
		animate_dust_particle(particle)

func create_dust_particle() -> ColorRect:
	"""Create individual dust particle"""
	
	var particle = ColorRect.new()
	particle.size = Vector2(1, 1)
	particle.position = Vector2(randf() * size.x, randf() * size.y)
	particle.color = Color(MedicalColors.FLUORESCENT_WHITE.r, MedicalColors.FLUORESCENT_WHITE.g, MedicalColors.FLUORESCENT_WHITE.b, 0.3)
	
	return particle

func animate_dust_particle(particle: ColorRect):
	"""Animate floating dust particle"""
	
	var tween = create_tween()
	tween.set_loops()
	
	# Random floating movement
	while true:
		var new_x = particle.position.x + (randf() - 0.5) * 20
		var new_y = particle.position.y + (randf() - 0.5) * 15
		
		new_x = clampf(new_x, 0, size.x)
		new_y = clampf(new_y, 0, size.y)
		
		tween.tween_property(particle, "position", Vector2(new_x, new_y), 3.0 + randf() * 2.0)
		tween.parallel().tween_property(particle, "modulate:a", 0.1 + randf() * 0.3, 1.5)
		tween.tween_delay(randf() * 1.0)

func add_environmental_shadows():
	"""Add subtle shadows for depth"""
	
	# Desk shadow
	var desk_shadow = ColorRect.new()
	desk_shadow.size = Vector2(size.x, 8)
	desk_shadow.position = Vector2(0, size.y * 0.85)
	desk_shadow.color = Color(0, 0, 0, 0.15)
	atmosphere_layer.add_child(desk_shadow)
	
	# Equipment shadows
	for device in medical_devices:
		if device.position.x < size.x - 100:  # Don't shadow edge equipment
			var shadow = ColorRect.new()
			shadow.size = Vector2(device.get_rect().size.x + 10, 3)
			shadow.position = Vector2(device.position.x + 5, size.y * 0.85)
			shadow.color = Color(0, 0, 0, 0.1)
			atmosphere_layer.add_child(shadow)

func add_activity_indicators():
	"""Add subtle indicators of hospital activity"""
	
	# Occasional monitor beep light
	add_monitor_indicator()
	
	# Phone/pager indicator light
	add_communication_indicator()

func add_monitor_indicator():
	"""Add blinking light on medical equipment"""
	
	if medical_devices.size() > 0:
		var monitor = medical_devices[0]  # Use first monitor
		
		var indicator = ColorRect.new()
		indicator.size = Vector2(3, 3)
		indicator.position = Vector2(70, 8)  # Top right of monitor
		indicator.color = MedicalColors.MONITOR_GREEN
		monitor.add_child(indicator)
		
		# Animate heartbeat-style blink
		animate_monitor_indicator(indicator)

func animate_monitor_indicator(indicator: ColorRect):
	"""Animate monitor heartbeat indicator"""
	
	var tween = create_tween()
	tween.set_loops()
	
	while true:
		# Double blink like heartbeat
		tween.tween_property(indicator, "modulate:a", 1.0, 0.1)
		tween.tween_property(indicator, "modulate:a", 0.2, 0.1)
		tween.tween_property(indicator, "modulate:a", 1.0, 0.1)
		tween.tween_property(indicator, "modulate:a", 0.2, 0.5)
		tween.tween_delay(1.0)  # Pause between heartbeats

func add_communication_indicator():
	"""Add phone/pager status light"""
	
	var comm_light = ColorRect.new()
	comm_light.size = Vector2(4, 4)
	comm_light.position = Vector2(size.x * 0.9, size.y * 0.1)
	comm_light.color = MedicalColors.WARNING_AMBER
	atmosphere_layer.add_child(comm_light)
	
	# Occasionally blink for incoming messages
	animate_communication_light(comm_light)

func animate_communication_light(light: ColorRect):
	"""Animate communication indicator"""
	
	var tween = create_tween()
	tween.set_loops()
	
	while true:
		# Random interval between messages
		tween.tween_delay(5.0 + randf() * 10.0)
		
		# Brief message indicator
		for i in range(3):
			tween.tween_property(light, "modulate:a", 1.0, 0.2)
			tween.tween_property(light, "modulate:a", 0.1, 0.2)
		
		tween.tween_property(light, "modulate:a", 0.3, 0.5)  # Dim state

func start_ambient_systems():
	"""Start ambient systems and effects"""
	
	environment_loaded.emit()
	print("Pixel art hospital environment loaded successfully")

# Public interface for dynamic changes

func set_lighting_state(new_state: String):
	"""Change lighting conditions (normal, dim, emergency, flickering)"""
	
	current_lighting_state = new_state
	
	match new_state:
		"dim":
			lighting_flicker_intensity = 0.1
			for light in fluorescent_lights:
				light.modulate = Color(0.7, 0.7, 0.8)
		
		"emergency":
			lighting_flicker_intensity = 0.6
			for light in fluorescent_lights:
				light.modulate = Color(1.0, 0.6, 0.6)  # Red emergency lighting
		
		"flickering":
			lighting_flicker_intensity = 0.8
			flicker_timer.wait_time = 0.05  # More frequent flickers
		
		"normal":
			lighting_flicker_intensity = 0.3
			for light in fluorescent_lights:
				light.modulate = Color.WHITE
			flicker_timer.wait_time = 0.1 + randf() * 0.2
	
	lighting_changed.emit(new_state)

func set_atmosphere_intensity(intensity: float):
	"""Change overall atmosphere intensity (0.0 calm to 1.0 chaotic)"""
	
	atmosphere_intensity = clampf(intensity, 0.0, 1.0)
	
	# Adjust dust particle speed
	# Adjust flicker frequency
	# Change coffee steam intensity
	
	if atmosphere_intensity > 0.7:
		# High stress environment
		flicker_timer.wait_time = 0.05 + randf() * 0.1
	elif atmosphere_intensity < 0.3:
		# Calm environment
		flicker_timer.wait_time = 0.2 + randf() * 0.3

func add_temporary_chart(chart_position: Vector2):
	"""Add a temporary chart that slides in"""
	
	var temp_chart = create_pixel_paper(chart_position, randi() % 3)
	temp_chart.modulate.a = 0.0
	desk_layer.add_child(temp_chart)
	
	# Slide in animation
	var tween = create_tween()
	tween.tween_property(temp_chart, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(temp_chart, "position:x", chart_position.x + 20, 0.3)
	
	return temp_chart

func remove_chart(chart: Control):
	"""Remove chart with slide out animation"""
	
	var tween = create_tween()
	tween.tween_property(chart, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(chart, "position:x", chart.position.x + 30, 0.2)
	tween.tween_callback(chart.queue_free)

func get_chart_slide_position() -> Vector2:
	"""Get position for new chart to slide in"""
	return Vector2(size.x * 0.4, size.y * 0.55)

func trigger_desk_interaction(interaction_type: String):
	"""Trigger desk interaction feedback"""
	desk_interaction.emit(interaction_type)
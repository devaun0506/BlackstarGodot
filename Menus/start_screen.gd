class_name StartScreen extends Control

const template_version: String = "0.1"

# These 4 lines are not covered in the initial video. They've been added here just to make it easier for you
# to differentiate versions. I had not intended to provide updates so this feature was skipped in original code.
@onready var version_num: Label = %VersionNum

# Performance optimization: Cache button references
@onready var start_button: Button = null
@onready var settings_button: Button = null 
@onready var quit_button: Button = null

func _ready() -> void:
	# Set version text once
	if version_num:
		version_num.text = "v%s" % template_version
	
	# Cache button references for better performance
	_cache_button_references()
	
	# Set process mode for better performance when paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _cache_button_references() -> void:
	"""Cache button references to avoid repeated node lookups"""
	# Performance: Find buttons once and cache them
	start_button = find_child("Start", false) as Button
	settings_button = find_child("Settings", false) as Button  
	quit_button = find_child("Quit", false) as Button
	
	# Mobile optimization: Ensure touch-friendly button sizes
	_optimize_for_mobile()
	
	# Optional: Connect to focus events for better UX
	if start_button:
		start_button.grab_focus()

func _optimize_for_mobile() -> void:
	"""Optimize UI elements for mobile devices"""
	# Detect if running on mobile platform
	var is_mobile = OS.get_name() in ["Android", "iOS"]
	
	if is_mobile:
		# Ensure minimum touch target size (44px minimum recommended)
		var buttons = [start_button, settings_button, quit_button]
		for button in buttons:
			if button:
				button.custom_minimum_size = Vector2(88, 44)  # 44px minimum touch target
				# Add more spacing between buttons for easier touch
				if button.get_parent() is VBoxContainer:
					(button.get_parent() as VBoxContainer).add_theme_constant_override("separation", 16)
		
		# Disable shader effects on mobile for better performance
		_disable_heavy_effects_on_mobile()

func _disable_heavy_effects_on_mobile() -> void:
	"""Disable performance-intensive effects on mobile"""
	var is_mobile = OS.get_name() in ["Android", "iOS"]
	
	if is_mobile:
		# Find any nodes with fluorescent shader and optimize them
		var nodes_with_shaders = _find_nodes_with_material(self)
		for node in nodes_with_shaders:
			var material = node.material as ShaderMaterial
			if material and material.shader and material.shader.code.contains("FluorescentFlicker"):
				material.set_shader_parameter("enable_mobile_optimization", true)

func _find_nodes_with_material(node: Node) -> Array[Node]:
	"""Recursively find all nodes with shader materials"""
	var result: Array[Node] = []
	
	if node.has_method("get_material") and node.material:
		result.append(node)
	
	for child in node.get_children():
		result.append_array(_find_nodes_with_material(child))
	
	return result

func _on_start_button_up() -> void:
	SceneManager.swap_scenes(SceneRegistry.levels["game_start"],get_tree().root,self,"wipe_to_right")	

func _on_settings_button_up() -> void:
	Globals.open_settings_menu()

func _on_quit_button_up() -> void:
	# todo add confirmation dialog before quitting
	get_tree().quit()

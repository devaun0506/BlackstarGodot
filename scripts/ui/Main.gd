extends Control
## Main entry point controller for Blackstar
##
## The Main script handles scene management and acts as the entry point
## for the Blackstar medical education game.

@onready var current_scene_container = %CurrentScene

# Scene paths
const MENU_SCENE = preload("res://scenes/MenuScene.tscn")
const GAME_SCENE = preload("res://scenes/GameScene.tscn")
const RESULTS_SCENE = preload("res://scenes/ResultsScene.tscn")

var current_scene_instance: Control

func _ready() -> void:
	print("Blackstar Main loaded")
	
	# Connect to ShiftManager signals with error handling
	if ShiftManager and ShiftManager.has_signal("shift_ended"):
		if not ShiftManager.shift_ended.is_connected(_on_shift_ended):
			ShiftManager.shift_ended.connect(_on_shift_ended)
			print("Main: Connected to ShiftManager.shift_ended signal")
	else:
		push_warning("Main: ShiftManager or shift_ended signal not available")
	
	# Start with menu scene
	change_to_scene(MENU_SCENE)

func change_to_scene(scene_resource: PackedScene) -> void:
	"""Change to a new scene"""
	print("Changing to scene: %s" % scene_resource.resource_path)
	
	# Clear current scene
	if current_scene_instance:
		current_scene_instance.queue_free()
		current_scene_instance = null
	
	# Instantiate new scene
	current_scene_instance = scene_resource.instantiate()
	current_scene_container.add_child(current_scene_instance)
	
	# Connect scene-specific signals
	_connect_scene_signals()

func _connect_scene_signals() -> void:
	"""Connect signals from the current scene"""
	if not current_scene_instance:
		return
	
	# Medical menu scene signals
	if current_scene_instance.has_signal("start_shift_requested"):
		current_scene_instance.start_shift_requested.connect(_on_start_shift_requested)
	elif current_scene_instance.has_signal("start_game_requested"):
		# Fallback for compatibility
		current_scene_instance.start_game_requested.connect(_on_start_game_requested)
	
	if current_scene_instance.has_signal("settings_requested"):
		current_scene_instance.settings_requested.connect(_on_settings_requested)
	if current_scene_instance.has_signal("feedback_requested"):
		current_scene_instance.feedback_requested.connect(_on_feedback_requested)
	if current_scene_instance.has_signal("quit_requested"):
		current_scene_instance.quit_requested.connect(_on_quit_requested)
	
	# Results scene signals
	if current_scene_instance.has_signal("restart_requested"):
		current_scene_instance.restart_requested.connect(_on_restart_requested)
	if current_scene_instance.has_signal("menu_requested"):
		current_scene_instance.menu_requested.connect(_on_menu_requested)

func _on_start_shift_requested() -> void:
	"""Handle start shift request from medical menu"""
	print("Main: Starting medical emergency department shift...")
	change_to_scene(GAME_SCENE)
	
	# Wait for scene to fully load and initialize medical systems
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for medical system initialization
	
	# Start medical shift flow
	if current_scene_instance and current_scene_instance.has_method("start_new_shift"):
		# Use the enhanced game scene start method
		current_scene_instance.start_new_shift()
	elif ShiftManager and ShiftManager.has_method("start_new_shift"):
		# Fallback to direct shift manager start
		ShiftManager.start_new_shift()
	else:
		push_error("Main: Cannot start new shift - Medical systems not available")

func _on_start_game_requested() -> void:
	"""Handle legacy start game request - redirects to shift start"""
	print("Main: Legacy start game request - redirecting to medical shift start")
	_on_start_shift_requested()

func _on_settings_requested() -> void:
	"""Handle settings request from medical menu"""
	print("Main: Settings requested from medical menu")
	# Open settings using global settings menu
	if Globals and Globals.has_method("open_settings_menu"):
		Globals.open_settings_menu()
	else:
		push_warning("Main: Settings menu not available")

func _on_feedback_requested() -> void:
	"""Handle feedback request from medical menu"""
	print("Main: Feedback requested from medical menu")
	# Feedback functionality is handled by the menu scene itself
	# This is just for logging and potential additional actions

func _on_quit_requested() -> void:
	"""Handle quit request"""
	print("Quitting game...")
	get_tree().quit()

func _on_restart_requested() -> void:
	"""Handle restart request from results"""
	print("Restarting medical shift...")
	_on_start_shift_requested()

func _on_menu_requested() -> void:
	"""Handle return to menu request"""
	print("Returning to menu...")
	change_to_scene(MENU_SCENE)

func _on_shift_ended() -> void:
	"""Handle shift completion"""
	print("Shift ended, showing results...")
	# Wait a moment then transition to results
	await get_tree().create_timer(1.0).timeout
	change_to_scene(RESULTS_SCENE)

func get_current_scene() -> Control:
	"""Get the current scene instance"""
	return current_scene_instance

func _input(event: InputEvent) -> void:
	"""Handle global input"""
	if event.is_action_pressed("ui_cancel"):
		# ESC key handling (could show pause menu in game)
		if current_scene_instance and current_scene_instance.has_method("handle_pause"):
			current_scene_instance.handle_pause()
	elif event.is_action_pressed("ui_accept"):
		# Enter key handling
		pass
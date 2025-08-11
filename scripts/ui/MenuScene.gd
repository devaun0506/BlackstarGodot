extends Control
## Main menu scene controller for Blackstar
##
## Handles the main menu interface and navigation to game modes.

signal start_game_requested
signal settings_requested
signal quit_requested

@onready var start_button = %StartButton
@onready var settings_button = %SettingsButton
@onready var quit_button = %QuitButton

func _ready() -> void:
	print("Menu scene loaded")
	
	# Validate UI elements
	_validate_ui_elements()
	
	# Connect button signals
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	else:
		push_error("MenuScene: Start button not found")
	
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	else:
		push_warning("MenuScene: Settings button not found")
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	else:
		push_error("MenuScene: Quit button not found")
	
	# Focus the start button
	if start_button:
		start_button.grab_focus()

func _validate_ui_elements() -> void:
	"""Validate that essential UI elements are present"""
	var missing_elements = []
	
	if not start_button:
		missing_elements.append("StartButton")
	if not quit_button:
		missing_elements.append("QuitButton")
	
	if missing_elements.size() > 0:
		push_error("MenuScene: Missing critical UI elements: " + str(missing_elements))
		print("MenuScene: Menu may not function correctly")
	else:
		print("MenuScene: UI elements validated successfully")

func _on_start_pressed() -> void:
	"""Handle start button press"""
	print("Start shift requested")
	start_game_requested.emit()

func _on_settings_pressed() -> void:
	"""Handle settings button press"""
	print("Settings requested")
	# TODO: Implement settings menu
	settings_requested.emit()

func _on_quit_pressed() -> void:
	"""Handle quit button press"""
	print("Quit requested")
	quit_requested.emit()

func _input(event: InputEvent) -> void:
	"""Handle menu input"""
	if event.is_action_pressed("ui_cancel"):
		# ESC acts as quit in menu
		_on_quit_pressed()
	elif event.is_action_pressed("ui_accept"):
		# Enter starts game if start button is focused
		if start_button and start_button.has_focus():
			_on_start_pressed()
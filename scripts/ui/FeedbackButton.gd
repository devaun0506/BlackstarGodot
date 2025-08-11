extends Button
class_name FeedbackButton

## Feedback button implementation for Blackstar
## Provides email integration with fallback mechanisms

signal feedback_sent_successfully()
signal feedback_failed(error_message: String)

# Configuration
const FEEDBACK_EMAIL = "devaun0506@gmail.com"
const FEEDBACK_SUBJECT = "Blackstar Feedback"

# Feedback template
const FEEDBACK_BODY_TEMPLATE = """Hello Blackstar Team,

I'm providing feedback on Blackstar, the medical education game:

[Please replace this text with your feedback, suggestions, bug reports, or questions]

Technical Information:
- Game Version: %s
- Platform: %s  
- Screen Resolution: %dx%d
- Date: %s

Thank you for creating this educational tool for medical students!

Best regards,
A Blackstar User"""

# UI styling
var feedback_style: StyleBoxFlat

func _ready() -> void:
	setup_feedback_button()
	connect_signals()
	apply_medical_styling()

func setup_feedback_button() -> void:
	"""Initialize feedback button properties"""
	text = "FEEDBACK"
	custom_minimum_size = Vector2(120, 44)  # Adequate touch target
	
	# Set tooltip
	tooltip_text = "Send feedback to the development team"

func connect_signals() -> void:
	"""Connect button signals"""
	button_up.connect(_on_feedback_button_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func apply_medical_styling() -> void:
	"""Apply medical theme styling to button"""
	
	# Create medical-themed button style
	feedback_style = StyleBoxFlat.new()
	feedback_style.bg_color = MedicalColors.INFO_BLUE
	feedback_style.border_width_left = 2
	feedback_style.border_width_top = 2
	feedback_style.border_width_right = 2
	feedback_style.border_width_bottom = 2
	feedback_style.border_color = MedicalColors.STERILE_BLUE_DARK
	feedback_style.corner_radius_top_left = 4
	feedback_style.corner_radius_top_right = 4
	feedback_style.corner_radius_bottom_left = 4
	feedback_style.corner_radius_bottom_right = 4
	
	# Apply styles for different states
	add_theme_stylebox_override("normal", feedback_style)
	
	# Hover style
	var hover_style = feedback_style.duplicate()
	hover_style.bg_color = MedicalColors.STERILE_BLUE_LIGHT
	add_theme_stylebox_override("hover", hover_style)
	
	# Pressed style
	var pressed_style = feedback_style.duplicate()
	pressed_style.bg_color = MedicalColors.STERILE_BLUE_DARK
	add_theme_stylebox_override("pressed", pressed_style)
	
	# Text styling
	add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	add_theme_color_override("font_hover_color", Color.WHITE)
	
	# Apply medical font if available
	if MedicalFont:
		var font_config = MedicalFont.get_button_font_config()
		MedicalFont.apply_font_config(self, font_config)

func _on_feedback_button_pressed() -> void:
	"""Handle feedback button press"""
	print("Feedback button pressed - opening email client...")
	
	# Add haptic feedback if available
	if Input.get_connected_joypads().size() > 0:
		Input.start_joy_vibration(0, 0.1, 0.1, 0.1)
	
	# Send feedback via email
	await send_feedback_email()

func send_feedback_email() -> void:
	"""Send feedback email using system default email client"""
	
	var email_data = prepare_email_data()
	var mailto_url = build_mailto_url(email_data)
	
	print("Opening email client with URL: %s" % mailto_url.left(100) + "...")
	
	# Try to open email client
	var result = OS.shell_open(mailto_url)
	
	if result == OK:
		feedback_sent_successfully.emit()
		show_success_message()
	else:
		print("Failed to open email client (error code: %d)" % result)
		handle_email_failure(result)

func prepare_email_data() -> Dictionary:
	"""Prepare email data with system information"""
	
	var version = get_game_version()
	var platform = OS.get_name()
	var screen_size = get_viewport().get_visible_rect().size
	var date = Time.get_datetime_string_from_system()
	
	var body = FEEDBACK_BODY_TEMPLATE % [version, platform, screen_size.x, screen_size.y, date]
	
	return {
		"recipient": FEEDBACK_EMAIL,
		"subject": FEEDBACK_SUBJECT,
		"body": body
	}

func get_game_version() -> String:
	"""Get game version from start screen or project settings"""
	
	# Try to get version from start screen
	var start_screen = get_tree().get_first_node_in_group("start_screen")
	if start_screen and start_screen.has_method("get_version"):
		return start_screen.get_version()
	
	# Try to get from StartScreen class constant
	if StartScreen and StartScreen.has_method("get_template_version"):
		return StartScreen.template_version
	
	# Fallback to project version
	return ProjectSettings.get_setting("application/config/version", "Unknown")

func build_mailto_url(email_data: Dictionary) -> String:
	"""Build mailto URL from email data"""
	
	var recipient = email_data.recipient
	var subject = email_data.subject.uri_encode()
	var body = email_data.body.uri_encode()
	
	return "mailto:%s?subject=%s&body=%s" % [recipient, subject, body]

func handle_email_failure(error_code: int) -> void:
	"""Handle email client failure with fallback options"""
	
	var error_message = get_email_error_message(error_code)
	feedback_failed.emit(error_message)
	
	# Show fallback dialog
	show_email_fallback_dialog(error_message)

func get_email_error_message(error_code: int) -> String:
	"""Get human-readable error message for email failure"""
	
	match error_code:
		ERR_UNAVAILABLE:
			return "No email client found on your system."
		ERR_UNCONFIGURED:
			return "Email client is not configured properly."
		_:
			return "Unable to open email client (Error: %d)." % error_code

func show_email_fallback_dialog(error_message: String) -> void:
	"""Show fallback dialog when email client fails"""
	
	var dialog = AcceptDialog.new()
	dialog.title = "Email Client Unavailable"
	
	var message = """
%s

You can still send feedback by:

1. Copying the email address: %s
2. Using your web browser or mobile email app
3. Including the subject: %s

Would you like to copy the email address to your clipboard?
""" % [error_message, FEEDBACK_EMAIL, FEEDBACK_SUBJECT]
	
	dialog.dialog_text = message
	
	# Add copy button
	var copy_button = dialog.add_button("Copy Email Address", false, "copy_email")
	var close_button = dialog.add_button("Close", true, "close")
	
	dialog.custom_action.connect(_on_fallback_dialog_action)
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered()

func _on_fallback_dialog_action(action: String) -> void:
	"""Handle fallback dialog actions"""
	
	match action:
		"copy_email":
			copy_email_to_clipboard()
			show_copy_confirmation()

func copy_email_to_clipboard() -> void:
	"""Copy email address to clipboard"""
	
	DisplayServer.clipboard_set(FEEDBACK_EMAIL)
	print("Email address copied to clipboard: %s" % FEEDBACK_EMAIL)

func show_copy_confirmation() -> void:
	"""Show confirmation that email was copied"""
	
	var confirmation = AcceptDialog.new()
	confirmation.title = "Email Copied"
	confirmation.dialog_text = "Email address copied to clipboard!\n\n%s" % FEEDBACK_EMAIL
	
	get_tree().root.add_child(confirmation)
	confirmation.popup_centered_minsize()
	
	# Auto-close after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(confirmation):
		confirmation.queue_free()

func show_success_message() -> void:
	"""Show success message when email client opens"""
	
	# Create subtle success indicator
	var success_label = Label.new()
	success_label.text = "✓ Email client opened"
	success_label.add_theme_color_override("font_color", MedicalColors.SUCCESS_GREEN)
	success_label.position = global_position + Vector2(0, -30)
	
	get_tree().root.add_child(success_label)
	
	# Animate success message
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.parallel().tween_property(success_label, "modulate:a", 0.0, 2.0)
	tween.parallel().tween_property(success_label, "position:y", success_label.position.y - 20, 2.0)
	
	tween.tween_callback(success_label.queue_free)

func _on_mouse_entered() -> void:
	"""Handle mouse enter for visual feedback"""
	
	# Add subtle glow effect
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.1, 1.1, 1.1), 0.1)

func _on_mouse_exited() -> void:
	"""Handle mouse exit"""
	
	# Remove glow effect
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

# ===== ACCESSIBILITY FUNCTIONS =====

func _input(event: InputEvent) -> void:
	"""Handle keyboard input for accessibility"""
	
	if not has_focus():
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ENTER, KEY_SPACE:
				_on_feedback_button_pressed()
				accept_event()

func _can_drop_data(_position: Vector2, data) -> bool:
	"""Allow dropping text feedback directly on button"""
	return data is String

func _drop_data(_position: Vector2, data) -> void:
	"""Handle dropped text as feedback"""
	if data is String:
		send_feedback_with_text(data)

func send_feedback_with_text(feedback_text: String) -> void:
	"""Send feedback with pre-filled text"""
	
	var email_data = prepare_email_data()
	
	# Replace template text with provided feedback
	email_data.body = email_data.body.replace(
		"[Please replace this text with your feedback, suggestions, bug reports, or questions]",
		feedback_text
	)
	
	var mailto_url = build_mailto_url(email_data)
	
	var result = OS.shell_open(mailto_url)
	
	if result == OK:
		feedback_sent_successfully.emit()
		show_success_message()
	else:
		handle_email_failure(result)

# ===== DEBUG AND TESTING FUNCTIONS =====

func test_email_functionality() -> bool:
	"""Test email functionality without actually sending"""
	
	print("Testing feedback email functionality...")
	
	# Test email data preparation
	var email_data = prepare_email_data()
	if email_data.recipient != FEEDBACK_EMAIL:
		print("❌ Email data preparation failed")
		return false
	
	# Test mailto URL building
	var mailto_url = build_mailto_url(email_data)
	if not mailto_url.begins_with("mailto:"):
		print("❌ Mailto URL building failed")
		return false
	
	# Test URL length (some systems have limits)
	if mailto_url.length() > 2048:
		print("⚠️  Mailto URL may be too long (%d characters)" % mailto_url.length())
	
	print("✅ Email functionality test passed")
	return true

func get_feedback_statistics() -> Dictionary:
	"""Get statistics about feedback functionality"""
	
	return {
		"email_address": FEEDBACK_EMAIL,
		"subject_template": FEEDBACK_SUBJECT,
		"platform_support": OS.get_name(),
		"accessibility_features": ["keyboard_navigation", "tooltip", "screen_reader_friendly"],
		"fallback_mechanisms": ["clipboard_copy", "manual_instructions", "error_dialogs"]
	}

## Show debug information
func debug_info() -> void:
	"""Display debug information about the feedback button"""
	
	print("=== FEEDBACK BUTTON DEBUG INFO ===")
	print("Email: %s" % FEEDBACK_EMAIL)
	print("Subject: %s" % FEEDBACK_SUBJECT)
	print("Button size: %s" % size)
	print("Touch target adequate: %s" % (size.x >= 44 and size.y >= 44))
	print("Platform: %s" % OS.get_name())
	print("Game version: %s" % get_game_version())
	print("===================================")
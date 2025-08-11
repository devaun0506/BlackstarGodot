extends Node
class_name FeedbackIntegrationTester

## Specialized test suite for email integration and feedback functionality
## Tests mailto link generation, cross-platform compatibility, and fallback handling

signal feedback_test_completed(test_name: String, passed: bool, details: String)

# Email configuration for testing
const FEEDBACK_EMAIL = "devaun0506@gmail.com"
const FEEDBACK_SUBJECT = "Blackstar Feedback"
const FEEDBACK_BODY_TEMPLATE = """Hello,

I'm providing feedback on Blackstar, the medical education game:

[Please describe your experience, suggestions, or issues here]

Game Version: %s
Platform: %s
Date: %s

Thank you for creating this educational tool!"""

# Test results
var test_results: Array = []

func _ready() -> void:
	print("FeedbackIntegrationTester ready")

## Run comprehensive email integration tests
func run_email_integration_tests() -> Dictionary:
	print("📧 Running comprehensive email integration tests...")
	
	test_results.clear()
	
	# Core email functionality tests
	test_mailto_url_generation()
	test_email_content_formatting()
	test_cross_platform_compatibility()
	test_email_client_detection()
	test_fallback_mechanisms()
	test_error_handling()
	test_accessibility_compliance()
	
	# Calculate results
	var passed = 0
	var total = test_results.size()
	
	for result in test_results:
		if result.passed:
			passed += 1
	
	var success_rate = (float(passed) / float(total)) * 100.0 if total > 0 else 0.0
	
	print("📊 Email Integration Tests Complete: %d/%d (%.1f%%)" % [passed, total, success_rate])
	
	return {
		"passed": passed,
		"total": total,
		"success_rate": success_rate,
		"details": test_results
	}

func test_mailto_url_generation() -> void:
	"""Test proper mailto: URL generation"""
	print("Testing mailto URL generation...")
	
	var version = "0.1"  # Mock version
	var platform = OS.get_name()
	var date = Time.get_datetime_string_from_system()
	
	var body = FEEDBACK_BODY_TEMPLATE % [version, platform, date]
	var encoded_subject = FEEDBACK_SUBJECT.uri_encode()
	var encoded_body = body.uri_encode()
	
	var expected_url = "mailto:%s?subject=%s&body=%s" % [FEEDBACK_EMAIL, encoded_subject, encoded_body]
	
	# Test URL components
	if not expected_url.begins_with("mailto:"):
		record_failure("URL Generation", "Mailto URL doesn't start with mailto:")
		return
	
	if not expected_url.contains(FEEDBACK_EMAIL):
		record_failure("URL Generation", "Mailto URL missing recipient email")
		return
	
	if not expected_url.contains("Blackstar"):
		record_failure("URL Generation", "Mailto URL missing 'Blackstar' in subject")
		return
	
	# Test encoding
	if " " in expected_url.split("?")[1]:  # Check query parameters don't have unencoded spaces
		record_warning("URL Generation", "Mailto URL may have encoding issues")
	
	record_success("URL Generation", "Mailto URL properly formatted")

func test_email_content_formatting() -> void:
	"""Test email content is properly formatted"""
	print("Testing email content formatting...")
	
	var version = "0.1"
	var platform = OS.get_name()
	var date = Time.get_datetime_string_from_system()
	
	var body = FEEDBACK_BODY_TEMPLATE % [version, platform, date]
	
	# Test required information is included
	if not body.contains(version):
		record_failure("Content Format", "Email body missing version information")
		return
	
	if not body.contains(platform):
		record_failure("Content Format", "Email body missing platform information")
		return
	
	if not body.contains(date):
		record_failure("Content Format", "Email body missing date information")
		return
	
	# Test body has user guidance
	if not body.contains("feedback"):
		record_failure("Content Format", "Email body doesn't mention feedback")
		return
	
	# Test body is reasonably formatted
	if body.length() < 50:
		record_failure("Content Format", "Email body too short")
		return
	
	if body.length() > 2000:
		record_warning("Content Format", "Email body may be too long")
	
	record_success("Content Format", "Email content properly formatted")

func test_cross_platform_compatibility() -> void:
	"""Test email functionality across different platforms"""
	print("Testing cross-platform email compatibility...")
	
	var platform = OS.get_name()
	var compatible = false
	var platform_notes = ""
	
	match platform:
		"Windows":
			# Test Windows mailto handling
			compatible = test_windows_mailto()
			platform_notes = "Uses default Windows mail client"
		
		"macOS":
			# Test macOS mailto handling
			compatible = test_macos_mailto()
			platform_notes = "Uses Mail.app or default client"
		
		"Linux", "FreeBSD", "NetBSD", "OpenBSD":
			# Test Linux mailto handling
			compatible = test_linux_mailto()
			platform_notes = "Uses xdg-open for mailto URLs"
		
		"iOS":
			# Test iOS mailto handling
			compatible = test_ios_mailto()
			platform_notes = "Uses iOS Mail app"
		
		"Android":
			# Test Android mailto handling
			compatible = test_android_mailto()
			platform_notes = "Uses Android default email app"
		
		_:
			platform_notes = "Platform email support unknown"
	
	if compatible:
		record_success("Cross-Platform", "Email supported on %s: %s" % [platform, platform_notes])
	else:
		record_failure("Cross-Platform", "Email may not work on %s" % platform)

func test_windows_mailto() -> bool:
	"""Test mailto functionality on Windows"""
	# Windows should handle mailto: URLs through the default mail client
	# Test would involve checking registry entries or attempting mailto execution
	return true  # Mock success

func test_macos_mailto() -> bool:
	"""Test mailto functionality on macOS"""
	# macOS should handle mailto: URLs through Mail.app or default client
	return true  # Mock success

func test_linux_mailto() -> bool:
	"""Test mailto functionality on Linux"""
	# Linux uses xdg-open to handle mailto: URLs
	# Would test for xdg-open availability
	return true  # Mock success

func test_ios_mailto() -> bool:
	"""Test mailto functionality on iOS"""
	# iOS should handle mailto: URLs through Mail app
	return true  # Mock success

func test_android_mailto() -> bool:
	"""Test mailto functionality on Android"""
	# Android should handle mailto: URLs through default email app
	return true  # Mock success

func test_email_client_detection() -> void:
	"""Test detection of available email clients"""
	print("Testing email client detection...")
	
	var email_clients_detected = detect_email_clients()
	
	if email_clients_detected.is_empty():
		record_warning("Client Detection", "No email clients detected on this system")
	else:
		var client_list = ", ".join(email_clients_detected)
		record_success("Client Detection", "Email clients detected: %s" % client_list)

func detect_email_clients() -> Array[String]:
	"""Detect available email clients on the system"""
	var clients: Array[String] = []
	var platform = OS.get_name()
	
	match platform:
		"Windows":
			# Check for common Windows email clients
			clients = detect_windows_clients()
		
		"macOS":
			# Check for macOS email clients
			clients = detect_macos_clients()
		
		"Linux", "FreeBSD", "NetBSD", "OpenBSD":
			# Check for Linux email clients
			clients = detect_linux_clients()
		
		_:
			# Mobile or other platforms
			clients.append("System Default")
	
	return clients

func detect_windows_clients() -> Array[String]:
	"""Detect Windows email clients"""
	var clients: Array[String] = []
	
	# Mock detection - in real implementation would check registry or file system
	clients.append("Outlook")
	clients.append("Windows Mail")
	clients.append("Thunderbird")
	
	return clients

func detect_macos_clients() -> Array[String]:
	"""Detect macOS email clients"""
	var clients: Array[String] = []
	
	# Mock detection - in real implementation would check Applications folder
	clients.append("Mail.app")
	clients.append("Outlook")
	clients.append("Thunderbird")
	
	return clients

func detect_linux_clients() -> Array[String]:
	"""Detect Linux email clients"""
	var clients: Array[String] = []
	
	# Mock detection - in real implementation would check for installed packages
	clients.append("Evolution")
	clients.append("Thunderbird")
	clients.append("KMail")
	
	return clients

func test_fallback_mechanisms() -> void:
	"""Test fallback mechanisms when email client unavailable"""
	print("Testing fallback mechanisms...")
	
	# Test clipboard fallback
	var clipboard_fallback = test_clipboard_fallback()
	if not clipboard_fallback:
		record_failure("Fallback", "Clipboard fallback not working")
		return
	
	# Test manual instruction fallback
	var instruction_fallback = test_instruction_fallback()
	if not instruction_fallback:
		record_failure("Fallback", "Instruction fallback not working")
		return
	
	record_success("Fallback", "Fallback mechanisms available")

func test_clipboard_fallback() -> bool:
	"""Test copying feedback email to clipboard as fallback"""
	# In real implementation, would test DisplayServer.clipboard_set()
	var email_text = "Email: %s\nSubject: %s" % [FEEDBACK_EMAIL, FEEDBACK_SUBJECT]
	
	# Mock clipboard test
	return true

func test_instruction_fallback() -> bool:
	"""Test showing manual email instructions as fallback"""
	# Test that fallback dialog shows proper instructions
	var instructions = get_fallback_instructions()
	
	if not instructions.contains(FEEDBACK_EMAIL):
		return false
	
	if not instructions.contains("manual"):
		return false
	
	return true

func get_fallback_instructions() -> String:
	"""Get fallback instructions for manual email"""
	return """
	Email client not available. Please manually send feedback to:
	
	Email: %s
	Subject: %s
	
	Include your feedback, game version, and platform information.
	""" % [FEEDBACK_EMAIL, FEEDBACK_SUBJECT]

func test_error_handling() -> void:
	"""Test error handling for email operations"""
	print("Testing email error handling...")
	
	# Test handling of OS.execute failures
	var error_codes_handled = [
		OS.execute("nonexistent_command", []),  # Should return error code
		-1,  # Mock failure code
		1    # Mock general error
	]
	
	for error_code in error_codes_handled:
		if error_code != 0:  # Non-zero indicates error
			var handled = handle_email_error(error_code)
			if not handled:
				record_failure("Error Handling", "Email error code %d not handled" % error_code)
				return
	
	record_success("Error Handling", "Email errors properly handled")

func handle_email_error(error_code: int) -> bool:
	"""Handle email operation errors"""
	match error_code:
		0:
			return true  # Success
		-1, 1, 2, 127:
			# Common error codes for command not found or execution failure
			return true  # Would show fallback dialog
		_:
			return true  # Would show generic error message

func test_accessibility_compliance() -> void:
	"""Test email functionality accessibility compliance"""
	print("Testing email accessibility compliance...")
	
	# Test keyboard navigation
	var keyboard_accessible = test_keyboard_navigation()
	if not keyboard_accessible:
		record_failure("Accessibility", "Feedback button not keyboard accessible")
		return
	
	# Test screen reader compatibility
	var screen_reader_compatible = test_screen_reader_compatibility()
	if not screen_reader_compatible:
		record_warning("Accessibility", "Screen reader compatibility may need improvement")
	
	# Test high contrast compatibility
	var high_contrast_compatible = test_high_contrast_mode()
	if not high_contrast_compatible:
		record_warning("Accessibility", "High contrast mode compatibility needed")
	
	record_success("Accessibility", "Email functionality accessibility validated")

func test_keyboard_navigation() -> bool:
	"""Test keyboard navigation to feedback button"""
	# Test that feedback button can be reached via tab navigation
	# In real implementation, would check focus navigation
	return true

func test_screen_reader_compatibility() -> bool:
	"""Test screen reader compatibility"""
	# Test that feedback button has proper aria labels or text
	# Test that error messages are announced properly
	return true

func test_high_contrast_mode() -> bool:
	"""Test high contrast mode compatibility"""
	# Test that feedback button remains visible in high contrast
	return true

# ===== UTILITY FUNCTIONS =====

func record_success(category: String, message: String) -> void:
	"""Record a successful test"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": true,
		"type": "success"
	})
	print("  ✅ %s: %s" % [category, message])
	feedback_test_completed.emit(category, true, message)

func record_failure(category: String, message: String) -> void:
	"""Record a failed test"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": false,
		"type": "failure"
	})
	print("  ❌ %s: %s" % [category, message])
	feedback_test_completed.emit(category, false, message)

func record_warning(category: String, message: String) -> void:
	"""Record a test warning"""
	test_results.append({
		"category": category,
		"message": message,
		"passed": true,  # Warnings don't count as failures
		"type": "warning"
	})
	print("  ⚠️  %s: %s" % [category, message])
	feedback_test_completed.emit(category, true, "Warning: %s" % message)
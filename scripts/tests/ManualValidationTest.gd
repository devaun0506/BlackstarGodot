extends Node
## Manual Validation Test Script for MenuScene
##
## This script can be attached to a scene and run to manually test MenuScene functionality
## Run this in the Godot editor to quickly verify the current state after fixes

func _ready():
	print("Starting Manual MenuScene Validation Test...")
	print("=" * 50)
	
	await get_tree().process_frame  # Wait a frame for initialization
	
	# Test 1: Check if MenuScene.gd compiles
	test_menuscene_compilation()
	
	# Test 2: Check medical colors
	test_medical_colors()
	
	# Test 3: Check medical fonts  
	test_medical_fonts()
	
	# Test 4: Test scene loading
	await test_scene_loading()
	
	print("=" * 50)
	print("Manual validation test completed")

func test_menuscene_compilation():
	print("\n🔧 Testing MenuScene Compilation...")
	
	try:
		var script = load("res://scripts/ui/MenuScene.gd")
		if script:
			print("✅ MenuScene.gd compiles successfully")
			
			# Try to create an instance
			var temp_instance = script.new()
			if temp_instance:
				print("✅ MenuScene script can be instantiated")
				temp_instance.queue_free()
			else:
				print("❌ MenuScene script instantiation failed")
		else:
			print("❌ MenuScene.gd failed to load")
			
	except Exception as e:
		print("❌ MenuScene compilation error: " + str(e))

func test_medical_colors():
	print("\n🎨 Testing Medical Colors...")
	
	try:
		# Try loading MedicalColors script
		if ResourceLoader.exists("res://scripts/ui/medical_theme/MedicalColors.gd"):
			var colors_script = load("res://scripts/ui/medical_theme/MedicalColors.gd")
			if colors_script:
				print("✅ MedicalColors script loads successfully")
				
				# Try to access key colors used in MenuScene
				if colors_script.has_method("new"):
					var colors_instance = colors_script.new()
					colors_instance.queue_free()
					print("✅ MedicalColors can be instantiated")
				
				# Test if class is accessible globally
				var test_color = MedicalColors.MEDICAL_GREEN if defined("MedicalColors") else null
				if test_color:
					print("✅ MedicalColors constants accessible globally")
				else:
					print("⚠️ MedicalColors not in global scope (may need class_name)")
					
			else:
				print("❌ MedicalColors script failed to load")
		else:
			print("❌ MedicalColors.gd file not found")
			
	except Exception as e:
		print("❌ Medical colors test error: " + str(e))

func test_medical_fonts():
	print("\n🔤 Testing Medical Fonts...")
	
	try:
		# Try loading MedicalFont script
		if ResourceLoader.exists("res://scripts/ui/medical_theme/MedicalFont.gd"):
			var fonts_script = load("res://scripts/ui/medical_theme/MedicalFont.gd")
			if fonts_script:
				print("✅ MedicalFont script loads successfully")
				
				# Try to access font configuration methods
				if fonts_script.has_method("new"):
					var fonts_instance = fonts_script.new()
					
					# Test key methods used in MenuScene
					if fonts_instance.has_method("get_chart_header_font_config"):
						var config = fonts_instance.get_chart_header_font_config()
						if config is Dictionary and config.has("size"):
							print("✅ Medical font configuration methods work")
						else:
							print("❌ Medical font configuration invalid")
					else:
						print("❌ Medical font methods missing")
					
					fonts_instance.queue_free()
				
			else:
				print("❌ MedicalFont script failed to load")
		else:
			print("❌ MedicalFont.gd file not found")
			
	except Exception as e:
		print("❌ Medical fonts test error: " + str(e))

func test_scene_loading():
	print("\n🎬 Testing Scene Loading...")
	
	try:
		# Test if MenuScene.tscn exists and loads
		if ResourceLoader.exists("res://scenes/MenuScene.tscn"):
			var scene_resource = load("res://scenes/MenuScene.tscn")
			if scene_resource and scene_resource is PackedScene:
				print("✅ MenuScene.tscn loads successfully")
				
				# Try to instantiate the scene
				var scene_instance = scene_resource.instantiate()
				if scene_instance:
					print("✅ MenuScene can be instantiated")
					
					# Add to tree temporarily to trigger _ready
					get_tree().root.add_child(scene_instance)
					
					# Wait a frame for initialization
					await get_tree().process_frame
					
					# Test if key UI elements exist
					await test_ui_elements(scene_instance)
					
					# Clean up
					scene_instance.queue_free()
				else:
					print("❌ MenuScene instantiation failed")
			else:
				print("❌ MenuScene.tscn is not a valid PackedScene")
		else:
			print("❌ MenuScene.tscn file not found")
			
	except Exception as e:
		print("❌ Scene loading test error: " + str(e))

func test_ui_elements(scene_instance):
	print("\n🖥️ Testing UI Elements...")
	
	# Check for key UI elements using unique names
	var ui_elements = {
		"StartShiftButton": "%StartShiftButton",
		"SettingsButton": "%SettingsButton", 
		"FeedbackButton": "%FeedbackButton",
		"QuitButton": "%QuitButton",
		"TitleLabel": "%TitleLabel",
		"SubtitleLabel": "%SubtitleLabel",
		"BackgroundPanel": "%BackgroundPanel",
		"MedicalOverlay": "%MedicalOverlay"
	}
	
	var found_elements = 0
	var total_elements = ui_elements.size()
	
	for element_name in ui_elements.keys():
		var node_path = ui_elements[element_name]
		var element = scene_instance.get_node_or_null(node_path)
		
		if element:
			print("✅ %s found" % element_name)
			found_elements += 1
			
			# Test button-specific properties
			if element_name.ends_with("Button"):
				if element.has_method("is_disabled") and not element.disabled:
					print("  ✅ %s is enabled" % element_name)
				else:
					print("  ⚠️ %s may be disabled" % element_name)
					
				# Check button text
				if element.has_property("text") and element.text != "":
					print("  ✅ %s has text: '%s'" % [element_name, element.text])
				else:
					print("  ⚠️ %s has no text" % element_name)
			
			# Test label-specific properties
			elif element_name.ends_with("Label"):
				if element.has_property("text") and element.text != "":
					print("  ✅ %s displays: '%s'" % [element_name, element.text])
				else:
					print("  ⚠️ %s has no text" % element_name)
		else:
			print("❌ %s not found" % element_name)
	
	print("\nUI Elements Summary: %d/%d found" % [found_elements, total_elements])
	
	# Test signals if all critical elements are present
	if found_elements >= 4:  # At least the 4 buttons
		test_button_signals(scene_instance)

func test_button_signals(scene_instance):
	print("\n📡 Testing Button Signals...")
	
	var required_signals = [
		"start_shift_requested",
		"settings_requested", 
		"feedback_requested",
		"quit_requested"
	]
	
	var signals_found = 0
	var signal_list = scene_instance.get_signal_list()
	
	for signal_info in signal_list:
		if signal_info.name in required_signals:
			print("✅ Signal found: %s" % signal_info.name)
			signals_found += 1
	
	print("Button Signals Summary: %d/%d found" % [signals_found, required_signals.size()])
	
	if signals_found == required_signals.size():
		print("✅ All button signals properly defined")
	else:
		print("❌ Some button signals missing")

# Helper function to check if a class is defined
func defined(class_name: String) -> bool:
	return ClassDB.class_exists(class_name)
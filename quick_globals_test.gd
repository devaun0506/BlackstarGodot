extends SceneTree
## Quick Globals.gd syntax and functionality test
## Run with: godot --script quick_globals_test.gd --headless

func _init():
	print("🔬 QUICK GLOBALS.GD SYNTAX TEST")
	print("=" * 40)
	
	var test_results = run_quick_validation()
	print_results(test_results)
	
	quit(0 if test_results.all_passed else 1)

func run_quick_validation() -> Dictionary:
	"""Run quick validation tests for Globals.gd syntax"""
	
	var results = {
		"all_passed": false,
		"compilation_test": false,
		"instantiation_test": false,
		"line_183_test": false,
		"line_200_test": false,
		"autoload_test": false,
		"errors": []
	}
	
	# Test 1: Compilation
	try:
		var globals_script_path = "res://scripts/core/autoloads/Globals.gd"
		if ResourceLoader.exists(globals_script_path):
			var script_resource = load(globals_script_path)
			if script_resource:
				results.compilation_test = true
				print("✅ Globals.gd compiles successfully")
				
				# Test 2: Instantiation
				var instance = script_resource.new()
				if instance:
					results.instantiation_test = true
					print("✅ Globals.gd can be instantiated")
					
					# Test 3: Line 183 area - format_time_mmss
					try:
						var time_result = instance.format_time_mmss(125.0)  # Should be "02:05"
						if time_result == "02:05":
							results.line_183_test = true
							print("✅ Line 183 area (format_time_mmss): %s" % time_result)
						else:
							print("❌ Line 183 area incorrect: got '%s', expected '02:05'" % time_result)
							results.errors.append("Line 183 format_time_mmss incorrect result")
					except Exception as e:
						print("❌ Line 183 area exception: %s" % str(e))
						results.errors.append("Line 183 exception: " + str(e))
					
					# Test 4: Line 200 area - format_large_number
					try:
						var number_result = instance.format_large_number(12345)  # Should be "12,345"
						if number_result == "12,345":
							results.line_200_test = true
							print("✅ Line 200 area (format_large_number): %s" % number_result)
						else:
							print("❌ Line 200 area incorrect: got '%s', expected '12,345'" % number_result)
							results.errors.append("Line 200 format_large_number incorrect result")
					except Exception as e:
						print("❌ Line 200 area exception: %s" % str(e))
						results.errors.append("Line 200 exception: " + str(e))
					
					instance.queue_free()
				else:
					print("❌ Failed to instantiate Globals.gd")
					results.errors.append("Script instantiation failed")
			else:
				print("❌ Failed to load Globals.gd as resource")
				results.errors.append("Script resource loading failed")
		else:
			print("❌ Globals.gd file not found at expected path")
			results.errors.append("Script file not found")
	except Exception as e:
		print("❌ Compilation test exception: %s" % str(e))
		results.errors.append("Compilation exception: " + str(e))
	
	# Test 5: Autoload accessibility
	if Globals:
		results.autoload_test = true
		print("✅ Globals autoload is accessible")
		
		# Quick autoload functionality test
		try:
			var platform = Globals.get_platform_name()
			var session = Globals.current_session_id
			print("✅ Autoload functional - Platform: %s, Session: %s" % [platform, session])
		except Exception as e:
			print("⚠️  Autoload accessible but functionality issue: %s" % str(e))
			results.errors.append("Autoload functionality issue: " + str(e))
	else:
		print("❌ Globals autoload not accessible")
		results.errors.append("Autoload singleton not accessible")
	
	# Calculate overall result
	results.all_passed = (
		results.compilation_test and
		results.instantiation_test and
		results.line_183_test and
		results.line_200_test and
		results.autoload_test
	)
	
	return results

func print_results(results: Dictionary):
	"""Print test results summary"""
	
	print("\n" + "=" * 40)
	print("QUICK TEST RESULTS")
	print("=" * 40)
	
	print("📊 Overall Status: %s" % ("✅ ALL TESTS PASSED" if results.all_passed else "❌ SOME TESTS FAILED"))
	
	print("\n📋 Test Breakdown:")
	print("  Compilation: %s" % ("✅ PASS" if results.compilation_test else "❌ FAIL"))
	print("  Instantiation: %s" % ("✅ PASS" if results.instantiation_test else "❌ FAIL"))
	print("  Line 183 Fix: %s" % ("✅ PASS" if results.line_183_test else "❌ FAIL"))
	print("  Line 200 Fix: %s" % ("✅ PASS" if results.line_200_test else "❌ FAIL"))
	print("  Autoload Access: %s" % ("✅ PASS" if results.autoload_test else "❌ FAIL"))
	
	if results.errors.size() > 0:
		print("\n❌ Errors Found:")
		for error in results.errors:
			print("  • %s" % error)
	
	print("\n🎯 Success Criteria:")
	print("  ✅ Zero parser errors: %s" % ("YES" if results.compilation_test else "NO"))
	print("  ✅ Autoload loads successfully: %s" % ("YES" if results.autoload_test else "NO"))
	print("  ✅ Lines 183 & 200 fixed: %s" % ("YES" if (results.line_183_test and results.line_200_test) else "NO"))
	print("  ✅ Functions return correct values: %s" % ("YES" if (results.line_183_test and results.line_200_test) else "NO"))
	
	if results.all_passed:
		print("\n💡 RECOMMENDATION: ✅ Globals.gd syntax fixes are successful")
		print("   • Ready for medical game production")
		print("   • All critical functions working correctly")
	else:
		print("\n💡 RECOMMENDATION: ❌ Issues detected - address before deployment")
		print("   • Check error details above")
		print("   • Re-run test after fixes")
	
	print("=" * 40)
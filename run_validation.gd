#!/usr/bin/env -S godot --headless --script

# Quick validation runner for TestingAgent
extends SceneTree

func _init():
	print("Initializing TestingAgent Validation...")
	
	# Load and instantiate our validation script
	var validation_script = load("res://TestingAgent_Validation.gd")
	if validation_script:
		var validator = validation_script.new()
		root.add_child(validator)
		
		# Wait for the validation to complete
		await validator.tree_exited
	else:
		print("❌ Failed to load validation script")
		quit(1)
	
	quit(0)
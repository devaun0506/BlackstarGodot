class_name StartScreenAnimationSystem
extends RefCounted

# Animation System for Blackstar Start Screen
# Authentic medical environment animations with pixel art aesthetic
# Designed for subtle, realistic hospital atmosphere

# Animation Types and Configurations
enum AnimationType {
	FLUORESCENT_FLICKER,
	COFFEE_STEAM,
	MONITOR_HEARTBEAT,
	PAPER_FLUTTER,
	ID_BADGE_SWAY,
	EQUIPMENT_STATUS_BLINK,
	ATMOSPHERIC_OVERLAY,
	WEAR_ACCUMULATION
}

# Core Animation Properties
const BASE_ANIMATION_SPEED = 1.0
const PIXEL_ART_FRAMERATE = 12  # Frames per second for pixel animations
const SMOOTH_ANIMATION_FRAMERATE = 60

# Fluorescent Lighting Animation Specifications
static var fluorescent_flicker_config = {
	"type": AnimationType.FLUORESCENT_FLICKER,
	"duration": 8.0,  # Full cycle duration
	"intensity_range": {"min": 0.85, "max": 1.05},
	"flicker_patterns": [
		{"timing": 0.0, "intensity": 1.0, "duration": 2.0},    # Stable
		{"timing": 2.0, "intensity": 0.9, "duration": 0.1},    # Quick dim
		{"timing": 2.1, "intensity": 1.05, "duration": 0.05},  # Brief bright
		{"timing": 2.15, "intensity": 0.95, "duration": 0.2},  # Settle
		{"timing": 2.35, "intensity": 1.0, "duration": 3.0},   # Normal
		{"timing": 5.35, "intensity": 0.88, "duration": 0.3},  # Longer dim
		{"timing": 5.65, "intensity": 1.02, "duration": 2.35}, # Return to normal
	],
	"affects_elements": [
		"background_lighting",
		"shadow_positions", 
		"equipment_visibility",
		"paper_brightness"
	],
	"colors": {
		"normal": "fluorescent",
		"dim": "flicker_dim", 
		"bright": "paper_clean"
	}
}

# Coffee Steam Animation
static var coffee_steam_config = {
	"type": AnimationType.COFFEE_STEAM,
	"loop_duration": 4.0,
	"particle_count": 6,
	"frames": 8,
	"movement_pattern": {
		"start_position": Vector2(0, 0),
		"end_position": Vector2(-2, -12),
		"curve_strength": 0.3,
		"dissipation_height": 8
	},
	"visual_properties": {
		"base_color": "steam_light",
		"opacity_curve": "fade_out_exponential",
		"size_curve": "expand_then_dissipate",
		"initial_size": 1,
		"final_size": 3
	}
}

# Medical Monitor Heartbeat Animation
static var monitor_heartbeat_config = {
	"type": AnimationType.MONITOR_HEARTBEAT,
	"heart_rate": 72,  # BPM - realistic resting rate
	"duration_per_beat": 0.833,  # 60/72
	"waveform_frames": 6,
	"ecg_pattern": [
		{"frame": 0, "amplitude": 0.0, "color": "monitor_active"},
		{"frame": 1, "amplitude": 0.1, "color": "monitor_active"},
		{"frame": 2, "amplitude": 0.8, "color": "monitor_bright"}, # QRS complex
		{"frame": 3, "amplitude": -0.2, "color": "monitor_active"},
		{"frame": 4, "amplitude": 0.0, "color": "monitor_active"},
		{"frame": 5, "amplitude": 0.0, "color": "monitor_idle"}
	],
	"audio_beep": true,
	"beep_volume": 0.1
}

# Paper Flutter Animation (clipboard pages)
static var paper_flutter_config = {
	"type": AnimationType.PAPER_FLUTTER,
	"trigger": "ambient_air_movement",
	"frequency": 12.0,  # Seconds between flutter events
	"duration": 0.8,
	"flutter_frames": 4,
	"movement": {
		"max_rotation": 2.0,  # degrees
		"max_displacement": Vector2(1, 0),
		"easing": "ease_out_quad"
	},
	"paper_stack_behavior": {
		"top_sheet_movement": 1.0,
		"middle_sheet_movement": 0.6,
		"bottom_sheet_movement": 0.2
	}
}

# ID Badge Sway Animation
static var id_badge_sway_config = {
	"type": AnimationType.ID_BADGE_SWAY,
	"trigger": "hover_activated",
	"duration": 2.5,
	"sway_pattern": {
		"amplitude": 3.0,  # degrees
		"frequency": 0.8,  # Hz
		"damping": 0.95   # Gradual settling
	},
	"lanyard_physics": {
		"length": 24,  # pixels
		"weight_influence": 0.3,
		"air_resistance": 0.1
	}
}

# Equipment Status Blink Animation
static var equipment_status_config = {
	"type": AnimationType.EQUIPMENT_STATUS_BLINK,
	"equipment_types": {
		"heart_monitor": {
			"blink_interval": 3.0,
			"blink_duration": 0.2,
			"colors": ["monitor_active", "monitor_bright"],
			"pattern": "steady_pulse"
		},
		"iv_pump": {
			"blink_interval": 5.0,
			"blink_duration": 0.1,
			"colors": ["warning", "equipment_main"],
			"pattern": "double_blink"
		},
		"defibrillator": {
			"blink_interval": 8.0,
			"blink_duration": 0.5,
			"colors": ["alert", "equipment_main"],
			"pattern": "slow_fade"
		}
	}
}

# Atmospheric Overlay Animation
static var atmospheric_overlay_config = {
	"type": AnimationType.ATMOSPHERIC_OVERLAY,
	"time_based_transitions": {
		"night_shift": {
			"hours": [22, 23, 0, 1, 2, 3, 4, 5, 6],
			"base_color": "night_shift",
			"intensity": 0.2,
			"fatigue_progression": true
		},
		"day_shift": {
			"hours": [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
			"base_color": "transparent",
			"intensity": 0.0
		},
		"evening_shift": {
			"hours": [19, 20, 21],
			"base_color": "stress_red_tint",
			"intensity": 0.1
		}
	},
	"stress_level_modifiers": {
		"low_stress": {"color_modifier": "calm_green_tint", "intensity": 0.05},
		"high_stress": {"color_modifier": "stress_red_tint", "intensity": 0.25}
	}
}

# Animation Controller Functions

static func create_fluorescent_flicker_animation(target_node: Node) -> Tween:
	"""Create fluorescent lighting flicker animation"""
	
	var tween = target_node.create_tween()
	tween.set_loops()
	
	var config = fluorescent_flicker_config
	
	for pattern in config.flicker_patterns:
		var intensity = pattern.intensity
		var duration = pattern.duration
		
		# Animate modulate property to simulate lighting changes
		tween.tween_method(
			func(light_intensity: float):
				var light_color = StartScreenMedicalPalette.get_color_by_name("fluorescent")
				target_node.modulate = Color(
					light_color.r * light_intensity,
					light_color.g * light_intensity, 
					light_color.b * light_intensity
				),
			target_node.modulate.r, intensity, duration
		)
		tween.tween_delay(0.1)
	
	return tween

static func create_coffee_steam_animation(coffee_cup_node: Node) -> Array[Node]:
	"""Create coffee steam particle animation"""
	
	var steam_particles: Array[Node] = []
	var config = coffee_steam_config
	
	for i in range(config.particle_count):
		var particle = ColorRect.new()
		particle.size = Vector2(2, 2)
		particle.color = StartScreenMedicalPalette.get_color_by_name("steam_light")
		
		# Position at coffee cup surface
		particle.position = Vector2(
			coffee_cup_node.position.x + 8 + (i * 2),
			coffee_cup_node.position.y - 2
		)
		
		coffee_cup_node.get_parent().add_child(particle)
		steam_particles.append(particle)
		
		# Animate steam rise and dissipation
		animate_steam_particle(particle, i * 0.5)  # Staggered start times
	
	return steam_particles

static func animate_steam_particle(particle: ColorRect, delay: float):
	"""Animate individual steam particle"""
	
	await particle.get_tree().create_timer(delay).timeout
	
	var tween = particle.create_tween()
	tween.set_loops()
	
	var config = coffee_steam_config
	var movement = config.movement_pattern
	
	# Rise and curve movement
	tween.parallel().tween_property(
		particle, "position",
		particle.position + movement.end_position,
		config.loop_duration
	)
	
	# Fade out as it rises
	tween.parallel().tween_property(
		particle, "modulate:a",
		0.0, config.loop_duration
	)
	
	# Size expansion
	tween.parallel().tween_property(
		particle, "size",
		Vector2(config.visual_properties.final_size, config.visual_properties.final_size),
		config.loop_duration * 0.6
	)
	
	# Reset for loop
	tween.tween_callback(func():
		particle.modulate.a = 0.6
		particle.size = Vector2(1, 1)
		particle.position = particle.position - movement.end_position
	)

static func create_monitor_heartbeat_animation(monitor_node: Node) -> Tween:
	"""Create medical monitor heartbeat display animation"""
	
	var tween = monitor_node.create_tween()
	tween.set_loops()
	
	var config = monitor_heartbeat_config
	
	for frame_data in config.ecg_pattern:
		var frame_duration = config.duration_per_beat / config.waveform_frames
		var amplitude = frame_data.amplitude
		var color_name = frame_data.color
		
		tween.tween_method(
			func(pulse_amplitude: float):
				# Update monitor display color based on heartbeat
				var pulse_color = StartScreenMedicalPalette.get_color_by_name(color_name)
				pulse_color = pulse_color.lerp(Color.WHITE, pulse_amplitude * 0.3)
				monitor_node.modulate = pulse_color
				
				# Optional: Add subtle scale pulse
				var scale_factor = 1.0 + (pulse_amplitude * 0.05)
				monitor_node.scale = Vector2(scale_factor, scale_factor),
			0.0, amplitude, frame_duration
		)
	
	return tween

static func create_paper_flutter_animation(paper_stack_node: Node) -> Tween:
	"""Create paper flutter animation for clipboard"""
	
	var tween = paper_stack_node.create_tween()
	tween.set_loops()
	
	var config = paper_flutter_config
	
	# Wait for random interval before flutter
	tween.tween_delay(randf_range(8.0, 16.0))
	
	# Flutter sequence
	for frame in range(config.flutter_frames):
		var frame_duration = config.duration / config.flutter_frames
		var rotation_amount = config.movement.max_rotation * sin(frame * PI / config.flutter_frames)
		
		tween.tween_property(
			paper_stack_node, "rotation_degrees",
			rotation_amount, frame_duration
		)
	
	# Return to rest position
	tween.tween_property(
		paper_stack_node, "rotation_degrees",
		0.0, config.duration * 0.3
	)
	
	return tween

static func create_id_badge_sway_animation(badge_node: Node) -> Tween:
	"""Create ID badge sway animation"""
	
	var tween = badge_node.create_tween()
	
	var config = id_badge_sway_config
	var sway = config.sway_pattern
	
	# Create realistic pendulum motion
	for i in range(8):  # Number of swings
		var amplitude = sway.amplitude * pow(sway.damping, i)
		var swing_duration = config.duration / 16  # Each half-swing
		
		tween.tween_property(
			badge_node, "rotation_degrees",
			amplitude * (1 if i % 2 == 0 else -1),
			swing_duration
		)
	
	# Settle to rest
	tween.tween_property(badge_node, "rotation_degrees", 0.0, 0.3)
	
	return tween

static func create_equipment_status_animation(equipment_node: Node, equipment_type: String) -> Tween:
	"""Create equipment status light animation"""
	
	var tween = equipment_node.create_tween()
	tween.set_loops()
	
	var config = equipment_status_config
	var equipment_config = config.equipment_types.get(equipment_type, config.equipment_types.heart_monitor)
	
	var colors = equipment_config.colors
	var interval = equipment_config.blink_interval
	var duration = equipment_config.blink_duration
	
	# Wait for interval
	tween.tween_delay(interval)
	
	# Blink sequence based on pattern
	match equipment_config.pattern:
		"steady_pulse":
			tween.tween_method(
				func(intensity: float):
					var base_color = StartScreenMedicalPalette.get_color_by_name(colors[0])
					var bright_color = StartScreenMedicalPalette.get_color_by_name(colors[1])
					equipment_node.modulate = base_color.lerp(bright_color, intensity),
				0.0, 1.0, duration * 0.5
			)
			tween.tween_method(
				func(intensity: float):
					var base_color = StartScreenMedicalPalette.get_color_by_name(colors[0])
					var bright_color = StartScreenMedicalPalette.get_color_by_name(colors[1])
					equipment_node.modulate = bright_color.lerp(base_color, intensity),
				0.0, 1.0, duration * 0.5
			)
		
		"double_blink":
			for blink in range(2):
				tween.tween_property(
					equipment_node, "modulate",
					StartScreenMedicalPalette.get_color_by_name(colors[1]),
					duration * 0.2
				)
				tween.tween_property(
					equipment_node, "modulate",
					StartScreenMedicalPalette.get_color_by_name(colors[0]),
					duration * 0.2
				)
				tween.tween_delay(duration * 0.1)
	
	return tween

static func create_atmospheric_overlay_animation(overlay_node: ColorRect) -> Tween:
	"""Create time-based atmospheric overlay animation"""
	
	var tween = overlay_node.create_tween()
	tween.set_loops()
	
	var config = atmospheric_overlay_config
	var current_hour = Time.get_datetime_dict_from_system().hour
	
	# Determine current time period
	var time_config = get_time_period_config(current_hour, config)
	
	if time_config.intensity > 0:
		var base_color = StartScreenMedicalPalette.get_color_by_name(time_config.base_color)
		var target_color = Color(
			base_color.r, base_color.g, base_color.b,
			time_config.intensity
		)
		
		# Gradual transition to atmospheric color
		tween.tween_property(overlay_node, "color", target_color, 2.0)
		
		# If night shift, add fatigue progression
		if time_config.has("fatigue_progression") and time_config.fatigue_progression:
			add_fatigue_progression_animation(tween, overlay_node)
	else:
		# Fade to transparent for day shifts
		tween.tween_property(overlay_node, "color", Color.TRANSPARENT, 1.0)
	
	return tween

static func get_time_period_config(hour: int, config: Dictionary) -> Dictionary:
	"""Get time period configuration based on current hour"""
	
	for period_name in config.time_based_transitions:
		var period_config = config.time_based_transitions[period_name]
		if hour in period_config.hours:
			return period_config
	
	# Default to day shift
	return config.time_based_transitions.day_shift

static func add_fatigue_progression_animation(tween: Tween, overlay_node: ColorRect):
	"""Add gradual fatigue progression during night shift"""
	
	# Slowly increase fatigue overlay intensity over time
	tween.tween_delay(30.0)  # Wait 30 seconds
	
	tween.tween_method(
		func(fatigue_level: float):
			var fatigue_color = StartScreenMedicalPalette.get_color_by_name("fatigue")
			var current_color = overlay_node.color
			var fatigue_overlay = Color(
				fatigue_color.r, fatigue_color.g, fatigue_color.b,
				fatigue_level * 0.1
			)
			overlay_node.color = current_color.lerp(fatigue_overlay, 0.3),
		0.0, 1.0, 60.0  # One minute progression
	)

# Animation Manager Functions

static func setup_start_screen_animations(root_node: Node) -> Dictionary:
	"""Setup all start screen animations and return animation controllers"""
	
	var animation_controllers = {}
	
	# Find and animate key elements
	var fluorescent_elements = find_nodes_by_name(root_node, "fluorescent")
	for element in fluorescent_elements:
		animation_controllers["fluorescent_" + element.name] = create_fluorescent_flicker_animation(element)
	
	var coffee_elements = find_nodes_by_name(root_node, "coffee")
	for element in coffee_elements:
		animation_controllers["coffee_steam_" + element.name] = create_coffee_steam_animation(element)
	
	var monitor_elements = find_nodes_by_name(root_node, "monitor")
	for element in monitor_elements:
		animation_controllers["monitor_" + element.name] = create_monitor_heartbeat_animation(element)
	
	var paper_elements = find_nodes_by_name(root_node, "clipboard")
	for element in paper_elements:
		animation_controllers["paper_" + element.name] = create_paper_flutter_animation(element)
	
	return animation_controllers

static func find_nodes_by_name(root_node: Node, name_pattern: String) -> Array[Node]:
	"""Helper function to find nodes with names containing pattern"""
	
	var found_nodes: Array[Node] = []
	
	for child in root_node.get_children():
		if child.name.to_lower().contains(name_pattern.to_lower()):
			found_nodes.append(child)
		
		# Recursively search children
		found_nodes.append_array(find_nodes_by_name(child, name_pattern))
	
	return found_nodes

static func get_animation_performance_settings() -> Dictionary:
	"""Get performance settings for animations based on device capability"""
	
	return {
		"max_simultaneous_animations": 6,
		"pixel_art_optimization": true,
		"reduced_particle_count_on_mobile": true,
		"animation_quality_levels": {
			"high": {"all_effects": true, "full_framerate": true},
			"medium": {"essential_effects_only": true, "reduced_framerate": true},
			"low": {"minimal_effects": true, "static_elements_only": true}
		},
		"battery_optimization": {
			"reduce_flicker_frequency": true,
			"disable_ambient_animations": true,
			"static_steam_sprite": true
		}
	}

static func get_medical_authenticity_guidelines() -> Dictionary:
	"""Get guidelines for maintaining medical authenticity in animations"""
	
	return {
		"equipment_behavior": "All medical equipment animations should reflect real device behavior",
		"timing_accuracy": "Heartbeat rates, medication drip rates should be medically accurate",
		"visual_feedback": "Status lights and displays should use standard medical color coding",
		"environmental_realism": "Hospital lighting, atmosphere should feel authentic",
		"workflow_support": "Animations should not distract from medical decision-making"
	}
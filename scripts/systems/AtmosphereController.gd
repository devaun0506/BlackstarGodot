class_name AtmosphereController
extends Node

## Atmosphere Controller for Blackstar
##
## Creates immersive medical environment with dynamic lighting, sounds,
## and visual effects that respond to game state and patient urgency.

signal atmosphere_changed(atmosphere_type: String, intensity: float)

# Atmosphere types
enum AtmosphereType {
	SHIFT_START,      # Beginning of shift - quiet preparation
	ROUTINE,          # Normal patient flow
	URGENT,           # Elevated urgency patient
	CRITICAL,         # Life-threatening situation
	BETWEEN_PATIENTS, # Brief calm moments
	SHIFT_END         # End of shift wind-down
}

# Audio components
@onready var ambient_sound: AudioStreamPlayer
@onready var equipment_sound: AudioStreamPlayer
@onready var footsteps_sound: AudioStreamPlayer
@onready var coffee_machine_sound: AudioStreamPlayer
@onready var page_system_sound: AudioStreamPlayer

# Visual components
@onready var lighting_controller: Node
@onready var equipment_monitors: Array[Control] = []
@onready var background_activity: Node

# Atmosphere state
var current_atmosphere: AtmosphereType = AtmosphereType.ROUTINE
var intensity_level: float = 0.5
var background_activity_level: float = 0.3

# Audio streams (would be loaded from files)
var ambient_streams = {
	"quiet": null,      # Low hospital hum
	"busy": null,       # More activity
	"urgent": null,     # Alarms, urgency
	"critical": null    # Code situations
}

var equipment_streams = {
	"monitors": null,   # Heart monitors, ventilators
	"alarms": null,     # Medical equipment alarms
	"typing": null,     # Computer keyboard sounds
	"pages": null       # Hospital PA system
}

func _ready() -> void:
	print("AtmosphereController: Initializing medical atmosphere")
	setup_audio_components()
	setup_visual_components()
	setup_default_atmosphere()

func setup_audio_components() -> void:
	"""Initialize audio components for medical atmosphere"""
	
	# Create audio players if they don't exist
	if not ambient_sound:
		ambient_sound = AudioStreamPlayer.new()
		ambient_sound.name = "AmbientSound"
		add_child(ambient_sound)
		ambient_sound.volume_db = -15
		ambient_sound.autoplay = false
	
	if not equipment_sound:
		equipment_sound = AudioStreamPlayer.new()
		equipment_sound.name = "EquipmentSound"
		add_child(equipment_sound)
		equipment_sound.volume_db = -20
		equipment_sound.autoplay = false
	
	if not footsteps_sound:
		footsteps_sound = AudioStreamPlayer.new()
		footsteps_sound.name = "FootstepsSound"
		add_child(footsteps_sound)
		footsteps_sound.volume_db = -25
		footsteps_sound.autoplay = false
	
	if not coffee_machine_sound:
		coffee_machine_sound = AudioStreamPlayer.new()
		coffee_machine_sound.name = "CoffeeMachineSound"
		add_child(coffee_machine_sound)
		coffee_machine_sound.volume_db = -18
		coffee_machine_sound.autoplay = false
	
	if not page_system_sound:
		page_system_sound = AudioStreamPlayer.new()
		page_system_sound.name = "PageSystemSound"
		add_child(page_system_sound)
		page_system_sound.volume_db = -12
		page_system_sound.autoplay = false
	
	print("AtmosphereController: Audio components created")

func setup_visual_components() -> void:
	"""Initialize visual atmosphere components"""
	
	# Visual components would be connected to actual UI elements
	print("AtmosphereController: Visual components ready")

func setup_default_atmosphere() -> void:
	"""Set up the default medical atmosphere"""
	set_atmosphere(AtmosphereType.ROUTINE, 0.5)

func set_atmosphere(atmosphere_type: AtmosphereType, intensity: float) -> void:
	"""Set the overall medical atmosphere"""
	
	var old_atmosphere = current_atmosphere
	current_atmosphere = atmosphere_type
	intensity_level = clamp(intensity, 0.0, 1.0)
	
	print("AtmosphereController: Setting atmosphere to %s (intensity: %.2f)" % [
		AtmosphereType.keys()[atmosphere_type], 
		intensity_level
	])
	
	# Apply atmosphere changes
	update_ambient_sound()
	update_equipment_sounds()
	update_lighting()
	update_background_activity()
	
	atmosphere_changed.emit(AtmosphereType.keys()[atmosphere_type], intensity_level)

func update_ambient_sound() -> void:
	"""Update ambient hospital sounds based on atmosphere"""
	
	if not ambient_sound:
		return
	
	var target_volume: float
	var sound_type: String
	
	match current_atmosphere:
		AtmosphereType.SHIFT_START:
			sound_type = "quiet"
			target_volume = -20
		AtmosphereType.ROUTINE:
			sound_type = "quiet"
			target_volume = -15
		AtmosphereType.URGENT:
			sound_type = "busy"
			target_volume = -12
		AtmosphereType.CRITICAL:
			sound_type = "urgent"
			target_volume = -8
		AtmosphereType.BETWEEN_PATIENTS:
			sound_type = "quiet"
			target_volume = -18
		AtmosphereType.SHIFT_END:
			sound_type = "quiet"
			target_volume = -22
	
	# Adjust volume based on intensity
	target_volume += (intensity_level - 0.5) * 6  # ±3db adjustment
	
	# Smoothly transition volume
	var tween = create_tween()
	tween.tween_property(ambient_sound, "volume_db", target_volume, 1.5)
	
	print("AtmosphereController: Ambient sound - %s at %s db" % [sound_type, target_volume])

func update_equipment_sounds() -> void:
	"""Update medical equipment sounds"""
	
	if not equipment_sound:
		return
	
	match current_atmosphere:
		AtmosphereType.SHIFT_START:
			play_equipment_sound("monitors", 0.3, 4.0)  # Slow, steady monitoring
		AtmosphereType.ROUTINE:
			play_equipment_sound("monitors", 0.5, 3.0)  # Normal monitoring
		AtmosphereType.URGENT:
			play_equipment_sound("monitors", 0.7, 2.0)  # Faster beeping
			schedule_random_page()  # Occasional pages
		AtmosphereType.CRITICAL:
			play_equipment_sound("alarms", 1.0, 1.5)   # Urgent alarms
			schedule_random_page(true)  # More frequent urgent pages
		AtmosphereType.BETWEEN_PATIENTS:
			play_equipment_sound("typing", 0.4, 5.0)   # Quiet computer work
		AtmosphereType.SHIFT_END:
			fade_equipment_sounds()

func play_equipment_sound(sound_type: String, volume_scale: float, interval: float) -> void:
	"""Play specific equipment sound with given parameters"""
	
	if not equipment_sound:
		return
	
	# Adjust volume
	equipment_sound.volume_db = -20 + (volume_scale * 8)
	
	# Create repeating sound timer
	var timer = Timer.new()
	timer.name = "EquipmentTimer_%s" % sound_type
	add_child(timer)
	timer.wait_time = interval
	timer.autostart = true
	timer.timeout.connect(_on_equipment_timer_timeout.bind(sound_type))
	
	print("AtmosphereController: Playing %s equipment sound every %.1fs" % [sound_type, interval])

func _on_equipment_timer_timeout(sound_type: String) -> void:
	"""Handle equipment sound timer timeout"""
	
	if equipment_sound and not equipment_sound.playing:
		# Play appropriate sound based on type
		# For now, just trigger a brief beep sound effect
		equipment_sound.pitch_scale = randf_range(0.9, 1.1)  # Slight variation
		equipment_sound.play()

func schedule_random_page(urgent: bool = false) -> void:
	"""Schedule a random PA system page"""
	
	var delay = randf_range(15.0, 45.0)  # Random delay between pages
	if urgent:
		delay = randf_range(5.0, 15.0)  # More frequent for critical
	
	await get_tree().create_timer(delay).timeout
	play_page_announcement(urgent)

func play_page_announcement(urgent: bool = false) -> void:
	"""Play a PA system page announcement"""
	
	if not page_system_sound:
		return
	
	var announcements = [
		"Dr. Johnson to Emergency, Dr. Johnson to Emergency",
		"Radiology technician to Room 3",
		"Housekeeping to the main desk",
		"Dr. Miller, please call extension 4829"
	]
	
	var urgent_announcements = [
		"Code Blue, Room 7, Code Blue Room 7",
		"Trauma Team to Bay 2, Trauma Team to Bay 2",
		"Respiratory Therapy to Emergency, STAT"
	]
	
	var announcement: String
	if urgent and randf() < 0.3:  # 30% chance of urgent announcement
		announcement = urgent_announcements[randi() % urgent_announcements.size()]
		page_system_sound.volume_db = -8  # Louder for urgent
	else:
		announcement = announcements[randi() % announcements.size()]
		page_system_sound.volume_db = -12  # Normal volume
	
	print("AtmosphereController: PA Announcement - %s" % announcement)
	
	# Play announcement sound (would be actual audio file)
	page_system_sound.play()

func update_lighting() -> void:
	"""Update lighting based on atmosphere"""
	
	# This would adjust actual lighting in the scene
	match current_atmosphere:
		AtmosphereType.SHIFT_START:
			set_lighting_mood("dim_prep")
		AtmosphereType.ROUTINE:
			set_lighting_mood("normal_clinical")
		AtmosphereType.URGENT:
			set_lighting_mood("elevated")
		AtmosphereType.CRITICAL:
			set_lighting_mood("emergency")
		AtmosphereType.BETWEEN_PATIENTS:
			set_lighting_mood("soft")
		AtmosphereType.SHIFT_END:
			set_lighting_mood("dim_end")

func set_lighting_mood(mood: String) -> void:
	"""Set specific lighting mood"""
	
	print("AtmosphereController: Setting lighting mood to %s" % mood)
	
	# This would adjust actual scene lighting
	# For now, just print the intended effect

func update_background_activity() -> void:
	"""Update background medical activity level"""
	
	match current_atmosphere:
		AtmosphereType.SHIFT_START:
			background_activity_level = 0.2
		AtmosphereType.ROUTINE:
			background_activity_level = 0.5
		AtmosphereType.URGENT:
			background_activity_level = 0.7
		AtmosphereType.CRITICAL:
			background_activity_level = 0.9
		AtmosphereType.BETWEEN_PATIENTS:
			background_activity_level = 0.3
		AtmosphereType.SHIFT_END:
			background_activity_level = 0.1
	
	print("AtmosphereController: Background activity level set to %.1f" % background_activity_level)
	
	# This would trigger background animations, additional sounds, etc.

func fade_equipment_sounds() -> void:
	"""Fade out equipment sounds smoothly"""
	
	if equipment_sound:
		var tween = create_tween()
		tween.tween_property(equipment_sound, "volume_db", -40, 2.0)
		tween.tween_callback(equipment_sound.stop)

func play_coffee_machine_effect() -> void:
	"""Play coffee machine sound effect for momentum building"""
	
	if coffee_machine_sound:
		coffee_machine_sound.pitch_scale = randf_range(0.95, 1.05)
		coffee_machine_sound.play()
		print("AtmosphereController: Coffee machine brewing...")

func play_footstep_sequence(urgency: float = 0.5) -> void:
	"""Play footstep sequence with varying urgency"""
	
	if not footsteps_sound:
		return
	
	# Adjust footstep speed based on urgency
	var step_interval = lerp(0.8, 0.3, urgency)  # Faster steps when urgent
	var num_steps = randi_range(3, 8)
	
	print("AtmosphereController: Playing %d footsteps (urgency: %.1f)" % [num_steps, urgency])
	
	for i in range(num_steps):
		footsteps_sound.pitch_scale = randf_range(0.9, 1.1)
		footsteps_sound.play()
		await get_tree().create_timer(step_interval).timeout

func trigger_medical_alarm(alarm_type: String = "general") -> void:
	"""Trigger specific medical equipment alarm"""
	
	print("AtmosphereController: Triggering %s medical alarm" % alarm_type)
	
	if equipment_sound:
		# Set alarm-specific properties
		match alarm_type:
			"cardiac":
				equipment_sound.pitch_scale = 1.2
				equipment_sound.volume_db = -6
			"oxygen":
				equipment_sound.pitch_scale = 0.8  
				equipment_sound.volume_db = -8
			"general":
				equipment_sound.pitch_scale = 1.0
				equipment_sound.volume_db = -10
		
		# Play alarm sequence
		for i in range(3):
			equipment_sound.play()
			await get_tree().create_timer(0.5).timeout

# Public interface methods
func get_current_atmosphere_type() -> AtmosphereType:
	"""Get current atmosphere type"""
	return current_atmosphere

func get_intensity_level() -> float:
	"""Get current intensity level"""
	return intensity_level

func set_background_activity(level: float) -> void:
	"""Set background activity level manually"""
	background_activity_level = clamp(level, 0.0, 1.0)
	print("AtmosphereController: Background activity set to %.2f" % background_activity_level)

# Utility methods for external systems
func create_medical_moment(moment_type: String, data: Dictionary = {}) -> void:
	"""Create a specific medical atmosphere moment"""
	
	match moment_type:
		"code_blue":
			set_atmosphere(AtmosphereType.CRITICAL, 1.0)
			trigger_medical_alarm("cardiac")
			play_page_announcement(true)
		"routine_check":
			play_footstep_sequence(0.3)
			await get_tree().create_timer(2.0).timeout
			play_equipment_sound("typing", 0.4, 8.0)
		"coffee_break":
			play_coffee_machine_effect()
			set_atmosphere(AtmosphereType.BETWEEN_PATIENTS, 0.2)
		"shift_change":
			play_footstep_sequence(0.6)
			play_page_announcement(false)
	
	print("AtmosphereController: Created medical moment - %s" % moment_type)

func cleanup_audio_timers() -> void:
	"""Clean up any running audio timers"""
	
	for child in get_children():
		if child is Timer and child.name.begins_with("EquipmentTimer_"):
			child.queue_free()
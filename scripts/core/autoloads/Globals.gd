extends Node

# Global singleton for shared game state and utilities
# Handles scene transitions, global settings, and cross-system communication

# Game state
enum GameState {
	MAIN_MENU,
	IN_GAME,
	PAUSED,
	SETTINGS,
	LOADING
}

var current_game_state: GameState = GameState.MAIN_MENU

# Global settings
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0
var fullscreen: bool = false
var vsync_enabled: bool = true

# Game session data
var current_session_id: String = ""
var session_start_time: int = 0

# Scene management
var current_scene_path: String = ""
var previous_scene_path: String = ""

func _ready() -> void:
	# Initialize session
	_start_new_session()
	
	# Set initial settings
	_apply_display_settings()
	
	print("Globals: Initialized")

func _start_new_session() -> void:
	"""Initialize a new game session"""
	current_session_id = _generate_session_id()
	session_start_time = Time.get_ticks_msec()
	print("Globals: Started session %s" % current_session_id)

func _generate_session_id() -> String:
	"""Generate unique session identifier"""
	var timestamp = Time.get_ticks_msec()
	var random_part = randi() % 10000
	return "session_%d_%04d" % [timestamp, random_part]

func set_game_state(new_state: GameState) -> void:
	"""Update global game state"""
	var old_state = current_game_state
	current_game_state = new_state
	print("Globals: Game state changed from %s to %s" % [_state_to_string(old_state), _state_to_string(new_state)])

func get_game_state() -> GameState:
	"""Get current game state"""
	return current_game_state

func _state_to_string(state: GameState) -> String:
	"""Convert game state enum to string"""
	match state:
		GameState.MAIN_MENU: return "MAIN_MENU"
		GameState.IN_GAME: return "IN_GAME"
		GameState.PAUSED: return "PAUSED"
		GameState.SETTINGS: return "SETTINGS"
		GameState.LOADING: return "LOADING"
	return "UNKNOWN"

# Settings management
func set_master_volume(volume: float) -> void:
	"""Set master volume (0.0 to 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	print("Globals: Master volume set to %.2f" % master_volume)

func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 to 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	# Apply to SFX bus if it exists
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))
	print("Globals: SFX volume set to %.2f" % sfx_volume)

func set_music_volume(volume: float) -> void:
	"""Set music volume (0.0 to 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	# Apply to Music bus if it exists
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	print("Globals: Music volume set to %.2f" % music_volume)

func set_fullscreen(enabled: bool) -> void:
	"""Toggle fullscreen mode"""
	fullscreen = enabled
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	print("Globals: Fullscreen %s" % ("enabled" if enabled else "disabled"))

func set_vsync(enabled: bool) -> void:
	"""Toggle VSync"""
	vsync_enabled = enabled
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	print("Globals: VSync %s" % ("enabled" if enabled else "disabled"))

func _apply_display_settings() -> void:
	"""Apply current display settings"""
	set_fullscreen(fullscreen)
	set_vsync(vsync_enabled)

# Scene management helpers
func notify_scene_changed(scene_path: String) -> void:
	"""Notify that scene has changed"""
	previous_scene_path = current_scene_path
	current_scene_path = scene_path
	print("Globals: Scene changed to %s" % scene_path)

func get_current_scene_path() -> String:
	"""Get current scene path"""
	return current_scene_path

func get_previous_scene_path() -> String:
	"""Get previous scene path"""
	return previous_scene_path

# Utility functions
func format_time_mmss(seconds: float) -> String:
	"""Format time as MM:SS"""
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func format_large_number(number: int) -> String:
	"""Format large numbers with commas"""
	var str_num = str(number)
	var result = ""
	var count = 0
	
	for i in range(str_num.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = str_num[i] + result
		count += 1
	
	return result

func get_platform_name() -> String:
	"""Get friendly platform name"""
	var platform = OS.get_name()
	match platform:
		"Windows": return "Windows"
		"macOS": return "Mac"
		"Linux": return "Linux"
		"Android": return "Android"
		"iOS": return "iPhone/iPad"
		"Web": return "Web"
	return platform

func is_mobile() -> bool:
	"""Check if running on mobile platform"""
	var platform = OS.get_name()
	return platform in ["Android", "iOS"]

func is_desktop() -> bool:
	"""Check if running on desktop platform"""
	var platform = OS.get_name()
	return platform in ["Windows", "macOS", "Linux"]

# Debug utilities
func debug_print_system_info() -> void:
	"""Print system information for debugging"""
	if OS.is_debug_build():
		print("=== System Info ===")
		print("Platform: %s" % get_platform_name())
		print("Godot Version: %s" % Engine.get_version_info().string)
		print("Session ID: %s" % current_session_id)
		print("Current Scene: %s" % current_scene_path)
		print("Game State: %s" % _state_to_string(current_game_state))
		print("===================")

func debug_test_audio() -> void:
	"""Test audio system"""
	if OS.is_debug_build():
		print("=== Audio Debug ===")
		print("Master Volume: %.2f" % master_volume)
		print("SFX Volume: %.2f" % sfx_volume)
		print("Music Volume: %.2f" % music_volume)
		
		var bus_count = AudioServer.get_bus_count()
		print("Audio Buses: %d" % bus_count)
		for i in range(bus_count):
			var bus_name = AudioServer.get_bus_name(i)
			var bus_db = AudioServer.get_bus_volume_db(i)
			print("  %s: %.2f dB" % [bus_name, bus_db])
		print("===================")
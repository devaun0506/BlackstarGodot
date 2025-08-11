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

# Performance caches
var _platform_name_cache: String = ""
var _is_mobile_cache: bool
var _is_desktop_cache: bool
var _platform_cache_initialized: bool = false
var _sfx_bus_index_cache: int = -2  # -2 indicates uninitialized
var _music_bus_index_cache: int = -2
var _state_string_cache: Dictionary = {}
var _debug_enabled_cache: bool
var _debug_cache_initialized: bool = false

func _ready() -> void:
	# Initialize caches for performance
	_initialize_performance_caches()
	
	# Initialize session
	_start_new_session()
	
	# Set initial settings
	_apply_display_settings()
	
	_debug_print("Globals: Initialized")

func _initialize_performance_caches() -> void:
	"""Initialize performance-critical caches once at startup"""
	# Cache platform detection
	var platform = OS.get_name()
	_platform_name_cache = _get_friendly_platform_name(platform)
	_is_mobile_cache = platform in ["Android", "iOS"]
	_is_desktop_cache = platform in ["Windows", "macOS", "Linux"]
	_platform_cache_initialized = true
	
	# Cache debug mode detection
	_debug_enabled_cache = OS.is_debug_build()
	_debug_cache_initialized = true
	
	# Initialize state string cache
	_state_string_cache[GameState.MAIN_MENU] = "MAIN_MENU"
	_state_string_cache[GameState.IN_GAME] = "IN_GAME"
	_state_string_cache[GameState.PAUSED] = "PAUSED"
	_state_string_cache[GameState.SETTINGS] = "SETTINGS"
	_state_string_cache[GameState.LOADING] = "LOADING"

func _get_friendly_platform_name(platform: String) -> String:
	"""Internal helper to get friendly platform name"""
	match platform:
		"Windows": return "Windows"
		"macOS": return "Mac"
		"Linux": return "Linux"
		"Android": return "Android"
		"iOS": return "iPhone/iPad"
		"Web": return "Web"
		_: return platform

func _start_new_session() -> void:
	"""Initialize a new game session"""
	current_session_id = _generate_session_id()
	session_start_time = Time.get_ticks_msec()
	_debug_print("Globals: Started session " + current_session_id)

func _generate_session_id() -> String:
	"""Generate unique session identifier - optimized for performance"""
	var timestamp = Time.get_ticks_msec()
	var random_part = randi() % 10000
	# Use string concatenation instead of formatting for better performance
	return "session_" + str(timestamp) + "_" + "%04d" % random_part

func set_game_state(new_state: GameState) -> void:
	"""Update global game state"""
	var old_state = current_game_state
	current_game_state = new_state
	_debug_print("Globals: Game state changed from " + _state_to_string(old_state) + " to " + _state_to_string(new_state))

func get_game_state() -> GameState:
	"""Get current game state"""
	return current_game_state

func _state_to_string(state: GameState) -> String:
	"""Convert game state enum to string - cached for performance"""
	return _state_string_cache.get(state, "UNKNOWN")

# Settings management
func set_master_volume(volume: float) -> void:
	"""Set master volume (0.0 to 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	_debug_print("Globals: Master volume set to " + "%.2f" % master_volume)

func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 to 1.0) - optimized with cached bus index"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	# Cache bus index for performance
	if _sfx_bus_index_cache == -2:
		_sfx_bus_index_cache = AudioServer.get_bus_index("SFX")
	
	if _sfx_bus_index_cache != -1:
		AudioServer.set_bus_volume_db(_sfx_bus_index_cache, linear_to_db(sfx_volume))
	_debug_print("Globals: SFX volume set to " + "%.2f" % sfx_volume)

func set_music_volume(volume: float) -> void:
	"""Set music volume (0.0 to 1.0) - optimized with cached bus index"""
	music_volume = clamp(volume, 0.0, 1.0)
	# Cache bus index for performance
	if _music_bus_index_cache == -2:
		_music_bus_index_cache = AudioServer.get_bus_index("Music")
	
	if _music_bus_index_cache != -1:
		AudioServer.set_bus_volume_db(_music_bus_index_cache, linear_to_db(music_volume))
	_debug_print("Globals: Music volume set to " + "%.2f" % music_volume)

func set_fullscreen(enabled: bool) -> void:
	"""Toggle fullscreen mode"""
	fullscreen = enabled
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_debug_print("Globals: Fullscreen " + ("enabled" if enabled else "disabled"))

func set_vsync(enabled: bool) -> void:
	"""Toggle VSync"""
	vsync_enabled = enabled
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_debug_print("Globals: VSync " + ("enabled" if enabled else "disabled"))

func _apply_display_settings() -> void:
	"""Apply current display settings"""
	set_fullscreen(fullscreen)
	set_vsync(vsync_enabled)

# Scene management helpers
func notify_scene_changed(scene_path: String) -> void:
	"""Notify that scene has changed"""
	previous_scene_path = current_scene_path
	current_scene_path = scene_path
	_debug_print("Globals: Scene changed to " + scene_path)

func get_current_scene_path() -> String:
	"""Get current scene path"""
	return current_scene_path

func get_previous_scene_path() -> String:
	"""Get previous scene path"""
	return previous_scene_path

# Utility functions
func format_time_mmss(seconds: float) -> String:
	"""Format time as MM:SS"""
	var minutes = int(seconds) // 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func format_large_number(number: int) -> String:
	"""Format large numbers with commas - optimized for performance"""
	if number == 0:
		return "0"
	
	var str_num = str(number)
	var str_length = str_num.length()
	
	# Quick return for small numbers (no formatting needed)
	if str_length <= 3:
		return str_num
	
	# Pre-calculate result size to avoid reallocations
	var comma_count = (str_length - 1) // 3
	var result_length = str_length + comma_count
	var result_chars = []
	result_chars.resize(result_length)
	
	var result_index = result_length - 1
	var source_index = str_length - 1
	var digit_count = 0
	
	# Build string from right to left using array for O(1) access
	while source_index >= 0:
		result_chars[result_index] = str_num[source_index]
		result_index -= 1
		source_index -= 1
		digit_count += 1
		
		if digit_count == 3 and source_index >= 0:
			result_chars[result_index] = ","
			result_index -= 1
			digit_count = 0
	
	return "".join(result_chars)

func get_platform_name() -> String:
	"""Get friendly platform name - cached for performance"""
	if not _platform_cache_initialized:
		_initialize_performance_caches()
	return _platform_name_cache

func is_mobile() -> bool:
	"""Check if running on mobile platform - cached for performance"""
	if not _platform_cache_initialized:
		_initialize_performance_caches()
	return _is_mobile_cache

func is_desktop() -> bool:
	"""Check if running on desktop platform - cached for performance"""
	if not _platform_cache_initialized:
		_initialize_performance_caches()
	return _is_desktop_cache

# Debug utilities
func debug_print_system_info() -> void:
	"""Print system information for debugging - optimized"""
	if not _is_debug_enabled():
		return
	
	print("=== System Info ===")
	print("Platform: " + get_platform_name())
	print("Godot Version: " + Engine.get_version_info().string)
	print("Session ID: " + current_session_id)
	print("Current Scene: " + current_scene_path)
	print("Game State: " + _state_to_string(current_game_state))
	print("===================")

func debug_test_audio() -> void:
	"""Test audio system - optimized"""
	if not _is_debug_enabled():
		return
	
	print("=== Audio Debug ===")
	print("Master Volume: " + "%.2f" % master_volume)
	print("SFX Volume: " + "%.2f" % sfx_volume)
	print("Music Volume: " + "%.2f" % music_volume)
	
	var bus_count = AudioServer.get_bus_count()
	print("Audio Buses: " + str(bus_count))
	for i in range(bus_count):
		var bus_name = AudioServer.get_bus_name(i)
		var bus_db = AudioServer.get_bus_volume_db(i)
		print("  " + bus_name + ": " + "%.2f" % bus_db + " dB")
	print("===================")

func _debug_print(message: String) -> void:
	"""Optimized debug print that only executes in debug builds"""
	if _is_debug_enabled():
		print(message)

func _is_debug_enabled() -> bool:
	"""Cached debug mode check for performance"""
	if not _debug_cache_initialized:
		_debug_enabled_cache = OS.is_debug_build()
		_debug_cache_initialized = true
	return _debug_enabled_cache

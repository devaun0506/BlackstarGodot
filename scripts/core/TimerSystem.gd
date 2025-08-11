extends Node
## Timer system for managing shift duration and countdown in Blackstar
##
## The TimerSystem handles countdown timers, time formatting,
## and provides time-based events for the medical shift gameplay.

signal time_updated(time_remaining: float)
signal time_expired
signal timer_paused
signal timer_resumed

# Timer state
var timer_active: bool = false
var timer_paused_state: bool = false
var total_time: float = 0.0
var time_remaining: float = 0.0
var update_interval: float = 0.5

# Internal timer
var timer: Timer

func _ready() -> void:
	# Create and configure internal timer
	timer = Timer.new()
	timer.wait_time = update_interval
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	print("TimerSystem ready")

func start_shift_timer(duration: float) -> void:
	"""Start the shift countdown timer"""
	if duration <= 0:
		push_error("TimerSystem: Invalid timer duration: " + str(duration))
		return
	
	if timer_active:
		push_warning("TimerSystem: Timer already active, stopping previous timer")
		stop_timer()
	
	print("Starting shift timer: %s" % format_time(duration))
	
	total_time = duration
	time_remaining = duration
	timer_active = true
	timer_paused_state = false
	
	# Start the update timer
	if timer and is_instance_valid(timer):
		timer.start()
	else:
		push_error("TimerSystem: Internal timer not available")
		return
	
	# Emit initial time update
	time_updated.emit(time_remaining)

func start_question_timer(duration: float) -> void:
	"""Start a timer for individual questions (future feature)"""
	# This could be used for time-limited questions
	# For now, we acknowledge the duration parameter but don't use it
	if duration > 0:
		print("Question timer requested for %s seconds (not implemented)" % duration)
	else:
		push_warning("TimerSystem: Invalid question timer duration: %s" % duration)

func pause_timer() -> void:
	"""Pause the active timer"""
	if timer_active and not timer_paused_state:
		timer_paused_state = true
		timer.paused = true
		print("Timer paused at: %s" % format_time(time_remaining))
		timer_paused.emit()

func resume_timer() -> void:
	"""Resume a paused timer"""
	if timer_active and timer_paused_state:
		timer_paused_state = false
		timer.paused = false
		print("Timer resumed at: %s" % format_time(time_remaining))
		timer_resumed.emit()

func stop_timer() -> void:
	"""Stop the active timer"""
	timer_active = false
	timer_paused_state = false
	timer.stop()
	print("Timer stopped")

func add_time(seconds: float) -> void:
	"""Add time to the current timer (for bonuses)"""
	if not timer_active:
		push_warning("TimerSystem: Cannot add time - timer is not active")
		return
	
	if seconds <= 0:
		push_warning("TimerSystem: Cannot add negative or zero time: " + str(seconds))
		return
	
	time_remaining += seconds
	time_remaining = min(time_remaining, total_time)  # Cap at original duration
	print("Added %s to timer. New time: %s" % [format_time(seconds), format_time(time_remaining)])
	time_updated.emit(time_remaining)

func subtract_time(seconds: float) -> void:
	"""Remove time from the current timer (for penalties)"""
	if not timer_active:
		push_warning("TimerSystem: Cannot subtract time - timer is not active")
		return
	
	if seconds <= 0:
		push_warning("TimerSystem: Cannot subtract negative or zero time: " + str(seconds))
		return
	
	time_remaining -= seconds
	time_remaining = max(time_remaining, 0.0)  # Don't go below zero
	print("Subtracted %s from timer. New time: %s" % [format_time(seconds), format_time(time_remaining)])
	time_updated.emit(time_remaining)
	
	# Check if time expired
	if time_remaining <= 0.0:
		_on_time_expired()

func get_time_remaining() -> float:
	"""Get the current time remaining in seconds"""
	return time_remaining

func get_formatted_time_remaining() -> String:
	"""Get the formatted time remaining as MM:SS"""
	return format_time(time_remaining)

func get_elapsed_time() -> float:
	"""Get the elapsed time in seconds"""
	return total_time - time_remaining

func get_formatted_elapsed_time() -> String:
	"""Get the formatted elapsed time as MM:SS"""
	return format_time(get_elapsed_time())

func get_progress_percentage() -> float:
	"""Get timer progress as a percentage (0.0 to 1.0)"""
	if total_time <= 0.0:
		return 0.0
	return (total_time - time_remaining) / total_time

func format_time(seconds: float) -> String:
	"""Format seconds into MM:SS format"""
	var total_seconds_int = int(seconds)
	var minutes = total_seconds_int / 60
	var remaining_seconds = total_seconds_int % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func format_time_with_decimals(seconds: float) -> String:
	"""Format seconds into MM:SS.D format"""
	var total_seconds_int = int(seconds)
	var minutes = total_seconds_int / 60
	var remaining_seconds = fmod(seconds, 60.0)
	return "%02d:%04.1f" % [minutes, remaining_seconds]

func is_timer_active() -> bool:
	"""Check if a timer is currently running"""
	return timer_active and not timer_paused_state

func is_timer_paused() -> bool:
	"""Check if the timer is paused"""
	return timer_paused_state

func get_time_warning_level() -> String:
	"""Get warning level based on remaining time"""
	if total_time <= 0.0:
		return "urgent"
	var percentage_remaining = time_remaining / total_time
	
	if percentage_remaining > 0.5:
		return "safe"
	elif percentage_remaining > 0.25:
		return "warning"
	elif percentage_remaining > 0.1:
		return "critical"
	else:
		return "urgent"

func should_show_warning() -> bool:
	"""Check if time warning should be displayed"""
	var percentage_remaining = time_remaining / total_time
	return percentage_remaining <= 0.25  # Show warning at 25% remaining

func should_flash_timer() -> bool:
	"""Check if timer should flash (critical time)"""
	var percentage_remaining = time_remaining / total_time
	return percentage_remaining <= 0.1  # Flash at 10% remaining

# Internal callbacks
func _on_timer_timeout() -> void:
	"""Handle timer update ticks"""
	if not timer_active or timer_paused_state:
		return
	
	# Decrease time remaining
	time_remaining -= update_interval
	time_remaining = max(time_remaining, 0.0)
	
	# Emit update signal
	time_updated.emit(time_remaining)
	
	# Check if time expired
	if time_remaining <= 0.0:
		_on_time_expired()

func _on_time_expired() -> void:
	"""Handle timer expiration"""
	print("Time expired!")
	timer_active = false
	timer.stop()
	time_expired.emit()

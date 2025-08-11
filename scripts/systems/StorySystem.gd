class_name StorySystem
extends Node

## Story System for Blackstar
##
## Manages character interactions, story progression, relationship development,
## and narrative integration with medical gameplay.

signal story_beat_triggered(story_data: Dictionary)
signal character_interaction_started(character_name: String)
signal character_interaction_completed(character_name: String, choice_made: String)
signal relationship_changed(character_name: String, relationship_level: int)

# Story progression state
var current_shift: int = 1
var story_progress: Dictionary = {}
var character_relationships: Dictionary = {}
var discovered_plot_points: Array[String] = []
var player_choices: Dictionary = {}

# Characters in the story
enum Characters {
	SENIOR_RESIDENT,    # Dr. Sarah Martinez - mentor figure
	NIGHT_NURSE,        # Nurse Thompson - supportive colleague  
	ATTENDING,          # Dr. Williams - supervisor
	PATIENT_ADVOCATE,   # Maria Santos - reveals systemic issues
	SECURITY_GUARD,     # Officer Kim - notices unusual patterns
	PARAMEDIC           # EMT Jackson - brings concerning cases
}

# Character data
var character_data: Dictionary = {}

# Story configuration
@export var story_beats_per_shift: int = 3
@export var relationship_decay_rate: float = 0.02  # Per patient without interaction
@export var major_story_beat_interval: int = 5     # Every N shifts

func _ready() -> void:
	print("StorySystem: Initializing story system")
	initialize_characters()
	initialize_story_progress()
	setup_story_data()

func initialize_characters() -> void:
	"""Initialize character data and relationships"""
	
	character_data = {
		"senior_resident": {
			"name": "Dr. Sarah Martinez",
			"role": "Senior Resident",
			"personality": "Supportive mentor, experienced, slightly tired but caring",
			"relationship_level": 50,  # Starts neutral-positive
			"interaction_count": 0,
			"last_seen": 0,
			"key_traits": ["mentor", "experienced", "empathetic"],
			"dialogue_style": "Professional but warm, offers guidance"
		},
		
		"night_nurse": {
			"name": "Nurse Thompson", 
			"role": "Night Shift Nurse",
			"personality": "Friendly, observant, knows everyone's coffee preferences",
			"relationship_level": 45,  # Starts friendly
			"interaction_count": 0,
			"last_seen": 0,
			"key_traits": ["caring", "observant", "practical"],
			"dialogue_style": "Casual, supportive, often offers practical help"
		},
		
		"attending": {
			"name": "Dr. Williams",
			"role": "Attending Physician", 
			"personality": "Demanding but fair, high standards, values competence",
			"relationship_level": 30,  # Starts neutral-skeptical
			"interaction_count": 0,
			"last_seen": 0,
			"key_traits": ["demanding", "fair", "professional"],
			"dialogue_style": "Direct, clinical, gives constructive feedback"
		},
		
		"patient_advocate": {
			"name": "Maria Santos",
			"role": "Patient Advocate",
			"personality": "Passionate about patient care, notices systemic problems",
			"relationship_level": 35,  # Starts neutral
			"interaction_count": 0,
			"last_seen": 0,
			"key_traits": ["passionate", "observant", "justice-minded"],
			"dialogue_style": "Earnest, concerned about patient welfare"
		}
	}
	
	# Initialize relationship tracking
	for character_id in character_data.keys():
		character_relationships[character_id] = character_data[character_id].relationship_level

func initialize_story_progress() -> void:
	"""Initialize story progression tracking"""
	
	story_progress = {
		"shift_count": 0,
		"total_patients_seen": 0,
		"major_discoveries": [],
		"active_plotlines": [],
		"completed_arcs": [],
		"player_reputation": {
			"competence": 50,
			"empathy": 50, 
			"collaboration": 50
		}
	}

func setup_story_data() -> void:
	"""Setup story beats and narrative data"""
	# This would eventually load from external files
	print("StorySystem: Story data initialized")

func trigger_story_beat(patients_seen: int, shift_number: int = -1) -> Dictionary:
	"""Trigger an appropriate story beat based on game state"""
	
	if shift_number >= 0:
		current_shift = shift_number
	
	# Determine what type of story beat to show
	var story_beat_type = determine_story_beat_type(patients_seen)
	var story_data = generate_story_beat(story_beat_type, patients_seen)
	
	story_beat_triggered.emit(story_data)
	return story_data

func determine_story_beat_type(patients_seen: int) -> String:
	"""Determine what type of story beat should occur"""
	
	# Major story beats at specific intervals
	if patients_seen % 10 == 0 and patients_seen > 0:
		return "major_story_beat"
	
	# Character interactions every few patients
	elif patients_seen % 3 == 0:
		return "character_interaction"
	
	# Atmospheric moments for pacing
	elif patients_seen % 2 == 0:
		return "atmosphere_moment"
	
	# Default brief pause
	else:
		return "brief_pause"

func generate_story_beat(beat_type: String, patients_seen: int) -> Dictionary:
	"""Generate story beat content based on type and game state"""
	
	match beat_type:
		"character_interaction":
			return generate_character_interaction(patients_seen)
		"major_story_beat":
			return generate_major_story_beat(patients_seen)
		"atmosphere_moment":
			return generate_atmosphere_moment(patients_seen)
		_:
			return generate_brief_pause(patients_seen)

func generate_character_interaction(patients_seen: int) -> Dictionary:
	"""Generate a character interaction story beat"""
	
	# Choose character based on relationship levels and story needs
	var character_id = choose_interaction_character(patients_seen)
	var character = character_data.get(character_id, {})
	
	if character.is_empty():
		return generate_brief_pause(patients_seen)
	
	# Generate context-appropriate dialogue
	var interaction_data = create_character_interaction(character_id, patients_seen)
	
	# Update character interaction tracking
	character["interaction_count"] += 1
	character["last_seen"] = patients_seen
	
	character_interaction_started.emit(character.get("name", "Unknown"))
	
	return interaction_data

func choose_interaction_character(patients_seen: int) -> String:
	"""Choose which character should interact based on story logic"""
	
	# Early shift - mentor interactions
	if patients_seen <= 3:
		return "senior_resident"
	
	# Mid shift - variety of characters
	elif patients_seen <= 8:
		# Rotate between nurse and attending
		if patients_seen % 2 == 0:
			return "night_nurse"
		else:
			return "attending"
	
	# Later shift - more complex interactions
	else:
		# Include patient advocate for deeper story moments
		if patients_seen % 5 == 0:
			return "patient_advocate"
		else:
			return "senior_resident"

func create_character_interaction(character_id: String, patients_seen: int) -> Dictionary:
	"""Create specific character interaction content"""
	
	var character = character_data.get(character_id, {})
	var relationship_level = character_relationships.get(character_id, 50)
	
	var interactions = get_character_interactions(character_id, relationship_level, patients_seen)
	var chosen_interaction = interactions[randi() % interactions.size()]
	
	# Add character context
	chosen_interaction["character_id"] = character_id
	chosen_interaction["character_name"] = character.get("name", "Staff Member")
	chosen_interaction["character_role"] = character.get("role", "Hospital Staff")
	chosen_interaction["relationship_level"] = relationship_level
	
	return chosen_interaction

func get_character_interactions(character_id: String, relationship_level: int, patients_seen: int) -> Array:
	"""Get possible interactions for a character based on relationship and context"""
	
	var interactions = []
	
	match character_id:
		"senior_resident":
			interactions = get_senior_resident_interactions(relationship_level, patients_seen)
		"night_nurse":
			interactions = get_night_nurse_interactions(relationship_level, patients_seen)
		"attending":
			interactions = get_attending_interactions(relationship_level, patients_seen)
		"patient_advocate":
			interactions = get_patient_advocate_interactions(relationship_level, patients_seen)
		_:
			interactions = [create_generic_interaction()]
	
	return interactions

func get_senior_resident_interactions(relationship: int, patients_seen: int) -> Array:
	"""Get interactions for the senior resident character"""
	
	var interactions = []
	
	if patients_seen <= 3:
		# Early shift guidance
		interactions.append({
			"type": "guidance",
			"title": "Getting Settled",
			"text": "Dr. Martinez stops by your workstation with a cup of coffee.",
			"dialogue": "\"How are you feeling so far? The night shift has its own rhythm—don't hesitate to ask if you need a second opinion on anything.\"",
			"choices": {
				"confident": "I'm feeling good about the cases so far.",
				"uncertain": "Actually, I could use some guidance on differential diagnosis.",
				"grateful": "Thanks for checking in—I appreciate the support."
			},
			"mood": "supportive"
		})
	elif patients_seen <= 6:
		# Mid-shift check-in
		interactions.append({
			"type": "check_in",
			"title": "Midpoint Assessment",
			"text": "Sarah reviews some of your recent charts while sipping her coffee.",
			"dialogue": "\"Your diagnostic reasoning is solid. I like how you're considering the social factors in your assessments—that's what makes a good emergency physician.\"",
			"choices": {
				"proud": "Thank you, I'm trying to see the whole picture.",
				"learning": "I'm still learning to balance speed with thoroughness.",
				"curious": "What would you have done differently on that last case?"
			},
			"mood": "encouraging"
		})
	else:
		# Later shift deeper conversation
		interactions.append({
			"type": "reflection",
			"title": "Late Night Wisdom",
			"text": "The department is quieter now, and Sarah takes a moment to sit down.",
			"dialogue": "\"You know what I love about emergency medicine? Every case is a puzzle, but more importantly, every patient is a person with a story. Never lose sight of that.\"",
			"choices": {
				"philosophical": "It's what drew me to this field in the first place.",
				"practical": "How do you maintain that perspective during busy nights?",
				"personal": "Sometimes I worry about getting too clinical."
			},
			"mood": "reflective"
		})
	
	return interactions

func get_night_nurse_interactions(relationship: int, patients_seen: int) -> Array:
	"""Get interactions for the night nurse character"""
	
	return [{
		"type": "support",
		"title": "Nursing Wisdom",
		"text": "Nurse Thompson appears with a fresh cup of coffee and a knowing smile.",
		"dialogue": "\"I restocked the supplies in room 3, and there's fresh coffee if you need it. How are you holding up?\"",
		"choices": {
			"grateful": "You're a lifesaver—thank you for thinking ahead.",
			"tired": "The coffee sounds perfect right about now.",
			"professional": "Everything's going smoothly, thanks to the great nursing support."
		},
		"mood": "caring"
	}]

func get_attending_interactions(relationship: int, patients_seen: int) -> Array:
	"""Get interactions for the attending physician"""
	
	return [{
		"type": "evaluation",
		"title": "Performance Review",
		"text": "Dr. Williams approaches with a tablet, reviewing your recent cases.",
		"dialogue": "\"I've been monitoring your diagnostic accuracy—you're performing well. Keep up the systematic approach, but don't be afraid to trust your clinical intuition.\"",
		"choices": {
			"confident": "Thank you, I'm finding my rhythm.",
			"improvement": "Are there areas where I can improve?",
			"systematic": "I'm trying to balance thoroughness with efficiency."
		},
		"mood": "professional"
	}]

func get_patient_advocate_interactions(relationship: int, patients_seen: int) -> Array:
	"""Get interactions for the patient advocate"""
	
	return [{
		"type": "concern",
		"title": "Patient Perspective",
		"text": "Maria Santos from Patient Advocacy sits down across from you.",
		"dialogue": "\"I've been talking with some of the patients you've seen tonight. They appreciate how you listen to their concerns—that makes a real difference in their experience.\"",
		"choices": {
			"empathetic": "Patient experience is really important to me.",
			"curious": "Is there feedback I should know about?",
			"collaborative": "I'd love to hear how we can improve patient satisfaction."
		},
		"mood": "earnest"
	}]

func create_generic_interaction() -> Dictionary:
	"""Create a generic interaction for fallback"""
	
	return {
		"type": "generic",
		"title": "Brief Encounter",
		"text": "A colleague stops by to check how things are going.",
		"dialogue": "\"Things seem to be running smoothly tonight. Keep up the good work.\"",
		"choices": {
			"acknowledge": "Thanks, appreciate it."
		},
		"mood": "neutral"
	}

func generate_major_story_beat(patients_seen: int) -> Dictionary:
	"""Generate a major story progression beat"""
	
	return {
		"type": "major_story",
		"title": "A Pattern Emerges",
		"text": "As you review the night's cases, you begin to notice something unusual...",
		"dialogue": "The cases tonight seem connected in a way that goes beyond coincidence. There's a pattern here that deserves attention.",
		"choices": {
			"investigate": "I should look into this pattern more carefully.",
			"report": "This might be something to discuss with the attending.",
			"document": "I'll make detailed notes about what I'm seeing."
		},
		"mood": "mysterious",
		"story_impact": "major"
	}

func generate_atmosphere_moment(patients_seen: int) -> Dictionary:
	"""Generate an atmospheric story moment"""
	
	var atmosphere_moments = [
		{
			"type": "atmosphere",
			"title": "The Night Shift",
			"text": "The emergency department has settled into its late-night rhythm. The fluorescent lights hum softly overhead, and the coffee machine gurgles in the distance.",
			"dialogue": "Outside, the city sleeps, but here, life continues its urgent pace. Each chart represents someone's story, someone's need for healing.",
			"mood": "contemplative"
		},
		{
			"type": "atmosphere", 
			"title": "Medical Precision",
			"text": "The scent of antiseptic mingles with the quiet conversations of the night staff. Monitors beep steadily, creating a rhythm of life and healing.",
			"dialogue": "This is the world you chose—where science meets compassion, where split-second decisions can change everything.",
			"mood": "professional"
		}
	]
	
	return atmosphere_moments[randi() % atmosphere_moments.size()]

func generate_brief_pause(patients_seen: int) -> Dictionary:
	"""Generate a brief pause moment"""
	
	return {
		"type": "pause",
		"title": "A Moment to Breathe",
		"text": "You take a brief moment to collect your thoughts before the next patient.",
		"dialogue": "The emergency department continues its quiet hum around you.",
		"mood": "neutral"
	}

func process_player_choice(character_id: String, choice_key: String, interaction_data: Dictionary) -> void:
	"""Process player's choice in character interaction"""
	
	# Record the choice
	if not player_choices.has(character_id):
		player_choices[character_id] = []
	player_choices[character_id].append({
		"choice": choice_key,
		"context": interaction_data.get("type", "unknown"),
		"timestamp": Time.get_ticks_msec()
	})
	
	# Update relationship based on choice
	update_character_relationship(character_id, choice_key, interaction_data)
	
	character_interaction_completed.emit(character_data[character_id].get("name", "Unknown"), choice_key)

func update_character_relationship(character_id: String, choice_key: String, interaction_data: Dictionary) -> void:
	"""Update character relationship based on player choice"""
	
	var relationship_change = calculate_relationship_change(character_id, choice_key, interaction_data)
	var current_level = character_relationships.get(character_id, 50)
	var new_level = clamp(current_level + relationship_change, 0, 100)
	
	character_relationships[character_id] = new_level
	character_data[character_id]["relationship_level"] = new_level
	
	if abs(relationship_change) > 0:
		relationship_changed.emit(character_data[character_id].get("name", "Unknown"), new_level)
		print("StorySystem: Relationship with %s changed by %d (now %d)" % [
			character_data[character_id].get("name", "Unknown"), 
			relationship_change, 
			new_level
		])

func calculate_relationship_change(character_id: String, choice_key: String, interaction_data: Dictionary) -> int:
	"""Calculate how much a choice affects character relationship"""
	
	var base_change = 0
	
	# Different characters respond differently to choices
	match character_id:
		"senior_resident":
			match choice_key:
				"confident", "proud":
					base_change = 3  # Likes confidence
				"uncertain", "learning":
					base_change = 5  # Really appreciates humility and learning
				"curious", "philosophical":
					base_change = 4  # Values thoughtfulness
				_:
					base_change = 2
		
		"night_nurse":
			match choice_key:
				"grateful", "tired":
					base_change = 4  # Appreciates acknowledgment of support
				"professional":
					base_change = 2  # Good but not as personal
				_:
					base_change = 1
		
		"attending":
			match choice_key:
				"confident", "systematic":
					base_change = 4  # Values competence and methodology
				"improvement":
					base_change = 3  # Appreciates desire to improve
				_:
					base_change = 2
		
		"patient_advocate":
			match choice_key:
				"empathetic", "collaborative":
					base_change = 5  # Highly values patient focus
				"curious":
					base_change = 3  # Good to be interested
				_:
					base_change = 1
	
	return base_change

func decay_unused_relationships(patients_seen: int) -> void:
	"""Gradually decay relationships with characters not recently seen"""
	
	for character_id in character_data.keys():
		var character = character_data[character_id]
		var last_interaction = character.get("last_seen", 0)
		
		# Decay if not seen recently
		if patients_seen - last_interaction > 3:
			var current_level = character_relationships.get(character_id, 50)
			var decay_amount = int(relationship_decay_rate * (patients_seen - last_interaction))
			var new_level = max(0, current_level - decay_amount)
			
			if new_level != current_level:
				character_relationships[character_id] = new_level
				character["relationship_level"] = new_level

# Public interface
func get_character_relationship(character_id: String) -> int:
	"""Get current relationship level with character"""
	return character_relationships.get(character_id, 50)

func get_all_relationships() -> Dictionary:
	"""Get all character relationships"""
	return character_relationships.duplicate()

func get_character_info(character_id: String) -> Dictionary:
	"""Get character information"""
	return character_data.get(character_id, {})

func get_story_progress() -> Dictionary:
	"""Get current story progress"""
	return story_progress.duplicate()

func update_story_progress(key: String, value) -> void:
	"""Update story progress tracking"""
	story_progress[key] = value

func add_discovery(discovery: String) -> void:
	"""Add a story discovery"""
	if discovery not in discovered_plot_points:
		discovered_plot_points.append(discovery)
		story_progress["major_discoveries"] = discovered_plot_points

# Save/Load functionality
func get_save_data() -> Dictionary:
	"""Get story system save data"""
	return {
		"current_shift": current_shift,
		"story_progress": story_progress,
		"character_relationships": character_relationships,
		"discovered_plot_points": discovered_plot_points,
		"player_choices": player_choices,
		"character_interaction_counts": get_interaction_counts()
	}

func get_interaction_counts() -> Dictionary:
	"""Get interaction counts for all characters"""
	var counts = {}
	for character_id in character_data.keys():
		counts[character_id] = character_data[character_id].get("interaction_count", 0)
	return counts

func load_save_data(save_data: Dictionary) -> void:
	"""Load story system from save data"""
	current_shift = save_data.get("current_shift", 1)
	story_progress = save_data.get("story_progress", {})
	character_relationships = save_data.get("character_relationships", {})
	discovered_plot_points = save_data.get("discovered_plot_points", [])
	player_choices = save_data.get("player_choices", {})
	
	# Update character data with loaded counts
	var interaction_counts = save_data.get("character_interaction_counts", {})
	for character_id in character_data.keys():
		if interaction_counts.has(character_id):
			character_data[character_id]["interaction_count"] = interaction_counts[character_id]
		if character_relationships.has(character_id):
			character_data[character_id]["relationship_level"] = character_relationships[character_id]
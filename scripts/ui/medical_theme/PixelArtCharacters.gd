class_name PixelArtCharacters
extends Control

# Pixel art character portrait system for Blackstar
# Creates expressive medical staff portraits with emotional states

signal character_emotion_changed(character: String, emotion: String)
signal character_dialogue_triggered(character: String, dialogue_text: String)

# Character types
enum CharacterType {
	SENIOR_RESIDENT,
	NIGHT_NURSE,
	ATTENDING,
	MEDICAL_STUDENT,
	PATIENT
}

# Emotional states
enum EmotionalState {
	NEUTRAL,
	FOCUSED,
	CONCERNED,
	EXHAUSTED,
	STRESSED,
	ENCOURAGING,
	FRUSTRATED,
	RELIEVED,
	ALERT,
	COMPASSIONATE
}

# Character data structure
class CharacterData:
	var character_type: CharacterType
	var name: String
	var current_emotion: EmotionalState = EmotionalState.NEUTRAL
	var stress_level: float = 0.0  # 0.0 to 1.0
	var experience_level: float = 0.5  # 0.0 novice to 1.0 expert
	var dialogue_lines: Array[String] = []

# UI Elements
@onready var portrait_container: Control
@onready var dialogue_panel: Panel
@onready var dialogue_label: Label
@onready var name_label: Label

# Character portraits
var character_portraits: Dictionary = {}
var current_active_character: CharacterData
var portrait_size: Vector2 = Vector2(80, 100)

func _ready():
	setup_character_system()
	create_character_portraits()

func setup_character_system():
	"""Initialize the character portrait system"""
	
	# Main container for character portraits
	portrait_container = Control.new()
	portrait_container.name = "PortraitContainer"
	portrait_container.size = Vector2(portrait_size.x + 20, portrait_size.y + 60)
	portrait_container.position = Vector2(get_parent().size.x - portrait_container.size.x - 10, 10)
	add_child(portrait_container)
	
	# Dialogue panel
	setup_dialogue_panel()

func setup_dialogue_panel():
	"""Create dialogue panel for character interactions"""
	
	dialogue_panel = Panel.new()
	dialogue_panel.name = "DialoguePanel"
	dialogue_panel.size = Vector2(250, 80)
	dialogue_panel.position = Vector2(portrait_container.position.x - dialogue_panel.size.x - 10, portrait_container.position.y + 20)
	dialogue_panel.visible = false
	add_child(dialogue_panel)
	
	# Style dialogue panel like a speech bubble
	var style = StyleBoxFlat.new()
	style.bg_color = MedicalColors.CHART_PAPER
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 2
	style.border_color = MedicalColors.TEXT_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	
	dialogue_panel.add_theme_stylebox_override("panel", style)
	
	# Dialogue text
	dialogue_label = Label.new()
	dialogue_label.name = "DialogueText"
	dialogue_label.position = Vector2(10, 8)
	dialogue_label.size = Vector2(dialogue_panel.size.x - 20, dialogue_panel.size.y - 25)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	dialogue_label.add_theme_font_size_override("font_size", 10)
	dialogue_label.add_theme_color_override("font_color", MedicalColors.TEXT_DARK)
	dialogue_panel.add_child(dialogue_label)
	
	# Character name in dialogue
	name_label = Label.new()
	name_label.name = "CharacterName"
	name_label.position = Vector2(10, dialogue_panel.size.y - 20)
	name_label.size = Vector2(dialogue_panel.size.x - 20, 15)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.add_theme_color_override("font_color", MedicalColors.TEXT_MUTED)
	dialogue_panel.add_child(name_label)

func create_character_portraits():
	"""Create all character portraits"""
	
	# Define character data
	var characters_data = [
		create_senior_resident(),
		create_night_nurse(),
		create_attending(),
		create_medical_student()
	]
	
	for char_data in characters_data:
		var portrait = create_character_portrait(char_data)
		character_portraits[char_data.character_type] = portrait
		portrait_container.add_child(portrait)

func create_senior_resident() -> CharacterData:
	"""Create senior resident character data"""
	
	var char = CharacterData.new()
	char.character_type = CharacterType.SENIOR_RESIDENT
	char.name = "Dr. Sarah Chen"
	char.current_emotion = EmotionalState.FOCUSED
	char.stress_level = 0.7
	char.experience_level = 0.8
	char.dialogue_lines = [
		"Check the vitals again. Something's not right.",
		"Good catch on that differential.",
		"Trust your instincts, but verify with data.",
		"We've seen this presentation before.",
		"Time is critical here.",
		"Document everything clearly.",
		"The attending will want to see this.",
		"Stay calm and think it through."
	]
	
	return char

func create_night_nurse() -> CharacterData:
	"""Create night nurse character data"""
	
	var char = CharacterData.new()
	char.character_type = CharacterType.NIGHT_NURSE
	char.name = "Marcus Rodriguez, RN"
	char.current_emotion = EmotionalState.ALERT
	char.stress_level = 0.5
	char.experience_level = 0.9
	char.dialogue_lines = [
		"Room 3 needs attention.",
		"Labs are back from the morning draw.",
		"Family's asking about the patient.",
		"We're running low on supplies.",
		"That patient's been asking for you.",
		"Coffee's fresh if you need it.",
		"Shift change is in an hour.",
		"I've seen worse nights than this."
	]
	
	return char

func create_attending() -> CharacterData:
	"""Create attending physician character data"""
	
	var char = CharacterData.new()
	char.character_type = CharacterType.ATTENDING
	char.name = "Dr. James Wilson"
	char.current_emotion = EmotionalState.CONCERNED
	char.stress_level = 0.8
	char.experience_level = 1.0
	char.dialogue_lines = [
		"What's your assessment?",
		"Consider the differential carefully.",
		"Order appropriate tests.",
		"Patient safety comes first.",
		"Good clinical reasoning.",
		"Think about the worst-case scenario.",
		"Time to make a decision.",
		"Call if you need backup."
	]
	
	return char

func create_medical_student() -> CharacterData:
	"""Create medical student character data"""
	
	var char = CharacterData.new()
	char.character_type = CharacterType.MEDICAL_STUDENT
	char.name = "Alex Kim (MS3)"
	char.current_emotion = EmotionalState.FOCUSED
	char.stress_level = 0.9
	char.experience_level = 0.2
	char.dialogue_lines = [
		"Should I order those labs?",
		"Is this normal?",
		"What would you do next?",
		"I'm still learning the system.",
		"Thanks for teaching me.",
		"That makes so much sense now.",
		"I want to help however I can.",
		"This is more intense than I expected."
	]
	
	return char

func create_character_portrait(char_data: CharacterData) -> Control:
	"""Create pixel art portrait for a character"""
	
	var portrait_panel = Panel.new()
	portrait_panel.name = str(char_data.character_type)
	portrait_panel.size = portrait_size
	portrait_panel.visible = false  # Start hidden
	
	# Portrait frame styling
	apply_portrait_frame_styling(portrait_panel, char_data)
	
	# Create pixel art face
	var face_container = Control.new()
	face_container.name = "Face"
	face_container.size = Vector2(portrait_size.x - 10, portrait_size.y - 30)
	face_container.position = Vector2(5, 5)
	portrait_panel.add_child(face_container)
	
	# Create facial features
	create_pixel_face(face_container, char_data)
	
	# Character name plate
	create_character_nameplate(portrait_panel, char_data)
	
	# Stress/fatigue indicators
	create_stress_indicators(portrait_panel, char_data)
	
	return portrait_panel

func apply_portrait_frame_styling(panel: Panel, char_data: CharacterData):
	"""Apply frame styling based on character type"""
	
	var style = StyleBoxFlat.new()
	
	# Frame color based on role
	match char_data.character_type:
		CharacterType.SENIOR_RESIDENT:
			style.bg_color = MedicalColors.MEDICAL_GREEN
		CharacterType.NIGHT_NURSE:
			style.bg_color = MedicalColors.STERILE_BLUE
		CharacterType.ATTENDING:
			style.bg_color = MedicalColors.EQUIPMENT_GRAY_DARK
		CharacterType.MEDICAL_STUDENT:
			style.bg_color = MedicalColors.CHART_PAPER
		_:
			style.bg_color = MedicalColors.EQUIPMENT_GRAY
	
	# Frame border
	style.border_width_left = style.border_width_top = style.border_width_right = style.border_width_bottom = 3
	style.border_color = MedicalColors.TEXT_DARK
	style.corner_radius_top_left = style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = 6
	
	# Shadow for depth
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	
	panel.add_theme_stylebox_override("panel", style)

func create_pixel_face(container: Control, char_data: CharacterData):
	"""Create pixel art facial features"""
	
	var face_width = container.size.x
	var face_height = container.size.y
	
	# Head/face base
	var head = create_face_base(face_width, face_height, char_data)
	container.add_child(head)
	
	# Eyes
	create_eyes(container, face_width, face_height, char_data)
	
	# Nose
	create_nose(container, face_width, face_height, char_data)
	
	# Mouth
	create_mouth(container, face_width, face_height, char_data)
	
	# Hair
	create_hair(container, face_width, face_height, char_data)
	
	# Medical accessories (stethoscope, glasses, etc.)
	create_medical_accessories(container, face_width, face_height, char_data)

func create_face_base(width: float, height: float, char_data: CharacterData) -> Control:
	"""Create base face shape"""
	
	var face_base = Panel.new()
	face_base.name = "FaceBase"
	face_base.size = Vector2(width * 0.8, height * 0.7)
	face_base.position = Vector2(width * 0.1, height * 0.15)
	
	var style = StyleBoxFlat.new()
	
	# Skin tone variation
	match char_data.character_type:
		CharacterType.SENIOR_RESIDENT:  # Asian
			style.bg_color = Color(0.96, 0.85, 0.73)
		CharacterType.NIGHT_NURSE:  # Hispanic
			style.bg_color = Color(0.85, 0.72, 0.55)
		CharacterType.ATTENDING:  # Caucasian
			style.bg_color = Color(0.98, 0.89, 0.78)
		CharacterType.MEDICAL_STUDENT:  # Korean
			style.bg_color = Color(0.95, 0.87, 0.75)
		_:
			style.bg_color = Color(0.92, 0.82, 0.70)
	
	# Face shape
	style.corner_radius_top_left = style.corner_radius_top_right = int(face_base.size.x * 0.4)
	style.corner_radius_bottom_left = style.corner_radius_bottom_right = int(face_base.size.x * 0.3)
	
	face_base.add_theme_stylebox_override("panel", style)
	
	return face_base

func create_eyes(container: Control, width: float, height: float, char_data: CharacterData):
	"""Create pixel art eyes with emotional expression"""
	
	var eye_size = Vector2(8, 6)
	var eye_y = height * 0.35
	
	# Left eye
	var left_eye = create_single_eye(Vector2(width * 0.3, eye_y), eye_size, char_data, true)
	container.add_child(left_eye)
	
	# Right eye  
	var right_eye = create_single_eye(Vector2(width * 0.6, eye_y), eye_size, char_data, false)
	container.add_child(right_eye)
	
	# Eyebrows for expression
	create_eyebrows(container, width, height, char_data)

func create_single_eye(pos: Vector2, eye_size: Vector2, char_data: CharacterData, is_left: bool) -> Control:
	"""Create individual eye with emotional state"""
	
	var eye_container = Control.new()
	eye_container.position = pos
	eye_container.size = eye_size
	
	# Eye white
	var eye_white = ColorRect.new()
	eye_white.size = eye_size
	eye_white.color = Color.WHITE
	eye_container.add_child(eye_white)
	
	# Iris
	var iris_size = Vector2(eye_size.x * 0.6, eye_size.y * 0.8)
	var iris = ColorRect.new()
	iris.size = iris_size
	iris.position = Vector2((eye_size.x - iris_size.x) / 2, (eye_size.y - iris_size.y) / 2)
	
	# Iris color based on character
	match char_data.character_type:
		CharacterType.SENIOR_RESIDENT:
			iris.color = Color(0.2, 0.1, 0.05)  # Dark brown
		CharacterType.NIGHT_NURSE:
			iris.color = Color(0.15, 0.1, 0.05)  # Dark brown
		CharacterType.ATTENDING:
			iris.color = Color(0.3, 0.5, 0.7)  # Blue
		CharacterType.MEDICAL_STUDENT:
			iris.color = Color(0.1, 0.05, 0.02)  # Very dark brown
		_:
			iris.color = Color(0.2, 0.15, 0.1)
	
	eye_container.add_child(iris)
	
	# Pupil
	var pupil_size = iris_size * 0.4
	var pupil = ColorRect.new()
	pupil.size = pupil_size
	pupil.position = Vector2((iris_size.x - pupil_size.x) / 2, (iris_size.y - pupil_size.y) / 2)
	pupil.color = Color.BLACK
	iris.add_child(pupil)
	
	# Adjust eye shape based on emotion
	apply_eye_emotion(eye_container, char_data.current_emotion)
	
	return eye_container

func apply_eye_emotion(eye_container: Control, emotion: EmotionalState):
	"""Apply emotional expression to eyes"""
	
	match emotion:
		EmotionalState.EXHAUSTED:
			# Half-closed eyes
			eye_container.scale.y = 0.6
		
		EmotionalState.STRESSED:
			# Wide eyes
			eye_container.scale = Vector2(1.2, 1.3)
		
		EmotionalState.ALERT:
			# Slightly wider
			eye_container.scale = Vector2(1.1, 1.2)
		
		EmotionalState.CONCERNED:
			# Slightly narrowed
			eye_container.scale.y = 0.8
		
		_:
			eye_container.scale = Vector2.ONE

func create_eyebrows(container: Control, width: float, height: float, char_data: CharacterData):
	"""Create expressive eyebrows"""
	
	var eyebrow_color = Color(0.3, 0.25, 0.2)  # Dark brown
	var eyebrow_y = height * 0.25
	
	# Left eyebrow
	var left_brow = ColorRect.new()
	left_brow.size = Vector2(12, 2)
	left_brow.position = Vector2(width * 0.27, eyebrow_y)
	left_brow.color = eyebrow_color
	container.add_child(left_brow)
	
	# Right eyebrow
	var right_brow = ColorRect.new()
	right_brow.size = Vector2(12, 2)
	right_brow.position = Vector2(width * 0.57, eyebrow_y)
	right_brow.color = eyebrow_color
	container.add_child(right_brow)
	
	# Adjust eyebrow angle for emotion
	apply_eyebrow_emotion(left_brow, right_brow, char_data.current_emotion)

func apply_eyebrow_emotion(left_brow: ColorRect, right_brow: ColorRect, emotion: EmotionalState):
	"""Apply emotional expression to eyebrows"""
	
	match emotion:
		EmotionalState.CONCERNED, EmotionalState.FOCUSED:
			# Furrowed brows
			left_brow.rotation = 0.2
			right_brow.rotation = -0.2
		
		EmotionalState.FRUSTRATED:
			# Angry brows
			left_brow.rotation = 0.4
			right_brow.rotation = -0.4
			left_brow.position.y -= 2
			right_brow.position.y -= 2
		
		EmotionalState.ENCOURAGING:
			# Raised brows
			left_brow.position.y -= 2
			right_brow.position.y -= 2
		
		_:
			left_brow.rotation = 0
			right_brow.rotation = 0

func create_nose(container: Control, width: float, height: float, char_data: CharacterData):
	"""Create simple pixel art nose"""
	
	var nose = ColorRect.new()
	nose.size = Vector2(2, 4)
	nose.position = Vector2(width * 0.48, height * 0.45)
	nose.color = Color(0.8, 0.7, 0.6, 0.8)  # Subtle nose shadow
	container.add_child(nose)

func create_mouth(container: Control, width: float, height: float, char_data: CharacterData):
	"""Create expressive mouth"""
	
	var mouth_y = height * 0.6
	var mouth = ColorRect.new()
	mouth.size = Vector2(8, 2)
	mouth.position = Vector2(width * 0.43, mouth_y)
	mouth.color = Color(0.6, 0.3, 0.3)  # Lip color
	container.add_child(mouth)
	
	# Adjust mouth for emotion
	apply_mouth_emotion(mouth, char_data.current_emotion)

func apply_mouth_emotion(mouth: ColorRect, emotion: EmotionalState):
	"""Apply emotional expression to mouth"""
	
	match emotion:
		EmotionalState.ENCOURAGING, EmotionalState.RELIEVED:
			# Slight smile
			mouth.size.x = 10
			mouth.position.x -= 1
			var corner_left = ColorRect.new()
			corner_left.size = Vector2(1, 1)
			corner_left.position = Vector2(-1, 0)
			corner_left.color = mouth.color
			mouth.add_child(corner_left)
			
			var corner_right = ColorRect.new()
			corner_right.size = Vector2(1, 1)
			corner_right.position = Vector2(mouth.size.x, 0)
			corner_right.color = mouth.color
			mouth.add_child(corner_right)
		
		EmotionalState.CONCERNED, EmotionalState.FOCUSED:
			# Neutral/slight frown
			mouth.size.x = 6
		
		EmotionalState.FRUSTRATED:
			# Frown
			mouth.position.y += 1
			var frown_left = ColorRect.new()
			frown_left.size = Vector2(1, 1)
			frown_left.position = Vector2(-1, -1)
			frown_left.color = mouth.color
			mouth.add_child(frown_left)
			
			var frown_right = ColorRect.new()
			frown_right.size = Vector2(1, 1)
			frown_right.position = Vector2(mouth.size.x, -1)
			frown_right.color = mouth.color
			mouth.add_child(frown_right)
		
		EmotionalState.EXHAUSTED:
			# Drooping mouth
			mouth.position.y += 2
			mouth.size.x = 6
		
		_:
			pass  # Default neutral mouth

func create_hair(container: Control, width: float, height: float, char_data: CharacterData):
	"""Create character-specific hair"""
	
	var hair_color: Color
	var hair_style: String
	
	# Define hair based on character
	match char_data.character_type:
		CharacterType.SENIOR_RESIDENT:
			hair_color = Color(0.1, 0.08, 0.05)  # Black hair
			hair_style = "short_professional"
		
		CharacterType.NIGHT_NURSE:
			hair_color = Color(0.2, 0.15, 0.1)  # Dark brown
			hair_style = "buzz_cut"
		
		CharacterType.ATTENDING:
			hair_color = Color(0.4, 0.4, 0.4)  # Graying hair
			hair_style = "receding"
		
		CharacterType.MEDICAL_STUDENT:
			hair_color = Color(0.05, 0.03, 0.02)  # Very dark
			hair_style = "messy"
		
		_:
			hair_color = Color(0.3, 0.25, 0.2)
			hair_style = "short"
	
	create_hair_style(container, width, height, hair_color, hair_style)

func create_hair_style(container: Control, width: float, height: float, hair_color: Color, style: String):
	"""Create specific hair style"""
	
	match style:
		"short_professional":
			create_short_professional_hair(container, width, height, hair_color)
		
		"buzz_cut":
			create_buzz_cut(container, width, height, hair_color)
		
		"receding":
			create_receding_hairline(container, width, height, hair_color)
		
		"messy":
			create_messy_hair(container, width, height, hair_color)
		
		_:
			create_default_hair(container, width, height, hair_color)

func create_short_professional_hair(container: Control, width: float, height: float, hair_color: Color):
	"""Create short professional hairstyle"""
	
	# Top hair
	var top_hair = ColorRect.new()
	top_hair.size = Vector2(width * 0.7, height * 0.25)
	top_hair.position = Vector2(width * 0.15, height * 0.05)
	top_hair.color = hair_color
	container.add_child(top_hair)
	
	# Side hair
	var left_side = ColorRect.new()
	left_side.size = Vector2(width * 0.15, height * 0.4)
	left_side.position = Vector2(width * 0.1, height * 0.15)
	left_side.color = hair_color
	container.add_child(left_side)
	
	var right_side = ColorRect.new()
	right_side.size = Vector2(width * 0.15, height * 0.4)
	right_side.position = Vector2(width * 0.75, height * 0.15)
	right_side.color = hair_color
	container.add_child(right_side)

func create_buzz_cut(container: Control, width: float, height: float, hair_color: Color):
	"""Create buzz cut hairstyle"""
	
	var buzz_hair = ColorRect.new()
	buzz_hair.size = Vector2(width * 0.8, height * 0.2)
	buzz_hair.position = Vector2(width * 0.1, height * 0.08)
	buzz_hair.color = Color(hair_color.r, hair_color.g, hair_color.b, 0.7)  # Shorter hair, more transparent
	container.add_child(buzz_hair)

func create_receding_hairline(container: Control, width: float, height: float, hair_color: Color):
	"""Create receding hairline"""
	
	# Side hair
	var left_hair = ColorRect.new()
	left_hair.size = Vector2(width * 0.15, height * 0.3)
	left_hair.position = Vector2(width * 0.1, height * 0.12)
	left_hair.color = hair_color
	container.add_child(left_hair)
	
	var right_hair = ColorRect.new()
	right_hair.size = Vector2(width * 0.15, height * 0.3)
	right_hair.position = Vector2(width * 0.75, height * 0.12)
	right_hair.color = hair_color
	container.add_child(right_hair)
	
	# Thinning top
	var top_hair = ColorRect.new()
	top_hair.size = Vector2(width * 0.4, height * 0.15)
	top_hair.position = Vector2(width * 0.3, height * 0.08)
	top_hair.color = Color(hair_color.r, hair_color.g, hair_color.b, 0.5)  # Thinning effect
	container.add_child(top_hair)

func create_messy_hair(container: Control, width: float, height: float, hair_color: Color):
	"""Create messy hairstyle"""
	
	# Multiple hair chunks for messy effect
	for i in range(5):
		var hair_chunk = ColorRect.new()
		hair_chunk.size = Vector2(width * 0.15 + randf() * width * 0.1, height * 0.2 + randf() * height * 0.1)
		hair_chunk.position = Vector2(
			width * 0.1 + i * width * 0.15 + randf() * width * 0.05,
			height * 0.05 + randf() * height * 0.05
		)
		hair_chunk.color = hair_color
		container.add_child(hair_chunk)

func create_default_hair(container: Control, width: float, height: float, hair_color: Color):
	"""Create default hair style"""
	
	var hair = ColorRect.new()
	hair.size = Vector2(width * 0.8, height * 0.3)
	hair.position = Vector2(width * 0.1, height * 0.05)
	hair.color = hair_color
	container.add_child(hair)

func create_medical_accessories(container: Control, width: float, height: float, char_data: CharacterData):
	"""Create medical accessories like stethoscopes, glasses"""
	
	match char_data.character_type:
		CharacterType.SENIOR_RESIDENT, CharacterType.ATTENDING:
			# Add stethoscope
			create_stethoscope_accessory(container, width, height)
		
		CharacterType.NIGHT_NURSE:
			# Add ID badge
			create_id_badge(container, width, height)
		
		CharacterType.MEDICAL_STUDENT:
			# Add nervous sweat drops when stressed
			if char_data.stress_level > 0.7:
				create_sweat_drops(container, width, height)

func create_stethoscope_accessory(container: Control, width: float, height: float):
	"""Create stethoscope around neck"""
	
	# Stethoscope tubing
	var tubing = ColorRect.new()
	tubing.size = Vector2(width * 0.6, 2)
	tubing.position = Vector2(width * 0.2, height * 0.8)
	tubing.color = MedicalColors.SHADOW_BLUE
	container.add_child(tubing)
	
	# Chest piece
	var chest_piece = ColorRect.new()
	chest_piece.size = Vector2(6, 4)
	chest_piece.position = Vector2(width * 0.3, height * 0.85)
	chest_piece.color = MedicalColors.EQUIPMENT_GRAY_DARK
	container.add_child(chest_piece)

func create_id_badge(container: Control, width: float, height: float):
	"""Create ID badge"""
	
	var badge = ColorRect.new()
	badge.size = Vector2(8, 12)
	badge.position = Vector2(width * 0.15, height * 0.6)
	badge.color = MedicalColors.CHART_PAPER
	container.add_child(badge)
	
	# Badge clip
	var clip = ColorRect.new()
	clip.size = Vector2(4, 2)
	clip.position = Vector2(2, -2)
	clip.color = MedicalColors.EQUIPMENT_GRAY
	badge.add_child(clip)

func create_sweat_drops(container: Control, width: float, height: float):
	"""Create stress sweat drops"""
	
	for i in range(2):
		var drop = ColorRect.new()
		drop.size = Vector2(2, 3)
		drop.position = Vector2(
			width * 0.2 + i * width * 0.6,
			height * 0.25 + randf() * height * 0.1
		)
		drop.color = Color(0.8, 0.9, 1.0, 0.7)  # Light blue sweat
		container.add_child(drop)

func create_character_nameplate(portrait_panel: Panel, char_data: CharacterData):
	"""Create character nameplate below portrait"""
	
	var nameplate = Panel.new()
	nameplate.name = "Nameplate"
	nameplate.size = Vector2(portrait_size.x, 20)
	nameplate.position = Vector2(0, portrait_size.y - 20)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(MedicalColors.TEXT_DARK.r, MedicalColors.TEXT_DARK.g, MedicalColors.TEXT_DARK.b, 0.8)
	nameplate.add_theme_stylebox_override("panel", style)
	
	var name_label = Label.new()
	name_label.text = char_data.name
	name_label.position = Vector2(5, 2)
	name_label.size = Vector2(nameplate.size.x - 10, nameplate.size.y - 4)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.add_theme_color_override("font_color", MedicalColors.TEXT_LIGHT)
	nameplate.add_child(name_label)
	
	portrait_panel.add_child(nameplate)

func create_stress_indicators(portrait_panel: Panel, char_data: CharacterData):
	"""Create visual stress level indicators"""
	
	if char_data.stress_level < 0.3:
		return  # No indicators for low stress
	
	# Stress indicator bar
	var stress_bar = ColorRect.new()
	stress_bar.size = Vector2(4, portrait_size.y * char_data.stress_level * 0.5)
	stress_bar.position = Vector2(portrait_size.x - 8, portrait_size.y - stress_bar.size.y - 25)
	stress_bar.color = MedicalColors.get_urgency_color(char_data.stress_level)
	portrait_panel.add_child(stress_bar)

# Public interface functions

func show_character(character_type: CharacterType):
	"""Show specific character portrait"""
	
	# Hide all characters first
	for portrait in character_portraits.values():
		portrait.visible = false
	
	# Show requested character
	if character_portraits.has(character_type):
		var portrait = character_portraits[character_type]
		portrait.visible = true
		
		# Find character data
		for char_data in [create_senior_resident(), create_night_nurse(), create_attending(), create_medical_student()]:
			if char_data.character_type == character_type:
				current_active_character = char_data
				break

func set_character_emotion(character_type: CharacterType, emotion: EmotionalState):
	"""Change character's emotional state"""
	
	if not character_portraits.has(character_type):
		return
	
	# Update character data
	for char_data in [create_senior_resident(), create_night_nurse(), create_attending(), create_medical_student()]:
		if char_data.character_type == character_type:
			char_data.current_emotion = emotion
			break
	
	# Recreate portrait with new emotion
	var old_portrait = character_portraits[character_type]
	var was_visible = old_portrait.visible
	old_portrait.queue_free()
	
	# Wait for removal
	await get_tree().process_frame
	
	# Create new portrait with updated emotion
	var char_data = null
	for data in [create_senior_resident(), create_night_nurse(), create_attending(), create_medical_student()]:
		if data.character_type == character_type:
			char_data = data
			break
	
	if char_data:
		char_data.current_emotion = emotion
		var new_portrait = create_character_portrait(char_data)
		character_portraits[character_type] = new_portrait
		portrait_container.add_child(new_portrait)
		new_portrait.visible = was_visible
		
		character_emotion_changed.emit(str(character_type), str(emotion))

func show_character_dialogue(character_type: CharacterType, dialogue_text: String = ""):
	"""Show dialogue from character"""
	
	if not character_portraits.has(character_type):
		return
	
	var char_data = null
	for data in [create_senior_resident(), create_night_nurse(), create_attending(), create_medical_student()]:
		if data.character_type == character_type:
			char_data = data
			break
	
	if not char_data:
		return
	
	# Use provided text or random from character's dialogue lines
	var text_to_show = dialogue_text
	if text_to_show == "" and char_data.dialogue_lines.size() > 0:
		text_to_show = char_data.dialogue_lines[randi() % char_data.dialogue_lines.size()]
	
	# Update dialogue panel
	dialogue_label.text = text_to_show
	name_label.text = "- " + char_data.name
	dialogue_panel.visible = true
	
	# Auto-hide after delay
	var timer = Timer.new()
	timer.wait_time = 3.0 + text_to_show.length() * 0.05
	timer.one_shot = true
	timer.timeout.connect(func(): 
		dialogue_panel.visible = false
		timer.queue_free()
	)
	add_child(timer)
	timer.start()
	
	character_dialogue_triggered.emit(str(character_type), text_to_show)

func set_character_stress_level(character_type: CharacterType, stress_level: float):
	"""Update character stress level"""
	
	var clamped_stress = clampf(stress_level, 0.0, 1.0)
	
	# Update character data and recreate portrait if needed
	for char_data in [create_senior_resident(), create_night_nurse(), create_attending(), create_medical_student()]:
		if char_data.character_type == character_type:
			if abs(char_data.stress_level - clamped_stress) > 0.2:  # Significant change
				char_data.stress_level = clamped_stress
				# Recreate portrait to show stress change
				set_character_emotion(character_type, char_data.current_emotion)
			break

func hide_all_characters():
	"""Hide all character portraits"""
	
	for portrait in character_portraits.values():
		portrait.visible = false
	
	dialogue_panel.visible = false
	current_active_character = null

func get_random_contextual_dialogue(character_type: CharacterType, context: String = "") -> String:
	"""Get contextual dialogue based on situation"""
	
	var char_data = null
	for data in [create_senior_resident(), create_night_nurse(), create_attending(), create_medical_student()]:
		if data.character_type == character_type:
			char_data = data
			break
	
	if not char_data or char_data.dialogue_lines.is_empty():
		return ""
	
	# Filter dialogue lines based on context if needed
	# For now, return random line
	return char_data.dialogue_lines[randi() % char_data.dialogue_lines.size()]
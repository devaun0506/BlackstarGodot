class_name PlaceholderAssets
extends RefCounted

## Placeholder Assets Generator for Blackstar
##
## Creates placeholder textures and visual assets for medical theming
## while real assets are being developed.

# Texture cache for performance
static var texture_cache: Dictionary = {}

static func create_coffee_stain_texture(size: Vector2i = Vector2i(32, 24)) -> ImageTexture:
	"""Create a coffee stain texture"""
	
	var cache_key = "coffee_stain_%dx%d" % [size.x, size.y]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	# Create irregular coffee stain shape
	var center = Vector2(size.x * 0.5, size.y * 0.5)
	var base_radius = min(size.x, size.y) * 0.3
	
	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			
			# Create irregular shape with noise
			var noise_factor = sin(x * 0.3) * cos(y * 0.4) * 0.3
			var adjusted_radius = base_radius + noise_factor * base_radius
			
			if dist < adjusted_radius:
				var alpha = 1.0 - (dist / adjusted_radius)
				alpha = pow(alpha, 0.7)  # Softer edges
				
				var brown = MedicalColors.COFFEE_BROWN
				image.set_pixel(x, y, Color(brown.r, brown.g, brown.b, alpha * 0.6))
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture_cache[cache_key] = texture
	
	return texture

static func create_paper_texture(size: Vector2i = Vector2i(512, 512)) -> ImageTexture:
	"""Create a paper texture for medical charts"""
	
	var cache_key = "paper_texture_%dx%d" % [size.x, size.y]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	var base_color = MedicalColors.CHART_PAPER
	
	# Add subtle texture variation
	for y in range(size.y):
		for x in range(size.x):
			var noise = (sin(x * 0.1) + cos(y * 0.15)) * 0.02
			var variation = noise + randf_range(-0.01, 0.01)
			
			var color = Color(
				clamp(base_color.r + variation, 0.0, 1.0),
				clamp(base_color.g + variation, 0.0, 1.0),
				clamp(base_color.b + variation, 0.0, 1.0),
				1.0
			)
			
			image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture_cache[cache_key] = texture
	
	return texture

static func create_medical_monitor_texture(size: Vector2i = Vector2i(64, 48)) -> ImageTexture:
	"""Create a medical monitor display texture"""
	
	var cache_key = "monitor_texture_%dx%d" % [size.x, size.y]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	# Dark background
	image.fill(Color(0.05, 0.1, 0.05, 1.0))
	
	# Add scan lines
	for y in range(0, size.y, 2):
		for x in range(size.x):
			image.set_pixel(x, y, Color(0.0, 0.15, 0.0, 1.0))
	
	# Add heart rate line simulation
	var heart_color = MedicalColors.MONITOR_GREEN
	var mid_y = size.y / 2
	
	for x in range(size.x):
		var wave = sin(x * 0.5) * 5 + sin(x * 0.1) * 2
		var y_pos = int(mid_y + wave)
		if y_pos >= 0 and y_pos < size.y:
			image.set_pixel(x, y_pos, heart_color)
			if y_pos > 0:
				image.set_pixel(x, y_pos - 1, Color(heart_color.r, heart_color.g, heart_color.b, 0.5))
			if y_pos < size.y - 1:
				image.set_pixel(x, y_pos + 1, Color(heart_color.r, heart_color.g, heart_color.b, 0.5))
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture_cache[cache_key] = texture
	
	return texture

static func create_urgency_indicator(urgency_level: float, size: Vector2i = Vector2i(16, 16)) -> ImageTexture:
	"""Create an urgency level indicator"""
	
	var cache_key = "urgency_%.1f_%dx%d" % [urgency_level, size.x, size.y]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var center = Vector2(size.x * 0.5, size.y * 0.5)
	var radius = min(size.x, size.y) * 0.4
	
	var urgency_color = MedicalColors.get_urgency_color(urgency_level)
	
	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			
			if dist < radius:
				var alpha = 1.0 - (dist / radius)
				alpha = pow(alpha, 1.5)  # More concentrated center
				
				image.set_pixel(x, y, Color(urgency_color.r, urgency_color.g, urgency_color.b, alpha))
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture_cache[cache_key] = texture
	
	return texture

static func create_equipment_panel_texture(size: Vector2i = Vector2i(128, 96)) -> ImageTexture:
	"""Create medical equipment panel texture"""
	
	var cache_key = "equipment_panel_%dx%d" % [size.x, size.y]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	# Base equipment color
	var base_color = MedicalColors.EQUIPMENT_GRAY
	image.fill(base_color)
	
	# Add panel lines
	var line_color = MedicalColors.EQUIPMENT_GRAY_DARK
	
	# Horizontal lines
	for y in [8, 16, 24, size.y - 8]:
		if y < size.y:
			for x in range(size.x):
				image.set_pixel(x, y, line_color)
	
	# Vertical lines
	for x in [16, 32, size.x - 16]:
		if x < size.x:
			for y in range(size.y):
				image.set_pixel(x, y, line_color)
	
	# Add some indicator lights
	var light_positions = [Vector2i(20, 12), Vector2i(40, 12), Vector2i(60, 12)]
	for pos in light_positions:
		if pos.x < size.x - 2 and pos.y < size.y - 2:
			var light_color = MedicalColors.MONITOR_GREEN if randf() > 0.5 else MedicalColors.MONITOR_AMBER
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if pos.x + dx >= 0 and pos.x + dx < size.x and pos.y + dy >= 0 and pos.y + dy < size.y:
						image.set_pixel(pos.x + dx, pos.y + dy, light_color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture_cache[cache_key] = texture
	
	return texture

static func create_chart_clip_texture(size: Vector2i = Vector2i(24, 32)) -> ImageTexture:
	"""Create a chart clipboard clip texture"""
	
	var cache_key = "chart_clip_%dx%d" % [size.x, size.y]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	# Metal clip color
	var metal_color = Color(0.7, 0.7, 0.75, 1.0)
	var shadow_color = Color(0.4, 0.4, 0.45, 1.0)
	
	# Create clip shape
	var clip_width = size.x * 0.6
	var clip_start_x = (size.x - clip_width) * 0.5
	
	for y in range(size.y):
		for x in range(int(clip_start_x), int(clip_start_x + clip_width)):
			if x >= 0 and x < size.x:
				var color = metal_color
				
				# Add shadow on right edge
				if x > clip_start_x + clip_width * 0.7:
					color = shadow_color
				
				image.set_pixel(x, y, color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture_cache[cache_key] = texture
	
	return texture

static func create_wear_overlay(size: Vector2i, wear_amount: float = 0.1) -> ImageTexture:
	"""Create a wear/aging overlay texture"""
	
	var cache_key = "wear_overlay_%.2f_%dx%d" % [wear_amount, size.x, size.y]
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	for y in range(size.y):
		for x in range(size.x):
			var noise = sin(x * 0.1) * cos(y * 0.1) + randf_range(-0.1, 0.1)
			var wear_alpha = clamp(noise * wear_amount, 0.0, wear_amount)
			
			var wear_color = MedicalColors.WEAR_GRAY
			image.set_pixel(x, y, Color(wear_color.r, wear_color.g, wear_color.b, wear_alpha))
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture_cache[cache_key] = texture
	
	return texture

# Utility methods
static func clear_texture_cache() -> void:
	"""Clear the texture cache to free memory"""
	texture_cache.clear()

static func get_cache_size() -> int:
	"""Get number of cached textures"""
	return texture_cache.size()
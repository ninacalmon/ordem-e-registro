extends Node2D

var mask_image: Image
var mask_texture: ImageTexture
var fading_regions = []
var fade_duration = 0.4

var dragging = false
var last_pos: Vector2

var is_cutting = false
var cutting_start_position = null

@onready var sprite: Sprite2D = self.get_parent()

func _ready():
	var texture = self.sprite.texture.get_image()

	mask_image = Image.create_empty(
		texture.get_width(),
		texture.get_height(),
		false,
		Image.FORMAT_RF
	)

	mask_image.fill(Color(1,1,1))

	self.mask_texture = ImageTexture.create_from_image(mask_image)

	self.sprite.material.set_shader_parameter(
		"mask_texture",
		self.mask_texture
	)

func _process(delta):	
	if self.fading_regions.size() == 0:
		return

	for region_data in self.fading_regions:
		region_data.time += delta
		var t = clamp(region_data.time / fade_duration, 0.0, 1.0)

		# Smooth easing (ease out cubic)
		var eased = 1.0 - pow(1.0 - t, 3.0)

		var alpha = 1.0 - eased

		for pixel in region_data.pixels:
			mask_image.set_pixel(pixel.x, pixel.y, Color(alpha,0,0))

	self.mask_texture.update(mask_image)

	# Remove finished regions
	self.fading_regions = self.fading_regions.filter(func(r):
		return r.time < fade_duration
	)


func _input(event):
	if event is InputEventMouseMotion:
		var previous_mouse = event.position - event.relative
		var current_mouse = event.position

		var previous_mouse_local_to_image = self.global_to_image_pos(previous_mouse)
		var current_mouse_local_to_image = self.global_to_image_pos(current_mouse)

		var current_inside_image: bool = self.is_aabb_overlap_with_image(current_mouse_local_to_image)
		var previous_inside_image: bool = self.is_aabb_overlap_with_image(previous_mouse_local_to_image)

		if current_inside_image and not is_cutting:
			self.is_cutting = true
		
		if self.is_cutting:
			self.draw_cut_line(previous_mouse, current_mouse, 2.0)
	
		if self.is_cutting and not current_inside_image and previous_inside_image:
			self.is_cutting = false
			self.remove_detached_regions()

	## Cut with mouse button pressed if we want
	#if event is InputEventMouseButton:
		#if event.pressed:
			#dragging = true
			#last_pos = event.position
		#else:
			#dragging = false
#
	#if event is InputEventMouseMotion and dragging:
		#draw_cut_line(last_pos, event.position, 2.0)
		#remove_detached_regions()
		#last_pos = event.position

func draw_cut_line(from_global: Vector2, to_global: Vector2, thickness: float):
	var from = self.global_to_image_pos(from_global)
	var to = self.global_to_image_pos(to_global)

	var steps = int(from.distance_to(to))
	for i in range(steps):
		var t = float(i) / steps
		var point = from.lerp(to, t)
		self.erase_circle(point, thickness)

	self.mask_texture.update(self.mask_image)

func remove_detached_regions():
	var width = self.mask_image.get_width()
	var height = self.mask_image.get_height()

	var visited = {}
	var regions = []

	for x in range(width):
		for y in range(height):
			if self.mask_image.get_pixel(x,y).r > 0.5 and not visited.has(Vector2i(x,y)):
				var region = self.flood_fill_region(Vector2i(x,y), visited)
				regions.append(region)

	if regions.size() <= 1:
		return
	
	# Find largest region
	regions.sort_custom(func(a,b): return a.size() > b.size())

	# Hide all other regions
	for i in range(1, regions.size()):
		self.fade_region(regions[i])

	self.mask_texture.update(self.mask_image)

func flood_fill_region(start: Vector2i, visited: Dictionary) -> Array:
	var stack = [start]
	var region = []

	while stack.size() > 0:
		var current = stack.pop_back()

		if visited.has(current):
			continue

		visited[current] = true

		if self.mask_image.get_pixel(current.x, current.y).r <= 0.5:
			continue

		region.append(current)

		var neighbors = [
			current + Vector2i(1,0),
			current + Vector2i(-1,0),
			current + Vector2i(0,1),
			current + Vector2i(0,-1)
		]

		for n in neighbors:
			if n.x >= 0 and n.y >= 0 and n.x < self.mask_image.get_width() and n.y < self.mask_image.get_height():
				if not visited.has(n):
					stack.append(n)

	return region

func fade_region(region: Array):
	self.fading_regions.append({
		"pixels": region,
		"time": 0.0
	})

func erase_circle(center: Vector2, radius: float):
	var min_x = int(center.x - radius)
	var max_x = int(center.x + radius)
	var min_y = int(center.y - radius)
	var max_y = int(center.y + radius)

	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			if x >= 0 and y >= 0 and x < self.mask_image.get_width() and y < self.mask_image.get_height():
				if Vector2(x,y).distance_to(center) <= radius:
					self.mask_image.set_pixel(x, y, Color(0,0,0))

func global_to_image_pos(global_pos: Vector2) -> Vector2:
	var local = self.sprite.to_local(global_pos)

	var tex_size = self.mask_image.get_size()
	var sprite_rect = self.sprite.get_rect()

	var uv = (local - sprite_rect.position) / sprite_rect.size

	return Vector2(
		uv.x * tex_size.x,
		uv.y * tex_size.y
	)
	

func is_aabb_overlap_with_image(local_to_image_position: Vector2) -> bool:
	return local_to_image_position.x >= 0 and \
		local_to_image_position.y >= 0 and \
		local_to_image_position.x < mask_image.get_width() and \
		local_to_image_position.y < mask_image.get_height()

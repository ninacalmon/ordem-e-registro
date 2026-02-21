extends Node2D
class_name CutModule

@export var focusable_module: FocusableModule
@export var image_comparison_module: ImageComparisonModule

@onready var sprite: Sprite2D = self.get_parent()

const CUT_COLOR: Color = Color(0.6, 0.6, 0.6)
const CUT_SIZE: float = 2.0

const MASK_SHOW_COLOR_VALUE: float = 1
const MASK_HIDE_COLOR_VALUE: float = 0
const FADE_DURATION: float = 0.3

var mask_image: Image
var mask_texture: ImageTexture

var fading_region_array = []

var is_cutting: bool = false
var is_selecting_cut: bool = false
var cut_path_pixel_array: Array[Vector2i] = []

func _ready():
	var texture_image = self.sprite.texture.get_image()

	self.mask_image = Image.create_empty(
		texture_image.get_width(),
		texture_image.get_height(),
		false,
		Image.FORMAT_RF
	)

	self.mask_image.fill(Color(self.MASK_SHOW_COLOR_VALUE, self.MASK_SHOW_COLOR_VALUE, self.MASK_SHOW_COLOR_VALUE))

	self.mask_texture = ImageTexture.create_from_image(self.mask_image)

	self.sprite.material.set_shader_parameter(
		"mask_texture",
		self.mask_texture
	)

func _process(delta):
	if self.fading_region_array.size() == 0:
		return

	for region_data in self.fading_region_array:
		region_data.time += delta
		var t = clamp(region_data.time / FADE_DURATION, 0.0, 1.0)

		var eased = 1.0 - pow(1.0 - t, 3.0)

		var alpha = 1.0 - eased

		for pixel in region_data.pixels:
			mask_image.set_pixel(pixel.x, pixel.y, Color(alpha,0,0))

	self.mask_texture.update(mask_image)

	self.fading_region_array = self.fading_region_array.filter(func(r):
		return r.time < FADE_DURATION
	)

func _input(event: InputEvent):
	if focusable_module && focusable_module.is_focused == false:
		return

	if event is InputEventMouseMotion:
		self.handle_mouse_motion(event)

	if event is InputEventMouseButton:
		self.handle_mouse_button(event)

func handle_mouse_motion(event: InputEventMouseMotion):
		var previous_mouse_pos = event.position - event.relative
		var current_mouse_pos = event.position
		
		var previous_mouse_info = self.compute_mouse_info(previous_mouse_pos)
		var current_mouse_info = self.compute_mouse_info(current_mouse_pos)

		var can_start_cutting: bool = current_mouse_info.is_inside_image \
		and not previous_mouse_info.is_inside_image \
		and not self.is_cutting \
		and not self.is_selecting_cut

		if can_start_cutting:
			self.is_cutting = true
		
		if self.is_cutting and not self.is_selecting_cut:
			self.draw_cut_line(previous_mouse_pos, current_mouse_pos, 1.5)
	
		if self.is_cutting and not current_mouse_info.is_inside_image and previous_mouse_info.is_inside_image:
			self.is_selecting_cut = true
			self.is_cutting = false

func handle_mouse_button(event: InputEventMouseButton):
	if self.is_selecting_cut and event.is_action_pressed("left_mouse_button"):
		var current_mouse_pos = event.position
		var current_mouse_info = self.compute_mouse_info(current_mouse_pos)

		if current_mouse_info.is_inside_image:
			var region = self.flood_fill_region(current_mouse_info.mouse_pos_local_to_image, {})
			region.append_array(self.cut_path_pixel_array)

			self.fade_region(region)
			self.cut_path_pixel_array.clear()
			self.is_selecting_cut = false

func compute_mouse_info(global_pos: Vector2) -> ImageMouseInfo:
	var mouse_info = ImageMouseInfo.new()
	var mouse_pos_local_to_image = Global.global_to_image_pos(global_pos, self.sprite, self.mask_image)

	mouse_info.mouse_pos_local_to_image = mouse_pos_local_to_image
	mouse_info.is_inside_image = self.is_mask_image_overlap(mouse_pos_local_to_image, self.mask_image)

	return mouse_info

func draw_cut_line(from_global: Vector2, to_global: Vector2, thickness: float):
	var from = Global.global_to_image_pos(from_global, self.sprite, mask_image)
	var to = Global.global_to_image_pos(to_global, self.sprite, mask_image)

	var steps = int(from.distance_to(to))
	for i in range(steps):
		var t = float(i) / steps
		var point = from.lerp(to, t)
		if not Global.is_aabb_overlap_with_image(point, mask_image):
			continue
		self.erase_circle(point, thickness)

	self.mask_texture.update(self.mask_image)

func flood_fill_region(start: Vector2i, visited: Dictionary) -> Array[Vector2i]:
	var stack = [start]
	var region: Array[Vector2i] = []

	while stack.size() > 0:
		var current = stack.pop_back()

		if visited.has(current):
			continue

		visited[current] = true
		
		## Fill on everything that is MASK_SHOW_COLOR_VALUE. Everything else should be counted as a
		## boundary, including MASK_HIDE_COLOR_VALUE and CUT_COLOR
		if self.mask_image.get_pixel(current.x, current.y).r < self.MASK_SHOW_COLOR_VALUE:
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
	self.fading_region_array.append({
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
			var position_in_image = Vector2(x, y)
			if Global.is_aabb_overlap_with_image(position_in_image, self.mask_image):
				if position_in_image.distance_to(center) <= radius:
					if self.mask_image.get_pixel(x, y).r != self.MASK_HIDE_COLOR_VALUE:
						self.mask_image.set_pixel(x, y, self.CUT_COLOR)
						self.cut_path_pixel_array.append(Vector2i(x,y))

func compare_cut_precision():
	if self.image_comparison_module == null:
		print("No image comparison on cut module")
		push_error("image_comparison_module is not assigned on %s" % self)
		return

	for x in self.mask_image.get_width():
		for y in self.mask_image.get_height():
			var mask_pixel = mask_image.get_pixel(x, y)
			## We need to compare only on the black pixels because the mask is used
			## at GPU runtime to calculate the alpha based on it (with shader).
			## Black values = 0 alpha, White values = 1 alpha.
			if mask_pixel.r != 0:
				var global_pos = Global.image_to_global_pos(Vector2(x, y), self.sprite, self.mask_image)
				self.image_comparison_module.compare_coordinates_cut(global_pos.x, global_pos.y)

func is_mask_image_overlap(local_pos: Vector2, msk_img: Image) -> bool:
	const VISIBILITY_THRESHOLD = 0.5

	var x = local_pos.x
	var y = local_pos.y
	
	if not Global.is_aabb_overlap_with_image(local_pos, msk_img):
		return false
	
	var pixel = msk_img.get_pixel(x, y)

	## Check if current pixel is white (visible, > 0.5) or black (transparent, < 0.5)
	return pixel.r > VISIBILITY_THRESHOLD

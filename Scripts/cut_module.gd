extends Node2D
class_name CutModule

@export var focusable_module: FocusableModule
@export var image_comparison_module: ImageComparisonModule

@onready var sprite: Sprite2D = self.get_parent()

const CUT_COLOR: Color = Color(0.8, 0.8, 0.8)
const CUT_THICKNESS: float = 1.5

const MASK_SHOW_COLOR_VALUE: float = 1.0
const MASK_HIDE_COLOR_VALUE: float = 0.0
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

	self.mask_image.fill(Color(self.MASK_SHOW_COLOR_VALUE, self.MASK_SHOW_COLOR_VALUE, self.MASK_SHOW_COLOR_VALUE, 1.0))

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
			if mask_image.get_pixel(pixel.x, pixel.y).r != self.MASK_HIDE_COLOR_VALUE:
				mask_image.set_pixel(pixel.x, pixel.y, Color(alpha,0,0))

	self.mask_texture.update(mask_image)

	self.fading_region_array = self.fading_region_array.filter(func(r):
		return r.time < FADE_DURATION
	)

func _input(event: InputEvent):
	if focusable_module && focusable_module.is_focused == false:
		return
	
	if event.is_action_pressed("cut_action"):
		var current_mouse_pos = get_global_mouse_position()
		var current_mouse_info = Global.compute_mouse_info(current_mouse_pos, self.sprite, self.mask_image)

		var can_start_cutting: bool = !current_mouse_info.is_inside_image \
		and not self.is_cutting \
		and not self.is_selecting_cut

		if can_start_cutting:
			self.is_cutting = true
	
	if event.is_action_pressed("select_cut"):
		if not self.is_cutting:
			self.is_selecting_cut = !self.is_selecting_cut
	
	if event is InputEventMouseMotion:
		self.handle_mouse_motion(event)

	if event is InputEventMouseButton:
		self.handle_mouse_button(event)

func handle_mouse_motion(event: InputEventMouseMotion):
		var current_mouse_pos = get_global_mouse_position()
		var previous_mouse_pos = current_mouse_pos - event.relative

		var previous_mouse_info = Global.compute_mouse_info(previous_mouse_pos, self.sprite, self.mask_image)
		var current_mouse_info = Global.compute_mouse_info(current_mouse_pos, self.sprite, self.mask_image)

		if self.is_cutting and not self.is_selecting_cut:
			self.draw_cut_line(previous_mouse_pos, current_mouse_pos, self.CUT_THICKNESS)
	
		if self.is_cutting and not current_mouse_info.is_inside_image and previous_mouse_info.is_inside_image:
			self.is_cutting = false

func handle_mouse_button(event: InputEventMouseButton):
	if self.is_selecting_cut and event.is_action_pressed("left_mouse_button"):
		var current_mouse_pos = get_global_mouse_position()
		var current_mouse_info = Global.compute_mouse_info(current_mouse_pos, self.sprite, self.mask_image)

		if current_mouse_info.is_inside_image:
			var region = self.flood_fill_region(current_mouse_info.mouse_pos_local_to_image, {})
			var has_user_selected_valid_region = region.size() > 0

			if has_user_selected_valid_region:
				region.append_array(self.cut_path_pixel_array)
				self.cut_path_pixel_array.clear()
				## Redraw frame when cut pixel array is changed
				queue_redraw()
				self.fade_region(region)
				self.is_selecting_cut = false

func draw_cut_line(from_global: Vector2, to_global: Vector2, thickness: float):
	## Using Bresenham again to draw the cut lines as well
	var from = Global.global_to_image_pos(from_global, self.sprite, mask_image.get_size())
	var to = Global.global_to_image_pos(to_global, self.sprite, mask_image.get_size())

	var current_x = int(from.x)
	var current_y = int(from.y)
	var target_x = int(to.x)
	var target_y = int(to.y)

	var delta_x = abs(target_x - current_x)
	var delta_y = abs(target_y - current_y)

	var step_x = -1 if current_x > target_x else 1
	var step_y = -1 if current_y > target_y else 1

	var error_value = delta_x - delta_y

	while true:
		var point = Vector2(current_x, current_y)

		if Global.is_aabb_overlap_with_image(point, mask_image):
			self.erase_circle(point, thickness)

		if current_x == target_x and current_y == target_y:
			break

		var doubled_error = 2 * error_value

		if doubled_error > -delta_y:
			error_value -= delta_y
			current_x += step_x

		if doubled_error < delta_x:
			error_value += delta_x
			current_y += step_y

	self.mask_texture.update(self.mask_image)


func erase_circle(center: Vector2, radius: float):
	var min_x = floor(center.x - radius)
	var max_x = ceil(center.x + radius)
	var min_y = floor(center.y - radius)
	var max_y = ceil(center.y + radius)

	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			var position_in_image = Vector2(x, y)
			if Global.is_aabb_overlap_with_image(position_in_image, self.mask_image):
				if position_in_image.distance_to(center) <= radius:
					var pixel = Vector2i(x,y)
					if self.mask_image.get_pixel(x, y).r != self.MASK_HIDE_COLOR_VALUE and not self.cut_path_pixel_array.has(pixel):
						self.mask_image.set_pixel(x, y, self.CUT_COLOR)
						self.cut_path_pixel_array.append(Vector2i(x,y))
						## Redraw frame when cut pixel array is changed
						queue_redraw()

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
		if self.mask_image.get_pixel(current.x, current.y).r < 0.90:
			continue

		region.append(current)

		var neighbors = [
			current + Vector2i(1,0),
			current + Vector2i(-1,0),
			current + Vector2i(0,1),
			current + Vector2i(0,-1),
			current + Vector2i(1,1),
			current + Vector2i(-1,-1),
			current + Vector2i(1,-1),
			current + Vector2i(-1,1)
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

func _draw():
	if cut_path_pixel_array.is_empty():
		return

	for pixel in cut_path_pixel_array:
		draw_rect(
			Rect2(Vector2(pixel.x, pixel.y), Vector2(self.CUT_THICKNESS, self.CUT_THICKNESS)),
			Color(1, 0, 0)
		)

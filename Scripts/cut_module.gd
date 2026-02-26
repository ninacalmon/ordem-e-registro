extends Node2D
class_name CutModule
signal just_removed_cut_part

@export var focusable_module: FocusableModule
@export var image_comparison_module: ImageComparisonModule
@export var sprite: Sprite2D
@export var cutting_custom_mouse_texture: CompressedTexture2D
@export var selecting_custom_mouse_texture: CompressedTexture2D

const CUT_COLOR: Color = Color(0.8, 0.8, 0.8)
const CUT_THICKNESS: float = 1.5

const MASK_SHOW_COLOR_VALUE: float = 1.0
const MASK_HIDE_COLOR_VALUE: float = 0.0
const FADE_DURATION: float = 0.3

var mask_image: Image
var mask_texture: ImageTexture
var mask_white_bounds: Rect2

var fading_region_array = []

var is_cutting: bool = false
var is_selecting_cut: bool = false
var cut_count: int = 0
var cut_path_pixel_array: Array[Vector2i] = []

var mask_debug_sprite: Sprite2D

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
	mask_debug_sprite = Sprite2D.new()
	mask_debug_sprite.texture = mask_texture
	mask_debug_sprite.global_transform = sprite.global_transform
	mask_debug_sprite.centered = sprite.centered
	mask_debug_sprite.scale = sprite.scale
	mask_debug_sprite.modulate = Color(1, 0, 0, 0.4) # vermelho semi-transparente
	#get_tree().current_scene.add_child(mask_debug_sprite)
	self.sprite.material.set_shader_parameter(
		"mask_texture",
		self.mask_texture
	)

	self.mask_white_bounds = self.get_mask_white_bounds()

func _process(delta):
	mask_debug_sprite.global_transform = sprite.global_transform
	self.handle_mouse_pointer_state()

	if self.fading_region_array.size() == 0:
		return

	var finished_regions = []

	for region_data in self.fading_region_array:
		var was_finished = region_data.time >= FADE_DURATION
		
		region_data.time += delta
		var t = clamp(region_data.time / FADE_DURATION, 0.0, 1.0)

		var eased = 1.0 - pow(1.0 - t, 3.0)

		var alpha = 1.0 - eased

		for pixel in region_data.pixels:
			if mask_image.get_pixel(pixel.x, pixel.y).r != self.MASK_HIDE_COLOR_VALUE:
				mask_image.set_pixel(pixel.x, pixel.y, Color(alpha,0,0))

		if not was_finished and region_data.time >= FADE_DURATION:
					finished_regions.append(region_data)

	self.mask_texture.update(mask_image)

	self.fading_region_array = self.fading_region_array.filter(func(r):
		return r.time < FADE_DURATION
	)

	for _region in finished_regions:
		self.mask_white_bounds = self.get_mask_white_bounds()
		self.just_removed_cut_part.emit()

func _input(event: InputEvent):
	if focusable_module && focusable_module.is_focused == false:
		self.is_cutting = false
		self.is_selecting_cut = false
		return
	
	if event.is_action_pressed("cut_action"):
		var current_mouse_pos = get_global_mouse_position()
		var current_mouse_info = Global.compute_mouse_info(current_mouse_pos, self.sprite, self.mask_image)

		var can_start_cutting: bool = !current_mouse_info.is_inside_image

		if can_start_cutting:
			self.is_cutting = !self.is_cutting
			self.is_selecting_cut = false
	
	if event.is_action_pressed("select_cut") and self.cut_count > 0:
		var current_mouse_pos = get_global_mouse_position()
		var current_mouse_info = Global.compute_mouse_info(current_mouse_pos, self.sprite, self.mask_image)
		
		if current_mouse_info.is_inside_image and self.is_cutting:
			return

		self.is_selecting_cut = !self.is_selecting_cut
		self.is_cutting = false

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
			self.cut_count += 1

func handle_mouse_button(event: InputEventMouseButton):
	if self.is_selecting_cut and event.is_action_pressed("left_mouse_button"):
		var current_mouse_pos = get_global_mouse_position()
		var current_mouse_info = Global.compute_mouse_info(current_mouse_pos, self.sprite, self.mask_image)

		if current_mouse_info.is_inside_image:
			var region = self.flood_fill_region(current_mouse_info.mouse_pos_local_to_image, {})
			region.append_array(self.cut_path_pixel_array)
			self.cut_path_pixel_array.clear()
			## Redraw frame when cut pixel array is changed
			queue_redraw()
			self.fade_region(region)

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
				#self.image_comparison_module.compare_coordinates_cut(global_pos.x, global_pos.y)

func _draw():
	if cut_path_pixel_array.is_empty():
		return

	for pixel in cut_path_pixel_array:
		## Unfortunately we need to make this conversion here because, as this is a module, the transform of the sprite
		## which is the space the cut_path_pixel_array pixels are located, is different from the CutModule transform.
		## This happens because they are siblings. So we transform sprite local space -> global local space -> cut module local space
		var global_pos = Global.image_to_global_pos(
			pixel,
			self.sprite,
			self.mask_image
		)

		var local_pos = to_local(global_pos)

		draw_rect(
			Rect2(local_pos, Vector2(self.CUT_THICKNESS, self.CUT_THICKNESS)),
			Color(1, 0, 0)
		)

func handle_mouse_pointer_state():
	if self.is_cutting:
		Global.pointer_state = Global.PointerVariations.SCISSOR
	if self.is_selecting_cut:
		Global.pointer_state = Global.PointerVariations.DELETE

func get_mask_white_bounds() -> Rect2i:
	var width = mask_image.get_width()
	var height = mask_image.get_height()

	var top = -1
	var bottom = -1
	var left = -1
	var right = -1

	# ---- TOP ----
	for y in range(height):
		for x in range(width):
			if mask_image.get_pixel(x, y).r > 0.9:
				top = y
				break
		if top != -1:
			break

	# If there is no white pixels on mask
	if top == -1:
		return Rect2(0, 0, 0, 0)

	# ---- BOTTOM ----
	for y in range(height - 1, -1, -1):
		for x in range(width):
			if mask_image.get_pixel(x, y).r > 0.9:
				bottom = y
				break
		if bottom != -1:
			break

	# ---- LEFT ----
	for x in range(width):
		for y in range(height):
			if mask_image.get_pixel(x, y).r > 0.9:
				left = x
				break
		if left != -1:
			break

	# ---- RIGHT ----
	for x in range(width - 1, -1, -1):
		for y in range(height):
			if mask_image.get_pixel(x, y).r > 0.9:
				right = x
				break
		if right != -1:
			break

	var rect_width = right - left + 1
	var rect_height = bottom - top + 1

	return Rect2(left, top, rect_width, rect_height)

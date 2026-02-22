extends Node2D

@export var drawable_canvas: DrawableCanvas
@export var draw_color: Color = Color(1, 0, 0, 1)
@export var focusable_module: FocusableModule

@onready var image: Image = drawable_canvas.image
@onready var new_texture: ImageTexture = drawable_canvas.new_texture
@onready var image_width: int = drawable_canvas.image_width
@onready var image_height: int = drawable_canvas.image_height
var drawing := false
var last_pixel: Vector2i

func _input(event):
	if focusable_module && focusable_module.is_focused == false:
		return
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_mouse_button"):
			var current_pixel = Global.global_to_image_pos(get_global_mouse_position(), self.drawable_canvas, self.drawable_canvas.texture.get_size())
			if !Global.is_aabb_overlap_with_image(current_pixel, image):
				return
			drawing = true
			last_pixel = Global.global_to_image_pos(get_global_mouse_position(), self.drawable_canvas, self.drawable_canvas.texture.get_size())
		if event.is_action_released("left_mouse_button"):
			drawing = false

	if event is InputEventMouseMotion and drawing:
		var current_pixel = Global.global_to_image_pos(get_global_mouse_position(), self.drawable_canvas, self.drawable_canvas.texture.get_size())
		draw_line_pixels(last_pixel, current_pixel)
		last_pixel = current_pixel

func draw_line_pixels(start: Vector2i, end: Vector2i):
	#Thank you mister Bresenham!!!
	var current_x = start.x
	var current_y = start.y
	var target_x = end.x
	var target_y = end.y
	
	var delta_x = abs(target_x - current_x)
	var delta_y = abs(target_y - current_y)
	
	var step_x = -1 if current_x > target_x else 1
	var step_y = -1 if current_y > target_y else 1
	
	var error_value = delta_x - delta_y
	
	while true:
		draw_pixel(current_x, current_y)
		
		if current_x == target_x and current_y == target_y:
			break
		
		var doubled_error = 2 * error_value
		
		if doubled_error > -delta_y:
			error_value -= delta_y
			current_x += step_x
			
		if doubled_error < delta_x:
			error_value += delta_x
			current_y += step_y
			
	new_texture.update(image)

func draw_pixel(x: int, y: int):
	if x >= 0 and x < image_width and y >= 0 and y < image_height:
		EventBus.new_pixel_drawn.emit(x, y, draw_color, image.get_pixel(x, y))
		image.set_pixel(x, y, draw_color)

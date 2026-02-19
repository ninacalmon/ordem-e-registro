extends Node

@export var drawable_canvas: DrawableCanvas
@export var image_width: int = 128
@export var image_height: int = 64
@export var draw_color: Color = Color(1, 0, 0, 1)

@onready var image: Image = drawable_canvas.image
@onready var new_texture: ImageTexture = drawable_canvas.new_texture
var drawing := false
var last_pixel: Vector2i

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed
			
			if drawing:
				last_pixel = get_pixel_from_mouse()

	if event is InputEventMouseMotion and drawing:
		var current_pixel = get_pixel_from_mouse()
		draw_line_pixels(last_pixel, current_pixel)
		last_pixel = current_pixel

func get_pixel_from_mouse() -> Vector2i:
	var mouse_global = get_viewport().get_mouse_position()
	var local_pos = drawable_canvas.to_local(mouse_global)
	
	var x = int(local_pos.x)
	var y = int(local_pos.y)
	
	return Vector2i(x, y)

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

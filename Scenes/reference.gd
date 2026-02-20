## TEMPORARY! REFERENCE IMAGE WILL NOT BE CREATED HERE!
extends Sprite2D
class_name Reference

@export var image_width: int = 20
@export var image_height: int = 20
@export var draw_color: Color = Color(0, 0, 0, 1)

var sprite: Sprite2D = self
var image: Image
var new_texture: ImageTexture
var drawing := false
var last_pixel: Vector2i

func _ready():
	sprite.centered = false
	image = Image.create_empty(image_width, image_height, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0.0))
	
	new_texture = ImageTexture.create_from_image(image)
	sprite.texture = new_texture
	
	sprite.scale = Vector2(5, 5)
	
	draw_even_coordinates()

func draw_even_coordinates():
	## Draw solid image v
	for x in range(image_width):
		for y in range(image_height):
			draw_pixel(x, y)

	## Draw grid layout v
	#for x in range(image_width):
		#for y in range(image_height):
			#if x % 5 == 0 or y % 5 == 0:
				#draw_pixel(x, y)
			
	new_texture.update(image)

func draw_pixel(x: int, y: int):
	if x >= 0 and x < image_width and y >= 0 and y < image_height:
		image.set_pixel(x, y, draw_color)

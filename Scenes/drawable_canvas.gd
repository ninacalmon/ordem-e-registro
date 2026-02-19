extends Sprite2D
class_name DrawableCanvas

@export var reference: Reference

@onready var image_width: int = reference.image_width
@onready var image_height: int = reference.image_height

var image: Image
var new_texture: ImageTexture

func _ready():
	self.centered = false
	image = Image.create_empty(image_width, image_height, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0.0))
	
	new_texture = ImageTexture.create_from_image(image)
	self.texture = new_texture
	
	self.scale = reference.scale

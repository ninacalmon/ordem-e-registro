## TEMPORARY! REFERENCE IMAGE WILL NOT BE CREATED HERE!
extends Sprite2D
class_name Reference

@onready var image_width: int = self.texture.get_width()
@onready var image_height: int = self.texture.get_height()
@export var reference_texture_array: Array[CompressedTexture2D]

var sprite: Sprite2D = self
var image: Image
var new_texture: ImageTexture
var drawing = false
var last_pixel: Vector2i

func _ready():
	sprite.texture = reference_texture_array.pick_random()
	sprite.centered = false
	

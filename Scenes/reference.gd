## TEMPORARY! REFERENCE IMAGE WILL NOT BE CREATED HERE!
extends Sprite2D
class_name Reference

@onready var image_width: int = self.texture.get_width()
@onready var image_height: int = self.texture.get_height()
@export var reference_texture_array: Array[CompressedTexture2D]
var bapo_signature: CompressedTexture2D = preload("res://Sprites/Signatures/Sig_bapo.png")


var sprite: Sprite2D = self
var image: Image
var new_texture: ImageTexture
var drawing = false
var last_pixel: Vector2i

func _ready():
	if Global.is_tutorial_on:
		sprite.texture = bapo_signature
	else:
		sprite.texture = reference_texture_array.pick_random()

	sprite.centered = false

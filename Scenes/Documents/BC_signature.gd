extends Sprite2D

@export var signature_texture_array: Array[CompressedTexture2D]

func _ready() -> void:
	self.texture = signature_texture_array.pick_random()

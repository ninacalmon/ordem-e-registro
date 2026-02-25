extends Node2D


@export var sprite: Sprite2D
@export var parent: Node2D

func _ready() -> void:
	EventBus.item_dropped.connect(_on_item_dropped)

## Not working properly for all kinds of overlap detection.
## Currently it works only with is_aabb_overlap_with_image =/
func _on_item_dropped(parent: Node2D, item: Node2D, custom_sprite: Sprite2D, function: Callable):
	var new_custom_sprite = custom_sprite.duplicate()

	var local_to_sprite_pos = Global.global_to_image_pos(item.global_position, self.sprite, self.sprite.texture.get_size())
	var is_overlap = function.bind(local_to_sprite_pos, self.sprite.texture.get_image()).call()

	if is_overlap: #This here works only for doc id. never use this module elsewhere. >:(
		new_custom_sprite.global_position = Global.global_to_image_pos(item.global_position, self.sprite, self.sprite.texture.get_size())
		new_custom_sprite.show()
		EventBus.document_stamped.emit()
		sprite.add_child(new_custom_sprite)

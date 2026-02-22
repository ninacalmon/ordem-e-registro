extends Node

var focus_layer = 200
var focus_time = 0.4
var is_something_focused = false

func is_aabb_overlap_with_image(local_to_image_position: Vector2, image: Image) -> bool:
	return local_to_image_position.x >= 0 and \
		local_to_image_position.y >= 0 and \
		local_to_image_position.x < image.get_width() and \
		local_to_image_position.y < image.get_height()

## This one here considers scale + rotation
func global_to_image_pos(global_pos: Vector2, sprite: Sprite2D, image: Image) -> Vector2:
	var local = sprite.get_global_transform().affine_inverse() * global_pos

	if sprite.centered:
		local += image.get_size() / 2.0

	return local.floor()
	
func image_to_global_pos(image_pos: Vector2, sprite: Sprite2D, image: Image) -> Vector2:
	var local = image_pos

	if sprite.centered:
		local -= image.get_size() / 2.0

	var global = sprite.get_global_transform() * local

	return global

func get_viewport_center() -> Vector2:
	return get_viewport().get_visible_rect().size / (Vector2.ONE * 2)

func get_sprite_center_global(sprite: Sprite2D) -> Vector2:
	return sprite.to_global(sprite.texture.get_size() * sprite.scale / 2.0)

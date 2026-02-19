extends Node

var focus_layer = 200
var focus_time = 0.4

func is_aabb_overlap_with_image(local_to_image_position: Vector2, image: Image) -> bool:
	return local_to_image_position.x >= 0 and \
		local_to_image_position.y >= 0 and \
		local_to_image_position.x < image.get_width() and \
		local_to_image_position.y < image.get_height()

func convert_global_to_node_local_pos(node_2d: Node2D) -> Vector2i:
	var mouse_global = get_viewport().get_mouse_position()
	var local_pos = node_2d.to_local(mouse_global)
	
	var x = int(local_pos.x)
	var y = int(local_pos.y)
	
	return Vector2i(x, y)

func get_viewport_center() -> Vector2:
	return get_viewport().get_visible_rect().size / (Vector2.ONE * 2)

func get_sprite_center_global(sprite: Sprite2D) -> Vector2:
	return sprite.to_global(sprite.texture.get_size() * sprite.scale / 2.0)

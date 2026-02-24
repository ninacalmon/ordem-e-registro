extends Node2D

@export var stamp: Stamp
@onready var tint_area_mask_sprite: Sprite2D = $TintAreaMaskSprite


func _input(_event: InputEvent) -> void:
	if !stamp.draggable_module.dragging:
		var local_item_pos = Global.global_to_image_pos(stamp.shadow.global_position, tint_area_mask_sprite, tint_area_mask_sprite.texture.get_size())
		if Global.is_aabb_overlap_with_image(local_item_pos, tint_area_mask_sprite.texture.get_image()):
			stamp.is_tinted = true
			var tween = get_tree().create_tween()
			tween.tween_property(stamp.bottom, "modulate", stamp.new_bottom_modulate, 0.8)

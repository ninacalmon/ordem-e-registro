extends Node

@export var focusable_module: FocusableModule

@export var sprite: Sprite2D
@export var target_node: Node2D

@onready var initial_pos: Vector2 = target_node.position
@onready var initial_scale: Vector2 = target_node.scale

@export var min_zoom: float = 1
@export var max_zoom: float = 5
@export var zoom_speed: float = 0.1

func _input(event: InputEvent) -> void:
	if focusable_module and !focusable_module.is_focused:
		target_node.position = initial_pos
		target_node.scale = initial_scale

	if event is InputEventMouseButton \
	and focusable_module.is_focused:
		var sprite_image: Image = self.sprite.texture.get_image()
		var mouse_global = get_viewport().get_mouse_position()
		var mouse_local_to_sprite = Global.global_to_image_pos(mouse_global, self.sprite, sprite_image.get_size())

		if event.button_index == MOUSE_BUTTON_WHEEL_UP \
		and Global.is_aabb_overlap_with_image(mouse_local_to_sprite, sprite_image):
			zoom_logic(1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_logic(1.0 - zoom_speed * 2)

func zoom_logic(factor: float) -> void:
	var old_scale = target_node.scale
	var new_scale = (old_scale * factor).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	
	if old_scale == new_scale: 
		return

	if new_scale == Vector2.ONE:
		var smooth_reset_tween = create_tween()
		smooth_reset_tween.tween_property(target_node, "position", initial_pos, 0.1)
		smooth_reset_tween.tween_property(target_node, "scale", Vector2.ONE, 0.1)
		return
	
	var mouse_pos = target_node.get_parent().get_local_mouse_position()
	var direction_to_mouse = target_node.position - mouse_pos
	
	var smooth_zoom_tween = create_tween()
	smooth_zoom_tween.set_ease(Tween.EASE_IN)
	
	smooth_zoom_tween.tween_property(target_node, "scale", new_scale, 0.05)
	
	var new_mouse_position =  mouse_pos + direction_to_mouse * (new_scale / old_scale)
	smooth_zoom_tween.parallel().tween_property(target_node, "position", new_mouse_position, 0.05)

	if factor < 1.0:
		target_node.position = target_node.position.lerp(initial_pos, 0.01)

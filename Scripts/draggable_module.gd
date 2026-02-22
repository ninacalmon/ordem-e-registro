extends Node2D

@export var sprite: Sprite2D
@export var target: Node2D

var dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	if target == null:
		target = get_parent()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse_button"):
		var mouse_pos: Vector2 = get_global_mouse_position()
		var mouse_info: ImageMouseInfo = Global.compute_mouse_info(
			mouse_pos,
			sprite,
			sprite.texture.get_image()
		)

		if Global.is_aabb_overlap_with_image(
			mouse_info.mouse_pos_local_to_image,
			sprite.texture.get_image()
		):
			dragging = true
			drag_offset = target.global_position - mouse_pos

	if event.is_action_released("right_mouse_button"):
		dragging = false

func _process(_delta: float) -> void:
	if dragging:
		target.global_position = get_global_mouse_position() + drag_offset

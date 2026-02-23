extends Node2D

@export var sprite: Sprite2D
@export var target: Node2D
@export var focusable_module: FocusableModule

var dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	if target == null:
		target = get_parent()

func _input(event: InputEvent) -> void:
	if Global.is_something_focused:
		return
	
	var mouse_pos: Vector2 = get_global_mouse_position()

	if event.is_action_pressed("right_mouse_button"):
		var mouse_info: ImageMouseInfo = Global.compute_mouse_info(
			mouse_pos,
			sprite,
			sprite.texture.get_image()
		)

		if Global.is_aabb_overlap_with_image(
			mouse_info.mouse_pos_local_to_image,
			sprite.texture.get_image()
		):
			## When something is on the mouse position and will be dragged
			## we set this input as handled to avoid the input event being bubbled to
			## all other nodes in the scene
			get_viewport().set_input_as_handled()
			self.dragging = true
			Global.is_something_being_dragged = true

			Global.set_current_mouse_pointer(Global.PointerVariations.DRAGGING)
			drag_offset = target.global_position - mouse_pos

	if event.is_action_released("right_mouse_button"):
		self.dragging = false
		Global.is_something_being_dragged = false

		Global.set_current_mouse_pointer(Global.PointerVariations.DEFAULT)
		if focusable_module:
			focusable_module.update_idle_transform()

	if event is InputEventMouseMotion:
		var mouse_info: ImageMouseInfo = Global.compute_mouse_info(
			mouse_pos,
			sprite,
			sprite.texture.get_image()
		)
		var is_overlap = Global.is_aabb_overlap_with_image(
			mouse_info.mouse_pos_local_to_image,
			sprite.texture.get_image()
		)

		## Ideally there will be a MAIN POINTER MANAGER how handles
		## the pointer state based on some variables such as something draggable
		## being hovered. These modules should report intent, and not change
		## the pointer directly
		if !self.dragging and !Global.is_something_being_dragged:
			if is_overlap:
				get_viewport().set_input_as_handled()
				Global.set_current_mouse_pointer(Global.PointerVariations.DRAGGABLE)

func _process(_delta: float) -> void:
	if dragging:
		var new_pos = get_global_mouse_position() + drag_offset
		
		var viewport_size = get_viewport_rect().size
		
		var margin = sprite.texture.get_size() * sprite.scale * 0.5
		
		## A little workaround to make the item go a little out of screen
		## a better option would be to calculate the camera movement and apply here
		new_pos.x = clamp(new_pos.x, -margin.x, viewport_size.x)
		new_pos.y = clamp(new_pos.y, -margin.y, viewport_size.y - margin.y)
		
		target.global_position = new_pos

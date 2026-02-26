extends Node2D
class_name DraggableModule

@export var sprite: Sprite2D
@export var target: Node2D
@export var focusable_module: FocusableModule
@export var zoom_module: ZoomModule

@onready var dragging_audio_stream_player: AudioStreamPlayer = %DraggingAudioStreamPlayer

var dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	if target == null:
		target = get_parent()

func _input(event: InputEvent) -> void:
	if Global.is_something_focused:
		return
	
	var mouse_pos: Vector2 = get_global_mouse_position()

	if event.is_action_pressed("left_mouse_button"):
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
			

			drag_offset = target.global_position - mouse_pos

	if event.is_action_released("left_mouse_button"):
		self.dragging = false

		if focusable_module:
			self.focusable_module.update_idle_transform()
		if zoom_module:
			var local_node_position = target.position
			self.zoom_module.update_initial_position(local_node_position)

func _process(_delta: float) -> void:
	if !Global.is_something_focused:
		self.handle_mouse_pointer_state()

	if dragging:
		if dragging_audio_stream_player:
			dragging_audio_stream_player.play()
		var new_pos = get_global_mouse_position() + drag_offset
		
		var viewport_size = get_viewport_rect().size
		
		var margin = sprite.texture.get_size() * sprite.scale * 0.5
		
		## A little workaround to make the item go a little out of screen
		## a better option would be to calculate the camera movement and apply here
		new_pos.x = clamp(new_pos.x, -margin.x, viewport_size.x)
		new_pos.y = clamp(new_pos.y, -margin.y, viewport_size.y - margin.y)
		
		target.global_position = new_pos

func handle_mouse_pointer_state():
	if self.dragging:
		Global.pointer_state = Global.PointerVariations.DRAGGING
	else:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var mouse_info: ImageMouseInfo = Global.compute_mouse_info(
			mouse_pos,
			sprite,
			sprite.texture.get_image()
		)
		var is_overlap = Global.is_aabb_overlap_with_image(
			mouse_info.mouse_pos_local_to_image,
			sprite.texture.get_image()
		)
		if is_overlap and Global.pointer_state != Global.PointerVariations.DRAGGING:
			Global.pointer_state = Global.PointerVariations.DRAGGABLE

extends Node2D

@export var book_spr: Sprite2D
@export var anim_player: AnimationPlayer
@export var book_page_division = 100
@export var pages_h_container: HBoxContainer
@onready var original_x_scale: float = book_spr.scale.x


var book_is_open: bool = false
var target: Node2D = self
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim):
	if book_is_open:
		pages_h_container.show()

func _input(event):
	if event is InputEventMouseButton:
		var frame_size = book_spr.texture.get_size() / Vector2(book_spr.hframes, book_spr.vframes)
		var global_mouse_pos = get_global_mouse_position()
		var pixel_in_frame = Global.global_to_image_pos(
			global_mouse_pos,
			book_spr,
			frame_size
			)
		var frame = book_spr.frame
		var column = frame % book_spr.hframes
		@warning_ignore("integer_division")
		var row = frame / book_spr.hframes
		var frame_offset = Vector2(column, row) * frame_size
		
		var atlas_pixel = pixel_in_frame + frame_offset
		var image = book_spr.texture.get_image()
		
		var is_mouse_overlapping = Global.is_mask_image_overlap_alpha(atlas_pixel, image)
		if event.is_action_pressed("left_mouse_button") \
		and is_mouse_overlapping \
		and !Global.is_something_focused:
			get_viewport().set_input_as_handled()
			if !book_is_open:
				self.anim_player.play("open")
				book_is_open = true
			elif book_is_open and get_local_mouse_position().x >= book_page_division:
				book_is_open = false
				self.book_spr.flip_h = true
				pages_h_container.hide()
				self.anim_player.play_backwards("open")
				await anim_player.animation_finished
			elif book_is_open and get_local_mouse_position().x < book_page_division:
				book_is_open = false
				self.book_spr.flip_h = false
				pages_h_container.hide()
				self.anim_player.play_backwards("open")
				await anim_player.animation_finished
				
				
		if event.is_action_pressed("right_mouse_button") \
		and is_mouse_overlapping \
		and !Global.is_something_focused:
			get_viewport().set_input_as_handled()
			dragging = true
			drag_offset = target.global_position - global_mouse_pos

		if event.is_action_released("right_mouse_button"):
			dragging = false

func _process(_delta: float) -> void:
	if dragging:
		var new_pos = get_global_mouse_position() + drag_offset
		
		var viewport_size = get_viewport_rect().size
		
		var frame_size = book_spr.texture.get_size() / Vector2(book_spr.hframes, book_spr.vframes)
		var margin = frame_size * book_spr.scale * 0.5
		
		
		## A little workaround to make the item go a little out of screen
		## a better option would be to calculate the camera movement and apply here
		new_pos.x = clamp(new_pos.x, -margin.x * 0.6, viewport_size.x)
		new_pos.y = clamp(new_pos.y, -margin.y, viewport_size.y - margin.y)
		
		target.global_position = new_pos

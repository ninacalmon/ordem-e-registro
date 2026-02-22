extends Node2D

@export var book_spr: Sprite2D
@export var anim_player: AnimationPlayer

@onready var original_x_scale: float = book_spr.scale.x

var book_is_open: bool = false

func _input(event):
	if event is InputEventMouseButton:
		var frame_size = book_spr.texture.get_size() / Vector2(book_spr.hframes, book_spr.vframes)
		
		var pixel_in_frame = Global.global_to_image_pos(
			get_global_mouse_position(),
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
			if !book_is_open:
				self.anim_player.play("open")
				book_is_open = true
			elif book_is_open and get_local_mouse_position().x >= 0:
				self.book_spr.scale.x = -original_x_scale
				self.anim_player.play_backwards("open")
				await anim_player.animation_finished
				book_is_open = false
			elif book_is_open and get_local_mouse_position().x < 0:
				self.book_spr.scale.x = original_x_scale
				self.anim_player.play_backwards("open")
				await anim_player.animation_finished
				book_is_open = false
				
#if event is InputEventMouseButton and !self.is_animation_playing:
		#var global_mouse_pos = get_global_mouse_position()
		#var current_pixel = Global.global_to_image_pos(global_mouse_pos, self.subject_spr, self.subject_image)
		#self.is_mouse_overlapping = Global.is_mask_image_overlap_alpha(current_pixel, subject_image)
		##Global.is_aabb_overlap_with_image(current_pixel, subject_image) USED TO BE THIS
#
		## Await the animation tween to finish before setting is_focused
		#if event.is_action_pressed("left_mouse_button") \
		#and is_mouse_overlapping \
		#and !is_focused \
		#and !Global.is_something_focused:
			### We need to check if something is focused only in the case of trying to focus on something else
			#await focus_on()
			#

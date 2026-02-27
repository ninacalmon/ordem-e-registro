extends Node2D
class_name FocusableModule

@export var subject_spr: Sprite2D
@export var bring_closer_scale: float = 1.3

@export var focus_on_image_texture: CompressedTexture2D
@export var focus_off_image_texture: CompressedTexture2D


@onready var subject: Node2D = self.get_parent()
@onready var subject_image: Image = subject_spr.texture.get_image()

@onready var is_mouse_overlapping: bool = false

@onready var subject_idle_rotation: float = subject.rotation
@onready var subject_idle_global_pos: Vector2 = subject.global_position
@onready var subject_idle_scale: Vector2 = subject.scale
@onready var subject_idle_z_index: int = subject.z_index
@onready var focusing_audio_stream_player: AudioStreamPlayer = %FocusingAudioStreamPlayer

var is_focused = false
var is_animation_playing = false
var focus_time = Global.focus_time
var unfocus_time = focus_time / 1.3

func _ready() -> void:
	EventBus.docs_arrived_at_final_position.connect(update_idle_transform)
	## When docs get out of scene on focus with zoom, 
	## THE DOCUMENT GETS DRAGGED OUT WITH A GIGANTIC SIZE
	## Fix that later if there is time
	EventBus.new_docs_timer_timeout.connect(focus_off)

func _input(event):
	if event is InputEventMouseButton and !self.is_animation_playing:
		var global_mouse_pos = get_global_mouse_position()
		var current_pixel = Global.global_to_image_pos(global_mouse_pos, self.subject_spr, self.subject_image.get_size())
		self.is_mouse_overlapping = Global.is_mask_image_overlap_alpha(current_pixel, subject_image)

		# Await the animation tween to finish before setting is_focused
		if event.is_action_pressed("right_mouse_button") \
		and is_mouse_overlapping \
		and !is_focused \
		and !Global.is_something_focused:
			## We need to check if something is focused only in the case of trying to focus on something else
			await focus_on()
			self.is_focused = true
			self.is_animation_playing = false
			self.change_image_texture_on_focus(self.is_focused)
		elif event.is_action_pressed("right_mouse_button") and is_focused:
			await focus_off()
			self.is_focused = false
			self.is_animation_playing = false
			self.change_image_texture_on_focus(self.is_focused)

func focus_on():
	Global.is_something_focused = true
	EventBus.focus_mode_changed.emit(subject, true)
	Global.pointer_state = Global.PointerVariations.DEFAULT
	if self.focusing_audio_stream_player:
		self.focusing_audio_stream_player.pitch_scale *= randf_range(1, 1.5)
		self.focusing_audio_stream_player.volume_db += randf_range(-3, 2)
		self.focusing_audio_stream_player.play()

	self.is_animation_playing = true
	subject.z_index = Global.focus_layer
	var center =  get_viewport().get_camera_2d().get_screen_center_position()
	var focus_tween = get_tree().create_tween()

	# unfortunately we are temporarily setting some values as the values they're going to be set later... in the tween.
	subject.rotation = 0
	subject.scale *= bring_closer_scale

	
	var sprite_rect = subject_spr.get_rect()
	var sprite_center_local = sprite_rect.size * 0.5
	var sprite_center_global = Global.image_to_global_pos(sprite_center_local, subject_spr, subject_spr.texture.get_image())

	# and then we get then back to normal after calculations have already been set, and just then, we tween it.
	# it's really sad how bad it is. i challenge you to fix it T.T
	subject.rotation = subject_idle_rotation
	subject.scale = subject_idle_scale
	
	var offset = center - sprite_center_global

	focus_tween.tween_property(subject, "global_position", subject.global_position + offset, self.focus_time)
	focus_tween.parallel().tween_property(subject, "rotation", 0, self.focus_time)
	focus_tween.tween_property(subject, "global_scale", subject_idle_scale * bring_closer_scale, self.focus_time)

	await focus_tween.finished 

func focus_off():
	self.is_animation_playing = true
	
	Global.pointer_state = Global.PointerVariations.DEFAULT

	subject.z_index = subject_idle_z_index
	var focus_tween = get_tree().create_tween()
	focus_tween.tween_property(subject, "global_position", subject_idle_global_pos, self.unfocus_time)
	focus_tween.parallel().tween_property(subject, "rotation", subject_idle_rotation, self.unfocus_time)
	focus_tween.parallel().tween_property(subject, "global_scale", subject_idle_scale, self.unfocus_time)

	await focus_tween.finished

	EventBus.focus_mode_changed.emit(subject, false)
	Global.is_something_focused = false

func change_image_texture_on_focus(focus_enabled: bool):
	if focus_enabled && self.focus_on_image_texture != null:
		self.subject_spr.texture = self.focus_on_image_texture

	if !focus_enabled && self.focus_off_image_texture != null:
		self.subject_spr.texture = self.focus_off_image_texture

func update_idle_transform():
	self.subject_idle_rotation = subject.rotation
	self.subject_idle_global_pos = subject.global_position
	self.subject_idle_scale = subject.scale

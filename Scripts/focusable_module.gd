extends Node
class_name FocusableModule

@export var subject_spr: Sprite2D
@export var bring_closer_scale: float = 1.3

@onready var subject: Node2D = self.get_parent()
@onready var subject_image: Image = subject_spr.texture.get_image()

@onready var is_mouse_overlapping: bool = false

@onready var subject_idle_rotation: float = subject.rotation
@onready var subject_idle_global_pos: Vector2 = subject.global_position
@onready var subject_idle_scale: Vector2 = subject.scale
@onready var subject_idle_z_index: int = subject.z_index

var is_focused = false
var focus_time = Global.focus_time
var unfocus_time = focus_time / 1.3

func _input(event):
	if event is InputEventMouseButton:
		var current_pixel = Global.convert_global_to_node_local_pos(subject_spr)
		self.is_mouse_overlapping = Global.is_aabb_overlap_with_image(current_pixel, subject_image)
		if event.is_action_pressed("left_mouse_button") and is_mouse_overlapping and !is_focused:
			focus_on()
			is_focused = true
		elif event.is_action_pressed("left_mouse_button") and !is_mouse_overlapping and is_focused:
			focus_off()
			is_focused = false

func focus_on():
	EventBus.focus_mode_changed.emit(subject, true)
	subject.z_index = Global.focus_layer
	var center = Global.get_viewport_center()
	var focus_tween = get_tree().create_tween()

	# unfortunatly we are temporarily setting some values as the values they're going to be set later... in the tween.
	subject.rotation = 0
	subject.scale *= bring_closer_scale

	var sprite_rect = subject_spr.get_rect()
	var sprite_center_local = sprite_rect.position + sprite_rect.size / 2.0
	var sprite_center_global = subject_spr.get_global_transform() * sprite_center_local

	# and then we get then back to normal after calculations have already been set, and just then, we tween it.
	# it's really sad how bad it is. i challenge you to fix it T.T
	subject.rotation = subject_idle_rotation
	subject.scale = subject_idle_scale
	
	var offset = center - sprite_center_global

	focus_tween.tween_property(subject, "global_position", subject.global_position + offset, self.focus_time)
	focus_tween.parallel().tween_property(subject, "rotation", 0, self.focus_time)
	focus_tween.tween_property(subject, "global_scale", subject_idle_scale * bring_closer_scale, self.focus_time)

func focus_off():
	EventBus.focus_mode_changed.emit(subject, false)
	subject.z_index = subject_idle_z_index
	var focus_tween = get_tree().create_tween()
	focus_tween.tween_property(subject, "global_position", subject_idle_global_pos, self.unfocus_time)
	focus_tween.parallel().tween_property(subject, "rotation", subject_idle_rotation, self.unfocus_time)
	focus_tween.parallel().tween_property(subject, "global_scale", subject_idle_scale, self.unfocus_time)
	self.is_focused = false

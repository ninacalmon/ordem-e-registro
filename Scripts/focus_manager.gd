extends Node

@onready var blurred_layer: CanvasLayer = $BlurredLayer
@onready var blur_rect: ColorRect = %BlurRect
@onready var dark_rect: ColorRect = %DarkRect

@onready var blur_rect_material: ShaderMaterial = blur_rect.material

var original_parent: Node
var original_index: int

var focus_time = Global.focus_time
var unfocus_time = focus_time / 1.5

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)

func _on_focus_mode_changed(subject: Node2D, enabled: bool):
	if enabled:
		original_parent = subject.get_parent()
		original_index = subject.get_index()
		subject.reparent(blurred_layer)
		var blur_tween = get_tree().create_tween()
		blur_tween.tween_property(blur_rect_material, "shader_parameter/blur_amount", 4, self.focus_time)
		blur_tween.parallel().tween_property(dark_rect, "modulate", Color(1, 1, 1, 1), self.focus_time)
	else:
		if subject.get_parent() == blurred_layer:
			var unblur_tween = get_tree().create_tween()
			unblur_tween.tween_property(blur_rect_material, "shader_parameter/blur_amount", 0, self.unfocus_time)
			unblur_tween.parallel().tween_property(dark_rect, "modulate", Color(0, 0, 0, 0), self.unfocus_time)
			subject.reparent(original_parent)
			original_parent.move_child(subject, original_index)

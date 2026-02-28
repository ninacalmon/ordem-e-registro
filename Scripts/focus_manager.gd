extends Node


@onready var blur_rect: ColorRect = %BlurRect
@onready var blur_rect_material: ShaderMaterial = blur_rect.material


var original_parent: Node
var original_index: int

var blur_lighning: Node2D
var focus_time = Global.focus_time * 1.5
var unfocus_time = focus_time / 1.5

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)

func _on_focus_mode_changed(subject: Node2D, enabled: bool):
	if enabled:
		var blur_tween = get_tree().create_tween()
		blur_tween.tween_property(blur_rect_material, "shader_parameter/blur_amount", 4, self.focus_time)
	
	else:
		var unblur_tween = get_tree().create_tween()
		unblur_tween.tween_property(blur_rect_material, "shader_parameter/blur_amount", 0, self.unfocus_time)
			

extends Node2D
class_name Stamp

@export var draggable_module: DraggableModule

@onready var stamp: Sprite2D = $Stamp
@onready var stamp_mark: Sprite2D = $StampMark
@onready var shadow: Sprite2D = $Shadow
@onready var bottom: Sprite2D = $Stamp/Bottom

var is_tinted: bool = false
var has_emitted: bool = true
var original_bottom_modulate: Color = Color(0.294, 0.224, 0.184)
var new_bottom_modulate: Color = Color(0.482, 0.029, 0.029, 1.0)

func _input(_event: InputEvent) -> void:
	if !draggable_module.dragging:
		stamp.position.y = 0
		if has_emitted == false and is_tinted == true:
			#Randomizing Stamp Mark
			stamp_mark.rotation_degrees = randi_range(-40, 40)
			stamp_mark.modulate.a = randf_range(0.3, 0.6)
			EventBus.item_dropped.emit(self, shadow, stamp_mark, Global.is_aabb_overlap_with_image)
			has_emitted = true
			var tween = get_tree().create_tween()
			tween.tween_property(bottom, "modulate", original_bottom_modulate, 0.5)
			is_tinted = false
	else: 
		stamp.position.y = -30
		has_emitted = false
	#if is_tinted == true:
		#bottom.modulate = 

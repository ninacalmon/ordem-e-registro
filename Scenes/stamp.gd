extends Node2D
class_name Stamp

@export var draggable_module: DraggableModule

@onready var stamp: Sprite2D = $Stamp
@onready var stamp_mark: Sprite2D = $StampMark
@onready var shadow: Sprite2D = $Shadow
@onready var bottom: Sprite2D = $Stamp/Bottom
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var initial_volume = audio_stream_player.volume_db
@onready var initial_pitch = audio_stream_player.pitch_scale

var is_tinted: bool = false
var has_emitted: bool = false
var original_bottom_modulate: Color = Color(0.294, 0.224, 0.184)
var new_bottom_modulate: Color = Color(0.482, 0.029, 0.029, 1.0)

func _input(_event: InputEvent) -> void:
	if draggable_module.dragging:
		self.has_emitted = true

	if !draggable_module.dragging and self.has_emitted:
		stamp.position.y = 0
		if !is_tinted:
			audio_stream_player.volume_db = initial_volume + randf_range(-13, -9)
			audio_stream_player.pitch_scale = randf_range(0.8, 1.6)
			audio_stream_player.play()
		
		if is_tinted:
			audio_stream_player.volume_db = initial_volume + randf_range(-3, 4)
			audio_stream_player.pitch_scale = randf_range(0.8, 1.6)
			audio_stream_player.play()
			#Randomizing Stamp Mark
			stamp_mark.rotation_degrees = randi_range(-40, 40)
			stamp_mark.modulate.a = randf_range(0.3, 0.6)
			EventBus.item_dropped.emit(self, shadow, stamp_mark, Global.is_aabb_overlap_with_image)
			has_emitted = true
			var tween = get_tree().create_tween()
			tween.tween_property(bottom, "modulate", original_bottom_modulate, 0.5)
			is_tinted = false

		self.has_emitted = false
	elif draggable_module.dragging: 
		stamp.position.y = -30
	#if is_tinted == true:
		#bottom.modulate = 

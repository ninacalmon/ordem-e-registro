extends Node
class_name camera_shake

var camera: Camera2D
var threshold = 0.01
var shake_strength
var shake_decay
var rng = RandomNumberGenerator.new()
var base_position: Vector2

func _ready() -> void:
	randomize()

func set_camera(cmr: Camera2D):
	camera = cmr
	base_position = camera.position

func apply_shake(shake_str: float, shake_dcay: float):
	self.shake_strength = shake_str
	self.shake_decay = shake_dcay

func _process(delta: float):
	if shake_strength and shake_strength > 0 and shake_decay and shake_decay > 0 and camera:
		camera.position = base_position + get_random_offset()
		var decay = 1.0 - pow(threshold, delta / shake_decay)
		shake_strength = lerpf(shake_strength, 0.0, decay)

		if shake_strength <= 0.05:
			shake_strength = 0.0
			camera.position = base_position

func get_random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)

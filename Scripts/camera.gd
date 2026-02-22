extends Camera2D

@export var min_offset: int = -200
@export var max_offset: int = 200
@export var border_size: int = 200

var is_focused: bool = false

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)

func _on_focus_mode_changed(_subject, focus_enabled):
	self.is_focused = focus_enabled

func _process(_delta):
	if is_focused:
		return
	
	var screen_center = get_screen_center_position()
	var mouse_offset = get_global_mouse_position() - screen_center
	
	var new_offset = mouse_offset * 0.1
	new_offset.x = clamp(new_offset.x, min_offset, max_offset)
	new_offset.y = clamp(new_offset.y, min_offset, max_offset)

	offset = offset.lerp(new_offset, 0.1)

extends Camera2D

var is_focused: bool = false
var camera_2d: Camera2D
var viewport_size: Vector2

@export var min_offset: int = -200
@export var max_offset: int = 200
@export var border_size: int = 200

var desired_zoom: Vector2
@export var zoom_amount: float = 0.1
@export var max_zoom: float = 3
@export var min_zoom: float = 0.6
@export var mouse_dependent: bool = false

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)
	viewport_size = get_viewport().size
	camera_2d = self

func _on_focus_mode_changed(_subject, focus_enabled):
	self.is_focused = focus_enabled

func _process(_delta):
	if is_focused:
		return
	
	var mouse_offset = camera_2d.get_global_mouse_position() - camera_2d.global_position
	var new_offset = mouse_offset * 0.1
	new_offset.x = clamp(new_offset.x, min_offset, max_offset)
	new_offset.y = clamp(new_offset.y, min_offset, max_offset)

	camera_2d.offset = camera_2d.offset.lerp(new_offset, 0.1)

#func _input(event: InputEvent) -> void:
	#if !is_focused:
		#return
		#
	#if event is InputEventMouseButton and event.is_action_pressed("mouse_wheel_up"):
		#print('up')
		#handle_camera_zoom(zoom_amount)
	#elif event is InputEventMouseButton and event.is_action_pressed("mouse_wheel_down"):
		#print('down')
		#handle_camera_zoom(-zoom_amount)
#
#func handle_camera_zoom(amount):
	#var mouse_pos_before = camera_2d.get_global_mouse_position()
#
	#desired_zoom = camera_2d.zoom + Vector2(amount, amount)
	#desired_zoom.x = clamp(desired_zoom.x, min_zoom, max_zoom)
	#desired_zoom.y = clamp(desired_zoom.y, min_zoom, max_zoom)
	#camera_2d.zoom = desired_zoom
	#var mouse_pos_after = camera_2d.get_global_mouse_position()
	#camera_2d.global_position += mouse_pos_before - mouse_pos_after

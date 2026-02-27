extends Node

@onready var paused_overlay: Control = %PausedOverlay
@onready var dark_overlay: ColorRect = %DarkOverlay
@onready var restart_overlay: Control = %RestartOverlay

var blur_time = Global.focus_time * 1.5
var unblur_time = blur_time / 1.5
var is_player_dead: bool = false

func _ready() -> void:
	EventBus.player_death.connect(_on_player_death)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		var is_pausing = !paused_overlay.visible
		paused_overlay.visible = is_pausing
		
		var tween = get_tree().create_tween()
		if is_pausing:
			tween.tween_property(dark_overlay.material, "shader_parameter/blur_amount", 3, self.blur_time)
			await tween.finished
			get_tree().paused = true
		else:
			get_tree().paused = false
			tween.tween_property(dark_overlay.material, "shader_parameter/blur_amount", 0, self.unblur_time)
	
	if Input.is_action_just_pressed("restart") and is_player_dead == true:
			get_tree().paused = false
			get_tree().reload_current_scene()
			restart_overlay.hide()
			
func _on_player_death() -> void:
	is_player_dead = true
	get_tree().paused = true
	restart_overlay.show()

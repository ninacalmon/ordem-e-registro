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
	if Input.is_action_just_pressed("ui_cancel") and not is_player_dead:
		_toggle_pause()

	if Input.is_action_just_pressed("restart") and is_player_dead:
		_restart_game()


func _toggle_pause():
	var should_pause = not get_tree().paused
	
	get_tree().paused = should_pause
	paused_overlay.visible = should_pause
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	if should_pause:
		tween.tween_property(
			dark_overlay.material,
			"shader_parameter/blur_amount",
			3.0,
			blur_time
		)
	else:
		tween.tween_property(
			dark_overlay.material,
			"shader_parameter/blur_amount",
			0.0,
			unblur_time
		)

func _on_player_death() -> void:
	is_player_dead = true
	get_tree().paused = true
	restart_overlay.show()

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		dark_overlay.material,
		"shader_parameter/blur_amount",
		3.0,
		blur_time
	)

func _restart_game():
	get_tree().paused = false
	is_player_dead = false
	restart_overlay.hide()
	Global.reset()

	get_tree().reload_current_scene()

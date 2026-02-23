extends Button

func _ready() -> void:
	self.pressed.connect(on_start_button_pressed)
	
func on_start_button_pressed():
	LevelTransition.change_scene_to("res://Scenes/game.tscn")

extends Button

func _ready() -> void:
	self.pressed.connect(on_exit_button_pressed)

func on_exit_button_pressed():
	get_tree().quit()

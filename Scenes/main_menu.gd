extends Button

func _ready() -> void:
	self.pressed.connect(on_main_menu_button_pressed)
	
func on_main_menu_button_pressed():
	var tree = get_tree()
	tree.paused = false
	Global.pointer_state = Global.PointerVariations.DEFAULT
	Global.reset()

	tree.change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

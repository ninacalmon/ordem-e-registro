extends LineEdit

@export var focusable_module: FocusableModule

func _process(delta: float) -> void:
	if !self.focusable_module.is_focused:
		self.hide()
		return
	
	self.show()

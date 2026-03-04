extends Node2D

var current_state: Global.PointerVariations = Global.PointerVariations.DEFAULT

func _process(_delta):
	var next_state: Global.PointerVariations

	match Global.pointer_state:
		Global.PointerVariations.DRAGGING:
			next_state = Global.PointerVariations.DRAGGING
		Global.PointerVariations.DRAGGABLE:
			next_state = Global.PointerVariations.DRAGGABLE
		Global.PointerVariations.SCISSOR:
			next_state = Global.PointerVariations.SCISSOR
		Global.PointerVariations.DELETE:
			next_state = Global.PointerVariations.DELETE
		Global.PointerVariations.PEN:
			next_state = Global.PointerVariations.PEN
		_:
			next_state = Global.PointerVariations.DEFAULT

	if next_state != current_state:
		current_state = next_state
		Global.set_current_mouse_pointer(current_state)

	Global.pointer_state = Global.PointerVariations.DEFAULT

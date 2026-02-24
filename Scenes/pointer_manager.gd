extends Node2D

func _process(_delta):
	var next_state: Global.PointerVariations = Global.PointerVariations.DEFAULT
	print("NEXT STATEEEE ", next_state)
	match Global.pointer_state:
		Global.PointerVariations.DRAGGING:
			next_state = Global.PointerVariations.DRAGGING
		Global.PointerVariations.DRAGGABLE:
			next_state = Global.PointerVariations.DRAGGABLE
		Global.PointerVariations.SCISSOR:
			next_state = Global.PointerVariations.SCISSOR
		Global.PointerVariations.DELETE:
			next_state = Global.PointerVariations.DELETE

	Global.set_current_mouse_pointer(next_state)

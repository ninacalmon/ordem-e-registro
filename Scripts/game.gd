extends Node2D

@export var cut_module: CutModule

func _process(_delta: float):
	if Input.is_action_just_pressed("ui_accept"):
		self.cut_module.compare_cut_precision()

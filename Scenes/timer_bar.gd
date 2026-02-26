extends TextureProgressBar

@onready var new_docs_timer: Timer = %NewDocsTimer

func _process(_delta: float) -> void:
	self.max_value = new_docs_timer.wait_time
	value = new_docs_timer.time_left

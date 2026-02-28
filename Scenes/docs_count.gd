extends RichTextLabel

func _ready() -> void:
	text = str(Global.docs_correctly_stamped)
	EventBus.new_docs_timer_timeout.connect(_on_new_docs_timer_timeout)

func _on_new_docs_timer_timeout():
	text = str(Global.docs_correctly_stamped)

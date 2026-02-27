extends RichTextLabel

func _ready() -> void:
	EventBus.player_death.connect(_on_player_death)

func _on_player_death():
	self.text = "Você registrou %s documentos corretamente." % Global.docs_correctly_stamped

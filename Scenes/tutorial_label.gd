extends RichTextLabel

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)

func _on_focus_mode_changed(subject: Node2D, enabled: bool):
	if Global.is_tutorial_on and enabled:
		match get_node_group_type(subject):
			"Id":
				id_tutorial()
			"BirthCertificate":
				birth_certificate_tutorial()
			"PhotoToCut":
				photo_to_cut_tutorial()
			_:
				print("Grupo desconhecido")

func id_tutorial():
	self.text = "Este é o [b][color=000000]Registro de Identificação[/color][/b], o documento que você deve preencher. Preencha os dados pessoais, código civil (vide o livro em caso de dúvidas), cole a foto, assine e, por fim, carimbe para enviar."

func birth_certificate_tutorial():
	self.text = "Esta é a certidão de nascimento. O principal documento que te guiará no processo de preenchimento do [b][color=000000]Registro de Identificação[/color][/b]. "

func photo_to_cut_tutorial():
	self.text = "Esta é a foto do cliente. Corte-a com sua tesoura e remova as partes indesejadas para colá-la no [b][color=000000]Registro de Identificação[/color][/b]. É imprescindível que a foto mostre o rosto do sujeito para otimização do controle [b][color=000000]Estatal.[/color][/b]"

func get_node_group_type(subject: Node) -> String:
	if subject.is_in_group("t_IdGroup"):
		return "Id"
	if subject.is_in_group("t_BirthCertificateGroup"):
		return "BirthCertificate"
	if subject.is_in_group("t_PhotoToCutGroup"):
		return "PhotoToCut"
	return "unknown"

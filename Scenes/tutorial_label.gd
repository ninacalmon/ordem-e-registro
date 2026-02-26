extends RichTextLabel

var default_text: String

var id_tutorial_complete: bool = false
var birth_control_tutorial_complete: bool = false
var photo_tutorial_complete: bool = false

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)
	default_text = "sei la o que lore"
	self.text = default_text

func _process(delta: float) -> void:
	self.visible = Global.is_tutorial_on
	if id_tutorial_complete and birth_control_tutorial_complete and photo_tutorial_complete:
		default_text = "texto final teste"

func _on_focus_mode_changed(subject: Node2D, enabled: bool):
	if !enabled:
		self.text = default_text
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
	id_tutorial_complete = true

func birth_certificate_tutorial():
	self.text = "Esta é a certidão de nascimento. O principal documento que te guiará no processo de preenchimento do [b][color=000000]Registro de Identificação[/color][/b]. "
	birth_control_tutorial_complete = true

func photo_to_cut_tutorial():
	self.text = "Esta é a foto do cliente. Corte-a com sua tesoura e remova as partes indesejadas para colá-la no [b][color=000000]Registro de Identificação[/color][/b]. É imprescindível que a foto mostre o rosto do sujeito para otimização do controle [b][color=000000]Estatal.[/color][/b]"
	photo_tutorial_complete = true

func get_node_group_type(subject: Node) -> String:
	if subject.is_in_group("t_IdGroup"):
		return "Id"
	if subject.is_in_group("t_BirthCertificateGroup"):
		return "BirthCertificate"
	if subject.is_in_group("t_PhotoToCutGroup"):
		return "PhotoToCut"
	return "unknown"

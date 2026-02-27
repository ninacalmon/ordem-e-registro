extends RichTextLabel

var default_text: String

var id_tutorial_complete: bool = false
var birth_control_tutorial_complete: bool = false
var photo_tutorial_complete: bool = false

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)
	default_text = "Você foi designado ao [b][color=000000]Cartório Nacional do Novo Estado Bósnio-Brasiliense[/color][/b]. Sua função consiste no preenchimento e na validação do [b][color=000000]Registro de Identificação[/color][/b] da população. 
Em decorrência do recente 'desaparecimento' dos antigos funcionários, suas funções foram imediatamente transferidas a este posto. É de suma importância que [b][color=000000]ninguém[/color][/b] tenha conhecimento do ocorrido; portanto, durante os procedimentos, você deverá reproduzir as assinaturas dos registradores anteriores conforme os padrões arquivados.
Fique à vontade para conferir os documentos sobre sua mesa."
	self.text = default_text

func _process(delta: float) -> void:
	self.visible = Global.is_tutorial_on
	if id_tutorial_complete and birth_control_tutorial_complete and photo_tutorial_complete:
		default_text = "[b][color=000000]Ao final do preenchimento[/color][/b], você deverá carimbar o documento para submetê-lo à análise. Certifique-se da exatidão das informações, pois, caso seu desempenho esteja abaixo do esperado, resultará em realocação imediata para um de nossos [b][color=000000]Centros de Readequação[/color][/b].
Ademais, fique atento: o [b][color=000000]tempo[/color][/b] para o preenchimento de cada registro poderá tornar-se mais [b][color=000000]curto[/color][/b] à medida que nos aproximamos do horário de pico.
Boa sorte. [b][color=000000]Não nos decepcione.[/color][/b]"

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
	#self.text = "Este é o [b][color=000000]Registro de Identificação[/color][/b], o documento que você deve preencher. Preencha os dados pessoais, código civil (vide o livro em caso de dúvidas), cole a foto, assine e, por fim, carimbe para enviar."
	self.text = "Este é o [b][color=000000]Registro de Identificação[/color][/b]. Preencha os dados pessoais e o código civil (vide o livro em caso de dúvidas), cole a foto, reproduza a assinatura e, por fim, carimbe-o para envio."
	id_tutorial_complete = true

func birth_certificate_tutorial():
	#self.text = "Esta é a certidão de nascimento. O principal documento que te guiará no processo de preenchimento do [b][color=000000]Registro de Identificação[/color][/b]. "
	self.text = "Esta é a certidão de nascimento. Trata-se do documento primário para a formalização do [b][color=000000]Registro de Identificação.[/color][/b] Utilize-o como única referência autorizada."
	birth_control_tutorial_complete = true

func photo_to_cut_tutorial():
	#self.text = "Esta é a foto do cliente. Corte-a com sua tesoura e remova as partes indesejadas para colá-la no [b][color=000000]Registro de Identificação[/color][/b]. É imprescindível que a foto mostre o rosto do sujeito para otimização do controle [b][color=000000]Estatal.[/color][/b]"
	self.text = "Esta é a fotografia do indivíduo. Corte-a com sua tesoura, remova quaisquer partes indesejadas e fixe-a no [b][color=000000]Registro de Identificação[/color][/b]. É imprescindível que a foto mostre o rosto do sujeito para a otimização do controle [b][color=000000]Estatal[/color][/b]."
	photo_tutorial_complete = true

func get_node_group_type(subject: Node) -> String:
	if subject.is_in_group("t_IdGroup"):
		return "Id"
	if subject.is_in_group("t_BirthCertificateGroup"):
		return "BirthCertificate"
	if subject.is_in_group("t_PhotoToCutGroup"):
		return "PhotoToCut"
	return "unknown"

extends RichTextLabel

var tutorial_complete = {
	"intro_text": false,
	"id": false,
	"birth": false,
	"photo": false
}

var is_typing = false
var current_typing_session_id = 0
var skip_requested = false

var sound_timer = 0.0

@export var typing_speed: float = 0.02
@export var typing_sound_rate: float = 0.05

@onready var tutorial_audio: AudioStreamPlayer = %TutorialAudioStreamPlayer
@onready var type_sound: AudioStreamPlayer = %TypeSoundPlayer

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)

	self.visible = true
	await self.intro_text()

func _gui_input(event):
	if event.is_action_pressed("left_mouse_button"):
		if self.is_typing:
			self.skip_requested = true
		else:
			clear_text()

func show_text(content: String, typing_session: int = 0) -> void:
	self.visible = true

	## Maintain a reference to the session id when some typing session starts
	var typing_session_id
	if typing_session == 0:
		self.current_typing_session_id += 1
		typing_session_id = self.current_typing_session_id
	else:
		typing_session_id = typing_session
	
	await type_text(content, typing_session_id)


func clear_text() -> void:
	self.is_typing = false
	self.skip_requested = false
	text = ""
	self.visible_characters = 0
	self.visible = false

func type_text(content: String, typing_session: int) -> void:
	self.skip_requested = false
	self.is_typing = true
	sound_timer = 0.0

	self.text = content
	self.visible_characters = 0

	var total_char_count = get_total_character_count()
	for i in range(total_char_count):
		## If the class typing session is not the typing session we received at the start of the method, 
		## then we break the loop. Not the best but ok
		if typing_session != self.current_typing_session_id:
			break
		
		if self.skip_requested:
			self.visible_characters = total_char_count
			break

		self.visible_characters += 1

		if sound_timer <= 0.0:
			type_sound.play()
			sound_timer = typing_sound_rate

		await get_tree().create_timer(typing_speed).timeout
		sound_timer -= typing_speed
	
	if self.visible_characters == total_char_count:
		self.is_typing = false

func _on_focus_mode_changed(subject: Node2D, enabled: bool) -> void:
	self.current_typing_session_id += 1

	if not Global.is_tutorial_on:
		return

	if not enabled:
		clear_text()
		if !tutorial_complete["intro_text"]:
			intro_text()
		
		if all_tutorials_complete():
			tutorial_audio.play()
			await show_text(get_final_text())

		return

	match get_node_group_type(subject):
		"id":
			self.play_id_tutorial()
		"birth":
			self.play_birth_tutorial()
		"photo":
			self.play_photo_tutorial()


func play_id_tutorial() -> void:
	clear_text()
	tutorial_complete["id"] = true
	tutorial_audio.play()
	show_text("Este é o [b][color=000000]Registro de Identificação[/color][/b]. Preencha os dados pessoais e o código civil. A leitura completa do livro é essencial para a composição do código. Cole a foto, reproduza a assinatura e, por fim, carimbe-o para envio.")


func play_birth_tutorial() -> void:
	clear_text()
	tutorial_complete["birth"] = true
	tutorial_audio.play()
	show_text("Esta é a certidão de nascimento. Trata-se do documento primário para a formalização do [b][color=000000]Registro de Identificação.[/color][/b] Utilize-o como única referência autorizada.")


func play_photo_tutorial() -> void:
	clear_text()
	tutorial_complete["photo"] = true
	tutorial_audio.play()
	show_text("Esta é a fotografia do indivíduo. Corte-a com sua tesoura, remova quaisquer partes indesejadas e fixe-a no [b][color=000000]Registro de Identificação[/color][/b]. É imprescindível que a foto mostre o rosto do sujeito para a otimização do controle [b][color=000000]Estatal[/color][/b].")

func intro_text():
	self.current_typing_session_id += 1
	var typing_session_id = self.current_typing_session_id
	await show_text(
		"Você foi designado ao [b][color=000000]Cartório Nacional do Novo Estado Bósnio-Braziliense[/color][/b]. Sua função consiste no preenchimento e na validação do [b][color=000000]Registro de Identificação[/color][/b] da população.\nEm decorrência do recente 'desaparecimento' dos antigos funcionários, suas funções foram imediatamente transferidas a este posto. É de suma importância que [b][color=000000]ninguém[/color][/b] tenha conhecimento do ocorrido; portanto, durante os procedimentos, você deverá reproduzir as assinaturas dos registradores anteriores conforme os padrões arquivados.\nFique à vontade para conferir os documentos sobre sua mesa.",
		typing_session_id
	)

	if typing_session_id == self.current_typing_session_id:
		tutorial_complete["intro_text"] = true

func all_tutorials_complete() -> bool:
	return tutorial_complete["id"] and tutorial_complete["birth"] and tutorial_complete["photo"]

func get_node_group_type(subject: Node) -> String:
	if subject.is_in_group("t_IdGroup"):
		return "id"
	if subject.is_in_group("t_BirthCertificateGroup"):
		return "birth"
	if subject.is_in_group("t_PhotoToCutGroup"):
		return "photo"
	return "unknown"

func get_final_text() -> String:
	return "[b][color=000000]Ao final do preenchimento[/color][/b], você deverá carimbar o documento para submetê-lo à análise. Certifique-se da exatidão das informações, pois, caso seu desempenho esteja abaixo do esperado, resultará em realocação imediata para um de nossos [b][color=000000]Centros de Readequação[/color][/b].\nAdemais, fique atento: o [b][color=000000]tempo[/color][/b] para o preenchimento de cada registro poderá tornar-se mais [b][color=000000]curto[/color][/b] à medida que nos aproximamos do horário de pico.\nBoa sorte. [b][color=000000]Não nos decepcione.[/color][/b]"

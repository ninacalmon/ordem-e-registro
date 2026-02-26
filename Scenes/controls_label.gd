extends RichTextLabel

var default_text: String
@onready var left_mouse_img: String = "res://Sprites/Icons/mouseLeft.png"
@onready var right_mouse_img: String = "res://Sprites/Icons/mouseRight.png"
@onready var middle_mouse_img: String = "res://Sprites/Icons/mouseMiddle.png"
@onready var x_img: String = "res://Sprites/Icons/X.png"
@onready var z_img: String = "res://Sprites/Icons/Z.png"

func _ready() -> void:
	EventBus.focus_mode_changed.connect(_on_focus_mode_changed)
	default_text = "[img=bottom,bottom]%s[/img] para arrastar		[img=bottom,bottom]%s[/img] para focar" % [
	left_mouse_img, right_mouse_img
	]

	self.text = default_text
	
func _on_focus_mode_changed(subject: Node2D, enabled: bool):
	if !enabled:
		self.text = default_text
	if Global.is_tutorial_on and enabled:
		match get_node_group_type(subject):
			"Id":
				self.text =  "rolar[img=bottom,bottom]%s[/img] para zoom		[img=bottom,bottom]%s[/img] para escrever / assinar" % [
	middle_mouse_img, left_mouse_img
	]
			"BirthCertificate":
				self.text =  "rolar[img=bottom,bottom]%s[/img] para zoom" % [
	middle_mouse_img
	]
			"PhotoToCut":
				self.text = "[img=bottom,bottom]%s[/img] para pegar a tesoura		[img=bottom,bottom]%s[/img] para remover partes indesejadas" % [
x_img, z_img
				]
			_:
				print("Grupo desconhecido")

func get_node_group_type(subject: Node) -> String:
	if subject.is_in_group("t_IdGroup"):
		return "Id"
	if subject.is_in_group("t_BirthCertificateGroup"):
		return "BirthCertificate"
	if subject.is_in_group("t_PhotoToCutGroup"):
		return "PhotoToCut"
	return "unknown"

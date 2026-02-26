extends Node2D

@export var texture_to_show_text: CompressedTexture2D

@onready var birth_data_hbox: HBoxContainer = %BirthDataHbox
@onready var birth_data_rich_text_label: RichTextLabel = %BirthDataRichTextLabel
@onready var doc_spr: Sprite2D = %DocSpr
@onready var skin_color: Sprite2D = $DocSpr/SkinColor
@onready var signature: Sprite2D = $DocSpr/Signature

func _ready():
	birth_data_rich_text_label.text = \
	"CERTIFICO que, no livro %s, foi lavrado o assento de: %s.\n Nascido(a) no dia %s, no HOSPITAL PATRIA, polo estado %s, filho(a) de %s e de %s." \
	% [CustomerInfo.book_code, CustomerInfo.child_complete_name, CustomerInfo.child_birth_date, CustomerInfo.child_birth_state.state, CustomerInfo.mother_complete_name, CustomerInfo.father_complete_name]

func _process(_delta: float) -> void:
	## Oh my god vvvvvv sem palavras pra essa atrocidade >*O*<
	if !birth_data_rich_text_label.visible:
		birth_data_rich_text_label.show()

	if self.doc_spr.texture == self.texture_to_show_text:
		self.birth_data_hbox.show()
		self.skin_color.show()
		self.signature.show()
	else:
		self.birth_data_hbox.hide()

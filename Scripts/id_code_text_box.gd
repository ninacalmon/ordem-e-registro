extends LineEdit

enum InputCodeTypes {
	ID_NAME,
	ID_BIRTH_DATE,
	ID_CODE
}

@export var focusable_module: FocusableModule
@export var value_type: InputCodeTypes

var already_submitted: bool = false
var previous_text: String = ""

func _ready():
	self.text_submitted.connect(_on_line_input_submitted)
	self.text_changed.connect(_on_line_text_changed)

func _process(_delta: float) -> void:
	if !self.focusable_module.is_focused:
		self.editable = false
		self.release_focus()
		return
	
	if !self.already_submitted:
		self.editable = true

func _on_line_text_changed(new_text):
	match value_type:
		InputCodeTypes.ID_BIRTH_DATE:
			format_birth_date(new_text)
		
		InputCodeTypes.ID_CODE:
			format_id_code(new_text)
		
		_:
			return

func _on_line_input_submitted(new_text: String):
	var expected: String = ""
	
	match value_type:
		InputCodeTypes.ID_NAME:
			expected = CustomerInfo.child_complete_name
		InputCodeTypes.ID_BIRTH_DATE:
			expected = CustomerInfo.child_birth_date
		InputCodeTypes.ID_CODE:
			expected = CustomerInfo.consolidated_id_code
	
	if new_text.to_upper() == expected.to_upper():
		print("PARABÉNS, ACERTOU O ID!")
		EventBus.score_updated.emit(1)
	self.editable = false
	self.already_submitted = true
	release_focus()

func format_birth_date(new_text: String):
	text_changed.disconnect(_on_line_text_changed)
	
	var is_deleting := new_text.length() < previous_text.length()
	
	if !is_deleting:
		if new_text.length() == 2 or new_text.length() == 5:
			if !new_text.ends_with("/"):
				new_text += "/"
	
	text = new_text
	set_caret_column(text.length())
	
	previous_text = text
	text_changed.connect(_on_line_text_changed)

func format_id_code(new_text: String):
	text_changed.disconnect(_on_line_text_changed)
	
	var is_deleting := new_text.length() < previous_text.length()
	
	if !is_deleting:
		if new_text.length() == 2 or new_text.length() == 6:
			if !new_text.ends_with("-"):
				new_text += "-"
	
	text = new_text
	set_caret_column(text.length())
	
	previous_text = text
	text_changed.connect(_on_line_text_changed)
	

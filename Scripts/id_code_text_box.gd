extends LineEdit

enum InputCodeTypes {
	ID_CODE,
	ID_BIRTH_DATE
}

@export var focusable_module: FocusableModule
@export var value_type: InputCodeTypes

func _ready():
	self.text_submitted.connect(_on_line_input_submitted)

func _process(_delta: float) -> void:
	if !self.focusable_module.is_focused:
		self.hide()
		return
	
	self.show()

func _on_line_input_submitted(new_text: String):
	var expected: String = ""
	
	match value_type:
		InputCodeTypes.ID_CODE:
			expected = CustomerInfo.consolidated_id_code
		InputCodeTypes.ID_BIRTH_DATE:
			expected = CustomerInfo.child_birth_date
	
	if new_text.to_upper() == expected.to_upper():
		print("PARABÉNS, ACERTOU O ID!")
		editable = false
		release_focus()

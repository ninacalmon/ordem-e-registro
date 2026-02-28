extends LineEdit

enum InputCodeTypes {
	ID_NAME,
	ID_BIRTH_DATE,
	ID_CODE
}

@export var focusable_module: FocusableModule
@export var value_type: InputCodeTypes

var previous_text: String = ""

func _ready():
	self.text_changed.connect(_on_line_text_changed)

func _process(_delta: float) -> void:
	if !self.focusable_module.is_focused:
		self.editable = false
		self.release_focus()
		return
	
	self.editable = true

func _on_line_text_changed(new_text):
	self.text_changed.disconnect(_on_line_text_changed)
	var upper_text = new_text.to_upper()
	self.text = upper_text
	set_caret_column(self.text.length())

	match value_type:
		InputCodeTypes.ID_BIRTH_DATE:
			format_birth_date(upper_text)
		
		InputCodeTypes.ID_CODE:
			format_id_code(upper_text)

	self.previous_text = self.text
	self._update_score(self.text)
	self.text_changed.connect(_on_line_text_changed)

func _update_score(new_text: String):
	var expected: String = ""
	
	match value_type:
		InputCodeTypes.ID_NAME:
			expected = CustomerInfo.child_complete_name
		InputCodeTypes.ID_BIRTH_DATE:
			expected = CustomerInfo.child_birth_date
		InputCodeTypes.ID_CODE:
			expected = CustomerInfo.consolidated_id_code

	var score = calculate_score(new_text, expected)
	EventBus.score_updated.emit(score, true, value_type)

func format_birth_date(new_text: String):
	text_changed.disconnect(_on_line_text_changed)
	
	var is_deleting = new_text.length() < previous_text.length()
	
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
	
	var is_deleting = new_text.length() < previous_text.length()
	
	if !is_deleting:
		if new_text.length() == 2 or new_text.length() == 6:
			if !new_text.ends_with("-"):
				new_text += "-"
	
	text = new_text
	set_caret_column(text.length())
	
	previous_text = text
	text_changed.connect(_on_line_text_changed)

func calculate_score(input: String, expected: String) -> float:
	var input_upper = input.to_upper()
	var expected_upper = expected.to_upper()
	
	var raw_score = 0
	var max_score = 0

	for i in range(expected_upper.length()):
		var expected_char = expected_upper[i]

		if expected_char == "/" or expected_char == "-":
			continue
		
		max_score += 1
		
		if i < input_upper.length() and input_upper[i] == expected_char:
			raw_score += 1
	
	if max_score == 0:
		return 0.0
	
	return float(raw_score) / float(max_score)

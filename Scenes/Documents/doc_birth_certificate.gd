extends Node2D

@export var texture_to_show_text: CompressedTexture2D

@onready var birth_data_hbox: HBoxContainer = %BirthDataHbox
@onready var birth_data_rich_text_label: RichTextLabel = %BirthDataRichTextLabel
@onready var doc_spr: Sprite2D = %DocSpr

enum Gender {
	MALE,
	FEMALE
}

const MALE_NAMES: Array[String] = [
	"João", "Pedro", "Lucas", "Gabriel", "Rafael", "Felipe", "Bruno",
	"Thiago", "Gustavo", "Matheus", "Leonardo", "Daniel", "Henrique",
	"Eduardo", "Vitor", "André", "Rodrigo", "Diego", "Vinicius",
	"Caio", "Arthur", "Enzo", "Murilo", "Davi", "Samuel",
	"Nicolas", "Heitor", "Benjamin", "Otávio", "Miguel",
	"Noah", "Pietro", "Bernardo", "Anthony", "Lorenzo",
	"Lucca", "Theo", "Emanuel", "Ian", "Ryan", "Nathan",
	"Gael", "Levi", "Isaac", "Álvaro", "Tomás", "Cauã",
	"Cristiano", "Augusto", "Renato", "Fábio", "Marcelo",
	"Adriano", "César", "Jonathan", "Alexandre",
	"Ricardo", "Roberto", "Leandro", "Sérgio",
	"Paulo", "Maurício", "Igor", "Fernando", "Alan", "Otto"
]

const FEMALE_NAMES: Array[String] = [
	"Maria", "Ana", "Mariana", "Beatriz", "Carolina", "Juliana",
	"Larissa", "Camila", "Isabela", "Amanda", "Bianca",
	"Vitória", "Natália", "Gabriela", "Yasmin", "Lívia",
	"Letícia", "Clara", "Helena", "Manuela", "Sophia",
	"Valentina", "Alice", "Laura", "Eloá", "Heloísa",
	"Cecília", "Esther", "Maya", "Antonella", "Rebeca",
	"Sarah", "Liz", "Isadora", "Elisa", "Marina",
	"Alícia", "Emilly", "Milena", "Melissa", "Ana Clara",
	"Maria Eduarda", "Fernanda", "Paula", "Brenda",
	"Mirella", "Vanessa", "Lorena", "Tainá", "Júlia",
	"Rayssa", "Tatiane", "Monique", "Patrícia",
	"Denise", "Silvana", "Cristina", "Simone",
	"Elaine", "Aline", "Tatiana", "Kelly",
	"Renata", "Mônica", "Nina"
]

const SURNAMES: Array[String] = [
	"Silva", "Santos", "Oliveira", "Souza", "Rodrigues", "Ferreira",
	"Alves", "Pereira", "Lima", "Gomes", "Costa", "Ribeiro",
	"Martins", "Carvalho", "Almeida", "Lopes", "Soares", "Fernandes",
	"Vieira", "Barbosa", "Rocha", "Dias", "Monteiro", "Cardoso",
	"Reis", "Araújo", "Correia", "Teixeira", "Castro", "Melo",
	"Freitas", "Batista", "Campos", "Moraes", "Ramos", "Nascimento",
	"Andrade", "Moreira", "Pinto", "Cavalcanti", "Peixoto",
	"Figueiredo", "Machado", "Azevedo", "Barros", "Coelho",
	"Marques", "Cunha", "Tavares", "Borges", "Mendes",
	"Franco", "Guimarães", "Fonseca", "Rezende", "Neves",
	"Amaral", "Sales", "Macedo", "Nogueira", "Porto",
	"Queiroz", "Duarte", "Santana", "Moura", "Xavier",
	"Aguiar", "Bittencourt", "Braga", "Caldeira", "Chagas",
	"Damasceno", "Esteves", "Farias", "Garcia", "Henriques",
	"Leite", "Magalhães", "Noronha", "Paiva", "Quintana",
	"Siqueira", "Torres", "Valente", "Werneck", "Zanetti",
	"Delgado", "Ventura", "Pacheco", "Lacerda", "Barreto",
	"Cabral", "Drummond", "Goulart", "Meireles", "Rangel",
	"Sampaio", "Trindade", "Uchoa", "Vasconcelos", "Zanon"
]

func _ready():
	var book_code = generate_book_code()
	var father_first = generate_first_name(Gender.MALE)
	var mother_first = generate_first_name(Gender.FEMALE)
	
	var father_surname = generate_surname()
	var mother_surname = generate_surname()
	
	var father_name = (father_first + " " + father_surname).to_upper()
	var mother_name = (mother_first + " " + mother_surname).to_upper()
	
	var child_gender = [Gender.MALE, Gender.FEMALE].pick_random()
	var child_first = generate_first_name(child_gender)
	var child_birth_date = generate_birth_date()

	var inherited_surname = [father_surname, mother_surname].pick_random()
	
	var child_name = (child_first + " " + inherited_surname).to_upper()
	
	birth_data_rich_text_label.text = \
	"CERTIFICO que, no livro %s, foi lavrado o assento de: %s.\n Nascido(a) no dia %s, no HOSPITAL PATRIA, filho(a) de %s e de %s." \
	% [book_code, child_name, child_birth_date, father_name, mother_name]

func _process(_delta: float) -> void:
	if self.doc_spr.texture == self.texture_to_show_text:
		self.birth_data_hbox.show()
	else:
		self.birth_data_hbox.hide()

func generate_book_code() -> String:
	var letter = char(randi_range(65, 90))
	var number = randi_range(1, 999)
	
	return "%s-%03d" % [letter, number]

func generate_first_name(gender: Gender) -> String:
	var pool: Array[String]
	
	match gender:
		Gender.MALE:
			pool = MALE_NAMES
		Gender.FEMALE:
			pool = FEMALE_NAMES
		_:
			push_error("Invalid option")
			return ""
	
	return pool.pick_random()

func generate_surname() -> String:
	if SURNAMES.is_empty():
		push_error("SURNAMES is empty")
		return ""
	
	return SURNAMES.pick_random()

func generate_birth_date() -> String:
	var year = randi_range(1910, 1959)
	var month = randi_range(1, 12)
	
	var days_in_month = get_days_in_month(month, year)
	var day = randi_range(1, days_in_month)
	
	return "%02d/%02d/%04d" % [day, month, year]

func get_days_in_month(month: int, year: int) -> int:
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			if is_leap_year(year):
				return 29
			return 28
	
	return 30

func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

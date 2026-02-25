extends Node

enum Gender {
	MALE,
	FEMALE
}

const MALE_NAMES: Array[String] = [
	"Thiago", "Antônio", "José", "Manoel", "Francisco", "Joaquim", "Sebastião", 
	"Alfredo", "Osvaldo", "Aníbal", "Alberto", "Arnaldo", "Afonso", "Benedito",
	"Clóvis", "Dionísio", "Domingos", "Elias", "Estevão", "Evaristo",
	"Floriano", "Geraldo", "Gervásio", "Herculano", "Inácio", "Isidoro",
	"Juvêncio", "Leôncio", "Lourenço", "Manuel", "Mário",
	"Norberto", "Olavo", "Orlando", "Pascoal", "Plínio", "Raul",
	"Rodolfo", "Romeu", "Salvador", "Adão",
	"Teodoro", "Ulisses", "Valentim", "Vicente", "Virgílio",
	"Zacarias", "Baltazar", "Celestino", "Cipriano", "Dário",
	"Edmundo", "Ezequiel", "Gaspar", "Heitor", "Ivo",
	"Josip", "Antun", "Francislav", "Alberdan", "Sebastjan",
	"Dominko", "Estevan",
	"Valdemirko", "Teodoran", "Vicentko", "Raimir", "Viktor"
]

const FEMALE_NAMES: Array[String] = [
	"Maria", "Ana", "Francisca", "Antônia", "Sebastiana", "Josefa", "Tereza",
	"Benedita", "Alzira", "Almerinda", "Amélia", "Anastácia", "Aparecida",
	"Beatriz", "Carlota", "Celina", "Conceição", "Dalva", "Doralina",
	"Efigênia", "Elvira", "Ernestina", "Eulália",
	"Filomena", "Florinda", "Gertrudes", "Helena",
	"Hortênsia", "Inácia", "Iolanda", "Isabel", "Izabelina",
	"Jandira", "Julieta", "Lourdes", "Leonor", "Lindalva",
	"Marcelina", "Margarida", "Matilde", "Nazira", "Odete",
	"Palmira", "Quitéria", "Raimunda", "Rosalina", "Eva",
	"Santina", "Serafina", "Tarsila", "Valentina",
	"Anita", "Mariana", "Francina", "Antonieta",
	"Teresina", "Doroteia", "Milena",
	"Helenaura", "Isabela", "Floriana", "Celestina",
	"Vladina", "Anabela", "Luciana", "Nina"
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
	"Queiroz", "Duarte", "Santana", "Moura", "Xavier", "Oliveira",
	"Aguiar", "Bittencourt", "Braga", "Caldeira", "Chagas",
	"Damasceno", "Esteves", "Farias", "Garcia", "Henriques",
	"Leite", "Magalhães", "Noronha", "Paiva", "Quintana",
	"Siqueira", "Torres", "Valente", "Werneck", "Zanetti",
	"Delgado", "Ventura", "Pacheco", "Lacerda", "Barreto",
	"Cabral", "Drummond", "Goulart", "Meireles", "Rangel",
	"Sampaio", "Trindade", "Uchoa", "Vasconcelos", "Zanon"
]

const STATES: Array[Array] = [
  ["Sarajevo do Sul", "1A"],
  ["Planalto Drínico", "7C"],
  ["Nova Mostária", "2F"],
  ["Vale do Igua-Drina", "3B"],
  ["Bósnia Atlântica", "9H"],
  ["Santa Tuzla", "5D"],
  ["Serra Bósnio-Catarinense", "4K"],
  ["Litoral Herzegovino", "8M"],
  ["Nova Banja do Oeste", "6E"],
  ["Alto Neretva", "1P"],
  ["Campina Zenicana", "2R"],
  ["Cerrado Sarajevita", "8L"],
  ["Nova Travnik Imperial", "9T"],
  ["Fronteira Mostarense", "5N"],
  ["Doboj das Missões", "6S"],
  ["Vale Verde Bósnio", "1J"],
  ["Costa Adriático-Brasiliense", "3V"],
  ["Novo Srebrenik", "4X"]
]

const SKIN_COLORS: Array[Color] = [
	Color(0.76, 0.703, 0.646, 1.0),
	Color(0.66, 0.546, 0.508, 1.0),
	Color(0.36, 0.283, 0.245, 1.0)
]

var father_first_name: String
var mother_first_name: String

var father_surname: String
var mother_surname: String

var father_complete_name: String
var mother_complete_name: String

var child_gender
var child_birth_date: String
var child_skin_color: Color
var child_birth_state

var child_first_name: String
var child_inherited_surname: String
var child_complete_name: String

var book_code: String
var consolidated_id_code: String

func generate_new_customer_info():
	var _father_first_name = _generate_first_name(Gender.MALE)
	var _mother_first_name = _generate_first_name(Gender.FEMALE)

	self.father_first_name = _father_first_name
	self.mother_first_name = _mother_first_name
	
	var _father_surname = _generate_surname()
	var _mother_surname = _generate_surname()
	
	self.father_surname = _father_surname
	self.mother_surname = _mother_surname
	
	self.father_complete_name = (_father_first_name + " " + _father_surname).to_upper()
	self.mother_complete_name = (_mother_first_name + " " + _mother_surname).to_upper()
	
	var _child_gender = [Gender.MALE, Gender.FEMALE].pick_random()
	self.child_gender = _child_gender
	
	var _child_first_name = _generate_first_name(_child_gender)
	self.child_first_name = _child_first_name
	self.child_birth_date = _generate_birth_date()
	self.child_skin_color = SKIN_COLORS.pick_random()
	self.child_birth_date = _generate_birth_date()
	
	var _child_inherited_surname = [_father_surname, _mother_surname].pick_random()
	self.child_inherited_surname = _child_inherited_surname
	
	self.child_complete_name = (_child_first_name + " " + _child_inherited_surname).to_upper()
	self.child_birth_state = _generate_birth_state()

	self.book_code = _generate_book_code()
	self.consolidated_id_code = _compute_consolidated_id_code()
	

func _compute_consolidated_id_code():
	if self.child_birth_state == null \
	or self.mother_first_name == null \
	or self.father_first_name == null \
	or self.child_birth_date == null:
		assert(false, "Cannot compute consolidated id code because of lack of info")
	
	var consolidated_code = self.child_birth_state.code + "-" \
	+ self.mother_first_name[0] \
	+ self.father_first_name[0] \
	+ self.child_first_name[0] \
	+ "-" \
	+ "00M"
	
	return consolidated_code


func _generate_book_code() -> String:
	var letter = char(randi_range(65, 90)) # ASCII alphabet
	var number = randi_range(1, 999)
	
	return "%s-%03d" % [letter, number]

func _generate_first_name(gender: Gender) -> String:
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

func _generate_surname() -> String:
	if SURNAMES.is_empty():
		push_error("SURNAMES is empty")
		return ""
	
	return SURNAMES.pick_random()

func _generate_birth_state() -> Dictionary:
	if STATES.is_empty():
		push_error("STATES is empty")
		return {}

	var state = STATES.pick_random()
	return {
		"state": state[0].to_upper(),
		"code": state[1]
	}

func _generate_birth_date() -> String:
	var year = randi_range(1905, 1928)
	var month = randi_range(1, 12)
	
	var days_in_month = _get_days_in_month(month, year)
	var day = randi_range(1, days_in_month)
	
	return "%02d/%02d/%04d" % [day, month, year]

func _get_days_in_month(month: int, year: int) -> int:
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			if _is_leap_year(year):
				return 29
			return 28
	
	return 30

func _is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

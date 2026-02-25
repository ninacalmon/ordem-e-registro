extends Node2D

@export var doc_photo_to_cut_scene: PackedScene

var current_docs_instantiated_scene = null

func _enter_tree() -> void:
	CustomerInfo.generate_new_customer_info()
	## On timer timeout

func _ready():
	var doc_photo_to_cut = doc_photo_to_cut_scene.instantiate()
	doc_photo_to_cut.get_node("Photo").texture = CustomerInfo.customer_photo
	doc_photo_to_cut.global_position = Global.get_viewport_center()
	self.add_child(doc_photo_to_cut)
	

func _new_docs_timer_timeout():
	#if current_docs_instantiated_scene:
		#pausas o jogo ptro cara nao poder mais mexer
		#tween dos documentos existentes indo para cima
		#uando sair da tela, queue free
	CustomerInfo.generate_new_customer_info()
	#var cena_placeholder instanciada
#
	#var doc_photo_to_cut = doc_photo_to_cut_scene.instantiate()
	#doc_photo_to_cut.get_node("Photo").texture = CustomerInfo.customer_photo
	#doc_photo_to_cut.global_position = Global.get_viewport_center()
	### ou global
	#doc_photo_to_cut.position = cena_placeholder instanciada.foto_position_placeholder.position
	#cena_placeholder instanciada.add_child(doc_photo_to_cut)
	#self.add_child(cena_placeholder instanciada) lá em cima
	#tween dos documentos descendo
	#despausa o jogo
	

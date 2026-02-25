extends Node2D

@export var documents_group: PackedScene
@export var doc_photo_to_cut_scene: PackedScene

@onready var documents_layer: Node2D = %DocumentsLayer
@onready var new_docs_timer: Timer = %NewDocsTimer

var current_docs_instantiated_scene = null

func _enter_tree() -> void:
	CustomerInfo.generate_new_customer_info()
	## On timer timeout

func _ready():
	self.new_docs_timer.timeout.connect(_on_new_docs_timer_timeout)
	instanciate_documents()

func _on_new_docs_timer_timeout():
	EventBus.new_docs_timer_timeout.emit()
	
	await self.remove_documents()
	CustomerInfo.generate_new_customer_info()
	self.instanciate_documents()

func remove_documents() -> void:
	if !current_docs_instantiated_scene:
		push_error("No current docs instantiated to remove")
		return

	var tween := create_tween()
	tween.tween_property(
		current_docs_instantiated_scene,
		"global_position:y",
		- get_viewport_rect().size.y * 2,
		0.8
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	await tween.finished
	current_docs_instantiated_scene.queue_free()
	current_docs_instantiated_scene = null

func instanciate_documents():
		var new_documents: Node2D = documents_group.instantiate()
		new_documents.global_position.y = get_viewport_rect().size.y * -2
		documents_layer.add_child(new_documents)
		var doc_photo_to_cut = doc_photo_to_cut_scene.instantiate()
		var doc_id_sprite = new_documents.get_node("doc_Id/idSpr")

		doc_photo_to_cut.target_sprite = doc_id_sprite
		doc_photo_to_cut.get_node("Photo").texture = CustomerInfo.customer_photo
		
		var placeholder_photo_to_cut = new_documents.get_node("Placeholder_PhotoToCut")
		placeholder_photo_to_cut.add_child(doc_photo_to_cut)
		
		var doc_arrival_tween = get_tree().create_tween()
		doc_arrival_tween.tween_property(new_documents, "global_position:y", 0, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		self.current_docs_instantiated_scene = new_documents

		await doc_arrival_tween.finished

		EventBus.docs_arrived_at_final_position.emit()

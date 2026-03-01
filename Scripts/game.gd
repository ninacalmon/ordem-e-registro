extends Node2D

@export var documents_group: PackedScene
@export var doc_photo_to_cut_scene: PackedScene
@export var timer_curve: Curve

@onready var documents_layer: Node2D = %DocumentsLayer
@onready var new_docs_timer: Timer = %NewDocsTimer
@onready var score_bar: ProgressBar = %ScoreBar
@onready var fail_overlay_light: PointLight2D = %FailOverlayLight
@onready var camera: Camera2D = %Camera


var current_docs_instantiated_scene = null
var current_timer_wait_time: float
var id_was_stamped = false
var documents_registred: int = 0

func _ready():
	randomize()
	Global.is_tutorial_on = true
	EventBus.document_stamped.connect(_on_document_stamped)
	CameraShake.set_camera(camera)
	self.new_docs_timer.timeout.connect(_on_new_docs_timer_timeout)
	self.current_timer_wait_time = new_docs_timer.wait_time
	instanciate_documents()

func _on_new_docs_timer_timeout():
	documents_registred += 1
	new_docs_timer.wait_time = (timer_curve.sample(documents_registred) * 60)

	if score_bar.value < Global.current_score_threshold or !id_was_stamped:
		Global.player_lifes -= 1
		CameraShake.apply_shake(5, 1)
		var tween = create_tween()
		tween.tween_property(fail_overlay_light, "energy", 1, 0.2)
		tween.tween_property(fail_overlay_light, "energy", 0, 0.5)
	else:
		Global.docs_correctly_stamped += 1

	if Global.player_lifes == 0:
		CameraShake.apply_shake(10, 1)
		EventBus.player_death.emit()
		return
	
	if documents_registred >= 7:
		Global.current_score_threshold = Global.BASE_SCORE_THRESHOLD + 0.5
		
	self.score_bar.value = 0
	self.current_timer_wait_time = new_docs_timer.wait_time
	self.new_docs_timer.start()
	EventBus.new_docs_timer_timeout.emit()
	
	await self.remove_documents()
	self.instanciate_documents()
	self.id_was_stamped = false

func remove_documents(time_to_wait_before_removal:float = 0) -> void:
	if !current_docs_instantiated_scene:
		push_error("No current docs instantiated to remove")
		return

	Global.current_score = 0

	## Be careful, this here pauses everything before removing docs
	current_docs_instantiated_scene.process_mode = Node.PROCESS_MODE_DISABLED
	var tween = create_tween()
	tween.tween_property(
		current_docs_instantiated_scene,
		"global_position:y",
		- get_viewport_rect().size.y * 2,
		0.8
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(time_to_wait_before_removal)

	await tween.finished
	current_docs_instantiated_scene.queue_free()
	current_docs_instantiated_scene = null

func instanciate_documents():
	CustomerInfo.generate_new_customer_info()

	var new_documents: Node2D = documents_group.instantiate()
	new_documents.global_position.y = get_viewport_rect().size.y * -2
	documents_layer.add_child(new_documents)

	new_documents.process_mode = Node.PROCESS_MODE_DISABLED

	var doc_photo_to_cut = doc_photo_to_cut_scene.instantiate()
	var doc_id_sprite: Sprite2D = new_documents.get_node("doc_Id/idSpr")
	var placeholder_photo_to_cut: Node2D = new_documents.get_node("Placeholder_PhotoToCut")

	placeholder_photo_to_cut.add_child(doc_photo_to_cut)

	doc_photo_to_cut.setup(
		doc_id_sprite,
		CustomerInfo.customer_photo
	)

	var doc_arrival_tween = get_tree().create_tween()
	doc_arrival_tween.tween_property(
		new_documents,
		"global_position:y",
		0,
		1.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	self.current_docs_instantiated_scene = new_documents

	await doc_arrival_tween.finished
	new_documents.process_mode = Node.PROCESS_MODE_INHERIT

	EventBus.docs_arrived_at_final_position.emit()

func _on_document_stamped():
	# Avoid stamping when timer is close to timeout
	if new_docs_timer.time_left <= 1:
		return
	
	self.id_was_stamped = true
	CameraShake.apply_shake(1.5, 0.5)
	new_docs_timer.stop()
	await remove_documents(1)

	if Global.is_tutorial_on:
		EventBus.tutorial_ended.emit()

	new_docs_timer.timeout.emit()

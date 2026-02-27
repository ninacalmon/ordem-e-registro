extends ProgressBar

var on_demand_scores = {}
var incremental_score: float = 0.0

var old_drawing_score: float = 0.0
@onready var enough_score_overlay_light: PointLight2D = %EnoughScoreOverlayLight

func _ready():
	EventBus.new_docs_timer_timeout.connect(func(): 
		on_demand_scores = {}
		incremental_score = 0.0
	)
	EventBus.score_updated.connect(update_current_score)

	self.show()
	max_value = Global.MAX_SCORE
	value = 0

func update_current_score(new_score: float, is_update_on_demand: bool = false, source = null):
	const EASE_TIME = 0.3
	
	if is_update_on_demand:
		on_demand_scores[source] = new_score
	else:
		incremental_score += new_score
	
	var dynamic_total = 0.0
	for score in on_demand_scores.values():
		dynamic_total += score
	
	Global.current_score = max(incremental_score + dynamic_total, 0)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"value",
		Global.current_score,
		EASE_TIME
	)

	if Global.current_score >= Global.current_score_threshold  and self.modulate != Color(0.553, 0.769, 0.153):
		var color_tween = get_tree().create_tween()
		color_tween.tween_property(self, "modulate", Color(0.553, 0.769, 0.153), 0.5)
		color_tween.parallel().tween_property(enough_score_overlay_light, "energy", 1, 0.5)
		color_tween.tween_property(enough_score_overlay_light, "energy", 0, 0.5)
	elif Global.current_score < Global.current_score_threshold  and self.modulate == Color(0.553, 0.769, 0.153):
		var color_tween = get_tree().create_tween()
		color_tween.tween_property(self, "modulate", Color(0.769, 0.165, 0.153), 0.5)

extends ProgressBar

var drawing_score_accumulated: float = 0.0
var old_drawing_score: float = 0.0
@onready var enough_score_overlay_light: PointLight2D = %EnoughScoreOverlayLight


func _ready():
	EventBus.score_updated.connect(update_current_score)
	self.show()
	max_value = Global.MAX_SCORE
	value = 0

func update_current_score(new_score: float, is_drawing: bool = false):
	const EASE_TIME = 0.3
	if is_drawing:
		drawing_score_accumulated = new_score
		var total_to_add = drawing_score_accumulated - old_drawing_score
		old_drawing_score = new_score

		Global.current_score = max(Global.current_score + total_to_add, 0)
	else:
		Global.current_score += new_score

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"value",
		Global.current_score,
		EASE_TIME
	)
	if Global.current_score >= Global.SCORE_THRESHOLD and self.modulate != Color(0.553, 0.769, 0.153):
		var color_tween = get_tree().create_tween()
		color_tween.tween_property(self, "modulate", Color(0.553, 0.769, 0.153), 0.5)
		color_tween.parallel().tween_property(enough_score_overlay_light, "energy", 1, 0.5)
		color_tween.tween_property(enough_score_overlay_light, "energy", 0, 0.5)

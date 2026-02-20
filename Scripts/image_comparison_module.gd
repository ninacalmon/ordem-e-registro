extends Node
class_name ImageComparisonModule

@export var reference: Sprite2D

@onready var reference_image: Image = reference.image
@onready var reference_image_width = reference_image.get_width()
@onready var reference_image_height = reference_image.get_height()

var match_value = 0
var max_possible_score = 0

var count = 0

func _ready() -> void:
	EventBus.new_pixel_drawn.connect(self.compare_coordinates)

	for x in range(self.reference_image_width):
		for y in range(self.reference_image_height):
			if (self.reference_image.get_pixel(x, y).a != 0):
				self.max_possible_score += 1

func compare_coordinates(sam_x, sam_y, color, previous_color):
	if color == previous_color:
		return

	@warning_ignore("narrowing_conversion")
	var ref_alpha: float = self.reference_image.get_pixel(sam_x, sam_y).a
	
	if ref_alpha != 0:
		self.match_value = min(self.match_value + 1, self.max_possible_score)
	elif ref_alpha == 0:
		self.match_value = max(self.match_value - 1, 0)

func _process(_delta: float):
	count += 1
	
	if count % 240 == 0:
		print("MATCH VAL", self.match_value)

func compare_coordinates_cut(sam_global_x: float, sam_global_y: float):
	var coordinates_in_ref_local = Global.global_to_image_pos(Vector2(sam_global_x, sam_global_y), self.reference, self.reference_image)

	if Global.is_aabb_overlap_with_image(coordinates_in_ref_local, self.reference_image):
		self.match_value = min(self.match_value + 1, self.max_possible_score)
	else:
		self.match_value = max(self.match_value - 1, 0)

extends Node
class_name ImageComparisonModule

@export var reference: Sprite2D
@export var should_compare_drawing: bool = true

@onready var reference_image: Image = reference.texture.get_image()
@onready var reference_image_width = reference_image.get_width()
@onready var reference_image_height = reference_image.get_height()

var match_value: float = 0
var max_possible_score: float = 0
var max_possible_score_photo: float = 0

var count = 0

func _ready() -> void:
	EventBus.new_pixel_drawn.connect(self.compare_coordinates)
	EventBus.photo_just_glued.connect(self.compare_coordinates_cut)
	
	for x in range(self.reference_image_width):
		for y in range(self.reference_image_height):
			if (self.reference_image.get_pixel(x, y).r != 0):
				self.max_possible_score_photo += 1

	for x in range(self.reference_image_width):
		for y in range(self.reference_image_height):
			if (self.reference_image.get_pixel(x, y).a != 0):
				self.max_possible_score += 1


func compare_coordinates(sam_x, sam_y, color, previous_color):
	if color == previous_color:
		return
	if !should_compare_drawing:
		return
	@warning_ignore("narrowing_conversion")
	var ref_alpha: float = self.reference_image.get_pixel(sam_x, sam_y).a
	
	if ref_alpha != 0:
		self.match_value = min(self.match_value + 1, self.max_possible_score)
	elif ref_alpha == 0:
		self.match_value = max(self.match_value - 0.5, 0)

	EventBus.score_updated.emit(self.match_value / self.max_possible_score, true, "signature_draw")

func compare_coordinates_cut(mask_image: Image, sprite_to_glue: Sprite2D):
	if self.should_compare_drawing:
		return

	var ref_rect_local = reference.get_rect()
	var ref_rect_global = Rect2(
		reference.to_global(ref_rect_local.position),
		ref_rect_local.size * reference.global_scale
	)

	var glue_rect_local = sprite_to_glue.get_rect()
	var glue_rect_global = Rect2(
		sprite_to_glue.to_global(glue_rect_local.position),
		glue_rect_local.size * sprite_to_glue.global_scale
	)
	
	var intersection = ref_rect_global.intersection(glue_rect_global)

	if intersection.size == Vector2.ZERO:
		return

	for x in range(int(intersection.position.x), int(intersection.end.x)):
		for y in range(int(intersection.position.y), int(intersection.end.y)):
			var global_pos = Vector2(x, y)
			var ref_image_pos = Global.global_to_image_pos(
				global_pos,
				reference,
				reference.texture.get_size()
			)
			var mask_image_pos = Global.global_to_image_pos(
				global_pos,
				sprite_to_glue,
				mask_image.get_size()
			)

			var ref_pixel = reference_image.get_pixel(ref_image_pos.x, ref_image_pos.y).r
			var mask_pixel = mask_image.get_pixel(mask_image_pos.x, mask_image_pos.y).r

			var mask_is_white = mask_pixel > 0.5
			var ref_is_white = ref_pixel > 0.5

			if mask_is_white and ref_is_white:
				match_value = min(match_value + 1, max_possible_score_photo)

			elif mask_is_white and not ref_is_white:
				match_value = max(match_value - 1, 0)

	EventBus.score_updated.emit(self.match_value / self.max_possible_score_photo)

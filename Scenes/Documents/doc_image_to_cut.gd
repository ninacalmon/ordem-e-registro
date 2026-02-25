extends Node2D

@export var draggable_module: DraggableModule
@export var cut_module: CutModule
@export var sprite_to_glue: Sprite2D
## PUT TARGET SPRITE IN A GROUP AND GET THE NODE HERE, IT IS BETTER THIS TIME
@export var target_sprite: Sprite2D
@export var target_sprite_parent: Node2D

var sprite_to_glue_total_pixels: float = 0
var is_being_dragged: bool = false

func _ready() -> void:
	self.cut_module.just_removed_cut_part.connect(_cut_module_just_removed_part)
	var sprite_to_glue_image = self.cut_module.mask_image

	for x in range(sprite_to_glue_image.get_width()):
		for y in range(sprite_to_glue_image.get_height()):
			if (sprite_to_glue_image.get_pixel(x, y).r > 0.5):
				self.sprite_to_glue_total_pixels += 1
	print("TOTAL TO GLUE ON INITTTTTTTT ", self.sprite_to_glue_total_pixels)
	## UPDATE THIS WHEN CUT HAPPENS, WE SHOULD USE A SIGNAL

## Workaround to implement fast
func _process(_delta: float) -> void:
	if draggable_module.dragging:
		self.is_being_dragged = true

	if !draggable_module.dragging and self.is_being_dragged:
		var target_mask = self.target_sprite.texture.get_image()
		
		## CALCULATE THIS GLUE RECT BASED OF MASK IMAGE SPRITE OF CUT MODULE
		## TO GET ACTUAL CURRENT IMAGE SIZE
		var glue_rect_local = sprite_to_glue.get_rect()
		var glue_rect_global = Rect2(
			sprite_to_glue.to_global(glue_rect_local.position),
			glue_rect_local.size * sprite_to_glue.global_scale
		)

		var target_rect_local = target_sprite.get_rect()
		var target_rect_global = Rect2(
			target_sprite.to_global(target_rect_local.position),
			target_rect_local.size * target_sprite.global_scale
		)

		var intersection = glue_rect_global.intersection(target_rect_global)
		var overlap_pixel_count: float = 0

		for x in range(int(intersection.position.x), int(intersection.end.x)):
			for y in range(int(intersection.position.y), int(intersection.end.y)):
				var local_to_target_pos = Global.global_to_image_pos(Vector2i(x, y), self.target_sprite, target_mask.get_size())
				
				if Global.is_aabb_overlap_with_image(local_to_target_pos, target_mask):
					overlap_pixel_count += 1
					var percentage_of_image_overlap = (overlap_pixel_count / self.sprite_to_glue_total_pixels) * 100
					if percentage_of_image_overlap > 66:
						var to_glue = self.sprite_to_glue.duplicate()
						to_glue.global_position = Global.global_to_image_pos(self.sprite_to_glue.global_position, self.target_sprite, self.target_sprite.texture.get_size())

						self.target_sprite.add_child(to_glue)
						self.target_sprite_parent.call_deferred("queue_free")
						break
	
		self.is_being_dragged = false

## This here runs more times than it needs to because the emitter sends more
## than once this event with the same values
func _cut_module_just_removed_part():
	self.sprite_to_glue_total_pixels = 0
	var sprite_to_glue_image = self.cut_module.mask_image

	for x in range(sprite_to_glue_image.get_width()):
		for y in range(sprite_to_glue_image.get_height()):
			if (sprite_to_glue_image.get_pixel(x, y).r > 0.5):
				self.sprite_to_glue_total_pixels += 1

extends Node2D

@export var draggable_module: DraggableModule
@export var cut_module: CutModule
@export var focusable_module: FocusableModule
@export var sprite_to_glue: Sprite2D
@export var sprite_to_glue_parent: Node2D

@onready var photo_sprite: Sprite2D = $Photo
## For some reason after the first doc batch gets queued free, the @onready var target_sprite
## turns into null as we cant find it by group anymore, and every doc batch after that does not holds a reference correctly.
## Therefore, we assign this reference here on the moment of instantiation of this node
## Bad but, well, its a gamejam after all
var target_sprite: Sprite2D

var sprite_to_glue_total_pixels: float = 0
var is_being_dragged: bool = false

func _ready() -> void:
	self.cut_module.just_removed_cut_part.connect(_cut_module_just_removed_part)

## Workaround to implement fast
func _process(_delta: float) -> void:
	if draggable_module.dragging:
		self.is_being_dragged = true

	if !draggable_module.dragging and self.is_being_dragged:
		var target_mask = self.target_sprite.texture.get_image()
		
		## This here gets the current white mask bounds to calculate
		## if it needs to glue based off the current visible sprite
		## (as already mentioned on this code before, the black parts of the mask
		## make the sprite on top invisible)
		var mask_bounds = cut_module.mask_white_bounds

		var sprite_to_glue_local_position = Vector2(mask_bounds.position)
		var sprite_to_glue_local_size = Vector2(mask_bounds.size)

		var glue_rect_global = Rect2(
			Global.image_to_global_pos(sprite_to_glue_local_position, self.sprite_to_glue, self.sprite_to_glue.texture.get_image()),
			sprite_to_glue_local_size * sprite_to_glue.global_scale
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
						var to_glue: Sprite2D = self.sprite_to_glue.duplicate()
						to_glue.global_position = Global.global_to_image_pos(self.sprite_to_glue.global_position, self.target_sprite, self.target_sprite.texture.get_size())
						
						self.target_sprite.add_child(to_glue)
						var mask_image: Image = self.cut_module.mask_image

						EventBus.photo_just_glued.emit(mask_image, to_glue)
						self.sprite_to_glue_parent.call_deferred("queue_free")
						self.is_being_dragged = false
						return

		self.is_being_dragged = false

func _cut_module_just_removed_part():
	self.sprite_to_glue_total_pixels = 0
	var sprite_to_glue_image = self.cut_module.mask_image

	for x in range(sprite_to_glue_image.get_width()):
		for y in range(sprite_to_glue_image.get_height()):
			if (sprite_to_glue_image.get_pixel(x, y).r > 0.5):
				self.sprite_to_glue_total_pixels += 1

func initialize():
	var sprite_to_glue_image = self.cut_module.mask_image

	for x in range(sprite_to_glue_image.get_width()):
		for y in range(sprite_to_glue_image.get_height()):
			if (sprite_to_glue_image.get_pixel(x, y).r > 0.5):
				self.sprite_to_glue_total_pixels += 1

func setup(target: Sprite2D, texture: Texture2D):
	self.target_sprite = target

	photo_sprite.texture = texture

	# Explicit injection
	cut_module.sprite = photo_sprite

	assert(cut_module.sprite != null)
	assert(cut_module.sprite.texture != null)

	#await get_tree().process_frame

	cut_module.initialize()
	self.initialize()
	focusable_module.subject_image = texture.get_image()

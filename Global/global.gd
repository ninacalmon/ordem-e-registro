extends Node

const MAX_SCORE: int = 5
const SCORE_THRESHOLD: float = 3.5

var player_lifes = 5
var docs_correctly_stamped: int = 0

var is_tutorial_on: bool

var current_score: float

var focus_layer = 200
var focus_time = 0.4
var is_something_focused = false

enum AudioBus {
	MASTER,
	MUSIC,
	SOUND_EFFECTS
}

const AUDIO_BUS_DIC = {
	AudioBus.MASTER: "Master",
	AudioBus.MUSIC: "Music",
	AudioBus.SOUND_EFFECTS: "SoundEffects"
}

enum PointerVariations {
	DEFAULT,
	SCISSOR,
	DELETE,
	DRAGGABLE,
	DRAGGING,
	PEN
}

var pointer_state: PointerVariations = PointerVariations.DEFAULT

const POINTER_VARIATIONS_DIC = {
	PointerVariations.DEFAULT: {
		"texture": preload("res://Sprites/UI/Mouse1.png"),
		"hotspot": Vector2(0, 0)
	},
	PointerVariations.SCISSOR: {
		"texture": preload("res://Sprites/UI/MouseSC1.png"),
		"hotspot": Vector2(8, 8)
	},
	PointerVariations.DELETE: {
		"texture": preload("res://Sprites/UI/MouseX1.png"),
		"hotspot": Vector2(15, 15)
	},
	PointerVariations.DRAGGABLE: {
		"texture": preload("res://Sprites/UI/MouseHO.png"),
		"hotspot": Vector2(10, 15)
	},
	PointerVariations.DRAGGING: {
		"texture": preload("res://Sprites/UI/MouseHC.png"),
		"hotspot": Vector2(10, 15)
	},
	PointerVariations.PEN: {
		"texture": preload("res://Sprites/UI/MouseP1.png"),
		"hotspot": Vector2(0, 27)
	}
}

func set_current_mouse_pointer(pointer_variation: PointerVariations):
	var pointer_var = POINTER_VARIATIONS_DIC[pointer_variation]

	Input.set_custom_mouse_cursor(pointer_var.texture, Input.CursorShape.CURSOR_ARROW, pointer_var.hotspot)

func is_aabb_overlap_with_image(local_to_image_position: Vector2, image: Image) -> bool:
	return local_to_image_position.x >= 0 and \
		local_to_image_position.y >= 0 and \
		local_to_image_position.x < image.get_width() and \
		local_to_image_position.y < image.get_height()

## This one here considers scale + rotation
func global_to_image_pos(global_pos: Vector2, sprite: Sprite2D, image_size: Vector2) -> Vector2:
	var local = sprite.get_global_transform().affine_inverse() * global_pos

	if sprite.centered:
		local += image_size / 2.0

	return local
	
func image_to_global_pos(image_pos: Vector2, sprite: Sprite2D, image: Image) -> Vector2:
	var local = image_pos

	if sprite.centered:
		local -= image.get_size() / 2.0

	var global = sprite.get_global_transform() * local

	return global

func is_mask_image_overlap(local_pos: Vector2, msk_img: Image) -> bool:
	const VISIBILITY_THRESHOLD = 0.5
	var x = local_pos.x
	var y = local_pos.y

	if not Global.is_aabb_overlap_with_image(local_pos, msk_img):
		return false
	
	var pixel = msk_img.get_pixel(x, y)

	## Check if current pixel is white (visible, > 0.5) or black (transparent, < 0.5)
	return pixel.r > VISIBILITY_THRESHOLD

func is_mask_image_overlap_alpha(local_pos: Vector2, img: Image) -> bool:
	const ALPHA_THRESHOLD = 0.1

	if not is_aabb_overlap_with_image(local_pos, img):
		return false

	var pixel = img.get_pixelv(local_pos.floor())
	return pixel.a > ALPHA_THRESHOLD

func compute_mouse_info(global_pos: Vector2, sprite: Sprite2D, image: Image) -> ImageMouseInfo:
	var mouse_info = ImageMouseInfo.new()
	var mouse_pos_local_to_image = Global.global_to_image_pos(global_pos, sprite, image.get_size())

	mouse_info.mouse_pos_local_to_image = mouse_pos_local_to_image
	mouse_info.is_inside_image = self.is_mask_image_overlap(mouse_pos_local_to_image, image)

	return mouse_info

func get_viewport_center() -> Vector2:
	return get_viewport().get_visible_rect().size / (Vector2.ONE * 2)

func get_sprite_center_global(sprite: Sprite2D) -> Vector2:
	return sprite.to_global(sprite.texture.get_size() * sprite.scale / 2.0)

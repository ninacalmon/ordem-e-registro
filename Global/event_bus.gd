extends Node

signal new_pixel_drawn(x: int, y: int, color: Color, previous_color: Color)
signal focus_mode_changed(subject: Node2D, enabled: bool)
signal item_dropped(parent: Node2D, item_to_verify: Node2D, sprite_to_attatch: Sprite2D, overlap_func: Callable)
signal docs_arrived_at_final_position()
signal new_docs_timer_timeout()
signal document_stamped()
signal photo_just_glued(mask_image: Image, sprite_glued: Sprite2D)
signal score_updated(module_current_score_normalized: float, is_update_on_demand: bool, source)
signal player_death()

extends Node2D

func _on_Area2D_body_enter( body ):
	if body.has_method("climb_begin"):
		body.climb_begin(self);

func _on_Area2D_body_exit( body ):
	if body.has_method("climb_end"):
		body.climb_end(self);

func _ready():
	var sprite = get_node("Sprite");
	var scale = get_scale();
	sprite.set_region_rect(Rect2(Vector2(), scale*32));
	sprite.set_scale(Vector2(1, 1)/scale);
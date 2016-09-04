
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

func _change_scene(path):
	kpusher.clear();
	get_tree().change_scene(path);

func _reset_scene():
	kpusher.clear();
	get_tree().reload_current_scene();

func reset():
	call_deferred("_reset_scene");

func change_scene(path):
	call_deferred("_change_scene", path);

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



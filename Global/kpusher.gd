
extends Node

# It's important that this is a hashtable because I need to be able to index by nodes
# This is so that it's easier to get the current vector for a given node.
onready var pushed_objects = {}

signal kpusher_push(delta);
func _fixed_process(delta):
	emit_signal("kpusher_push", delta);
	for dir in pushed_objects.values():
		var node = dir.node;
		var ldiff = dir.vec / dir.count;
		var body = dir.node;
		var motion = body.move(ldiff);
		if body.is_colliding():
			var n = body.get_collision_normal();
			motion = n.slide(motion);
			body.move(motion);
	pushed_objects.clear();
	
func push_object(pusher, node, vec):
	if node.has_method("_platform_can_move") and \
	not node._platform_can_move(pusher):
		return;
	if pushed_objects.has(node):
		var dir = pushed_objects[node];
		dir.count += 1;
		dir.vec += vec;
	else:
		var dir = {
			node = node,
			vec = vec,
			count = 1
		}
		pushed_objects[node] = dir;

func clear():
	pushed_objects.clear();

func _ready():
	set_fixed_process(true);



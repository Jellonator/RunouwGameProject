
extends Node2D

export var speed = 10;
export(String, "stop", "backwards") var button_method = "stop";
export var wait_time = 0.0;
export var reverse_on_end = false;

var offset = 0;

onready var curve = get_parent().get_curve();
onready var max_offset = curve.get_baked_length();
onready var anim = get_node("StaticBody2D/AnimationPlayer");
const THETA = 1e-5
const DIR_FORWARD = 1;
const DIR_BACKWARD = -1;
const DIR_STOP = 0;
var direction = DIR_FORWARD;
var wait = 0;
var reverse = 1;

func _fixed_process(delta):
	var do_anim = false;
		
	if wait > 0:
		wait -= delta;
		anim.set_active(do_anim);
		return;
	
	var poffset = offset;
	offset += speed * delta * direction * reverse;
	if not has_loop():
		if reverse_on_end:
			if offset <= 0 and reverse == -1:
				reverse = 1;
				wait = wait_time;
			elif offset >= max_offset - 1e-5 and reverse == 1:
				reverse = -1;
				wait = wait_time;
		offset = clamp(offset, 0, max_offset - 1e-5);
	else:
		offset = fmod(offset, max_offset);
		
	if offset != poffset:
		do_anim = true;
	
	anim.set_active(do_anim);
	
	set_offset(offset);

func _ready():
	anim.play("default");
	set_fixed_process(true);

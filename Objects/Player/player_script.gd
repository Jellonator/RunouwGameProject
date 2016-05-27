extends KinematicBody2D

const MOVE_SPEED = 100;      # Speed of horizontal movement
const GRAVITY = 800;         # Force of gravity
const JUMP_SPEED_INITIAL = 420;      # Force of jump
const JUMP_PRESS_TIME = 0.1; # Seconds where player can jump before landing
const JUMPING_TIME = 1;
var veloc = Vector2();
var time_since_jump_press = JUMP_PRESS_TIME + 1;
var jumping_time = 0;

func _ready():
	set_process_input(true);
	set_fixed_process(true);
	
func _input(event):
	if event.is_action("ui_up") and not event.is_echo():
		time_since_jump_press = 0;
	
func _fixed_process(delta):
	var gravity_scale = 1;
	time_since_jump_press += delta;
	
	if Input.is_action_pressed("ui_left"):
		veloc.x = -1;
	elif Input.is_action_pressed("ui_right"):
		veloc.x =  1;
	else:
		veloc.x =  0;
	
	veloc.x *= MOVE_SPEED;
	var movement = veloc * delta;
	move(movement);
	
	
	if is_colliding():
		var normal = get_collision_normal();
		var new_move = normal.slide(movement);
		veloc = normal.slide(veloc);
		move(new_move);
		
		if normal.dot(Vector2(0, -1)) > 0.2:
			veloc.y = 0;
			if Input.is_action_pressed("ui_up") and time_since_jump_press < JUMP_PRESS_TIME:
				veloc.y = -JUMP_SPEED_INITIAL;
	
	if not Input.is_action_pressed("ui_up"):
		if veloc.y < 0:
			gravity_scale = 4;
	
	veloc.y += delta * GRAVITY * gravity_scale;
	



extends "res://lib/character.gd"

const GRAVITY_SLOPE   = 4000.0 #Gravity to keep player grounded on slopes
const GRAVITY_GROUND  = 1000.0 #Base gravity for standing on the ground
const GRAVITY_AIR     = 1600.0 #Gravity whilst in air
const GRAVITY_JUMP    = 1000.0 #Gravity while holding jump
const GRAVITY_RELEASE = 2200.0 #Gravity when not holding jump, but still going up
const GRAVITY_LADDER  =    0.0 #No gravity while climbing a ladder

const MOVE_SPEED = 200;

const JUMP_SPEED = 500;
const JUMP_RELEASE_SCALE = 0.6;

const CLIMB_SPEED = 120;
const CLIMB_JUMP_SCALE = 0.8;
const CLIMB_MOVE_SCALE = 0.5;

const SLOPE_MOVE_SCALE_MIN = 0.2;

onready var sprite = get_node("Sprite");
#onready var anim = get_node("AnimationPlayer");
onready var graphic = get_node("Sprite");
var jump_press = false;
var climb_count = 0;
var is_climbing = false;
var climb_x = 0;
var climb_range = 0;

var first_ready = true;

func play_anim(name):
	pass
	#Nothing here yet
#	if anim.get_current_animation() != name:
#		anim.play(name);

func climb_begin(ladder):
	climb_count += 1;
	climb_x = ladder.get_global_pos().x;
	
func climb_end(ladder):
	climb_count -= 1;

func _before_move(delta):
	var jump = Input.is_action_pressed("jump")
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var down = Input.is_action_pressed("down")
	var up = Input.is_action_pressed("up")
	# DO NOT update x_press variables here
	var do_jump = jump and not jump_press;
	
	# 11 is the droppable platform bit
	set_collision_mask_bit(11, not down);
	
	var active_speed = MOVE_SPEED;
	var active_jump_speed = JUMP_SPEED;
	var active_climb_speed = CLIMB_SPEED;
	if is_climbing:
		active_speed *= CLIMB_MOVE_SCALE;
	
	# move horizontally
	if (left):
		char_set_move(-active_speed);
		graphic.set_flip_h(false);
	elif (right):
		char_set_move(active_speed);
		graphic.set_flip_h(true);
	else:
		char_set_move(0);
		
	# Play animations
	if char_can_jump() or is_climbing:
		if abs(char_walkSpeed) > 0:
			play_anim("walk");
		else:
			play_anim("idle"); 
	else:
		play_anim("jump");
	
	# Jump
	if (do_jump):
		if is_climbing and not up:
			if not char_can_jump():
				char_set_jump(CLIMB_JUMP_SCALE * active_jump_speed);
			print("WOW");
			is_climbing = false;
		if char_can_jump():
			char_set_jump(active_jump_speed);
			print("JUMP");
	elif not jump and not char_can_jump():
		char_set_fall(JUMP_RELEASE_SCALE);
		print("FALL")
		
	# Climbing
	if climb_count > 0 and (up or down):
		is_climbing = true;
	elif climb_count == 0:
		is_climbing = false;
	
	if is_climbing and char_airTime == 0 and down:
		is_climbing = false;
	
	if is_climbing:
		if up:
			char_move_vertically(-active_climb_speed * delta);
		if down:
			char_move_vertically(active_climb_speed * delta);
			
	# Set gravity
	if is_climbing and char_velocity.y >= 0:
		char_set_gravity(GRAVITY_LADDER);
		char_velocity.y = 0;
	elif (test_move(Vector2(0, 5)) and char_can_jump()):
		var check_dir = 0;
		if char_walkSpeed > 0:
			check_dir =  0.2;
		elif char_walkSpeed < 0:
			check_dir = -0.2;
			
		if test_move(Vector2(check_dir, 0)):
			# When going up slope, use lighter gravity
			char_set_gravity(GRAVITY_GROUND);
		else:
			# When going down slope, use heavier gravity
			char_set_gravity(GRAVITY_SLOPE);
		
		# When traveling down slope, slow down a bit
		if test_move(Vector2(-check_dir, 0)):
			var floordiff = rad2deg(acos(char_floorNormal.dot( Vector2(0,-1))))
			# 0 for no slowdown
			# 22.5 for some slowdown
			# 45 for full slowdown
			var slowdown = lerp(1, SLOPE_MOVE_SCALE_MIN, \
				clamp(floordiff / 45.0, 0, 45.0));
			char_set_move(char_walkSpeed * slowdown);
			
	elif (char_is_falling()):
		char_set_gravity(GRAVITY_AIR);
	elif (char_is_jumping()):
		char_set_gravity(GRAVITY_JUMP);
	else:
		char_set_gravity(GRAVITY_RELEASE);

func _after_move(delta):
	if Input.is_action_pressed("reload"):
		scenemanager.reset();
	var jump = Input.is_action_pressed("jump")
	# DO update x_press variables here
	jump_press = jump;

func _ready():
	add_to_group("player");
	set_fixed_process(true);
	connect("char_after_move", self, "_after_move");
	connect("char_before_move", self, "_before_move");

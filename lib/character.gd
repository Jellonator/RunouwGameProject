extends KinematicBody2D

# This is a class used to simulate a single character

#Gravity definitions
var char_gravity = 500.0

#Angle in degrees towards either side that the player can 
const CHAR_FLOOR_ANGLE_TOLERANCE = 60
const CHAR_JUMP_MAX_AIRBORNE_TIME=0.2
const CHAR_SLIDE_STOP_VELOCITY=1.0 #one pixel per second
const CHAR_SLIDE_STOP_MIN_TRAVEL=0.05 #one (fraction of a) pixel
const CHAR_TERMINAL_VELOCITY = 640;

var char_velocity = Vector2()
var char_airTime = 100
var char_isJumping = false
var char_walkSpeed = 0.0
var char_delta_mult = 1;
var char_vertical_movement = 0;
var char_floorNormal = Vector2();

# Signals for callbacks
signal char_after_move(delta);
signal char_before_move(delta);

# Functions to get character state
func char_is_jumping():
	return (char_isJumping and char_velocity.y < 0 and char_airTime > 0);
	
func char_is_falling():
	return (char_airTime > 0 and char_velocity.y > 0);

func char_is_on_ground():
	return (char_airTime == 0);

func char_can_jump():
	return (char_airTime < CHAR_JUMP_MAX_AIRBORNE_TIME and not char_isJumping)

# Functions to set character properties
func char_set_gravity(value):
	char_gravity = value;
	
func char_set_delta_mult(value):
	char_delta_mult = value;

# Functions to make character do things
func char_set_jump(speed):
	char_isJumping = true;
	char_velocity.y = -speed;
	char_airTime = CHAR_JUMP_MAX_AIRBORNE_TIME
	
func char_move_vertically(speed):
	char_vertical_movement += speed;

func char_set_fall(scale = 1):
	if char_isJumping == true and char_velocity.y < 0:
		char_velocity.y *= scale
	char_isJumping = false;

func char_set_move(speed):
	char_walkSpeed = speed;
	if (speed == 0 and char_is_on_ground()):
		char_velocity.y = 0

# Update function
func _fixed_process(delta):
	emit_signal("char_before_move", delta);
	_char_update(delta);
	emit_signal("char_after_move", delta);
	
func _char_update(delta):
	var real_delta = delta;
	delta *= char_delta_mult;
	if delta <= 0:
		return;
	
	#Manage velocity
	char_velocity.x = char_walkSpeed;
	char_velocity.y += char_gravity * delta;
	char_velocity.y = clamp(char_velocity.y, -CHAR_TERMINAL_VELOCITY, CHAR_TERMINAL_VELOCITY);
	
	#integrate velocity into motion and move
	var motion = char_velocity * delta;
	motion.y += char_vertical_movement;
	char_vertical_movement = 0;
	
	#move and consume motion
	var on_ground = false;
	var floor_velocity=Vector2()
	motion = move(motion);
	
	if (is_colliding()):
		#ran against something, is it the floor? get normal
		var n = get_collision_normal()
		floor_velocity = get_collider_velocity()
		char_floorNormal = n;
		
		if (rad2deg(acos(n.dot( Vector2(0,-1)))) < CHAR_FLOOR_ANGLE_TOLERANCE):
			#if angle to the "up" vectors is < angle tolerance
			#char is on floor
			char_airTime = 0
			on_ground = true;
				
		if (char_airTime == 0
		and get_travel().length() < CHAR_SLIDE_STOP_MIN_TRAVEL
		and abs(char_velocity.x) < CHAR_SLIDE_STOP_VELOCITY
		and floor_velocity==Vector2()):
			#Since this formula will always slide the character around, 
			#a special case must be considered to to stop it from moving 
			#if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time==0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			revert_motion()
			char_velocity.y=0
			
		else:
			#For every other case of motion,our motion was interrupted.
			#Try to complete the motion by "sliding"
			#by the normal
			
			motion = n.slide(motion)
			char_velocity = n.slide(char_velocity)
			#then move again
			move(motion)
		
	#if falling, no longer jumping
	if (char_isJumping and char_velocity.y>0):
		char_isJumping=false
		
	# Only increase time in air when not on ground
	if (not on_ground):
		char_airTime += delta

func _ready():
	#Initalization here
	set_fixed_process(true)
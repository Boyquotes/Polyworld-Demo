class_name PlayerOLD
extends CharacterBody3D


const RUN_SPEED := 9.0
const RUN_ACCEL := 50.0
const RUN_DECEL := 50.0
const AIR_ACCEL := 30.0
const TURN_SPEED := 15.0
const JUMP_VELOCITY := 10.0
const GRAVITY := 40.0
const HOLD_GRAVITY := 20.0
const FALL_GRAVITY := 60.0
const JUMP_BUFFER := 0.075
const COYOTE_TIME := 0.075

enum States {
	IDLE,
	RUN,
	AIR,
	LHAND,
	RHAND
}

var current_state := States.IDLE

var input_dir := Vector2.ZERO
var relative_input_dir := Vector2.ZERO
var facing_dir := Vector2.DOWN
var target_facing_dir := Vector2.DOWN

var can_hold_jump := false
var in_jump_buffer := false
var in_coyote_time := false

var attack_len = 0

@onready var cam = get_viewport().get_camera_3d()
@onready var anim = $Model/AnimationPlayer as AnimationPlayer


func _physics_process(delta):
	
	# Get the input direction
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	# Get the input direction relative to the camera
	relative_input_dir = input_dir.rotated(cam.global_rotation.y).normalized()
	
	# Set the rotation
	facing_dir = facing_dir.slerp(target_facing_dir, TURN_SPEED * delta)
	rotation.y = -facing_dir.angle() + PI/2
	
	# Execute current state function
	match current_state:
		States.IDLE: state_idle(delta)
		States.RUN: state_run(delta)
		States.AIR: state_air(delta)
		States.LHAND: state_attack(delta)
		States.RHAND: state_attack(delta)
		
		_: state_idle(delta) #default
	


# IDLE STATE
func state_idle(delta):
	
	anim.play("idle")
	
	# Add the gravity
	velocity.y -= GRAVITY * delta
	
	if input_dir:
		current_state = States.RUN
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_DECEL * delta)
		velocity.z = move_toward(velocity.z, 0, RUN_DECEL * delta)
	
	move_and_slide()
	
	if is_on_floor():
		# Handle jump
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		current_state = States.AIR
		set_coyote_time()
	
	if Input.is_action_just_pressed("left_hand"):
		activate_slot(0)
	if Input.is_action_just_pressed("right_hand"):
		activate_slot(1)


# RUN STATE
func state_run(delta):
	
	anim.play("run")
	
	# Add the gravity
	velocity.y -= GRAVITY * delta
	
	if input_dir:
		
		set_target_facing(relative_input_dir)
		
		velocity.x = move_toward(velocity.x, relative_input_dir.x * RUN_SPEED, RUN_ACCEL * delta)
		velocity.z = move_toward(velocity.z, relative_input_dir.y * RUN_SPEED, RUN_ACCEL * delta)
		
	else:
		current_state = States.IDLE
	
	move_and_slide()
	
	if is_on_floor():
		# Handle jump
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		current_state = States.AIR
		set_coyote_time()
	
	if Input.is_action_just_pressed("left_hand"):
		activate_slot(0)
	if Input.is_action_just_pressed("right_hand"):
		activate_slot(1)


# AIR STATE
func state_air(delta):
	
	if not Input.is_action_pressed("jump"):
		can_hold_jump = false
	
	elif Input.is_action_just_pressed("jump"):
		set_jump_buffer()
		if in_coyote_time and velocity.y <= 1:
			jump()
	
	# Add the appropriate gravity
	if velocity.y >= 0:
		anim.play("inair_up")
		if can_hold_jump:
			velocity.y -= HOLD_GRAVITY * delta
		else:
			velocity.y -= GRAVITY * delta
	else:
		anim.play("inair_down")
		velocity.y -= FALL_GRAVITY * delta
		can_hold_jump = false
	
	if input_dir:
		
		set_target_facing(relative_input_dir)
		
		velocity.x = move_toward(velocity.x, relative_input_dir.x * RUN_SPEED, AIR_ACCEL * delta)
		velocity.z = move_toward(velocity.z, relative_input_dir.y * RUN_SPEED, AIR_ACCEL * delta)
	
	
	move_and_slide()
	
	# Handle landing
	if is_on_floor():
		can_hold_jump = false
		
		if velocity.y <= -40.0:
			print("fall damage")
		
		if in_jump_buffer:
			jump()
		else:
			
			if input_dir:
				current_state = States.RUN
			else:
				current_state = States.IDLE
	
	if Input.is_action_just_pressed("left_hand"):
		activate_slot(0)
	if Input.is_action_just_pressed("right_hand"):
		activate_slot(1)
	

func activate_slot(slot_index : int):
	if slot_index == 0:
		attack_len = 30
		var burst = load("res://Attacks/BurningFist.tscn").instantiate()
		burst.caster = self
		get_tree().root.add_child(burst)
		
		current_state = States.LHAND
		

# this should be renamed to activate slot 1
func state_attack(delta):
	
	anim.play("thrust")
	
	# look at players inventory to determine the response
	var temp = 0
	if temp == 0:
		
		if attack_len > 0:
			#$Hitbox/CollisionShape3d.disabled = false
			velocity.x = target_facing_dir.x * attack_len
			velocity.z = target_facing_dir.y * attack_len
			attack_len -= 60 * delta
		else:
			#$Hitbox/CollisionShape3d.disabled = true
			current_state = States.IDLE
			
		
		move_and_slide()
		
	


func jump():
	velocity.y = JUMP_VELOCITY
	can_hold_jump = true
	current_state = States.AIR
	


func set_target_facing(dir:Vector2):
	target_facing_dir = dir.normalized()
	


func set_jump_buffer():
	in_jump_buffer = true
	await get_tree().create_timer(JUMP_BUFFER).timeout
	in_jump_buffer = false
	


func set_coyote_time():
	in_coyote_time = true
	await get_tree().create_timer(COYOTE_TIME).timeout
	in_coyote_time = false
	


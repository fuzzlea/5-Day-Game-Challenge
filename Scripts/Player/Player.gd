class_name Player

extends CharacterBody2D

## Signals

signal Jump
signal WallJump
signal AirJump

signal JumpReady
signal WallJumpReady

signal MoveLeft
signal MoveRight

signal Hurt

signal Attack_Mele
signal Attack_Ranged

## Vars

# Exports

@export_subgroup("Init Stats")
@export var InitHealth: float = 100.0
@export var InitMeleDamage : float = 10.0
@export var InitRangedDamage : float = 5.0

@export_subgroup("Components")
@export var c_BodyComponent : BodyComponent

# Inputs

var mele_cooldown = 0
var mele_cooldown_threshold = 0.35

var ranged_cooldown = 0
var ranged_cooldown_threshold = 0.15


# Movement

var speed = 1250.0
var jump_force = -1250.0
var accel = 0.25
var dir = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var air_jumps = 1
var current_air_jumps = 0
var air_jump_boost = 1.15

var wall_jumps = 0

var coyote_timer = 0.0
var coyote_timer_threshold = 0.1

var jump_buffer_timer = 0.0
var jump_buffer_timer_threshold = 0.1

#

## Functions

# Initialization

func InitializePlayer():
	c_BodyComponent.init(self, InitHealth)

#

# Inputs

func handle_inputs(delta: float):
	
	if mele_cooldown > 0:
		mele_cooldown -= delta
		mele_cooldown = clampf(mele_cooldown,0,mele_cooldown_threshold)
	if ranged_cooldown > 0:
		ranged_cooldown -= delta
		ranged_cooldown = clampf(ranged_cooldown,0,ranged_cooldown_threshold)
	
	if Input.is_action_just_pressed("Player-Mele"):
		if mele_cooldown != 0: return
		print("Mele")
		mele_cooldown = mele_cooldown_threshold
	
	if Input.is_action_just_pressed("Player-Range"):
		if ranged_cooldown != 0: return
		print("Ranged")
		ranged_cooldown = ranged_cooldown_threshold

# Movement

func handle_movement(delta : float):
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		current_air_jumps = air_jumps
		coyote_timer = coyote_timer_threshold
	
	if is_on_wall():
		wall_jumps = 1
		WallJumpReady.emit()
	
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	if Input.is_action_just_pressed("Player-Jump"):
		jump_buffer_timer = jump_buffer_timer_threshold

	if jump_buffer_timer > 0:
		if is_on_floor() or coyote_timer > 0:
			
			velocity.y = jump_force
			jump_buffer_timer = 0
			coyote_timer = 0
			
			Jump.emit()
			
		elif current_air_jumps > 0:
			
			velocity.y = jump_force * air_jump_boost
			current_air_jumps -= 1
			jump_buffer_timer = 0
			
			AirJump.emit()
			
		elif wall_jumps > 0:
			velocity.y = jump_force * air_jump_boost
			wall_jumps -= 1
			jump_buffer_timer = 0
			
			WallJump.emit()
		
	dir = Input.get_axis("Player-MoveLeft", "Player-MoveRight")
		
	if dir:
		velocity.x = lerp(velocity.x, dir * speed, accel)
	else:
		velocity.x = lerp(velocity.x, dir * speed, accel)

#

## Connectors

# Phys_Proc

func _physics_process(delta : float) -> void:
	
	handle_movement(delta)
	handle_inputs(delta)
	
	move_and_slide()

#

# Signals

func signal_Jump():
	pass

func signal_WallJump():
	pass

func signal_AirJump():
	pass

func signal_JumpReady():
	pass

func signal_WallJumpReady():
	pass

func signal_MoveLeft():
	pass

func signal_MoveRight():
	pass

func signal_Hurt():
	print("Hurt me owie owie")

#

# Ready

func _ready() -> void:
	
	# Connect Signals and Functions
	Jump.connect(signal_Jump)
	WallJump.connect(signal_WallJump)
	AirJump.connect(signal_AirJump)
	JumpReady.connect(signal_JumpReady)
	WallJumpReady.connect(signal_WallJumpReady)
	MoveLeft.connect(signal_MoveLeft)
	MoveRight.connect(signal_MoveRight)
	Hurt.connect(signal_Hurt)
	
	# Initialize the Player
	InitializePlayer()

#

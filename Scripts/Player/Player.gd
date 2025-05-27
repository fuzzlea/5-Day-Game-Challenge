extends CharacterBody2D

## Signals

signal Jump
signal WallJump
signal AirJump

signal JumpReady
signal WallJumpReady

signal MoveLeft
signal MoveRight

## Vars

# Exports

@export_subgroup("Init Stats")
@export var InitHealth: float = 100.0

@export_subgroup("Components")
@export var c_BodyComponent : BodyComponent

# Movement

var speed = 1250.0
var jump_force = -1250.0
var accel = 0.25

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
		
	var direction = Input.get_axis("Player-MoveLeft", "Player-MoveRight")
		
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, accel)
	else:
		velocity.x = lerp(velocity.x, direction * speed, accel)

#

## Connectors

# Phys_Proc

func _physics_process(delta : float) -> void:
	handle_movement(delta)
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
	
	# Initialize the Player
	InitializePlayer()

#

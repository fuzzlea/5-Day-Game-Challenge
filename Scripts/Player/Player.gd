class_name Player

extends CharacterBody2D

## Signals

signal Jump
signal WallJump
signal AirJump
signal Landed

signal JumpReady
signal WallJumpReady

signal MoveLeft
signal MoveRight

signal Hurt

signal Attack_Mele
signal Attack_Ranged

## Vars

# Onready

@onready var DamageComponentScene: PackedScene = preload("res://Scenes/Components/DamageComponent.tscn")
@onready var BulletScene: PackedScene = preload("res://Scenes/Player/Bullet.tscn")

# Exports

@export_subgroup("Stats")
@export var State: String

@export_subgroup("Init Stats")
@export var Health: float = 100.0
@export var RangedBullet: String = "Meow"

@export_subgroup("Components")
@export var c_BodyComponent: BodyComponent

# Inputs

var mele_cooldown = 0
var mele_cooldown_threshold = 0.35

var ranged_cooldown = 0
var ranged_cooldown_threshold = 0.15

# Movement

var speed = 600.0
var jump_force = -1000.0
var roll_force = 5000.0
var accel = 0.25
var dir = 1
var prevDir = 1

var jumping = false
var in_air = false
var climbing = false
var running = false
var idle = true
var attacking = false
var attacking_mele = false
var attacking_ranged = false
var rolling = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var rolling_timer = 0
var rolling_timer_threshold = 0.25

var air_jumps = 1
var air_jump_boost = 1.15
var current_air_jumps = 0

var wall_jumps = 0

var coyote_timer = 0.0
var coyote_timer_threshold = 0.1

var jump_buffer_timer = 0.0
var jump_buffer_timer_threshold = 0.1

#

## Functions

# Initialization

func InitializePlayer():
	c_BodyComponent.init(self, Health)

#

# Inputs

func handle_inputs(delta: float):
	
	mele_cooldown -= delta
	mele_cooldown = clampf(mele_cooldown, 0, mele_cooldown_threshold)
	
	rolling_timer -= delta
	rolling_timer = clampf(rolling_timer, 0, rolling_timer_threshold)
	
	if ranged_cooldown > 0:
		ranged_cooldown -= delta
		ranged_cooldown = clampf(ranged_cooldown, 0, ranged_cooldown_threshold)
	
	if Input.is_action_just_pressed("Player-Mele"):
		if mele_cooldown != 0: return
		
		mele_attack()
		mele_cooldown = mele_cooldown_threshold
	
	if Input.is_action_just_pressed("Player-Range"):
		if ranged_cooldown != 0: return
		
		ranged_attack()
		ranged_cooldown = ranged_cooldown_threshold
	
	if Input.is_action_just_pressed("Player-Roll"):
		roll()
	
	attacking = attacking_mele or attacking_ranged

# Attacks

func mele_attack():
	if not DamageComponentScene.can_instantiate() or attacking_ranged: return
	
	attacking_mele = true
	
	var newDamage: DamageComponent = DamageComponentScene.instantiate()
	var newCollisionShape: CollisionShape2D = CollisionShape2D.new()
	var newCircleShape: CircleShape2D = CircleShape2D.new()
	
	newDamage.add_child(newCollisionShape)
	
	newCircleShape.radius = DATA.BulletInformation[RangedBullet]["Special"]["Radius"]
	newCollisionShape.shape = newCircleShape
	newCollisionShape.debug_color = Color.RED
	
	get_tree().current_scene.add_child(newDamage)
	
	newDamage.position = self.position + Vector2(prevDir * 100, 0)
	
	newDamage.init(self, Player, DATA.BulletInformation[RangedBullet]["Special"]["Damage"])
	
	await get_tree().create_timer(0.1).timeout
	
	attacking_mele = false
	
	if newDamage: newDamage.free()

func ranged_attack():
	if RangedBullet == null or RangedBullet == "" or attacking_mele: return
	
	attacking_ranged = true
	
	var newBullet: Bullet = BulletScene.instantiate()
	
	get_tree().current_scene.add_child(newBullet)
	
	newBullet.create(RangedBullet, self, self.position, prevDir)
	
	await get_tree().create_timer(ranged_cooldown_threshold).timeout
	
	attacking_ranged = false

# Movement

func roll():
	
	if rolling_timer != 0: return
	if not running: return
	if climbing: return
	
	rolling = true
	velocity += Vector2(dir * roll_force, jump_force / 2)
	
	rolling_timer = rolling_timer_threshold
	
	await get_tree().create_timer(0.25).timeout
	
	rolling = false

func handle_movement(delta: float):
	
	if not is_on_floor():
		velocity.y += gravity * delta
		in_air = true
	else:
		if jumping: jumping = false; Landed.emit()
		
		in_air = false
		
		current_air_jumps = air_jumps
		coyote_timer = coyote_timer_threshold
	
	if is_on_wall() and in_air:
		wall_jumps = 1
		WallJumpReady.emit()
		
		climbing = true
	else: climbing = false
	
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
			
			jumping = true
			
		elif current_air_jumps > 0:
			velocity.y = jump_force * air_jump_boost
			current_air_jumps -= 1
			jump_buffer_timer = 0
			
			AirJump.emit()
			
			jumping = true
			
		elif wall_jumps > 0:
			velocity.y = jump_force * air_jump_boost
			wall_jumps -= 1
			jump_buffer_timer = 0
			
			WallJump.emit()
			
			jumping = true
		
	dir = Input.get_axis("Player-MoveLeft", "Player-MoveRight")
		
	if dir:
		prevDir = dir
		
		velocity.x = lerp(velocity.x, dir * speed, accel)
		running = true
		
		if dir == -1: $AnimatedSprite2D.flip_h = true
		else: $AnimatedSprite2D.flip_h = false
		
	else:
		velocity.x = lerp(velocity.x, dir * speed, accel)
		running = false
		
	if not jumping and not in_air and not running: idle = true
	elif jumping or in_air or running: idle = false

#

# Animations & State

func handle_state():
	
	if rolling:
		State = "roll"
		return
	
	if attacking:
		
		if attacking_mele:
			State = "attack_mele"
		
		if attacking_ranged:
			State = "attack_ranged"
		
		return
	
	if climbing:
		State = "climb"
		return
	
	if idle:
		State = "idle"
		return
	
	if jumping:
		State = "jump"
		return
	
	if in_air and not jumping:
		State = "fall"
		return
	
	if running:
		State = "run"
	

func handle_animations():
	
	var current_anims = [ # temp
		
		"jump",
		"idle",
		"run",
		"roll",
		"attack_ranged",
		"climb"
		
	] #temp
	
	if State == "": return
	if not current_anims.has(State): return
	
	$AnimatedSprite2D.animation = State
	$AnimatedSprite2D.play()

## Connectors

# Phys_Proc

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_inputs(delta)
	handle_state()
	handle_animations()
	
	#print(State)
	
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

func signal_Landed():
	pass

func signal_WallJumpReady():
	pass

func signal_MoveLeft():
	pass

func signal_MoveRight():
	pass

func signal_Hurt():
	print("Hurt me owie owie")

func signal_AttackMele():
	pass

func signal_AttackRanged():
	pass

#

# Ready

func _ready() -> void:
	# Connect Signals and Functions
	Jump.connect(signal_Jump)
	WallJump.connect(signal_WallJump)
	AirJump.connect(signal_AirJump)
	JumpReady.connect(signal_JumpReady)
	Landed.connect(signal_Landed)
	WallJumpReady.connect(signal_WallJumpReady)
	MoveLeft.connect(signal_MoveLeft)
	MoveRight.connect(signal_MoveRight)
	Hurt.connect(signal_Hurt)
	Attack_Mele.connect(signal_AttackMele)
	Attack_Ranged.connect(signal_AttackRanged)
	
	# Initialize the Player
	InitializePlayer()

#

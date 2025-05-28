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

@onready var DamageComponentScene : PackedScene = preload("res://Scenes/Components/DamageComponent.tscn")

# Exports

@export_subgroup("Init Stats")
@export var Health: float = 100.0
@export var MeleDamage: float = 10.0
@export var MeleDamageRadius : float = 100.0
@export var RangedDamage: float = 5.0
@export var RangedBullet : String = "Regular"

@export_subgroup("Components")
@export var c_BodyComponent: BodyComponent

# Inputs

var mele_cooldown = 0
var mele_cooldown_threshold = 0.35

var ranged_cooldown = 0
var ranged_cooldown_threshold = 0.15

# Animation

var current_animation = "idle"

# Movement

var speed = 600.0
var jump_force = -1000.0
var accel = 0.25
var dir = 1
var prevDir = 1

var jumping = false :
	set(v):
		jumping = v
		if v: current_animation = "jump"
		else: current_animation = "idle"

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
	c_BodyComponent.init(self, Health)

#

# Inputs

func handle_inputs(delta: float):
	if mele_cooldown > 0:
		mele_cooldown -= delta
		mele_cooldown = clampf(mele_cooldown, 0, mele_cooldown_threshold)
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

# Attacks

func mele_attack():
	
	if not DamageComponentScene.can_instantiate(): return
	
	var newDamage : DamageComponent = DamageComponentScene.instantiate()
	var newCollisionShape : CollisionShape2D = CollisionShape2D.new()
	var newCircleShape : CircleShape2D = CircleShape2D.new()
	
	newDamage.add_child(newCollisionShape)
	
	newCircleShape.radius = MeleDamageRadius
	newCollisionShape.shape = newCircleShape
	newCollisionShape.debug_color = Color.RED
	
	get_tree().current_scene.add_child(newDamage)
	
	newDamage.position = self.position + Vector2(prevDir * 100,0)
	
	newDamage.init(self, MeleDamage)
	
	await get_tree().create_timer(0.1).timeout
	
	if newDamage: newDamage.free()

func ranged_attack():
	
	if RangedBullet == null or RangedBullet == "": return
	
	var newBulletScene : PackedScene = load("res://Scenes/Player/Bullets/" + RangedBullet + ".tscn")
	var newBullet : Bullet = newBulletScene.instantiate()
	
	get_tree().current_scene.add_child(newBullet)
	
	newBullet.create(self, self.position + Vector2(prevDir * 50.0, 0), prevDir)

# Movement

func handle_movement(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if jumping: Landed.emit()
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
		
		prevDir = dir
		velocity.x = lerp(velocity.x, dir * speed, accel)
		
		if dir == -1: $AnimatedSprite2D.flip_h = true
		else: $AnimatedSprite2D.flip_h = false
	else:
		velocity.x = lerp(velocity.x, dir * speed, accel)

#

# Animations

func handle_animations():
	
	if current_animation == "jump": $AnimatedSprite2D.animation = current_animation; $AnimatedSprite2D.play(); return
	
	if dir == 0 and is_on_floor():
		current_animation = "idle"
	
	if dir != 0 and is_on_floor():
		current_animation = "run"
	
	$AnimatedSprite2D.animation = current_animation
	$AnimatedSprite2D.play()

## Connectors

# Phys_Proc

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_inputs(delta)
	handle_animations()
	
	move_and_slide()

#

# Signals

func signal_Jump():
	jumping = true

func signal_WallJump():
	pass

func signal_AirJump():
	pass

func signal_JumpReady():
	pass

func signal_Landed():
	jumping = false

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

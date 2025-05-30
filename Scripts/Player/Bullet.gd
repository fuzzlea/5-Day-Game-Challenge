class_name Bullet
extends StaticBody2D

signal Explode(body)

var Sender
@export var BulletType : String
@export var Dir : float = 1.0

@onready var DamageScene : PackedScene = preload("res://Scenes/Components/DamageComponent.tscn")

var Decay = 0

var speed_increase : float = 0.0
var speed_kill : int = 1

func move_bullet():
	match BulletType:
		"Meow":
			position += Vector2(DATA.BulletInformation[BulletType]["Ranged"]["Speed"] * (Dir + (speed_increase * Dir)), sin(randf_range(-10,10)) * randf_range(-0.25,3) ) * Vector2(speed_kill, speed_kill)
		_:
			#position += Vector2(DATA.BulletInformation[BulletType]["Ranged"]["Speed"],0)
			pass

func explode(body):
	
	speed_kill = 0
	if body: position = body.global_position
	
	$Particle.visible = true
	
	$AnimatedSprite2D.visible = false
	$Particle.play(BulletType.to_lower())
	
	z_index = 100
	
	$Particle.animation_finished.connect(func():
		queue_free()
	)

func create(bullet : String, from, where : Vector2, dir : float):
	
	if not DamageScene.can_instantiate(): return
	
	$Particle.visible = false
	
	position = where
	
	Sender = from
	Dir = dir
	BulletType = bullet
	Decay = DATA.BulletInformation[BulletType]["Ranged"]["Decay"]
	
	var newDamage : DamageComponent = DamageScene.instantiate()
	var newCollisionShape : CollisionShape2D = $CollisionShape2D.duplicate()
	
	newDamage.add_child(newCollisionShape)
	add_child(newDamage)
	
	newDamage.init(from, Bullet, DATA.BulletInformation[BulletType]["Ranged"]["Damage"])
	
	scale = Vector2(0,0)
	get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).tween_property(self, "scale", Vector2(2,2), 0.2)
	
	var tempd = "right"; if dir < 0: tempd = "left"
	
	$AnimatedSprite2D.animation = bullet.to_lower() + "_" + tempd

func _physics_process(delta: float) -> void:
	
	speed_increase += delta
	
	if Decay <= 0: explode(null)
	
	move_bullet()
	
	Decay -= delta

func _ready():
	Explode.connect(explode)

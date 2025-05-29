class_name Bullet
extends StaticBody2D

signal Explode(body)

var Sender
@export var Speed : float = 15.0
@export var Damage : float = 10.0
@export var Dir : float = 1.0
@export var Decay : float = 5.0

@onready var DamageScene : PackedScene = preload("res://Scenes/Components/DamageComponent.tscn")

var speed_increase : float = 0.0
var speed_kill : int = 1

func explode(body : BodyComponent):
	
	speed_kill = 0
	position = body.global_position
	
	$AnimatedSprite2D.visible = false
	$Particle.play("poof")
	
	z_index = 100
	
	$Particle.animation_finished.connect(func():
		queue_free()
	)

func create(from, where : Vector2, dir : float):
	
	if not DamageScene.can_instantiate(): return
	
	position = where
	
	Sender = from
	Dir = dir
	
	var newDamage : DamageComponent = DamageScene.instantiate()
	var newCollisionShape : CollisionShape2D = $CollisionShape2D.duplicate()
	
	newDamage.add_child(newCollisionShape)
	add_child(newDamage)
	
	newDamage.init(from, Bullet, Damage)
	
	scale = Vector2(0,0)
	get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).tween_property(self, "scale", Vector2(2,2), 0.2)
	
	if dir > 0:
		$AnimatedSprite2D.animation = "right"
	else:
		$AnimatedSprite2D.animation = "left"

func _physics_process(delta: float) -> void:
	
	speed_increase += delta
	if Decay <= 0: queue_free()
	
	position += Vector2(Speed * (Dir + (speed_increase * Dir)), sin(randf_range(-10,10)) * randf_range(-0.25,3) ) * Vector2(speed_kill, speed_kill)
	Decay -= delta

func _ready():
	Explode.connect(explode)

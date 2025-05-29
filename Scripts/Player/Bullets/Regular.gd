class_name Bullet
extends StaticBody2D

var Sender
@export var Speed : float = 15.0
@export var Damage : float = 10.0
@export var Dir : float = 1.0
@export var Decay : float = 2.0

@onready var DamageScene : PackedScene = preload("res://Scenes/Components/DamageComponent.tscn")

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
	
	$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	
	if Decay <= 0: queue_free()
	
	position += Vector2(Speed * Dir, sin(randf_range(-10,10)) )
	Decay -= delta

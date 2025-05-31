class_name Enemy
extends CharacterBody2D

signal Hurt

@export_subgroup("Stats")
@export var _Enemy : Dictionary
@export var Health : float = 0.0
@export var Speed : float = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var hash_enemy_info : Dictionary = {
	
	"Frank": {
		"Scale": 0.5,
		"CollisionShapePosition": Vector2(0,-64)
	}
	
}

func remove_bcs():
	$EnemyExtras.queue_free()

func signal_hurt():
	print($BodyComponent.Health)

func signal_die(from : DamageComponent):
	print('bleh from: ' + from.get_parent().name)
	queue_free() 

func init_extras(_name : String):
	match _name:
		"Frank":
			
			var bodyCollisionShape : CollisionShape2D = $EnemyExtras/Frank/BodyCollisionShape
			var collisionShape : CollisionShape2D = $EnemyExtras/Frank/CollisionShape
			var damageComponent : DamageComponent = $EnemyExtras/Frank/DamageComponent
			
			bodyCollisionShape.owner = null
			collisionShape.owner = null
			damageComponent.owner = null
			
			bodyCollisionShape.reparent($BodyComponent)
			collisionShape.reparent(self)
			damageComponent.reparent(self)
			
			bodyCollisionShape.disabled = false
			collisionShape.disabled = false
			
			bodyCollisionShape.position = Vector2($AnimatedSprite2D.position.x / 2, $AnimatedSprite2D.position.y / 2)
			damageComponent.position = Vector2($AnimatedSprite2D.position.x / 2, $AnimatedSprite2D.position.y / 2)
			
			if hash_enemy_info.has(_name):
				collisionShape.position = hash_enemy_info[_name]["CollisionShapePosition"]
			
			damageComponent.init(self, Enemy)
			
		_:
			pass

func init(type : String):
	
	if not DATA.EnemyInformation.has(type): return
	
	_Enemy = DATA.EnemyInformation[type]
	Health = _Enemy["Health"]
	Speed = _Enemy["Speed"]
	
	init_extras(type)
	remove_bcs()
	
	$BodyComponent.init(self, Health)
	
	if hash_enemy_info.has(type):
		scale = Vector2(hash_enemy_info[type]["Scale"],hash_enemy_info[type]["Scale"])
	
	print(type + " Initialized | \nHealth: " + str(Health) + "\nSpeed: " + str(Speed) + "\n")

func _ready():
	Hurt.connect(signal_hurt)
	$BodyComponent.Die.connect(signal_die)

#

func apply_gravity(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	

func _physics_process(delta: float) -> void:
	
	if _Enemy["UseGravity"]:
		apply_gravity(delta)
	
	move_and_slide()

# Make sure to add a collision shape as child 0

class_name BodyComponent
extends Area2D

signal Die(from : DamageComponent)

var User : CharacterBody2D
var Health : float
var CollisionShape : CollisionShape2D
var Dead : bool

func init(user: CharacterBody2D, health: float = 100.0):
	
	if health == -1: health = INF
	
	print("Body Initialized For: " + user.name + "\nHealth: " + str(health))
	
	User = user
	Health = health
	CollisionShape = get_child(0)
	Dead = false
	
	area_entered.connect(f_area_entered)
	area_exited.connect(f_area_exited)

func hit(with : DamageComponent):
	
	if (User is Player) and (with.Owner is Player): return
	
	Health -= with.Damage
	
	if Health <= 0:
		Dead = true
		Die.emit(with)
	
	with.hit(self)

func f_area_entered(a : Area2D):
	if a is DamageComponent: hit(a)

func f_area_exited(_a : Area2D):
	pass

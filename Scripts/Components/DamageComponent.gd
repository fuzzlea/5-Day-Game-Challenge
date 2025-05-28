class_name DamageComponent
extends Area2D

var Owner
@export var Damage : float

func init(owner, damage: float = 10.0):
	Owner = owner
	Damage = damage

func hit(what : BodyComponent):
	
	if what.User is Player and Owner is Player: return
	
	queue_free()
	print(self.name + " Hit " + what.get_parent().name + "!\nHealth: " + str(what.Health))

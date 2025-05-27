class_name DamageComponent
extends Area2D

@export var Damage : float

func init(damage: float = 10.0):
	Damage = damage

func hit(what : BodyComponent):
	queue_free()
	
	print(self.name + " Hit " + what.get_parent().name + "!\nHealth: " + str(what.Health))

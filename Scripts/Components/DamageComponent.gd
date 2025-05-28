class_name DamageComponent
extends Area2D

var Owner
@export var Damage : float

@warning_ignore("shadowed_variable_base_class")
func init(owner, damage: float = 10.0):
	Owner = owner
	Damage = damage

func hit(what : BodyComponent):
	
	if (what.User is Player) and (Owner is Player): return
	
	queue_free()
	print(self.name + " Hit " + what.get_parent().name + "!\nHealth: " + str(what.Health))
	
	if what.User is Player:
		what.User.emit_signal("Hurt")
	if what.User is Enemy:
		what.User.emit_signal("Hurt")

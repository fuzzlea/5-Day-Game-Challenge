class_name DamageComponent
extends Area2D

var Owner
var Type
@export var Damage : float

@warning_ignore("shadowed_variable_base_class")
func init(owner, type, damage: float = 1.0):
	Type = type
	Owner = owner
	Damage = damage

func hit(what : BodyComponent):
	
	if (what.User is Player) and (Owner is Player): return
	if (what.User is Enemy) and (Owner is Enemy): return
	
	#print(self.name + " Hit " + what.get_parent().name + "!\nHealth: " + str(what.Health))
	
	if Type == Bullet:
		get_parent().emit_signal("Explode", what)
	else:
		queue_free()
	
	if what.User is Player:
		what.User.emit_signal("Hurt")
	if what.User is Enemy:
		what.User.emit_signal("Hurt")
 

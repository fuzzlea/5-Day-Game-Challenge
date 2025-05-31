extends CharacterBody2D

signal Hurt

@export_category("Stats")
@export var Health : float = -1.0

@export_category("Components")
@export var c_BodyComponent : BodyComponent

func hit():
	self.modulate = Color(5,5,5)
	self.create_tween().tween_property(self, "modulate", Color(1,1,1), 0.1)

func _ready():
	c_BodyComponent.init(self, Health)
	
	Hurt.connect(hit)

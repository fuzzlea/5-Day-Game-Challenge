extends CharacterBody2D 

@export var _E : String

@onready var EnemyScene : PackedScene = preload("res://Scenes/Enemies/Enemy.tscn")

var E : Enemy

func _ready():
	
	if not EnemyScene.can_instantiate() or not _E: return
	
	$Sprite2D.visible = false
	
	E = EnemyScene.instantiate()
	
	get_tree().current_scene.add_child.call_deferred(E)
	E.position = position
	
	E.init(_E)
	
	queue_free()

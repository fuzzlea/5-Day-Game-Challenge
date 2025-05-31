class_name Enemy
extends CharacterBody2D

signal Hurt

@export_subgroup("Stats")
@export var Health : float = 0.0
@export var Speed : float = 0.0

func init():
	pass

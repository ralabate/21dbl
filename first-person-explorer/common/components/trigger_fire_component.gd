class_name TriggerFireComponent extends Node


signal node_instantiated(badguy: Node3D, location: Vector3, direction: Vector3)
signal fired

@export var projectile_template: PackedScene
@export var vertical_offset: float

var ability_template: PackedScene
var direction: Vector3
var can_fire: bool


func _ready() -> void:
	InstantiationStation.register_instantiator(self)


func _physics_process(delta: float) -> void:
	var template: PackedScene
	
	if can_fire:
		if Input.is_action_pressed("fire_projectile"):
			template = projectile_template
		elif Input.is_action_pressed("trigger_ability"):
			template = ability_template

	if template:
		node_instantiated.emit(
			template.instantiate(),
			get_parent().position + (Vector3.UP * vertical_offset),
			direction
		)

		fired.emit()

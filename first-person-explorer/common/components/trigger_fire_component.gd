class_name TriggerFireComponent extends Node


signal node_instantiated(badguy: Node3D, location: Vector3, direction: Vector3)
signal fired

@export var projectile_speed: float
@export var vertical_offset: float

var ability_template: PackedScene
var direction: Vector3
var can_fire: bool


func _ready() -> void:
	InstantiationStation.register_instantiator(self)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("trigger_ability") and can_fire:
		node_instantiated.emit(
			ability_template.instantiate(),
			get_parent().position + (Vector3.UP * vertical_offset),
			direction
		)
		fired.emit()

extends Area3D


signal node_instantiated(node: Node3D, location: Vector3, direction: Vector3)

@export var explosion_template: PackedScene
@export var damage_amount: int

@onready var timer = %Timer

var damage_list = []


func _ready() -> void:
	InstantiationStation.register_instantiator(self)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)


func _on_body_entered(node: Node3D) -> void:
	damage_list.append(node)


func _on_body_exited(node: Node3D) -> void:
	damage_list.erase(node)


func _on_timer_timeout() -> void:
	for badguy in damage_list:
		if badguy.has_node("HealthComponent"):
			var health_component = badguy.get_node("HealthComponent") as HealthComponent
			health_component.damage(damage_amount)

	node_instantiated.emit(
		explosion_template.instantiate(),
		global_position,
		global_basis.z
	)

	queue_free()

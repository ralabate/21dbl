class_name AbilityInventory extends Node


signal node_instantiated(node: Node3D, location: Vector3, direction: Vector3)
signal selected_ability(scene: PackedScene)


@export var abilities: Array[PackedScene]

var _current_ability = 0


func _ready() -> void:
	InstantiationStation.register_instantiator(self)


func _process(delta: float) -> void:
	var previous = _current_ability
	if Input.is_action_just_pressed("ability_1"):
		_current_ability = 0
	elif Input.is_action_just_pressed("ability_2"):
		_current_ability = 1

	if _current_ability != previous:
		var selected = abilities[_current_ability]
		Log.info("New ability selected: [%s]" % selected)
		selected_ability.emit(selected)


func get_current_ability() -> PackedScene:
	return abilities[_current_ability]

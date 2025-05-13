class_name AbilityInventory extends Node


signal node_instantiated(node: Node3D, location: Vector3, direction: Vector3)
signal selected_ability(scene: PackedScene)


var abilities = [
	preload("res://player/bullet.tscn"),
	preload("res://player/mine.tscn"),
	preload("res://player/decoy.tscn"),
]

var current_ability = 0


func _ready() -> void:
	InstantiationStation.register_instantiator(self)


func _process(delta: float) -> void:
	var previous = current_ability
	if Input.is_action_just_pressed("ability_select_up"):
		current_ability += 1
	elif Input.is_action_just_pressed("ability_select_down"):
		current_ability -= 1

	current_ability = clampi(current_ability, 0, abilities.size() - 1)
	if current_ability != previous:
		var selected = abilities[current_ability]
		Log.info("New ability selected: [%s]" % selected)
		selected_ability.emit(selected)


func get_current_ability() -> PackedScene:
	return abilities[current_ability]

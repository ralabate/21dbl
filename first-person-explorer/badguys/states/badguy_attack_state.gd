extends FSMState
class_name BadguyAttackState


@export var attack_component: BaseAttackComponent


func enter() -> void:
	super.enter()
	await attack_component.attack()
	transition("")

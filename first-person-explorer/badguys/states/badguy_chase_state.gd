extends FSMState
class_name BadguyChaseState


@export var navigation_component: NavigationComponent
@export var attack_distance: float


func enter() -> void:
	super.enter()
	navigation_component.start_navigation()


func exit() -> void:
	super.exit()
	navigation_component.stop_navigation()


func update(delta: float) -> void:
	if navigation_component.distance_to_target() <= attack_distance:
		transition("BadguyAttackState")
	else:
		navigation_component.update_target_position()

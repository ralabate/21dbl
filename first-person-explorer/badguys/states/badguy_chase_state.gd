extends FSMState
class_name BadguyChaseState


@export var navigation_component: NavigationComponent
@export var attack_distance: float


func enter() -> void:
	super.enter()

	var target = get_tree().get_first_node_in_group("player")
	assert(target != null, "The player does not exist!")

	navigation_component.start_navigation(target)


func exit() -> void:
	super.exit()
	navigation_component.stop_navigation()


func update(delta: float) -> void:
	if navigation_component.distance_to_target() <= attack_distance:
		transition("BadguyAttackState")
	else:
		navigation_component.update_target_position()


func _on_chase_timer_timeout() -> void:
	navigation_component.update_target_position()

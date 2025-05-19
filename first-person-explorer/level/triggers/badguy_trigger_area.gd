extends Area3D


var _triggered = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not _triggered and body.is_in_group("player"):
		for overlapping in get_overlapping_bodies():
			if overlapping is Badguy:
				var badguy = overlapping as Badguy
				badguy.enter_chase_state(body)
				_triggered = true

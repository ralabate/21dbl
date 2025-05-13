extends Area3D


@export var type: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(not type.is_empty(), "Type not assigned!")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.has_node("KeyInventoryComponent"):
		var key_inventory = body.get_node("KeyInventoryComponent") as KeyInventoryComponent
		key_inventory.add_key(type)
		Log.info("Picked up key: [%s]" % type)

	queue_free()

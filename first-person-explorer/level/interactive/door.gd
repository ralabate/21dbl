extends Area3D


@export var required_key: String
@export var opening_speed: float = 1.0

@onready var animation_player = %AnimationPlayer

var is_open: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	animation_player.speed_scale = opening_speed
	is_open = false


func _on_body_entered(body: Node3D) -> void:
	var can_open = false

	if required_key.is_empty():
		can_open = true
	elif body.has_node("KeyInventoryComponent"):
		var key_inventory = body.get_node("KeyInventoryComponent") as KeyInventoryComponent
		can_open = key_inventory.has_key(required_key)
		Log.info("Door requires key: [%s]" % required_key)
	
	if can_open:
		animation_player.play("open")
		is_open = true


func _on_body_exited(body: Node3D) -> void:
	if is_open:
		animation_player.play_backwards("open")
		is_open = false

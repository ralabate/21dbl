extends Area3D


@export var required_key: DoorKey.Type = DoorKey.Type.NONE
@export var opening_speed: float = 1.0
@export var open_once: bool = false

@onready var animation_player = %AnimationPlayer

var is_open: bool
var body_list: Array[Node3D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	animation_player.speed_scale = opening_speed
	is_open = false


func _on_body_entered(body: Node3D) -> void:
	if is_open:
		return

	var can_open = false

	if required_key == DoorKey.Type.NONE:
		can_open = true
	elif body.has_node("KeyInventoryComponent"):
		var key_inventory = body.get_node("KeyInventoryComponent") as KeyInventoryComponent
		can_open = key_inventory.has_key(required_key)
		Log.info("Door requires key: [%s]" % required_key)
	
	if can_open:
		animation_player.play("open")
		is_open = true
		
		if open_once:
			await animation_player.animation_finished
			queue_free()
		else:
			body_list.append(body)


func _on_body_exited(body: Node3D) -> void:
	body_list.erase(body)

	if is_open and body_list.is_empty():
		animation_player.play_backwards("open")
		is_open = false

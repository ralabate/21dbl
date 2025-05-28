extends CharacterBody3D


@export var speed = 250
@export var sprint_speed = 500
@export var jump_velocity = 4.5
@export var head_turning_rate = 0.1
@export var headbob_speed = 1.0
@export var headbob_amount = 0.05
@export var headbob_frequency = 10.0

@onready var health_component: HealthComponent = %HealthComponent
@onready var trigger_fire_component: TriggerFireComponent = %TriggerFireComponent
@onready var ability_inventory: AbilityInventory = %AbilityInventory
@onready var key_inventory_component: KeyInventoryComponent = %KeyInventoryComponent
@onready var uni_ammo_component: UniversalAmmoComponent = %UniversalAmmoComponent
@onready var camera: Camera3D = %Camera3D

# TODO: Move UI stuff out of here.
@onready var weapon_sprite: AnimatedSprite2D = %WeaponSprite
@onready var hurt_flash: ColorRect = %HurtFlashRect
@onready var health_bar: ProgressBar = %HealthBar
@onready var key_inventory_container: HBoxContainer = %KeyInventoryContainer

var _is_sprinting = false
var default_camera_pos: Vector3
var headbob_timer = 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	health_component.damage_received.connect(_on_damage_received)
	ability_inventory.selected_ability.connect(_on_ability_selected)
	key_inventory_component.key_acquired.connect(_on_key_acquired)
	uni_ammo_component.amount_changed.connect(_on_ammo_amount_changed)

	trigger_fire_component.fired.connect(_on_weapon_fired)
	trigger_fire_component.ammo_requested.connect(_on_ammo_requested)
	trigger_fire_component.can_fire = true
	trigger_fire_component.ability_template = ability_inventory.get_current_ability()
	
	default_camera_pos = camera.position

	# TODO: Move UI stuff out of here.
	hurt_flash.visible = false
	weapon_sprite.play("idle")
	update_health_bar_value()
	for key_icon in key_inventory_container.get_children():
		key_icon.visible = false

	$HUD/AbilityLabel.text = trigger_fire_component.ability_template.resource_path
	$HUD/AmmoLabel.text = str(uni_ammo_component.amount)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-deg_to_rad(event.screen_relative.x * head_turning_rate))
			trigger_fire_component.direction = global_transform.basis.z


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed

	if direction:
		velocity.x = direction.x * current_speed * delta
		velocity.z = direction.z * current_speed * delta
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
	
	if velocity.length() > 0.1:
		headbob_timer += delta * headbob_frequency
		camera.position = default_camera_pos + Vector3(
			0,
			sin(headbob_timer * headbob_speed) * headbob_amount,
			0
		)
	else:
		headbob_timer = 0.0
		camera.position = default_camera_pos


func update_health_bar_value() -> void:
	health_bar.value = float(health_component.current_health) / health_component.MAX_HEALTH


func _on_damage_received(amount: int) -> void:
	hurt_flash.visible = true
	await get_tree().create_timer(0.1).timeout
	hurt_flash.visible = false
	update_health_bar_value()


func _on_weapon_fired() -> void:
	weapon_sprite.play("fire")
	trigger_fire_component.can_fire = false
	await weapon_sprite.animation_finished
	weapon_sprite.play("idle")
	trigger_fire_component.can_fire = true


func _on_ammo_requested() -> void:
	var amount_required = ability_inventory.get_ammo_required()
	if uni_ammo_component.has_ammo(amount_required):
		trigger_fire_component.use_current_ability()
		uni_ammo_component.use_ammo(amount_required)


func _on_ammo_amount_changed(new_amount: int) -> void:
	$HUD/AmmoLabel.text = str(new_amount)


func _on_ability_selected(scene: PackedScene) -> void:
	trigger_fire_component.ability_template = scene
	$HUD/AbilityLabel.text = trigger_fire_component.ability_template.resource_path


func _on_key_acquired(key: DoorKey.Type) -> void:
	var node_name: String
	match key:
		DoorKey.Type.RED:
			node_name = "RedKeyIcon"
		DoorKey.Type.YELLOW:
			node_name = "YellowKeyIcon"
		DoorKey.Type.BLUE:
			node_name = "BlueKeyIcon"
			
	var key_icon = key_inventory_container.get_node(node_name)
	if key_icon:
		key_icon.visible = true

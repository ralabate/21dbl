extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var HEAD_TURNING_RATE = 0.1

@onready var health_component: HealthComponent = %HealthComponent
@onready var trigger_fire_component: TriggerFireComponent = %TriggerFireComponent
@onready var ability_inventory: AbilityInventory = %AbilityInventory
@onready var weapon_sprite: AnimatedSprite2D = %WeaponSprite
@onready var hurt_flash: ColorRect = %HurtFlashRect
@onready var health_bar: ProgressBar = %HealthBar


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	health_component.damage_received.connect(_on_damage_received)
	trigger_fire_component.fired.connect(_on_weapon_fired)
	trigger_fire_component.can_fire = true
	trigger_fire_component.ability_template = ability_inventory.get_current_ability()
	ability_inventory.selected_ability.connect(_on_ability_selected)

	hurt_flash.visible = false
	weapon_sprite.play("idle")

	update_health_bar_value()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-deg_to_rad(event.screen_relative.x * HEAD_TURNING_RATE))
			$Camera3D.rotate_x(-deg_to_rad(event.screen_relative.y * HEAD_TURNING_RATE))
			$TriggerFireComponent.direction = global_transform.basis.z


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


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


func _on_ability_selected(scene: PackedScene) -> void:
	trigger_fire_component.ability_template = scene

@tool
extends Area3D


@export var node_list: Array[Node3D]:
	set(new_list):
		node_list = new_list
		build_meshes()

@export var draw_lines_ingame = false
@export var debug_line_color: Color

var mesh_instances: Array[MeshInstance3D]
var _triggered = false
var line_material = StandardMaterial3D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

	line_material.vertex_color_use_as_albedo = true
	build_meshes()


func _process(delta: float) -> void:
	if draw_lines_ingame or Engine.is_editor_hint():
		draw_all_lines()


func draw_all_lines() -> void:
	for idx in node_list.size():
		var node = node_list[idx]
		if node:
			var from = Vector3.ZERO
			var to = node.global_position - self.global_position
			draw_line(idx, from, to)


func build_meshes() -> void:
	for mesh_instance in mesh_instances:
		mesh_instance.queue_free()
	mesh_instances.clear()

	for node in node_list:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = ImmediateMesh.new()
		mesh_instances.append(mesh_instance)
		add_child(mesh_instance)


func draw_line(idx: int, from: Vector3, to: Vector3) -> void:
	var immediate_mesh = mesh_instances[idx].mesh as ImmediateMesh
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, line_material)
	immediate_mesh.surface_set_color(debug_line_color)
	immediate_mesh.surface_add_vertex(from)
	immediate_mesh.surface_add_vertex(to)
	immediate_mesh.surface_end()


func _on_body_entered(body: Node3D) -> void:
	if not _triggered and body.is_in_group("player"):
		for node in node_list:
			if node == null or node.is_queued_for_deletion():
				continue
			if node.has_method("wake"):
				node.wake()
			_triggered = true

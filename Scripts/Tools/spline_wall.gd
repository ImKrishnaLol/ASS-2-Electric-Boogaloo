@tool
extends Path2D
class_name SplineWall

enum BlockType { BLUE, ORANGE, GREEN, PURPLE }

@export var block_scene: PackedScene:
	set(value):
		block_scene = value
		update_wall()

@export var wall_physics_material: PhysicsMaterial:
	set(value):
		wall_physics_material = value
		update_wall()

@export var block_spacing: float = 24.0:
	set(value):
		block_spacing = value
		update_wall()

@export var default_block_size: Vector2 = Vector2(20.0, 10.0):
	set(value):
		default_block_size = value
		update_wall()

@export var blue_block_color: Color = Color(0.2, 0.45, 0.95):
	set(value):
		blue_block_color = value
		update_wall()

@export var orange_block_color: Color = Color(0.95, 0.5, 0.1):
	set(value):
		orange_block_color = value
		update_wall()

@export var green_block_color: Color = Color(0.2, 0.8, 0.3):
	set(value):
		green_block_color = value
		update_wall()

@export var purple_block_color: Color = Color(0.7, 0.3, 0.9):
	set(value):
		purple_block_color = value
		update_wall()

@export var block_types: Array[BlockType] = []:
	set(value):
		block_types = value
		update_wall()

@export var closed_loop: bool = false:
	set(value):
		closed_loop = value
		update_wall()

@export var bake_interval: float = 4.0:
	set(value):
		bake_interval = value
		if curve:
			curve.bake_interval = bake_interval
		update_wall()

var blocks_container: Node2D

func _ready() -> void:
	setup_nodes()
	_connect_curve()
	update_wall()

func _exit_tree() -> void:
	if Engine.is_editor_hint() and blocks_container:
		blocks_container.queue_free()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_connect_curve()

func _connect_curve() -> void:
	if curve:
		if not curve.changed.is_connected(update_wall):
			curve.changed.connect(update_wall)
			update_wall()

func setup_nodes() -> void:
	blocks_container = get_node_or_null("Blocks") as Node2D
	if not blocks_container:
		blocks_container = Node2D.new()
		blocks_container.name = "Blocks"
		add_child(blocks_container)
		_set_owner_recursive(blocks_container)

func _set_owner_recursive(target_node: Node) -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	var edited_root: Node = get_tree().edited_scene_root
	if not edited_root:
		return
	if target_node != edited_root and not target_node.owner:
		target_node.owner = edited_root
	for child: Node in target_node.get_children():
		_set_owner_recursive(child)

func _is_curve_closed() -> bool:
	if not curve or curve.get_point_count() < 3:
		return false
	var first_point: Vector2 = curve.get_point_position(0)
	var last_point: Vector2 = curve.get_point_position(curve.get_point_count() - 1)
	return first_point.distance_to(last_point) < 4.0

func update_wall() -> void:
	if not curve or not is_inside_tree() or not blocks_container:
		return

	for child: Node in blocks_container.get_children():
		blocks_container.remove_child(child)
		child.queue_free()

	var curve_length: float = curve.get_baked_length()
	if curve_length <= 0.0 or block_spacing <= 0.0:
		return

	var is_closed: bool = closed_loop or _is_curve_closed()
	var total_blocks: int = 0
	var effective_spacing: float = block_spacing

	if is_closed:
		total_blocks = roundi(curve_length / block_spacing)
		total_blocks = maxi(1, total_blocks)
		effective_spacing = curve_length / float(total_blocks)
	else:
		total_blocks = ceili(curve_length / block_spacing)

	if total_blocks <= 0:
		return

	if block_types.size() != total_blocks:
		block_types.resize(total_blocks)

	var half_height: float = default_block_size.y / 2.0
	var first_start_normal: Vector2 = Vector2.ZERO
	var first_start_point: Vector2 = Vector2.ZERO

	for block_index: int in range(total_blocks):
		var start_distance: float = float(block_index) * effective_spacing
		var end_distance: float = float(block_index + 1) * effective_spacing

		if not is_closed:
			end_distance = minf(curve_length, end_distance)

		var start_point: Vector2 = curve.sample_baked(start_distance)
		var end_point: Vector2 = curve.sample_baked(end_distance)

		var start_dir: Vector2 = (curve.sample_baked(minf(curve_length, start_distance + 1.0)) - start_point).normalized()
		var end_dir: Vector2 = (curve.sample_baked(minf(curve_length, end_distance + 1.0)) - end_point).normalized()

		if start_dir == Vector2.ZERO:
			start_dir = Vector2.RIGHT
		if end_dir == Vector2.ZERO:
			end_dir = Vector2.RIGHT

		var start_normal: Vector2 = Vector2(-start_dir.y, start_dir.x)
		var end_normal: Vector2 = Vector2(-end_dir.y, end_dir.x)

		if block_index == 0:
			first_start_point = start_point
			first_start_normal = start_normal

		if is_closed and block_index == total_blocks - 1:
			end_point = first_start_point
			end_normal = first_start_normal

		var sample_center_distance: float = (start_distance + end_distance) / 2.0
		var center: Vector2 = curve.sample_baked(sample_center_distance)

		var top_left: Vector2 = (start_point + start_normal * half_height) - center
		var top_right: Vector2 = (end_point + end_normal * half_height) - center
		var bottom_right: Vector2 = (end_point - end_normal * half_height) - center
		var bottom_left: Vector2 = (start_point - start_normal * half_height) - center

		var polygon: PackedVector2Array = PackedVector2Array([top_left, top_right, bottom_right, bottom_left])
		var current_type: BlockType = block_types[block_index]

		var block_node: Node2D
		if block_scene:
			block_node = block_scene.instantiate() as Node2D
			block_node.position = center
			block_node.rotation = (end_point - start_point).angle()
			if "block_type" in block_node:
				block_node.set("block_type", current_type)
		else:
			block_node = _create_wedge_block(polygon, current_type)
			block_node.position = center

		block_node.name = "Block_" + str(block_index)
		blocks_container.add_child(block_node)
		_set_owner_recursive(block_node)

func _create_wedge_block(polygon: PackedVector2Array, type: BlockType) -> StaticBody2D:
	var body_node: StaticBody2D = StaticBody2D.new()
	body_node.physics_material_override = wall_physics_material
	body_node.add_to_group("breakable_blocks")
	body_node.set_meta("block_type", type)

	var group_name: String = "blue_blocks"
	var block_color: Color = blue_block_color

	match type:
		BlockType.ORANGE:
			group_name = "orange_blocks"
			block_color = orange_block_color
		BlockType.GREEN:
			group_name = "green_blocks"
			block_color = green_block_color
		BlockType.PURPLE:
			group_name = "purple_blocks"
			block_color = purple_block_color
		_:
			group_name = "blue_blocks"
			block_color = blue_block_color

	body_node.add_to_group(group_name)

	var collision_shape: CollisionPolygon2D = CollisionPolygon2D.new()
	collision_shape.polygon = polygon
	body_node.add_child(collision_shape)

	var visual_polygon: Polygon2D = Polygon2D.new()
	visual_polygon.polygon = polygon
	visual_polygon.color = block_color
	body_node.add_child(visual_polygon)

	return body_node

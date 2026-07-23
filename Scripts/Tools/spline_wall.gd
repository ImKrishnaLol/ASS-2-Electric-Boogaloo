@tool
extends Path2D
class_name SplineWall

@export var wall_width: float = 10.0:
	set(value):
		wall_width = value
		update_wall()

@export var wall_color: Color = Color.WHITE:
	set(value):
		wall_color = value
		update_wall()

@export var bake_interval: float = 4.0:
	set(value):
		bake_interval = value
		if curve:
			curve.bake_interval = bake_interval
		update_wall()

var line_node: Line2D
var body_node: AnimatableBody2D
var collision_node: CollisionPolygon2D

func _ready() -> void:
	setup_nodes()
	_connect_curve()
	update_wall()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_connect_curve()

func _connect_curve() -> void:
	if curve:
		curve.bake_interval = bake_interval
		if not curve.changed.is_connected(update_wall):
			curve.changed.connect(update_wall)
			update_wall()

func setup_nodes() -> void:
	line_node = get_node_or_null("Line2D")
	if not line_node:
		line_node = Line2D.new()
		line_node.name = "Line2D"
		add_child(line_node)
		# Assign ownership so dynamically created nodes are saved with the edited scene
		_set_node_owner(line_node)

	body_node = get_node_or_null("AnimatableBody2D")
	if not body_node:
		body_node = AnimatableBody2D.new()
		body_node.name = "AnimatableBody2D"
		add_child(body_node)
		_set_node_owner(body_node)

	collision_node = body_node.get_node_or_null("CollisionPolygon2D")
	if not collision_node:
		collision_node = CollisionPolygon2D.new()
		collision_node.name = "CollisionPolygon2D"
		body_node.add_child(collision_node)
		_set_node_owner(collision_node)

	collision_node.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	line_node.joint_mode = Line2D.LINE_JOINT_ROUND
	line_node.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line_node.end_cap_mode = Line2D.LINE_CAP_ROUND

func _set_node_owner(node: Node) -> void:
	if Engine.is_editor_hint() and is_inside_tree():
		var root_node: Node = get_tree().edited_scene_root
		if root_node and node != root_node and not node.owner:
			node.owner = root_node

func update_wall() -> void:
	if not curve or not is_inside_tree():
		return

	var points: PackedVector2Array = curve.get_baked_points()
	if points.size() < 2:
		if line_node:
			line_node.points = PackedVector2Array()
		if collision_node:
			collision_node.polygon = PackedVector2Array()
		return

	if line_node:
		line_node.points = points
		line_node.width = wall_width
		line_node.default_color = wall_color

	if collision_node:
		var polygons: Array[PackedVector2Array] = Geometry2D.offset_polyline(points, wall_width / 2.0, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
		if polygons.size() > 0:
			collision_node.polygon = polygons[0]

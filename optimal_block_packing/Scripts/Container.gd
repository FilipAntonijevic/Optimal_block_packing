extends Node3D

@onready var blocks_node = $Blocks

@export var height: float = 1000
@export var color: Color = Color(1, 1, 1)
@export var zoom_speed: float = 2.0   # koliko brzo zumira
@export var camera_min_height: float = 0
@export var camera_max_height: float = 1000

var camera_distance: float

func _ready() -> void:
	draw_container()
	camera_distance = max(GlobalData.container_width, GlobalData.container_depth)
	position_camera()
	
func draw_container() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.queue_free()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)

	var hw = GlobalData.container_width
	var hh = height
	var hd = GlobalData.container_depth

	var corners = [
		Vector3(0, 0, 0),
		Vector3(hw, 0, 0),
		Vector3(hw, hh, 0),
		Vector3(0, hh, 0),
		Vector3(0, 0, hd),
		Vector3(hw, 0, hd),
		Vector3(hw, hh, hd),
		Vector3(0, hh, hd)
	]

	var edges = [
		[0,1],[1,2],[2,3],[3,0],
		[4,5],[5,6],[6,7],[7,4],
		[0,4],[1,5],[2,6],[3,7]
	]

	for e in edges:
		st.set_color(color)
		st.add_vertex(corners[e[0]])
		st.set_color(color)
		st.add_vertex(corners[e[1]])

	var mesh = st.commit()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)

	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mesh_instance.material_override = mat

	position_camera()

func position_camera() -> void: 
	var camera = $Camera3D 
	var target = Vector3(GlobalData.container_width / 2.0, 0, GlobalData.container_depth / 2.0) 
	var distance = max(GlobalData.container_width, GlobalData.container_depth)
	camera.position = target + Vector3(distance, distance, distance) 
	camera.look_at(target, Vector3.UP) 
	camera.position.y += distance
	camera_min_height = camera.position.y
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var camera = $Camera3D

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.y = max(camera_min_height, camera.position.y - zoom_speed)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.y += zoom_speed

func add_blocks() -> void:
	for block in GlobalData.blocks:
		add_block(block)

func add_block(block : Block) -> void:
	var best_point = find_best_point_and_place_block(block)
	var t_block_x : Vector3 = Vector3(best_point.x + block.width , best_point.y , best_point.z)
	var t_block_z : Vector3 = Vector3(best_point.x , best_point.y  + block.height, best_point.z)
	var t_block_y : Vector3 = Vector3(best_point.x , best_point.y , best_point.z + block.depth)
	update_candidate_points(t_block_x, t_block_y, t_block_z)

func find_best_point_and_place_block(block) -> Vector3:
	var best_point: Vector3

	for t in GlobalData.candidate_points:
		if t.x + block.width <= GlobalData.container_width and t.z + block.depth <= GlobalData.container_depth:
			best_point = t
			break

	var mesh_instance = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(block.width, block.height, block.depth)
	mesh_instance.mesh = box

	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.8, 0.8, 0.8)
	mesh_instance.material_override = mat

	mesh_instance.position = best_point + Vector3(block.width/2, block.height/2, block.depth/2)

	blocks_node.add_child(mesh_instance)
	
	return best_point
	
func update_candidate_points(t_block_x, t_block_y, t_block_z) -> void:
	var t_best_x
	var t_best_x_max = 0
	var t_best_z
	var t_best_z_max = 0
	var t_best_y
	var t_best_y_max = -1
	
	var illegal_points : Array
	if t_block_x.x + GlobalData.min_block_width > GlobalData.container_width:
		illegal_points.append(t_block_x)
	if t_block_z.z + GlobalData.min_block_depth > GlobalData.container_depth:
		illegal_points.append(t_block_z)
		
	for t in GlobalData.candidate_points:
		if t_best_x not in illegal_points:
			if t.x <= t_block_x.x and t.z <= t_block_x.z and t.y <= t_block_x.y:
				var max = t.x * t.y
				if max > t_best_x_max:
					t_best_x_max = max
					t_best_x = t
		if t_best_z not in illegal_points:
			if t.x <= t_block_z.x and t.z <= t_block_z.z and t.y <= t_block_z.y:
				var max = t.x * t.y
				if max > t_best_z_max:
					t_best_z_max = max
					t_best_z = t
		if t.x <= t_block_y.x and t.z <= t_block_y.z and t.y <= t_block_y.y:
			var max = t.y
			if max > t_best_y_max:
				t_best_y_max = max
				t_best_y = t
		if t.x < t_block_x.x and t.x > t_block_z.x and t.z < t_block_z.z and t.z > t_block_x.z and t.y < t_block_x.y:
			illegal_points.append(t)
	
	for t in illegal_points:
		GlobalData.candidate_points.erase(t)
		
	if t_best_x != null:
		GlobalData.add_candidate_point(t_block_x.x, t_best_x.y, t_block_x.z)
	if t_best_z != null:
		GlobalData.add_candidate_point(t_block_z.x, t_best_z.y, t_block_z.z)
	GlobalData.add_candidate_point(t_best_y.x, t_block_y.y, t_best_y.z)

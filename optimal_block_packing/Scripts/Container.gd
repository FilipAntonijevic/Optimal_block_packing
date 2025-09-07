extends Node3D

@onready var blocks_node = $Container_node/Blocks
@onready var container_node = $Container_node

@export var height: float = 10000000000000000
@export var color: Color = Color(1, 1, 1)
@export var zoom_speed: float = GlobalData.max_block_height * 0.3
@export var camera_min_height: float = -10
@export var camera_max_height: float = 1000
@export var camera_autoscroll_enabled : bool = true

var camera_distance: float
var rotating := false
var last_mouse_pos: Vector2
var animation_duration = 0.4

signal highlight_this_block_in_storage

func _ready() -> void:
	draw_container()
	camera_distance = max(GlobalData.container_width, GlobalData.container_depth)
	position_camera()
	
func draw_container() -> void:
	for child in container_node.get_children():
		if child is MeshInstance3D:
			child.queue_free()
	container_node.rotation = Vector3.ZERO
	container_node.global_transform = Transform3D.IDENTITY


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
	container_node.add_child(mesh_instance)

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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				rotating = true
				last_mouse_pos = event.position
			else:
				rotating = false

	if event is InputEventMouseButton and event.pressed:
		var camera = $Camera3D
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_autoscroll_enabled = false
			camera.position.y = max(camera_min_height, camera.position.y - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.y = min(max(GlobalData.container_width ,GlobalData.container_depth) * 2 + GlobalData.get_height(), camera.position.y + zoom_speed)
			if camera.position.y >= GlobalData.get_height():
				camera_autoscroll_enabled = true
				
	if event is InputEventMouseMotion and rotating:
		var delta = event.position - last_mouse_pos
		var angle = deg_to_rad(-delta.x * 0.3)

		var pivot_local = Vector3(GlobalData.container_width/2.0, 0, GlobalData.container_depth/2.0)

		var pivot_global = container_node.to_global(pivot_local)

		var T = container_node.global_transform

		var translate_to_origin = Transform3D(Basis(), -pivot_global)
		var rotate = Transform3D(Basis(Vector3.UP, angle), Vector3.ZERO)
		var translate_back = Transform3D(Basis(), pivot_global)

		container_node.global_transform = translate_back * rotate * translate_to_origin * T

		last_mouse_pos = event.position

func add_blocks() -> void:
	position_camera()
	GlobalData.candidate_points.clear()
	GlobalData.add_candidate_point(0,0,0,0,0)

	for block in blocks_node.get_children():
		block.queue_free()

	if GlobalData.animations_bool:
		for block in GlobalData.blocks:
			await add_block(block)   
	else:
		for block in GlobalData.blocks:
			add_block(block)


func add_block(block : Block) -> void:
	var best_point: CandidatePoint = await find_best_point_and_place_block(block)
	var t_block_x: CandidatePoint = CandidatePoint.new(best_point.x + block.width, best_point.y, best_point.z, 0, 0)
	var t_block_y: CandidatePoint = CandidatePoint.new(best_point.x , best_point.y  + block.height, best_point.z, 0, 0)
	var t_block_z: CandidatePoint = CandidatePoint.new(best_point.x , best_point.y , best_point.z + block.depth, 0, 0)
	update_candidate_points(t_block_x, t_block_y, t_block_z, block)
	if camera_autoscroll_enabled:
		var new_camera_height = GlobalData.get_height() + max(GlobalData.container_depth, GlobalData.container_width)/2
		if new_camera_height > camera_min_height:
			var start_pos = $Camera3D.position
			var end_pos   = Vector3(start_pos.x, new_camera_height, start_pos.z)
			var tween := create_tween()
			tween.tween_property($Camera3D, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	emit_signal("highlight_this_block_in_storage")
			
func check_for_overlaps(i, best_point, block):
	var overlap = false
	var heighest_intersecting_block_height = best_point.y
	for j in range(i+1, GlobalData.candidate_points.size()):
		var t: CandidatePoint = GlobalData.candidate_points[j]
		if t.y > best_point.y and best_point.overlaps(t, block.width, block.depth):
			if heighest_intersecting_block_height < t.y:
				heighest_intersecting_block_height = t.y
				overlap = true

	return [overlap, heighest_intersecting_block_height]
	
func find_best_point_and_place_block(block) -> CandidatePoint:
	var best_point : CandidatePoint
	
	var ii = 0
	for i in range(GlobalData.candidate_points.size()):
		var t: CandidatePoint = GlobalData.candidate_points[i]
		if t.x + block.width <= GlobalData.container_width and t.z + block.depth <= GlobalData.container_depth:
			best_point = t
			ii = i
			break
	while(true):
		var result = check_for_overlaps(ii, best_point, block)
		var overlap = result[0]
		var max_y = result[1]
		
		if !overlap:
			break
		else:
			best_point.y = max_y

	var mesh_instance = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(block.width, block.height, block.depth)
	mesh_instance.mesh = box

	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL  
	mat.albedo_color = Color(0.5, 0.5, 0.5)  
	mat.roughness = 0.3  
	mat.metallic = 0.0  
	mesh_instance.material_override = mat


	if GlobalData.animations_bool:
		var start_pos = Vector3(best_point.x, best_point.y, best_point.z) + Vector3(block.width/2, block.height/2, block.depth/2) + Vector3(0, GlobalData.max_block_height*2, 0)
		var end_pos   = Vector3(best_point.x, best_point.y, best_point.z) + Vector3(block.width/2, block.height/2, block.depth/2)
		mesh_instance.position = start_pos
		blocks_node.add_child(mesh_instance) 
		var tween := create_tween()
		tween.tween_property(mesh_instance, "position", end_pos, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween.finished
	else:
		mesh_instance.position = Vector3(best_point.x, best_point.y, best_point.z) + Vector3(block.width/2, block.height/2, block.depth/2)
		blocks_node.add_child(mesh_instance)

	return best_point
	
func update_candidate_points(t_block_x: CandidatePoint, t_block_y: CandidatePoint, t_block_z: CandidatePoint, block) -> void:
	var t_best_x : CandidatePoint
	var t_best_x_max = -1
	var t_best_z : CandidatePoint
	var t_best_z_max = -1
	var t_best_y : CandidatePoint
	var t_best_y_max = -1
	
	var illegal_points: Array[CandidatePoint] = []

	if t_block_x.x + GlobalData.min_block_width > GlobalData.container_width:
		illegal_points.append(t_block_x)
	if t_block_z.z + GlobalData.min_block_depth > GlobalData.container_depth:
		illegal_points.append(t_block_z)

	for t in GlobalData.candidate_points:
		if t_block_x not in illegal_points:
			if t.x <= t_block_x.x and t.z <= t_block_x.z and t.y <= t_block_x.y and t.width == 0 and t.depth == 0:
				var max_val = (t.x + 1) * (t.z + 1)
				if max_val > t_best_x_max:
					t_best_x_max = max_val
					t_best_x = t
		if t_block_z not in illegal_points:
			if t.x <= t_block_z.x and t.z <= t_block_z.z and t.y <= t_block_z.y and t.width == 0 and t.depth == 0:
				var max_val = (t.x + 1) * (t.z + 1)
				if max_val > t_best_z_max:
					t_best_z_max = max_val
					t_best_z = t
		if t.x <= t_block_y.x and t.z <= t_block_y.z and t.y <= t_block_y.y:
			var max_val = t.y
			if max_val > t_best_y_max:
				t_best_y_max = max_val
				t_best_y = t
		if t.x <= t_block_x.x and t.x >= t_block_z.x and t.z <= t_block_z.z and t.z >= t_block_x.z and t.y <= t_block_x.y:
			illegal_points.append(t)

	for t in illegal_points:
		GlobalData.candidate_points.erase(t)

	if t_best_x != null:
		GlobalData.add_candidate_point(t_block_x.x, t_best_x.y, t_block_x.z, 0, 0)
	if t_best_z != null:
		GlobalData.add_candidate_point(t_block_z.x, t_best_z.y, t_block_z.z, 0, 0)
	GlobalData.add_candidate_point(t_best_y.x, t_block_y.y, t_best_y.z, 0,0)
	#we only add these points for calculating overlaping blocks, they will never be used as an actualy candidate points due to ordering of points.
	GlobalData.add_candidate_point(t_block_y.x, t_block_y.y, t_block_y.z, block.width, block.depth)
	GlobalData.add_candidate_point(t_block_y.x + block.width, t_block_y.y, t_block_y.z, -block.width, block.depth)
	GlobalData.add_candidate_point(t_block_y.x, t_block_y.y, t_block_y.z + block.depth, block.width, -block.depth)
	GlobalData.add_candidate_point(t_block_y.x + block.width, t_block_y.y, t_block_y.z + block.depth, -block.width, -block.depth)

extends Node3D

@onready var brute_force = BruteForce.new()
@onready var blocks_node = $Container_node/Blocks
@onready var container_node = $Container_node

@export var height: float = 10000000000000000
@export var color: Color = Color(1, 1, 1)
@export var zoom_speed: float = GlobalData.max_block_height * 0.3
@export var camera_min_height: float = -10
@export var camera_max_height: float = INF
@export var camera_autoscroll_enabled : bool = true

var camera_base_3d_position
var camera_base_2d_position
var rotating : bool = false
var last_mouse_pos: Vector2
var animation_duration = 0.4

signal show_blocks_in_storage()
signal highlight_this_block_in_storage()
signal add_blocks_done()

func _ready() -> void:
	add_child(brute_force)  
	draw_container()
	
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
	if GlobalData.view_2d:
		setup_2d_view()
	else:
		setup_3d_view()
		
func calculate_best_height() -> void:
	await brute_force.calculate_best_height()
	emit_signal("show_blocks_in_storage")
	add_blocks()
	
func calculate_height() -> float:
	add_blocks()
	return GlobalData.package_height

func calculate_height_async():
	add_blocks()
	return GlobalData.package_height

func add_blocks() -> void:
	GlobalData.package_height = -1
	position_camera()
	GlobalData.candidate_points.clear()
	GlobalData.overlap_control_points.clear()
	GlobalData.lowest_candidate_point_height = -1
	GlobalData.add_candidate_point(0,0,0)

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
	var t_block_x: CandidatePoint = CandidatePoint.new(best_point.x + block.width, best_point.y, best_point.z)
	var t_block_y: CandidatePoint = CandidatePoint.new(best_point.x , best_point.y  + block.height, best_point.z)
	var t_block_z: CandidatePoint = CandidatePoint.new(best_point.x , best_point.y , best_point.z + block.depth)
	update_candidate_points(t_block_x, t_block_y, t_block_z, block)
	update_overlap_control_points()
	autoscroll_camera()
	emit_signal("highlight_this_block_in_storage")
	
func autoscroll_camera() -> void:
	if camera_autoscroll_enabled:
		if GlobalData.view_2d:
			var new_camera_y = GlobalData.package_height + max(GlobalData.container_depth, GlobalData.container_width) / 2
			if new_camera_y > camera_min_height:
				var start_pos = $Camera3D.position
				var end_pos = Vector3(start_pos.x, new_camera_y, start_pos.z)
				var tween := create_tween()
				tween.tween_property($Camera3D, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			var new_camera_height = GlobalData.package_height + max(GlobalData.container_depth, GlobalData.container_width) / 2
			if new_camera_height > camera_min_height:
				var start_pos = $Camera3D.position
				var end_pos = Vector3(start_pos.x, new_camera_height, start_pos.z)
				var tween := create_tween()
				tween.tween_property($Camera3D, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func update_overlap_control_points() -> void:
	for t in GlobalData.overlap_control_points:
		if t.y < GlobalData.lowest_candidate_point_height:
			GlobalData.overlap_control_points.erase(t)
			
func check_for_overlaps(best_point, block):
	var overlap = false
	var max_y = best_point.y
	for t in GlobalData.overlap_control_points:
		if t.y > best_point.y and t.overlaps(best_point, block.width, block.depth):
			max_y = t.y
			overlap = true
			break
			
	return [overlap, max_y]
	
func find_best_point_and_place_block(block) -> CandidatePoint:
	var best_point : CandidatePoint
	
	for t in GlobalData.candidate_points:
		if t.x + block.width <= GlobalData.container_width and t.z + block.depth <= GlobalData.container_depth:
			var possible_best_point = CandidatePoint.new(t.x, t.y, t.z)
			while true:
				var result = check_for_overlaps(possible_best_point, block)
				var overlap : bool = result[0]
				var max_y : float  = result[1]
				
				if !overlap:
					if best_point == null or possible_best_point.y < best_point.y or (possible_best_point.y == best_point.y and (possible_best_point.x + 1) * (possible_best_point.z + 1) < (best_point.x + 1) * (best_point.z + 1)):
						best_point = possible_best_point
					break
				else:
					possible_best_point.y = max_y
	
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
	
	#updating lowest candidate point height
	GlobalData.lowest_candidate_point_height = INF
	for t in GlobalData.candidate_points:
		if t_block_x not in illegal_points:
			if t.x <= t_block_x.x and t.z <= t_block_x.z and t.y <= t_block_x.y:
				var max_val = (t.x + 1) * (t.z + 1)
				if max_val > t_best_x_max:
					t_best_x_max = max_val
					t_best_x = t
		if t_block_z not in illegal_points:
			if t.x <= t_block_z.x and t.z <= t_block_z.z and t.y <= t_block_z.y:
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
		else:
			if t.y < GlobalData.lowest_candidate_point_height:
				GlobalData.lowest_candidate_point_height = t.y

	for t in illegal_points:
		GlobalData.candidate_points.erase(t)

	if t_best_x != null:
		GlobalData.add_candidate_point(t_block_x.x, t_best_x.y, t_block_x.z)
	if t_best_z != null:
		GlobalData.add_candidate_point(t_block_z.x, t_best_z.y, t_block_z.z)
	
	if t_best_y != null:
		GlobalData.add_candidate_point(t_best_y.x, t_block_y.y, t_best_y.z)
	#adding overlap control points
	GlobalData.add_overlap_control_point_point(t_block_y.x, t_block_y.y, t_block_y.z, block.width, block.depth)
	if t_block_y.y > GlobalData.package_height:
		GlobalData.package_height = t_block_y.y
func setup_2d_view() -> void:
	container_node.global_transform = Transform3D.IDENTITY
	var camera = $Camera3D

	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.near = 0.1
	camera.far = 20000
	
	var target = Vector3(GlobalData.container_width / 2.0, 0, GlobalData.container_width / 2.0)
	var distance = GlobalData.container_width * 100.0
	camera.size = GlobalData.container_width * 2.0
	var base_position = Vector3(target.x, target.y, target.z + distance)
	var desired_y = 0.75 * GlobalData.container_width
	camera.position = base_position
	camera.look_at(target, Vector3.UP)
	camera.position.y = base_position.y + desired_y 

	camera_min_height += camera.position.y

func setup_3d_view() -> void:
	container_node.global_transform = Transform3D.IDENTITY

	var camera = $Camera3D 
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	var target = Vector3(GlobalData.container_width / 2.0, 0, GlobalData.container_depth / 2.0) 
	var distance = max(GlobalData.container_width, GlobalData.container_depth)
	var base_position = target + Vector3(distance, distance, distance)
	var desired_y = distance
	camera.position = base_position
	camera.look_at(target, Vector3.UP)
	camera.position.y = base_position.y + desired_y
	camera_min_height = camera.position.y
	
func _unhandled_input(event: InputEvent) -> void:
	if GlobalData.view_2d == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					rotating = true
					last_mouse_pos = event.position
				else:
					rotating = false
					
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
			
		if event is InputEventMouseButton and event.pressed:
			var camera = $Camera3D
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera_autoscroll_enabled = false
				camera.position.y = max(camera_min_height, camera.position.y - zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.position.y = min(max(GlobalData.container_width ,GlobalData.container_depth) * 2 + GlobalData.package_height, camera.position.y + zoom_speed)
				if camera.position.y >= GlobalData.package_height:
					camera_autoscroll_enabled = true
	else:
		if event is InputEventMouseButton and event.pressed:
			var camera = $Camera3D
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera_autoscroll_enabled = false
				camera.position.y = max(camera_min_height, camera.position.y - zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.position.y = min(GlobalData.package_height + 0.75 * GlobalData.container_width, camera.position.y + zoom_speed)
				if camera.position.y >= GlobalData.package_height:
					camera_autoscroll_enabled = true
